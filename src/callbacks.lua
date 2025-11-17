function G.FUNCS.TNSMI_change_pack_display(e) -- e represents the node
    TNSMI.config[e.config.ref_table[1]] = TNSMI.config[e.config.ref_table[1]] + e.config.ref_table[2]

    TNSMI.config.rows = math.max(1, math.min(4, TNSMI.config.rows))
    TNSMI.config.cols =  math.max(1, math.min(16, TNSMI.config.cols))

    SMODS.save_mod_config(TNSMI)
end

function G.FUNCS.TNSMI_change_priority(e)
    -- check if anything has been moved from expected positions and then save
    for i = #TNSMI.cardareas.priority, 1, -1 do
        if TNSMI.cardareas[i].params.soundpack ~= TNSMI.config.loaded_packs then
            TNSMI.save_soundpacks()
            break
        end
    end
end

function G.FUNCS.TNSMI_packs_button(e)
	G.SETTINGS.paused = true
    SMODS.save_mod_config(TNSMI)
    create_overlaymenu_musicpacks(1)
end

function G.FUNCS.music_packs_page(args)
    TNSMI.pages.current = args.cycle_config.current_option

    local option_cycle = G.OVERLAY_MENU:get_UIE_by_ID('tnsmi_pack_option_cycle')
    option_cycle.config.object:remove()

    local option_text = {}
    for i=1, TNSMI.pages.num do
        option_text[i] = (TNSMI.pages.current == i) and localize('k_page')..' '..tostring(TNSMI.pages.current)..'/'..tostring(TNSMI.pages.num) or ''
    end
    option_cycle.config.object = UIBox{
        definition = create_option_cycle({
            options = option_text,
            w = 4.5,
            cycle_shoulders = true,
            opt_callback = 'music_packs_page',
            focus_args = {snap_to = true, nav = 'wide'},
            current_option = TNSMI.pages.current,
            colour = G.C.RED
        }),
        config = {align = 'cm', offset = {x = 0, y = 0}, parent = option_cycle}
    }

    option_cycle.UIBox:recalculate()
end