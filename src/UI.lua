function create_soundpack_card(area, pack)
    local atlas = G.ANIMATION_ATLAS[pack.atlas] or G.ASSET_ATLAS[pack.atlas]
    local card = Card(
        area.T.x,
        area.T.y,
        G.CARD_W,
        G.CARD_H,
        nil,
        copy_table(G.P_CENTERS.j_joker),
        {tnsmi_soundpack = pack}
    )

    local layer = atlas.animated and 'animatedSprite' or 'center'
    local scale = math.max(atlas.px/71, atlas.py/95)
    if scale < 1 then scale = scale * 1.5 end
    local W = G.CARD_W*(atlas.px/71)/scale
    local H = G.CARD_H*(atlas.py/95)/scale

    if atlas.frames then
        card.T.w = W
        card.T.h = H
        card.children.animatedSprite = AnimatedSprite(card.T.x, card.T.y, card.T.w, card.T.h, atlas, atlas.pos)
        card.children.animatedSprite.T.w = W
        card.children.animatedSprite.T.h = H
        card.children.animatedSprite:set_role({major = card, role_type = 'Glued', draw_major = card})
        card.children.animatedSprite:rescale()
        card.children.animatedSprite.collide.can = false
        card.children.animatedSprite.drag.can = false
        card.children.center:remove()
        card.children.back:remove()
        card.no_shadow = true
        return card
    end

    card.children[layer]:reset()

    if atlas.px ~= 71 and atlas.py ~= 95 then
        card.T.w = W
        card.T.h = H
        card.children[layer] = Sprite(card.T.x, card.T.y, G.CARD_W, G.CARD_H, atlas, card.children.center.sprite_pos)
        card.children[layer].states.hover = card.states.hover
        card.children[layer].states.click = card.states.click
        card.children[layer].states.drag = card.states.drag
        card.children[layer].states.collide.can = false
        card.children[layer].states.drag.can = false
        card.children[layer]:set_role({major = card, role_type = 'Glued', draw_major = card})
    end

    return card
end

G.FUNCS.reload_soundpack_cards = function(current_page)
    sendDebugMessage('calling reload')
    TNSMI.pages.current = current_page or TNSMI.pages.current

    -- For already loaded packs
    local loaded_map = {}
    for _, v in ipairs(TNSMI.config.loaded_packs) do
        loaded_map[v] = true
        local pack = TNSMI.SoundPacks[v]
        local card = create_soundpack_card(TNSMI.cardareas.priority, pack)
        TNSMI.cardareas.priority:emplace(card, 'front')
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

    -- if it would result in too many pages, go to the last page
    if #soundpack_cards < start_index then
        start_index = num_per_page * (TNSMI.pages.current - 1)
    end

    TNSMI.pages.num = math.floor(#soundpack_cards/num_per_page) + 1
    TNSMI.pages.current = math.min(TNSMI.pages.current, TNSMI.pages.num)

    for i=1, num_per_page do
        local pack = TNSMI.SoundPacks[soundpack_cards[start_index + i]]
        local area_idx = math.floor(i/TNSMI.config.rows) + 1
        local card = create_soundpack_card(TNSMI.cardareas[area_idx], pack)
        TNSMI.cardareas[area_idx]:emplace(card)

        if (start_index + i) == #TNSMI.SoundPack.obj_buffer then break end
    end
end

function create_overlaymenu_soundpacks(current_page)
    TNSMI.pages.num = 1

    if TNSMI.cardareas.priority then TNSMI.cardareas.priority:remove() end
    TNSMI.cardareas.priority = CardArea(0, 0, G.CARD_W * 4, G.CARD_H * 0.75,
        {card_limit = #TNSMI.config.loaded_packs,  type = 'shop', highlight_limit = 1, thin_draw = 1, deck_height = 0.75}
    )

    -- these are likely unnecessary because area references get cleaned when UI is removed (I think)
    for i = #TNSMI.cardareas, 1, -1 do
        TNSMI.cardareas[i]:remove()
        TNSMI.cardareas[i] = nil
    end

    if #TNSMI.SoundPack.obj_buffer < 1 then return end

    local area_nodes = {}
    for i=1, TNSMI.config.rows do
        TNSMI.cardareas[i] = CardArea(0, 0, G.CARD_W * 4, G.CARD_H * 0.75,
            {card_limit = TNSMI.config.cols, highlight_limit = 1, type = 'shop', thin_draw = 1, deck_height = 0.75}
        )
        area_nodes[#area_nodes] = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.O, config = {object = TNSMI.cardareas[i]}}
        }}
    end

    local select_nodes = {n = G.UIT.C, config = {align = "cm"}, nodes = {
        {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
            {n = G.UIT.C, config = {align = "cl", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.T, config = {text = localize("tnsmi_manager_click_select"), scale = 0.45, colour = lighten(G.C.GREY,0.2), vert = true}},
            }},
        }},
        {n = G.UIT.R, config = {align = "cm"}, nodes = {
            {n = G.UIT.C, config = {align = "cm"}, nodes = area_nodes},
        }},
    }}

    G.FUNCS.reload_soundpack_cards(current_page)

    local option_text = {}
    for i=1, TNSMI.pages.num do
        option_text[i] = (TNSMI.pages.current == i) and localize('k_page')..' '..tostring(TNSMI.pages.current)..'/'..tostring(TNSMI.pages.num) or ''
    end
    local option_cycle = UIBox{
        definition = create_option_cycle({
            options = option_text,
            w = 4.5,
            cycle_shoulders = true,
            opt_callback = 'sound_packs_page',
            focus_args = {snap_to = true, nav = 'wide'},
            current_option = TNSMI.pages.current,
            colour = G.C.RED
        }),
        config = {align = 'cm', offset = {x = 0, y = 0}}
    }

    local t = {{n = G.UIT.C, config = {r = 0.1, align = "cm", padding = 0.1, colour = G.C.BLACK}, nodes = {
        --[[
        {n = G.UIT.R, config = {align = "tm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.C, config = {align = "tm", colour = G.C.CLEAR}, nodes = {
                name_node,
                desc_node
            }},
        }},
        --]]
        {n = G.UIT.R, config = {align = "cm", colour = G.C.UI.TEXT_DARK, r = 0.2, minw = 7, padding = 0.1}, nodes = {
            {n = G.UIT.T, config = {text = localize("tnsmi_manager_loaded"), scale = 0.45, colour = lighten(G.C.GREY,0.2), vert = true}},
            {n = G.UIT.O, config = {object = TNSMI.cardareas.priority}}
        }},
        {n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
            {n = G.UIT.C, config = {align = "cm", minw = 0.2}},
            {n = G.UIT.C, config = {align = "cm", colour = {G.C.L_BLACK[1], G.C.L_BLACK[2], G.C.L_BLACK[3], 0.5}, r = 0.2, padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = "SEARCH", scale = 0.3, colour = lighten(G.C.GREY,0.2), vert = true}},
                create_text_input({max_length = 12, w = 2.5, ref_table = TNSMI, ref_value = 'prompt_text_input'}),
                {n = G.UIT.C, config = {align = "cm", minw = 0.2, minh = 0.2, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLUE, shadow = true, button = "reload_soundpack_cards"}, nodes = {
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05, minw = 1.5}, nodes = {
                        {n = G.UIT.T, config = {text = localize("tnsmi_filter_label"), scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
                    }}
                }},
            }},

        }},
        select_nodes,
        {n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
            {n = G.UIT.O, config = {id = 'tnsmi_pack_option_cycle', object = option_cycle}}
        }}
    }}}

    G.FUNCS.overlay_menu({
		definition = {
            n = G.UIT.ROOT,
            config = {
                emboss = 0.05,
                minh = 6,
                r = 0.1,
                minw = 8,
                align = "tm",
                padding = 0.2,
                colour = G.C.BLACK
            },
            nodes = t
        }
	})

    local cycle_node = G.OVERLAY_MENU:get_UIE_by_ID('tnsmi_pack_option_cycle')
    cycle_node.config.object.config.parent = cycle_node
end


SMODS.current_mod.config_tab = function ()
   return { n = G.UIT.ROOT, config = {minw = 8, minh = 5, colour = G.C.CLEAR, align = "tm", padding = 0.2}, nodes = {
        {n = G.UIT.R, config = {align = "tm"}, nodes = {UIBox_button{ label = {localize("tnsmi_cfg_soundpack_manager")}, button = "TNSMI_packs_button", minw = 5}}},
        {n = G.UIT.R, config = {align = "tm"}, nodes = {create_toggle{
            label = "Display in pause menu",
            scale = 1,
            minw = 2, minh = 0.5,
            ref_table = TNSMI.mod_config,
            ref_value = "display_menu_button"
        }}},
        {n = G.UIT.R, config = {align = "tm", padding = 0.1}, nodes = {
            {n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {align = "cr", text = localize("tnsmi_cfg_rows")..": ", colour = G.C.WHITE, scale = 0.4}}}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.O, config = {align = "cr", object = DynaText{string = {{ref_table = TNSMI.mod_config, ref_value = "rows"}}, colours = {G.C.WHITE}, scale = 0.4}}}}},
            {n = G.UIT.C, config = {minw = 1}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{ label = {"-"}, button = "TNSMI_change_pack_display", minw = 0.5, minh = 0.5, ref_table = {"rows",-1}}}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{ label = {"+"}, button = "TNSMI_change_pack_display", minw = 0.5, minh = 0.5, ref_table = {"rows",1}}}},
        }},
        {n = G.UIT.R, config = {align = "tm", padding = 0.1}, nodes = {
            {n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {align = "cr", text = localize("tnsmi_cfg_cols")..": ", colour = G.C.WHITE, scale = 0.4}}}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.O, config = {align = "cr", object = DynaText{string = {{ref_table = TNSMI.mod_config, ref_value = "c_rows"}}, colours = {G.C.WHITE}, scale = 0.4}}}}},
            {n = G.UIT.C, config = {minw = 1}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{ label = {"-"}, button = "TNSMI_change_pack_display", minw = 0.5, minh = 0.5, ref_table = {"cols",-1}}}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{ label = {"+"}, button = "TNSMI_change_pack_display", minw = 0.5, minh = 0.5, ref_table = {"cols",1}}}},
        }},
   }}
end