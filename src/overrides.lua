local ref_card_click = Card.click
function Card:click(...)
    if self.params and self.params.soundpack then
        local toggle = self.area ~= TNSMI.TNSMI.cardareas.priority
        TNSMI.toggle_pack(self.params.soundpack, toggle)
    end

    return ref_card_click(self, ...)
end


--[[--- come back to this
local ref = SMODS.create_mod_badges
function SMODS.create_mod_badges(obj, badges)
    if obj then
        if obj.config then
            if type(obj.config.extra) ~= "table" then
                ref(obj, badges)
            elseif not obj.config.extra.TNSMI then
                ref(obj, badges)
            end
        else
            ref(obj,badges)
        end
    else
        ref(obj, badges)
    end
end
--]]