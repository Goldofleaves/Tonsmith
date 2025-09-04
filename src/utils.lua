TNSMI.packs = {}
TNSMI.reference = {}

---Defines and creates a vanilla soundpack for tonsmith to load.<br>
---[<u>View documentation<u>](https://github.com/Goldofleaves/tonsmith/wiki#tnsmipack_vanilla)
---@param args {name:string,mods:string[],description:{},authors:string[],sound_table:table[],thumbnail:string,extension?:".ogg"|string}
TNSMI.Pack = function(args)
    local name = args.name or ""
    local desc = args.description or {{lan = 'en-us', text = {}}}
    local authors = args.authors or {}
    local sound_table = args.sound_table or {}
    local mods = args.mods or {"Vanilla"}
    local thumb = args.thumbnail
    local ret = {}
    ret.sounds = {}
    ret.mod_prefix = SMODS.current_mod.prefix
    for i,sound in ipairs(sound_table) do
        sound.key = sound.key or ""
        sound.extention = sound.extention or "ogg"
        sound.prefix = sound.prefix or ""
        if sound.prefix ~= "" then sound.prefix = sound.prefix.."_" end
        sound.file = sound.file or sound.key
        sound.music_track = sound.select_music_track or nil
        if string.find(sound.key,"music") then 
            local ref = sound.music_track or true
            sound.music_track = function ()
                if not ref then return end -- Evaluate if the sound should play
                for i,v in ipairs(TNSMI.mod_config.soundpack_priority) do
                    if v == ret.mod_prefix.."_"..name then return 9e300+i end
                end
            end
        end
        if (sound.req_mod and next(SMODS.find_mod(sound.req_mod))) or not sound.req_mod then
            ret.sounds[i] = {SMODS.Sound {
                key = sound.key,
                path = sound.file.."."..sound.extention,
                pitch = sound.pitch,
                volume = sound.volume,
                sync = sound.sync,
                select_music_track = sound.music_track
            },
            sound.prefix..sound.key }
        end
    end

    local loc_txt = {}

    for i,v in ipairs(desc) do

        loc_txt[v.lan] = {
            name = name,
            text = {
                {"{X:green,C:white}"..(G.localization.misc.dictionary.k_tnsmi_descriptions or "Descriptions")},
                {"{X:chips,C:white}"..(G.localization.misc.dictionary.k_tnsmi_authors or "Authors")},
                {"{X:legendary,C:white}"..(G.localization.misc.dictionary.k_tnsmi_mods or "Mods")}
            }
        }

        for _,vv in ipairs(v.text) do
            table.insert(loc_txt[v.lan].text[1],vv)
        end
    end
    for _,v in pairs(loc_txt) do
        for _,vv in ipairs(authors) do
            table.insert(v.text[2],vv)
        end
        for _,vv in ipairs(mods) do
            table.insert(v.text[3],vv)
        end
    end

    if thumb then SMODS.Atlas { key = thumb , path = thumb..".png", px = 71, py = 95} end
    
    ret.joker = SMODS.Joker {
        no_collection = true,
        unlocked = true,
        discovered = true,
        key = name,
        set_card_type_badge = function (self, card, badges)badges[1] = nil end,
        in_pool = function(self, args) return false end,
        atlas = thumb or nil,
        pos = { x = 0, y = 0 },
        config = {extra = {TNSMI = true}},
        loc_txt = loc_txt
    }



    ret.name = name
    ret.selected = false
    ret.priority = 0

    for i,v in ipairs(TNSMI.mod_config.soundpack_priority) do
        if v == ret.mod_prefix.."_"..ret.name then ret.priority = i end
    end
    table.insert(TNSMI.packs,ret)
    table.insert(TNSMI.reference,ret)
end


---@param name string The sound pack to load.
TNSMI.toggle_pack = function(name)
    for _, pack in ipairs(TNSMI.packs) do
        if pack.name == name then
            if pack.selected then -- Disable pack
                pack.selected = false
                for _, sound in ipairs(pack.sounds) do
                    sound[1].replace = nil
                    SMODS.Sound.replace_sounds[sound[2]] = nil
                end

                for i,v in ipairs(TNSMI.mod_config.soundpack_priority) do
                    if v == pack.mod_prefix.."_"..pack.name then
                        table.remove(TNSMI.mod_config.soundpack_priority,i)
                    end
                end
                -- Reset pack priority
                pack.priority = 0
            else -- Enable pack
                pack.selected = true
                -- return "i did it"
            end
                if next(TNSMI.CARDAREAS) then
                TNSMI.load_cards()
            end
        end
    end
end

function TNSMI.save_soundpack_order ()
    for i,v in ipairs(TNSMI.CARDAREAS.selected.cards) do
        -- Save the priority to the config file.
        TNSMI.mod_config.soundpack_priority[i] = v.config.center.mod.prefix.."_"..v.config.center.original_key
        for ii, vv in ipairs(TNSMI.packs) do
            -- Compares the card key and the pack key.
            if v.config.center.mod.prefix.."_"..v.config.center.original_key == vv.mod_prefix.."_"..vv.name then
                -- Set the pack priority.
                vv.priority = i
                vv.selected = true
            end
        end
    end
end

function G.FUNCS.TNSMI_save_soundpack ()
    TNSMI.save_soundpack_order()
    TNSMI.load_soundpack_order()
end

function TNSMI.load_soundpack_order ()
    -- Load modded sounds, in order of priority
    for i,v in ipairs(TNSMI.mod_config.soundpack_priority) do
        for ii, vv in ipairs(TNSMI.packs) do
            -- Compares the card key and the pack key.
            if v == vv.mod_prefix.."_"..vv.name then
                vv.selected = true
                vv.priority = i
                for _, sound in ipairs(vv.sounds) do
                    sound[1].replace = sound[2]
                    SMODS.Sound.replace_sounds[sound[2]] = {times = -1, key = sound[1].key}
                end
            end
        end
    end
end
