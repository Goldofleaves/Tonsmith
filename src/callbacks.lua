function G.FUNCS.BSFX_reload_lists()
    print("Reload lists")
    selected_area = G.OVERLAY_MENU:get_UIE_by_ID("selected")
    available_area = G.OVERLAY_MENU:get_UIE_by_ID("available")
    if selected_area then print("Selected") end
    if available_area then print("available") end

    for k,v in pairs(BSFX.packs) do
        local card = Card(0,0,1,1, G.P_CENTERS.j_joker,G.P_CENTERS.c_base)
        --available_area:emplace(card)
    end
end