local ref = CardArea.can_highlight

function CardArea:can_highlight(card)
    if self.config.type == "bsfx_list" then return true end
    ref(self,card)
end

local ref = CardArea.update

function CardArea:update(dt)
    if self.config.type == "bsfx_list" then self.config.card_limit = #BSFX["packs"] end
    ref(self,dt)
end