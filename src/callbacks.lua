function G.FUNCS.TNSMI_reload_lists()
    print("Reload lists")
    for i=1, #TNSMI.CARDAREAS.available.cards do
        TNSMI.CARDAREAS.available.cards[i]:start_dissolve(nil,true,0)
    end

    for k,v in pairs(TNSMI.packs) do
        local card = Card(TNSMI.CARDAREAS.available.T.x+(TNSMI.CARDAREAS.available.T.w/2),TNSMI.CARDAREAS.available.T.y,G.CARD_W,G.CARD_H, G.P_CENTERS.j_joker,G.P_CENTERS.c_base)
        TNSMI.CARDAREAS.available:emplace(card)
    end
end

function G.FUNCS.TNSMI_main_tab () return TNSMI.main_tab() end

function G.FUNCS.TNSMI_change_pack_display(e) -- e represents the node
    TNSMI.mod_config[e.config.ref_table[1]] = TNSMI.mod_config[e.config.ref_table[1]] + e.config.ref_table[2]

    if TNSMI.mod_config.rows < 1 then TNSMI.mod_config.rows = 1 end
    if TNSMI.mod_config.rows > 4 then TNSMI.mod_config.rows = 4 end
    
    if TNSMI.mod_config.c_rows < 1 then TNSMI.mod_config.c_rows = 1 end
    if TNSMI.mod_config.c_rows > 16 then TNSMI.mod_config.c_rows = 16 end
    
end

function G.FUNCS.TNSMI_open_mod_options ()
    G.SETTINGS.paused = true
    _, G.ACTIVE_MOD_UI = next(SMODS.find_mod("tonsmith"))
    SMODS.LAST_SELECTED_MOD_TAB = "config"
    G.FUNCS.overlay_menu({
        definition = create_UIBox_mods()
    })
end