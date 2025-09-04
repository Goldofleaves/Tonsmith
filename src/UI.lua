local function tnsmi_desc_from_rows(desc_nodes, empty, align, maxw) 
    local t = {}
    for k, v in ipairs(desc_nodes) do
        t[#t+1] = {n=G.UIT.R, config={align = align or "cl", maxw = maxw}, nodes=v}
    end
    return {n=G.UIT.R, config={align = "cm", colour = empty and G.C.CLEAR or G.C.UI.BACKGROUND_WHITE, r = 0.1, padding = 0.04, minw = 2, minh = 0.25, emboss = not empty and 0.05 or nil, filler = true}, nodes={
        {n=G.UIT.R, config={align = align or "cl", padding = 0.03}, nodes=t}
    }}
end

function Card:resize(mod)
    self:hard_set_T(self.T.x, self.T.y, self.T.w * mod, self.T.h * mod)
    remove_all(self.children)
    self.children = {}
    self.children.shadow = Moveable(0, 0, 0, 0)
    self:set_sprites(self.config.center, self.base.id and self.config.card)
end

function TNSMI.create_fake_card(c_key, area) --Taken from Balatro Star Rail :3
    local card = Card(area.T.x + area.T.w / 2, area.T.y,
    G.CARD_W, G.CARD_H, G.P_CARDS.empty,
    G.P_CENTERS[c_key])
    card.children.back = Sprite(card.T.x, card.T.y, card.T.w, card.T.h, G.ASSET_ATLAS[(G.P_CENTERS[c_key] and G.P_CENTERS[c_key].atlas) or "Joker"], (G.P_CENTERS[c_key] and G.P_CENTERS[c_key].pos) or {x = 0, y = 0})
    card.children.back.states.hover = card.states.hover
    card.children.back.states.click = card.states.click
    card.children.back.states.drag = card.states.drag
    card.children.back.states.collide.can = false
    card.children.back:set_role({major = card, role_type = 'Glued', draw_major = card})

    area:emplace(card)

    return card
end

G.FUNCS.tnsmi_load_text_input = function(e)
    if not e.config or not e.config.auto_selected then
        if not e.config then e.config = {} end
        e.config.auto_selected = true

        G.E_MANAGER:add_event(Event({
            blockable = false,
            func = function() 
                e.UIBox:recalculate(true) 
                return true 
            end
        }))
    end
end

function tnsmi_create_text_input(args)
    args = args or {}
    args.colour = copy_table(args.colour) or copy_table(G.C.BLUE)
    args.hooked_colour = copy_table(args.hooked_colour) or darken(copy_table(G.C.BLUE), 0.3)
    args.w = args.w or 2.5
    args.h = args.h or 0.7
    args.text_scale = args.text_scale or 0.4
    args.max_length = args.max_length or 100
    args.all_caps = args.all_caps or false
    args.prompt_text = args.prompt_text or localize('k_enter_text')
    args.current_prompt_text = ''
    args.id = args.id or "text_input"

    local text = {ref_table = args.ref_table, ref_value = args.ref_value, letters = {}, current_position = string.len(args.ref_table[args.ref_value])}
    local ui_letters = {}
    for i = 1, args.max_length do
        text.letters[i] = (args.ref_table[args.ref_value] and (string.sub(args.ref_table[args.ref_value], i, i) or '')) or ''
        ui_letters[i] = {n=G.UIT.T, config={ref_table = text.letters, ref_value = i, scale = args.text_scale, colour = G.C.UI.TEXT_LIGHT, id = args.id..'_letter_'..i}}
    end
    args.text = text

    local position_text_colour = lighten(copy_table(G.C.BLUE), 0.4)

    ui_letters[#ui_letters+1] = {n=G.UIT.T, config={ref_table = args, ref_value = 'current_prompt_text', scale = args.text_scale, colour = lighten(copy_table(args.colour), 0.4), id = args.id..'_prompt'}}
    ui_letters[#ui_letters+1] = {n=G.UIT.B, config={r = 0.03,w=0.1, h=0.4, colour = position_text_colour, id = args.id..'_position', func = 'flash'}}

    local t = 
        {n=G.UIT.C, config={align = "cm", colour = G.C.CLEAR}, nodes = {
            {n=G.UIT.C, config={id = args.id, align = "cm", padding = 0.05, r = 0.1, hover = true, colour = args.colour,minw = args.w, min_h = args.h, func = "tnsmi_load_text_input", button = 'select_text_input', shadow = true}, nodes={
                {n=G.UIT.R, config={ref_table = args, padding = 0.05, align = "cm", r = 0.1, colour = G.C.CLEAR}, nodes={
                {n=G.UIT.R, config={ref_table = args, align = "cm", r = 0.1, colour = G.C.CLEAR, func = 'text_input', tnsmi_input = true}, nodes=
                    ui_letters
                }
                }}
            }}
            }}
    return t
end
function TNSMI.refresh_cardareas()
    for i,v in pairs(TNSMI.CARDAREAS) do
        v:remove()
        TNSMI.CARDAREAS[i] = nil
    end
end

function TNSMI.load_cards()
    
    for _,v in pairs(TNSMI.CARDAREAS) do
        if v.cards then
            for _,vv in ipairs(v.cards) do
                vv:start_dissolve(nil,true,0)
            end
            v.cards = {}
        end
    end
    if not TNSMI.CARDAREAS.selected or not TNSMI.CARDAREAS.selected.cards then return end
    local n_packs = 0
    for _,_ in pairs(TNSMI.packs) do n_packs = n_packs + 1 end
    if n_packs < 1 then return end
    
    for i,v in ipairs(TNSMI.CARDAREAS.selected.cards) do
        v:start_dissolve(nil,true,0)
    end

    -- For already existing packs
    for i,v in ipairs(TNSMI.mod_config.soundpack_priority) do
        local exists = false
        for ii,vv in ipairs(TNSMI.packs) do
            if v == vv.mod_prefix.."_"..vv.name then exists = true end
        end
        if exists then
            local card = TNSMI.create_fake_card("j_"..v,TNSMI.CARDAREAS.selected)
            card.ability.tnsmi_card = true
            card:resize(0.7)
        else
            table.remove(TNSMI.mod_config.soundpack_priority,i)
        end
    end

    -- For newly added packs
    for i,v in ipairs(TNSMI.packs) do
        if v.priority == 0 and v.selected then
            local card = TNSMI.create_fake_card("j_"..v.mod_prefix.."_"..v.name,TNSMI.CARDAREAS.selected)
            card.ability.tnsmi_card = true
            card:resize(0.7)
        end
    end
    
    TNSMI.load_soundpack_order()

    local temp_fill = {}

    for i,v in ipairs(TNSMI.packs) do
        if v and not v.selected then
            table.insert(temp_fill,v)
        end
    end

    for i=1, (TNSMI.mod_config.rows*TNSMI.mod_config.c_rows*(TNSMI.page-1)) do table.remove(temp_fill,1) end

    local row = 1
    for i,v in ipairs(temp_fill) do
        if row > TNSMI.mod_config.rows then break end
        local card = TNSMI.create_fake_card("j_"..v.mod_prefix.."_"..v.name, TNSMI.CARDAREAS["available"..row])
        card.ability.tnsmi_card = true
        card:resize(0.7)
        if #TNSMI.CARDAREAS["available"..row].cards >= TNSMI.mod_config.c_rows then row = row + 1 end
    end
end

function G.FUNCS.tnsmi_search()
    TNSMI.packs = SMODS.shallow_copy(TNSMI.reference)
    local fuckyou = TNSMI.prompt_text or ""
    local function j () 
        for k, v in ipairs(TNSMI.packs) do
            if type(string.find(v.name, fuckyou)) == "nil" then
                table.remove(TNSMI.packs, k)
                j()
            end
        end
    end
    j()
    TNSMI.load_cards()
end

function G.FUNCS.tnsmi_next_page(e)
    if TNSMI.max_pages > 0 then
    TNSMI.page = TNSMI.page + 1
    TNSMI.page = ((TNSMI.page - 1) % math.ceil(#TNSMI.packs / (TNSMI.mod_config.rows * TNSMI.mod_config.c_rows))) + 1
    end
    TNSMI.load_cards()
end

function G.FUNCS.tnsmi_prev_page(e)
    if TNSMI.max_pages > 0 then
    TNSMI.page = TNSMI.page - 1
    if TNSMI.page < 1 then
        TNSMI.page = math.ceil(#TNSMI.packs / (TNSMI.mod_config.rows * TNSMI.mod_config.c_rows)) - TNSMI.page
    end
    end
    TNSMI.load_cards()
end

function TNSMI.main_tab ()
    TNSMI.CARDAREAS.selected = CardArea(
        G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
        G.CARD_W * 4,
        G.CARD_H / 1.5,
        {card_limit = #TNSMI.packs or 0, type = 'joker', hide_card_count = true, no_highlight = true}
    )

    local name_node = {}
    localize {type = 'descriptions', key = "tnsmi_config_tab_name", set = 'dictionary', nodes = name_node, scale = 2, text_colour = G.C.WHITE, shadow = true} 
    name_node = tnsmi_desc_from_rows(name_node,true,"cm") --Reorganizes the text in the node properly (?).
    name_node.config.align = "cm"

    local desc_node = {}
    localize {type = 'descriptions', key = "tnsmi_config_tab_desc", set = 'dictionary', nodes = desc_node, scale = 1, text_colour = G.C.WHITE} 
    desc_node = tnsmi_desc_from_rows(desc_node,true,"cm")
    desc_node.config.align = "cm"

    local select_nodes = {
        {n = G.UIT.C, config = {align = "cm"}, nodes = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.1}, nodes = {
                {n = G.UIT.C, config = {align = "cl", colour = G.C.CLEAR}, nodes = {
                    {n = G.UIT.T, config = {text = localize("tnsmi_manager_click_select"), scale = 0.45, colour = lighten(G.C.GREY,0.2), vert = true}},
                }},
                {n = G.UIT.C, config = {align = "cm", colour = adjust_alpha(G.C.BLACK, 0.5), r = 0.2}, nodes = {
                }},
            }},
            {n = G.UIT.R, config = {align = "cm"}, nodes = {
                {n = G.UIT.C, config = {align = "cm"}, nodes = {
                }}, 
            }},
        }},
    }

    for i = 1, TNSMI.mod_config.rows do
        TNSMI.CARDAREAS["available"..i] = CardArea(
            G.ROOM.T.x + 0.2 * G.ROOM.T.w / 2, G.ROOM.T.h,
            G.CARD_W * 4,
            G.CARD_H / 1.5,
            {card_limit = 5, type = 'shop', hide_card_count = true, horizontal_align = true, no_highlight = true}
        )
        select_nodes[1].nodes[1].nodes[2].nodes[#select_nodes[1].nodes[1].nodes[2].nodes+1] = {n = G.UIT.R, config = {align = "cm", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.O, config = {object = TNSMI.CARDAREAS["available"..i]}}
        }}
    end

    local page_cycle = {
        {n = G.UIT.C, config = {align = "cm", minw = 0.5, minh = 0.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLACK, shadow = true, button = "tnsmi_prev_page"}, nodes = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                {n = G.UIT.T, config = {text = "<", scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
            }}
        }},
        {n = G.UIT.C, config = {align = "cm", minw = 2.5, minh = 0.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLACK, shadow = true}, nodes = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                {n = G.UIT.O, config = {object = DynaText{string = {localize("k_page").." "}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.4}}},
                {n = G.UIT.O, config = {object = DynaText{string = {{ref_table = TNSMI, ref_value = "page"}}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.4}}},
                {n = G.UIT.O, config = {object = DynaText{string = {"/"}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.4}}},
                {n = G.UIT.O, config = {object = DynaText{string = {{ref_table = TNSMI, ref_value = "max_pages"}}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.4}}},
                
            }}
        }},
        {n = G.UIT.C, config = {align = "cm", minw = 0.5, minh = 0.5, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLACK, shadow = true, button = "tnsmi_next_page"}, nodes = {
            {n = G.UIT.R, config = {align = "cm", padding = 0.05}, nodes = {
                {n = G.UIT.T, config = {text = ">", scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
            }}
        }},
    }

    local footer = {
        {n = G.UIT.R, config = {align = "cm", padding = 0.02, hover = true, shadow = true}, nodes = {
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{label = {localize("tnsmi_close")}, minw = 2, minh = 0.65, colour = G.C.ORANGE}}},
            {n = G.UIT.C, config = {align = "cm", minw = 0.2}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{label = {localize("tnsmi_options")}, minw = 2, minh = 0.65, colour = G.C.GREEN, button = "TNSMI_open_mod_options"}}},
            {n = G.UIT.C, config = {align = "cm", minw = 0.2}},
            {n = G.UIT.C, config = {align = "cr", minw = 2}, nodes = {
                {n = G.UIT.R, config = {align = "cr"}, nodes = {
                    {n = G.UIT.O, config = {object = DynaText{string = {localize("tnsmi_manager_active")..": "}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.25}}},
                    {n = G.UIT.O, config = {object = DynaText{string = {{ref_table = TNSMI, ref_value = "n_loaded_packs"}}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.25}}}
                }},
                {n = G.UIT.R, config = {align = "cr"}, nodes = {
                    {n = G.UIT.O, config = {object = DynaText{string = {localize("tnsmi_manager_installed")..": "}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.25}}},
                    {n = G.UIT.O, config = {object = DynaText{string = {tostring(#TNSMI.packs)}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.25}}}
                }},
            }},
            {n = G.UIT.C, config = {align = "cm", minw = 0.2}},
            {n = G.UIT.C, config = {align = "cr", minw = 0}, nodes = {
                {n = G.UIT.R, config = {align = "cr"}, nodes = {
                    {n = G.UIT.O, config = {object = DynaText{string = {localize("tnsmi_version_label")..": "}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.35}}},
                    {n = G.UIT.O, config = {object = DynaText{string = {tostring(SMODS.find_mod("tonsmith")[1].version)}, colours = {G.C.UI.TEXT_LIGHT}, scale = 0.35}}}
                }},
            }},

        }}
    }

    TNSMI.load_cards()

    local UI = {n = G.UIT.ROOT, config = {r = 0.1, minw = 5, align = "cm", padding = 0, colour = G.C.L_BLACK, outline = 1.5, outline_colour = G.C.UI.OUTLINE_LIGHT}, nodes = { 
        {n = G.UIT.C, config = {r = 0.1, align = "cm", padding = 0.1, colour = G.C.BLACK}, nodes = {
            {n = G.UIT.R, config = {align = "tm", colour = G.C.CLEAR}, nodes = {
                {n = G.UIT.C, config = {align = "tm", colour = G.C.CLEAR}, nodes = {
                    name_node,
                    desc_node
                }},
            }},
            {n = G.UIT.R, config = {align = "cm", colour = {G.C.L_BLACK[1], G.C.L_BLACK[2], G.C.L_BLACK[3], 0.5}, r = 0.2, padding = 0.1}, nodes = {
                {n = G.UIT.T, config = {text = localize("tnsmi_manager_selected"), scale = 0.45, colour = lighten(G.C.GREY,0.2), vert = true}},
                {n = G.UIT.O, config = {object = TNSMI.CARDAREAS.selected, func = "TNSMI_save_soundpack"}}
            }},
            {n = G.UIT.R, config = {align = "cm", padding = 0}, nodes = {
                {n = G.UIT.C, config = {align = "cm", minw = 0.2, padding = 0}, nodes = page_cycle},
                {n = G.UIT.C, config = {align = "cm", minw = 0.2}},
                {n = G.UIT.C, config = {align = "cm", colour = {G.C.L_BLACK[1], G.C.L_BLACK[2], G.C.L_BLACK[3], 0.5}, r = 0.2, padding = 0.1}, nodes = {
                    {n = G.UIT.T, config = {text = "SEARCH", scale = 0.3, colour = lighten(G.C.GREY,0.2), vert = true}},
                    tnsmi_create_text_input({max_length = 12, w = 2.5, prompt_text = TNSMI.prompt_text or "", id = "tnsmi_search", extended_corpus = true, ref_table = TNSMI, ref_value = 'prompt_text_input',
                        callback = function()
                            TNSMI.prompt_text = TNSMI.prompt_text_input
                        end
                    }),
                    {n = G.UIT.C, config = {align = "cm", minw = 0.2, minh = 0.2, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLUE, shadow = true, button = "tnsmi_search"}, nodes = {
                        {n = G.UIT.R, config = {align = "cm", padding = 0.05, minw = 1.5}, nodes = {
                            {n = G.UIT.T, config = {text = localize("tnsmi_filter_label"), scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
                        }}
                    }},
                }},
            }},
            {n = G.UIT.R, config = {align = "cm", colour = {G.C.L_BLACK[1], G.C.L_BLACK[2], G.C.L_BLACK[3], 0.5}, r = 0.2}, nodes = select_nodes},
            {n = G.UIT.R, config = {align = "cm", colour = {G.C.L_BLACK[1], G.C.L_BLACK[2], G.C.L_BLACK[3], 0.5}, r = 0.2}, nodes = footer}
        }},
    }}

    if G.OVERLAY_MENU then G.OVERLAY_MENU:remove() end
    G.OVERLAY_MENU = UIBox{
        definition = UI,
        config = {
            align = "cm",
            offset = {x=0,y=0},
            major = G.ROOM_ATTACH,
            bond = 'Weak',
            no_esc = false
        },
    }
end


SMODS.current_mod.config_tab = function ()
   return { n = G.UIT.ROOT, config = {minw = 8, minh = 5, colour = G.C.CLEAR, align = "tm", padding = 0.2}, nodes = {
        {n = G.UIT.R, config = {align = "tm"}, nodes = {UIBox_button{ label = {localize("tnsmi_cfg_soundpack_manager")}, button = "TNSMI_main_tab", minw = 5}}},
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
            {n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.T, config = {align = "cr", text = localize("tnsmi_cfg_c_rows")..": ", colour = G.C.WHITE, scale = 0.4}}}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {{n = G.UIT.O, config = {align = "cr", object = DynaText{string = {{ref_table = TNSMI.mod_config, ref_value = "c_rows"}}, colours = {G.C.WHITE}, scale = 0.4}}}}},
            {n = G.UIT.C, config = {minw = 1}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{ label = {"-"}, button = "TNSMI_change_pack_display", minw = 0.5, minh = 0.5, ref_table = {"c_rows",-1}}}},
            {n = G.UIT.C, config = {align = "cm"}, nodes = {UIBox_button{ label = {"+"}, button = "TNSMI_change_pack_display", minw = 0.5, minh = 0.5, ref_table = {"c_rows",1}}}},
        }},
   }}
end