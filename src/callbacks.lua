function G.FUNCS.BSFX_reload_lists()
    print("Reload lists")
    for i=1, #BSFX.CARDAREAS.available.cards do
        BSFX.CARDAREAS.available.cards[i]:start_dissolve(nil,true,0)
    end

    for k,v in pairs(BSFX.packs) do
        local card = Card(BSFX.CARDAREAS.available.T.x+(BSFX.CARDAREAS.available.T.w/2),BSFX.CARDAREAS.available.T.y,G.CARD_W,G.CARD_H, G.P_CENTERS.j_joker,G.P_CENTERS.c_base)
        BSFX.CARDAREAS.available:emplace(card)
    end
end
