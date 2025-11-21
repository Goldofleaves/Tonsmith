-- Creates a fake soundpack card partially based on the approach Malverk takes
function create_soundpack_card(area, pack, pos)
    local atlas = G.ANIMATION_ATLAS[pack.atlas] or G.ASSET_ATLAS[pack.atlas]
    local size_mod = TNSMI.get_size_mod()

    -- this card is provided a "fake" SoundPack center
    -- rather than registering an unused item, it fills in the
    -- fields SMODS.GameObject normally needs to display
    -- and localize UI for centers
    local card = Card(
        area.T.x,
        area.T.y,
        G.CARD_W * size_mod,
        G.CARD_W * size_mod,
        nil,
        {key = pack.key, name = "Sound Pack", atlas = pack.atlas, pos={x=0,y=0}, set = "SoundPack", label = 'Sound Pack', config = {}, generate_ui = SMODS.Center.generate_ui},
        {tnsmi_soundpack = pack.key}
    )

    card.states.drag.can = area == TNSMI.cardareas.priority
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
        area:emplace(card, pos)
        return card
    end

    area:emplace(card, pos)

    -- This delay is set in G.FUNCS.toggle_soundpack for juice
    -- when TNSMI.dissolve_flag is set, the next pack created of that key
    -- will materialize rather than instantly appearing
    -- so it appears to pop out of one cardarea and pop into the next
    if TNSMI.dissolve_flag == pack.key then
        card.states.visible = false
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.15,
            blocking = false,
            blockable = false,
            func = (function()
                card:start_materialize(nil, nil, 0.25)
                return true
            end)
        }))

        TNSMI.dissolve_flag = nil
    end
end

--- Definition for the Soundpack Overlay Menu
function create_UIBox_soundpacks()

    -- creates cardareas only once upon menu load to prevent any unnecessary calc
    -- updates occur within the existing cardareas
    local size_mod = TNSMI.get_size_mod()
    if TNSMI.cardareas.priority then TNSMI.cardareas.priority:remove() end
    TNSMI.cardareas.priority = CardArea(0, 0, G.CARD_W * TNSMI.config.cols * size_mod * 1.1, G.CARD_H * size_mod,
        {card_limit = TNSMI.config.cols, type = 'soundpack', highlight_limit = 99}
    )

    for _, v in ipairs(TNSMI.config.loaded_packs) do
        create_soundpack_card(TNSMI.cardareas.priority, TNSMI.SoundPacks[v], 'front')
    end

    -- these are likely unnecessary because area references get cleaned when UI is removed (I think)
    for i = #TNSMI.cardareas, 1, -1 do
        TNSMI.cardareas[i]:remove()
        TNSMI.cardareas[i] = nil
    end

    if #TNSMI.SoundPack.obj_buffer < 1 then return end

    local area_nodes = {}
    for i=1, TNSMI.config.rows do
        TNSMI.cardareas[i] = CardArea(0, 0, G.CARD_W * TNSMI.config.cols * size_mod * 1.1, G.CARD_H * size_mod,
            {card_limit = TNSMI.config.cols, highlight_limit = 99, type = 'soundpack'}
        )

        area_nodes[#area_nodes+1] = {n = G.UIT.R, config = {align = "cl", colour = G.C.CLEAR}, nodes = {
            {n = G.UIT.O, config = {id = 'tnsmi_area_'..i, object = TNSMI.cardareas[i]}}
        }}
    end

    -- Cycle config is stored in this global variable in order to change the state of the
    -- option cycle on the fly when filtering search results. Vanilla balatro expects
    -- they're only changed upon complete menu reload
    TNSMI.cycle_config = {
        options = {},
        w = 4.5,
        cycle_shoulders = true,
        opt_callback = 'soundpacks_page',
        focus_args = {snap_to = true, nav = 'wide'},
        current_option = 1,
        colour = G.C.RED,
        no_pips = true,
    }

    G.FUNCS.reload_soundpack_cards()

    local opt_cycle = create_option_cycle(TNSMI.cycle_config)
    opt_cycle.nodes[2].nodes[1].nodes[1].config.func = 'tnsmi_shoulder_buttons'
    opt_cycle.nodes[2].nodes[1].nodes[3].config.func = 'tnsmi_shoulder_buttons'


    local t = {
        {n = G.UIT.R, config = {align = "cm", colour = G.C.BLACK, r = 0.2, minh = 0.8, padding = 0.1}, nodes = {
            {n = G.UIT.C, config = {align = "cl"}, nodes = {
                {n = G.UIT.T, config = {align = 'cl', text = localize("tnsmi_manager_loaded"), padding = 0.1, scale = 0.25, colour = lighten(G.C.GREY,0.2), vert = true}},
            }},
            {n = G.UIT.C, config = {align = "cr", func = 'TNSMI_change_priority'}, nodes = {
                {n = G.UIT.O, config = {align = 'cr', minw = 6, object = TNSMI.cardareas.priority}}
            }},
        }},
        {n = G.UIT.R, config = {align = "cr", padding = 0}, nodes = {
            {n = G.UIT.C, config = {align = "cr", padding = 0.1}, nodes = {
                 {n = G.UIT.T, config = {ref_table = TNSMI, ref_value = 'search_text', scale = 0.25, colour = lighten(G.C.GREY, 0.2)}},
            }},
            {n = G.UIT.C, config = {align = "cr", colour = {G.C.L_BLACK[1], G.C.L_BLACK[2], G.C.L_BLACK[3], 0.5}, r = 0.2, padding = 0.1, minw = 3.5}, nodes = {
                create_text_input({max_length = 12, w = 3.5, ref_table = TNSMI, ref_value = 'prompt_text_input'}),
                {n = G.UIT.C, config = {align = "cm", minw = 0.2, minh = 0.2, padding = 0.1, r = 0.1, hover = true, colour = G.C.BLUE, shadow = true, button = "reload_soundpack_cards"}, nodes = {
                    {n = G.UIT.R, config = {align = "cm", padding = 0.05, minw = 1.5}, nodes = {
                        {n = G.UIT.T, config = {text = localize("tnsmi_filter_label"), scale = 0.4, colour = G.C.UI.TEXT_LIGHT}}
                    }}
                }},
            }},

        }},
        {n = G.UIT.R, config = {align = "cm", colour = G.C.BLACK, r = 0.2, minh = 4, padding = 0.1}, nodes = {
            {n = G.UIT.C, config = {align = "cm", colour = G.C.CLEAR}, nodes = area_nodes}
        }},
        opt_cycle
    }

    -- uses the same function as most Overlay Menu calls
    return create_UIBox_generic_options({ contents = t, back_func = 'settings', snap_back = nil })
end

--- Definition for the soundpack button that appears in the Options > Audio menu
function G.UIDEF.soundpack_button(card)
    local priority = card.area and card.area == TNSMI.cardareas.priority
    local text = priority and 'b_remove' or 'b_select'
    local color = priority and  G.C.RED or G.C.GREEN
    return {
        n=G.UIT.ROOT, config = {padding = 0, colour = G.C.CLEAR}, nodes={
            {n=G.UIT.R, config={ref_table = card, r = 0.08, padding = 0.1, align = "bm", minw = 0.5*card.T.w - 0.15, maxw = 0.9*card.T.w - 0.15, minh = 0.5*card.T.h, hover = true, shadow = true, colour = color, one_press = true, button = 'toggle_soundpack'}, nodes={
                {n=G.UIT.T, config={text = localize(text), colour = G.C.UI.TEXT_LIGHT, scale = 0.45, shadow = true}}
            }},
        }
    }
end

-- This function is weird as hell
-- there's no easy way to set a tab other than in the tab definition function
-- So this kinda fudges it to set the audio tab as chosen if tabs are being created from the soundpack menu (I.E. back to the settings menu)
local ref_create_tabs = create_tabs
function create_tabs(args)
    if args.tabs then
        local reset_chosen = false
        for i = #args.tabs, 1, -1 do
            if reset_chosen then
                args.tabs[i].chosen = nil
            elseif args.tabs[i].tab_definition_function_args == 'Audio' and G.OVERLAY_MENU.config.id == 'tnsmi_soundpack_menu' then
                args.tabs[i].chosen = true
                reset_chosen = false
            end
        end
    end

    return ref_create_tabs(args)
end