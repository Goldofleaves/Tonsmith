local ref_card_click = Card.click
function Card:click(...)
    if self.params and self.params.tnsmi_soundpack and self.area then
        local toggle = self.area ~= TNSMI.cardareas.priority
        TNSMI.toggle_pack(self.params.tnsmi_soundpack, toggle)
    end

    return ref_card_click(self, ...)
end

local ref_card_hover = Card.hover
function Card:hover()
    if not self.params and not self.params.tnsmi_soundpack then
        return ref_card_hover(self)
    end

    self:juice_up(0.05, 0.03)
    play_sound('paper1', math.random()*0.2 + 0.9, 0.35)

    --if this is the focused card
    if self.states.focus.is and not self.children.focused_ui then
        self.children.focused_ui = G.UIDEF.card_focus_ui(self)
    end

    if self.facing == 'front' and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui then
        sendDebugMessage('getting ui for key: '..self.params.tnsmi_soundpack)
        self.ability_UIBox_table = generate_card_ui(
        {set = 'SoundPack', key = self.params.tnsmi_soundpack, generate_ui = SMODS.Center.generate_ui},
        nil, nil, 'SoundPack', {card_type = 'SoundPack'}, nil, nil, nil, self)
        self.config.h_popup = G.UIDEF.card_h_popup(self)
        self.config.h_popup_config = self:align_h_popup()

        Node.hover(self)
    end
end

function Card:generate_UIBox_ability_table(vars_only)
    local card_type, hide_desc = self.ability.set or "None", nil
    local loc_vars = nil
    local main_start, main_end = nil,nil
    local no_badge = nil

    if vars_only then return loc_vars, main_start, main_end end
    local badges = {}

    return generate_card_ui(self.config.center, nil, loc_vars, card_type, badges, hide_desc, main_start, main_end, self)
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