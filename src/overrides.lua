--[[
local ref_card_hover = Card.hover
function Card:hover()
    if not self.params or not self.params.tnsmi_soundpack then
        return ref_card_hover(self)
    end

    self:juice_up(0.05, 0.03)
    play_sound('paper1', math.random()*0.2 + 0.9, 0.35)

    --if this is the focused card
    if self.states.focus.is and not self.children.focused_ui then
        self.children.focused_ui = G.UIDEF.card_focus_ui(self)
    end

    if self.facing == 'front' and (not self.states.drag.is or G.CONTROLLER.HID.touch) and not self.no_ui then
        self.ability_UIBox_table = generate_card_ui(
        {set = 'SoundPack', key = self.params.tnsmi_soundpack, generate_ui = SMODS.Center.generate_ui},
        nil, nil, 'SoundPack', {card_type = 'SoundPack'}, nil, nil, nil, self)
        self.config.h_popup = G.UIDEF.card_h_popup(self)
        self.config.h_popup_config = self:align_h_popup()

        Node.hover(self)
    end
end
--]]

local ref_ability = Card.set_ability
function Card:set_ability(center, initial, delay_sprites)
    sendDebugMessage(tostring(inspect(center)))
    return ref_ability(self, center, initial, delay_sprites)
end

local ref_type_colour = get_type_colour
function get_type_colour(_c, card)
    sendDebugMessage("set: "..tostring(_c and _c.set))
    return ref_type_colour(_c, card)
end

local ref_card_highlight = Card.highlight
function Card:highlight(is_higlighted)
    if not self.params or not self.params.tnsmi_soundpack then
        return ref_card_highlight(self, is_higlighted)
    end

    self.highlighted = is_higlighted
    if self.highlighted and self.area then
        -- unhighlight all other cards even in different cardareas
        for _, pack_area in ipairs(TNSMI.cardareas) do
            for _, v in ipairs(pack_area.highlighted) do
                if v ~= self then
                    pack_area:remove_from_highlighted(v)
                end
            end
        end

        self.children.use_button = UIBox{
            definition = G.UIDEF.soundpack_button(self),
            config = {align = "bmi", offset = {x=0,y=0.5}, parent = self}
        }
    elseif self.children.use_button then
        self.children.use_button:remove()
        self.children.use_button = nil
    end
end

local ref_cardarea_canhighlight = CardArea.can_highlight
function CardArea:can_highlight(card)
    return self.config.type == 'soundpack' or ref_cardarea_canhighlight(self, card)
end

local ref_cardarea_align = CardArea.align_cards
function CardArea:align_cards()
    if self.config.type ~= 'soundpack' then
        return ref_cardarea_align(self)
    end

    local smooth_align = false
    for k, card in ipairs(self.cards) do
        if G.CONTROLLER.dragging.target == card then
            smooth_align = true
        end

        if not card.states.drag.is then
            card.T.r = 0.1*(-#self.cards/2 - 0.5 + k)/(#self.cards)+ (G.SETTINGS.reduced_motion and 0 or 1)*0.02*math.sin(2*G.TIMERS.REAL+card.T.x)
            local max_cards = math.max(#self.cards, self.config.temp_limit)
            card.T.x = self.T.x + (self.T.w-self.card_w)*((k-1)/math.max(max_cards-1, 1) - 0.5*(#self.cards-max_cards)/math.max(max_cards-1, 1)) + 0.5*(self.card_w - card.T.w)

            if #self.cards > 2 or (#self.cards > 1 and self == G.consumeables) or (#self.cards > 1 and self.config.spread) then
                card.T.x = self.T.x + (self.T.w-self.card_w)*((k-1)/(#self.cards-1)) + 0.5*(self.card_w - card.T.w)
            elseif #self.cards > 1 and self ~= G.consumeables then
                card.T.x = self.T.x + (self.T.w-self.card_w)*((k - 0.5)/(#self.cards)) + 0.5*(self.card_w - card.T.w)
            else
                card.T.x = self.T.x + self.T.w/2 - self.card_w/2 + 0.5*(self.card_w - card.T.w)
            end

            local highlight_height = G.HIGHLIGHT_H/2
            if not card.highlighted then highlight_height = 0 end
            card.T.y = self.T.y + self.T.h/2 - card.T.h/2 - highlight_height + (G.SETTINGS.reduced_motion and 0 or 1)*0.03*math.sin(0.666*G.TIMERS.REAL+card.T.x)
            card.T.x = card.T.x + card.shadow_parrallax.x/30
        end
    end

    if not smooth_align then
        for k, card in ipairs(self.cards) do
            if not card.states.drag.is then
                card.VT.x = card.T.x
            end
        end
    end

    table.sort(self.cards, function (a, b) return a.T.x + a.T.w/2 < b.T.x + b.T.w/2 end)
end

local ref_cardarea_draw = CardArea.draw
function CardArea:draw()
    if self.config.type ~= 'soundpack' then
        return ref_cardarea_draw(self)
    end

    self:draw_boundingrect()
    add_to_drawhash(self)

    for k, v in ipairs({'shadow', 'card'}) do
        local defer = {}
        for i = 1, #self.cards do
            if self.cards[i] ~= G.CONTROLLER.focused.target and self.cards[i] ~= G.CONTROLLER.dragging.target then
                if self.cards[i].highlighted then
                    defer[#defer+1] = i
                else
                    self.cards[i]:draw(v)
                end
            end
        end

        for i = 1, #defer do
            self.cards[defer[i]]:draw(v)
        end
    end
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