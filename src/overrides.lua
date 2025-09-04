local hookTo = CardArea.align_cards
function CardArea:align_cards(...)
    if self.config and self.config.horizontal_align then
        for k, card in ipairs(self.cards) do
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
                card.T.y = self.T.y + self.T.h/2 - card.T.h/2 - highlight_height+ (G.SETTINGS.reduced_motion and 0 or 1)*0.03*math.sin(0.666*G.TIMERS.REAL+card.T.x)
                card.T.x = card.T.x + card.shadow_parrallax.x/30
            end
        end
        table.sort(self.cards, function (a, b) return a.T.x + a.T.w/2 - 100*((a.pinned and not a.ignore_pinned) and a.sort_id or 0) < b.T.x + b.T.w/2 - 100*((b.pinned and not b.ignore_pinned) and b.sort_id or 0) end)
    else
        local ret = hookTo(self,...)
        return ret
    end
end

local hookTo = CardArea.can_highlight
function CardArea:can_highlight(...)
    if self.config and self.config.no_highlight then
        return false
    else
        return hookTo(self,...)
    end
end

local hookTo = Card.click
function Card:click(...)
    local ret = hookTo(self,...)
    if self.ability and self.ability.tnsmi_card then
        TNSMI.toggle_pack(self.config.center.original_key)
        G.E_MANAGER:add_event(Event{
            func = function ()
                TNSMI.load_soundpack_order()
                return true
            end
        })
    end
    return ret
end


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

local ref = Game.update
function Game:update(dt)
    TNSMI.load_soundpack_order()

    for i,v in ipairs(TNSMI.mod_config.soundpack_priority) do
        local exists = false
        for ii,vv in ipairs(TNSMI.packs) do
            if v == vv.mod_prefix.."_"..vv.name then exists = true end
        end
        if not exists then
            table.remove(TNSMI.mod_config.soundpack_priority,i)
        end
    end
    
    TNSMI.loaded_packs = {}
    TNSMI.unloaded_packs = {}
    if TNSMI.page > TNSMI.max_pages then TNSMI.page = TNSMI.page - 1; TNSMI.load_cards() end
    if TNSMI.page <= 0 and TNSMI.max_pages > 0 then
        TNSMI.page = 1
    end
    for i,v in ipairs(TNSMI.packs) do if v.selected then table.insert(TNSMI.loaded_packs,v) else table.insert(TNSMI.unloaded_packs,v) end end


    TNSMI.n_loaded_packs = #TNSMI.loaded_packs
    TNSMI.max_pages = math.ceil(#TNSMI.unloaded_packs/(TNSMI.mod_config.rows*TNSMI.mod_config.c_rows))
    ref(self,dt)
end

local ref = create_UIBox_options

function create_UIBox_options(args)  
    local tbl = ref()
    local tnmsi_button = UIBox_button{ label = {localize("tnsmi_manager_pause")}, button = "TNSMI_main_tab", minw = 3.4, colour = G.C.PALE_GREEN}
    if TNSMI.mod_config.display_menu_button then
        local t = create_UIBox_generic_options({ contents = {
            tnmsi_button,
        }})

        local t_node = tbl.nodes[1].nodes[1].nodes[1].nodes

        for k,v in pairs(t_node) do
            if v.nodes[1].nodes[1].config then
                if v.nodes[1].nodes[1].config.minw == 5 then
                    v.nodes[1].nodes[1].config.minw = 7
                elseif v.nodes[1].nodes[1].config.minw == 2.4 then
                    v.nodes[1].nodes[1].config.minw = 3.4
                end
            end
        end

        local exists = false
        for k,v in pairs(t_node) do
            if v.nodes[1].config.button == "your_collection" then
                v.nodes[1].nodes[1].config.minw = 3.4
                local btn = v
                t_node[k] = {n = G.UIT.R, nodes = {{n = G.UIT.C, nodes = {
                    {n = G.UIT.C, nodes = {btn}},
                    {n = G.UIT.C, config = {minw = 0.2}},
                    {n = G.UIT.C, nodes = {tnmsi_button}},
                }}}}
                exists = true
            end
        end
        if not exists then 
            tnmsi_button = UIBox_button{ label = {localize("tnsmi_manager_pause")}, button = "TNSMI_main_tab", minw = 7, colour = G.C.PALE_GREEN}
            table.insert(t_node,7,tnmsi_button) 
        end
    end
    return tbl
end