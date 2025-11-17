function G.FUNCS.TNSMI_change_pack_display(e) -- e represents the node
    TNSMI.config[e.config.ref_table[1]] = TNSMI.config[e.config.ref_table[1]] + e.config.ref_table[2]

    TNSMI.config.rows = math.max(1, math.min(4, TNSMI.config.rows))
    TNSMI.config.cols =  math.max(1, math.min(16, TNSMI.config.cols))

    SMODS.save_mod_config(TNSMI)
end

function G.FUNCS.TNSMI_change_priority(e)
    -- check if anything has been moved from expected positions and then save
    local priority_changed = false
    for i = #TNSMI.cardareas.priority.cards, 1, -1 do
        local priority = i - #TNSMI.cardareas.priority.cards + 1
        if TNSMI.cardareas.priority.cards[i].params.tnsmi_soundpack ~= TNSMI.config.loaded_packs[priority] then
            priority_changed = true
            break
        end
    end

    if not priority_changed then return end

    for i, v in ipairs(TNSMI.cardareas.priority.cards) do
        local priority = i + #TNSMI.cardareas.priority.cards - 1
        TNSMI.config.loaded_packs[priority] = v.params.tnsmi_soundpack
    end

    TNSMI.save_soundpacks()
end

function G.FUNCS.TNSMI_packs_button(e)
	G.SETTINGS.paused = true
    SMODS.save_mod_config(TNSMI)
    create_overlaymenu_soundpacks()
end

function G.FUNCS.soundpacks_page(args)
    TNSMI.pages.current = args.cycle_config.current_option
    sendDebugMessage('current page: '..tostring(args.cycle_config.current_option))

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
            opt_callback = 'soundpacks_page',
            focus_args = {snap_to = true, nav = 'wide'},
            current_option = TNSMI.pages.current,
            colour = G.C.RED
        }),
        config = {align = 'cm', offset = {x = 0, y = 0}, parent = option_cycle}
    }

    option_cycle.UIBox:recalculate()
end


G.FUNCS.reload_soundpack_cards = function()
    for i = #TNSMI.cardareas, 1, -1 do
        if #TNSMI.cardareas[i].cards > 0 then
            remove_all(TNSMI.cardareas[i].cards)
        end
    end

    -- For already loaded packs
    local loaded_map = {}
    for _, v in ipairs(TNSMI.config.loaded_packs) do
        sendDebugMessage('loaded packs: '..v)
        loaded_map[v] = true
    end

    local num_per_page = TNSMI.config.cols * TNSMI.config.rows
    local start_index = num_per_page * (TNSMI.pages.current - 1)

    -- filtering for the current text input and selected packs
    local soundpack_cards = {}
    for i, v in ipairs(TNSMI.SoundPack.obj_buffer) do
        if (TNSMI.prompt_text_input == '' or string.find(localize{type = 'name_text', key = v, set = 'SoundPack'}, TNSMI.prompt_text_input))
        and not loaded_map[v] then
            soundpack_cards[#soundpack_cards+1] = v
        end
    end

    if #soundpack_cards < 1 then return end

    -- if it would result in too many pages, go to the last page
    if #soundpack_cards < start_index then
        start_index = num_per_page * (TNSMI.pages.current - 1)
    end

    TNSMI.pages.num = math.floor(#soundpack_cards/num_per_page) + 1
    TNSMI.pages.current = math.min(TNSMI.pages.current, TNSMI.pages.num)

    for i=1, num_per_page do
        local pack = TNSMI.SoundPacks[soundpack_cards[start_index + i]]
        local area_idx = math.floor(i/TNSMI.config.cols) + 1
        local card = create_soundpack_card(TNSMI.cardareas[area_idx], pack)

        TNSMI.cardareas[area_idx]:emplace(card)

        if (start_index + i) == #soundpack_cards then break end
    end
end