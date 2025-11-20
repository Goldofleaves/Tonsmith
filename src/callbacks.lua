function G.FUNCS.TNSMI_change_pack_display(e) -- e represents the node
    TNSMI.config[e.config.ref_table[1]] = TNSMI.config[e.config.ref_table[1]] + e.config.ref_table[2]

    TNSMI.config.rows = math.max(1, math.min(4, TNSMI.config.rows))
    TNSMI.config.cols =  math.max(1, math.min(16, TNSMI.config.cols))

    SMODS.save_mod_config(TNSMI)
end

function G.FUNCS.TNSMI_change_priority(e)
    -- check if anything has been moved from expected positions and then save
    if TNSMI.dissolve_flag then return end

    local priority_changed = false
    for i, v in ipairs(TNSMI.cardareas.priority.cards) do
        local priority = #TNSMI.cardareas.priority.cards - i + 1
        if v.params.tnsmi_soundpack ~= TNSMI.config.loaded_packs[priority] then
            priority_changed = true
            break
        end
    end

    if not priority_changed then return end

    TNSMI.config.loaded_packs = {}
    for i, v in ipairs(TNSMI.cardareas.priority.cards) do
        local priority = #TNSMI.cardareas.priority.cards - i + 1
        TNSMI.config.loaded_packs[priority] = v.params.tnsmi_soundpack
    end


    TNSMI.save_soundpacks()
end

function G.FUNCS.TNSMI_packs_button(e)
	G.SETTINGS.paused = true
    SMODS.save_mod_config(TNSMI)
    G.FUNCS.overlay_menu({
		definition = create_UIBox_soundpacks()
	})
    G.OVERLAY_MENU:recalculate()
end

function G.FUNCS.soundpacks_page(args)
    G.FUNCS.reload_soundpack_cards()
end

function G.FUNCS.tnsmi_shoulder_buttons(e)
    if #TNSMI.cycle_config.options > 1 then
        e.config.colour = G.C.RED
        e.config.hover = true
        e.config.shadow = true
        e.config.button = 'option_cycle'
        e.children[1].config.colour = G.C.UI.TEXT_LIGHT
    else
        e.config.colour = G.C.BLACK
        e.config.hover = nil
        e.config.shadow = nil
        e.config.button = nil
        e.children[1].config.colour = G.C.UI.TEXT_INACTIVE
    end
end


G.FUNCS.reload_soundpack_cards = function()
    for i = #TNSMI.cardareas, 1, -1 do
        if #TNSMI.cardareas[i].cards > 0 then
            remove_all(TNSMI.cardareas[i].cards)
        end
        TNSMI.cardareas[i].highlighted = {}
    end

    -- For already loaded packs
    local loaded_map = {}
    for _, v in ipairs(TNSMI.config.loaded_packs) do
        loaded_map[v] = true
    end

    local num_per_page = TNSMI.config.cols * TNSMI.config.rows
    local start_index = num_per_page * (TNSMI.cycle_config.current_option - 1)

    -- filtering for the current text input and selected packs
    local soundpack_cards = {}
    for i, v in ipairs(TNSMI.SoundPack.obj_buffer) do
        if not loaded_map[v] and (TNSMI.prompt_text_input == ''
        or string.find(string.lower(localize{type = 'name_text', key = v, set = 'SoundPack'}), string.lower(TNSMI.prompt_text_input))) then
            soundpack_cards[#soundpack_cards+1] = v
        end
    end

    -- if it would result in too many pages, go to the last page
    if #soundpack_cards < start_index then
        start_index = num_per_page * (TNSMI.cycle_config.current_option - 1)
    end

    TNSMI.search_text = localize{type = 'variable', key = 'tnsmi_search_text', vars = {
        start_index + 1,
        math.min((start_index + num_per_page), #soundpack_cards),
        #soundpack_cards
    }}

    if #soundpack_cards < 1 then return end

    local num_options = math.ceil(#soundpack_cards/num_per_page)
    local options = {}
    for i=1, num_options do
        options[i] = localize('k_page')..' '..tostring(i)..'/'..tostring(num_options)
    end

    TNSMI.cycle_config.options = options
    TNSMI.cycle_config.current_option = math.min(TNSMI.cycle_config.current_option, num_options)
    TNSMI.cycle_config.current_option_val = TNSMI.cycle_config.options[TNSMI.cycle_config.current_option]

    for i=1, num_per_page do
        local pack = TNSMI.SoundPacks[soundpack_cards[start_index + i]]
        local area_idx = math.floor((i - 1)/TNSMI.config.cols) + 1
        create_soundpack_card(TNSMI.cardareas[area_idx], pack)

        if (start_index + i) >= #soundpack_cards then break end
    end
end

G.FUNCS.toggle_soundpack = function(e)
    local card = e.config.ref_table
    local key = card.params.tnsmi_soundpack
    local is_priority = card.area and card.area == TNSMI.cardareas.priority

    if is_priority then -- Disable pack
        for i = #TNSMI.config.loaded_packs, 1, -1 do
            if TNSMI.config.loaded_packs[i] == key then
                card:start_dissolve(nil, nil, 0.25)
                table.remove(TNSMI.config.loaded_packs, i)
                break
            end
        end
        TNSMI.dissolve_flag = key
    else
        for _, pack_area in ipairs(TNSMI.cardareas) do
            for _, pack_card in ipairs(pack_area.cards) do
                if pack_card.params.tnsmi_soundpack == key then
                    pack_card:start_dissolve(nil, nil, 0.25)
                    break
                end
            end
        end

        TNSMI.dissolve_flag = key
        create_soundpack_card(TNSMI.cardareas.priority, TNSMI.SoundPacks[key])
        table.insert(TNSMI.config.loaded_packs, key)
    end

    G.E_MANAGER:add_event(Event({
        trigger = 'after',
        delay = 0.25,
        blocking = false,
        blockable = false,
        func = (function()
            G.FUNCS.reload_soundpack_cards()
            TNSMI.save_soundpacks()
            return true
        end)
    }))
end