function create_soundpack_card(area, pack)
    sendDebugMessage('searching for atlas: '..pack.atlas)
    local atlas = G.ANIMATION_ATLAS[pack.atlas] or G.ASSET_ATLAS[pack.atlas]
    local card = Card(
        area.T.x,
        area.T.y,
        G.CARD_W * 0.75,
        G.CARD_H * 0.75,
        nil,
        copy_table(G.P_CENTERS.j_joker),
        {tnsmi_soundpack = pack.key}
    )

    --[[
    local scale = math.max(atlas.px/71, atlas.py/95)
    if scale < 1 then scale = scale * 1.5 end
    local W = G.CARD_W*(atlas.px/71)/scale
    local H = G.CARD_H*(atlas.py/95)/scale
    --]]

    if atlas.frames then
        --card.T.w = W
        --card.T.h = H
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

    --card.T.w = W
    --card.T.h = H
    card.children.front = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, atlas, {x = 0, y = 0})
    card.children.front.states.hover = card.states.hover
    card.children.front.states.click = card.states.click
    card.children.front.states.drag = card.states.drag
    card.children.front.states.collide.can = false
    card.children.front:set_role({major = card, role_type = 'Glued', draw_major = card})

    local atlas_copy =  {}
    for k, v in pairs(card.children.front.atlas) do
        atlas_copy[k] = v
    end
    card.children.front.atlas = atlas_copy
    card.children.front.atlas.name = pack.atlas
    card.children.front:reset()

    return card
end

function create_overlaymenu_soundpacks()
    TNSMI.pages.num = 1

    if TNSMI.cardareas.priority then TNSMI.cardareas.priority:remove() end
    TNSMI.cardareas.priority = CardArea(0, 0, 9, G.CARD_H * 0.75,
        {card_limit = #TNSMI.config.loaded_packs,  type = 'shop', thin_draw = true, highlight_limit = 0, deck_height = 0.75}
    )

    for _, v in ipairs(TNSMI.config.loaded_packs) do
        local pack = TNSMI.SoundPacks[v]
        local card = create_soundpack_card(TNSMI.cardareas.priority, pack)
        TNSMI.cardareas.priority:emplace(card, 'front')
    end

    -- these are likely unnecessary because area references get cleaned when UI is removed (I think)
    for i = #TNSMI.cardareas, 1, -1 do
        TNSMI.cardareas[i]:remove()
        TNSMI.cardareas[i] = nil
    end

    if #TNSMI.SoundPack.obj_buffer < 1 then return end

    local area_nodes = {}
    for i=1, TNSMI.config.rows do
        TNSMI.cardareas[i] = CardArea(0, 0, 9, G.CARD_H * 0.75,
            {card_limit = TNSMI.config.cols, highlight_limit = 0, thin_draw = true, type = 'shop', deck_height = 0.75}
        )
        area_nodes[#area_nodes+1] = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.O, config = {id = 'tnsmi_area_'..i, object = TNSMI.cardareas[i]}}
        }}
    end

    TNSMI.pages.current = 1
    G.FUNCS.reload_soundpack_cards()

    local option_text = {}
    for i=1, TNSMI.pages.num do
        option_text[i] = localize('k_page')..' 1/'..tostring(TNSMI.pages.num)
    end
    local option_cycle = UIBox{
        definition = create_option_cycle({
            options = option_text,
            w = 4.5,
            cycle_shoulders = true,
            opt_callback = 'soundpacks_page',
            focus_args = {snap_to = true, nav = 'wide'},
            current_option = 1,
            colour = G.C.RED
        }),
        config = {align = 'cm', offset = {x = 0, y = 0}}
    }

    local t = {
        --[[
        {n = G.UIT.R, config = {align = "tm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.C, config = {align = "tm", colour = G.C.CLEAR}, nodes = {
                name_node,
                desc_node
            }},
        }},
        --]]
        {n = G.UIT.R, config = {align = "cl", colour = G.C.UI.TEXT_DARK, r = 0.2, minw = 10, minh = 0.9, padding = 0.1}, nodes = {
            {n = G.UIT.T, config = {align = 'cl', text = localize("tnsmi_manager_loaded"), scale = 0.45, colour = lighten(G.C.GREY,0.2), vert = true}},
            {n = G.UIT.O, config = {align = 'cl', minw = 6, object = TNSMI.cardareas.priority}}
        }},
        {n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
            {n = G.UIT.C, config = {align = "cm", minw = 3.5}},
            {n = G.UIT.C, config = {align = "cm", colour = {G.C.L_BLACK[1], G.C.L_BLACK[2], G.C.L_BLACK[3], 0.5}, r = 0.2, padding = 0.1, minw = 3.5}, nodes = {
                {n = G.UIT.T, config = {text = "SEARCH", scale = 0.3, colour = lighten(G.C.GREY,0.2), vert = true}},
                create_text_input({max_length = 12, w = 2.5, ref_table = TNSMI, ref_value = 'prompt_text_input'}),
                {n = G.UIT.C, config = {align = "cm", minw = 0.2, minh = 0.2, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLUE, shadow = true, button = "reload_soundpack_cards"}, nodes = {
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05, minw = 1.5}, nodes = {
                        {n = G.UIT.T, config = {text = localize("tnsmi_filter_label"), scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
                    }}
                }},
            }},

        }},
        {n = G.UIT.R, config = {align = "cm", colour = G.C.UI.TEXT_DARK, r = 0.2, minw = 10, minh = 4.5, padding = 0.1}, nodes = {
            {n = G.UIT.C, config = {align = "cm", colour = G.C.CLEAR}, nodes = area_nodes}
        }},
        {n = G.UIT.R, config = {align = "cm", padding = 0, minw = 5, minh = 1}, nodes = {
            {n = G.UIT.O, config = {id = 'tnsmi_pack_option_cycle', object = option_cycle}}
        }}
    }

    G.FUNCS.overlay_menu({
		definition = {
            n = G.UIT.ROOT,
            config = {
                emboss = 0.05,
                r = 0.1,
                align = "tm",
                padding = 0.2,
                colour = G.C.BLACK
            },
            nodes = t
        }
	})

    local cycle_node = G.OVERLAY_MENU:get_UIE_by_ID('tnsmi_pack_option_cycle')
    cycle_node.config.object.config.parent = cycle_node
    cycle_node.UIBox:recalculate()
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