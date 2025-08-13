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
