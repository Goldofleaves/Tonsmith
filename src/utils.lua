SMODS.Atlas({key = 'default_soundpack', path = 'default_soundpack.png', px = 71, py = 71, prefix_config = false})
SMODS.Atlas({key = 'sp_balatro', path = 'sp_balatro.png', px = 71, py = 75, prefix_config = false})
SMODS.Atlas({key = 'thumb' , path = 'thumb.png', px = 71, py = 71, prefix_config = false})

---Defines and creates a vanilla soundpack for tonsmith to load.<br>
---[<u>View documentation<u>](https://github.com/Goldofleaves/tonsmith/wiki#tnsmipack_vanilla)
---@param args {name:string,mods:string[],description:{},authors:string[],sound_table:table[],thumbnail:string,extension?:".ogg"|string}
TNSMI.SoundPacks = {}
TNSMI.SoundPack = SMODS.GameObject:extend ({
    obj_buffer = {},
    set = 'SoundPack',
    obj_table = TNSMI.SoundPacks,
    class_prefix = "sp",
    prefix_config = {
        atlas = false
    },
    atlas = 'default_soundpack',
    required_params = {
        'key',
        'sound_table'
    },
    process_loc_text = function(self) -- LOC_TXT structure = name = string, text = table of strings
        SMODS.process_loc_text(G.localization.descriptions.SoundPacks, self.key, self.loc_txt)
    end,
    register = function(self)
        if self.registered then
            sendWarnMessage(('Detected duplicate register call on object %s'):format(self.key), self.set)
            return
        end

        if (sound.req_mod and next(SMODS.find_mod(sound.req_mod))) or not sound.req_mod then
            ret.sounds[i] = {SMODS.Sound {
                key = sound.key,
                path = sound.file.."."..sound.extension,
                pitch = sound.pitch,
                volume = sound.volume,
                sync = sound.sync,
                select_music_track = sound.music_track
            },
            sound.prefix..sound.key }
        end
    end

    local loc_txt = {}
    local reference = G.localization.descriptions.Other
    init_localization()
    local jank = false
    local threshold = 5
    local tooltip_table = {}
    tooltip_table[1] = "This sound pack"
    tooltip_table[2] = "replaces the"
    tooltip_table[3] = "following sounds:"
    tooltip_table[4] = "{} {}"
    local amount = #sound_table
    local remainder = 0
    if amount > threshold then remainder = amount - threshold amount = threshold jank = true end
    for i = 1, amount do
        table.insert(tooltip_table, sound_table[i].key..((i == amount and not jank) and "." or ","))
    end
    if jank then
        table.insert(tooltip_table, "...")
        table.insert(tooltip_table, "{} {}")
        table.insert(tooltip_table, "...And "..remainder.." more.")
    end

    reference["tnsmi_"..string.lower(name).."_desc"] = {
        name = "Soundpack Info",
        text = tooltip_table
    }
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
    end,
})

function TNSMI.save_soundpacks()
    -- resets all existing replace sounds
    local replace_map = TNSMI.config.loaded_packs.replace_map or {}
    for k, v in pairs (replace_map) do
        if type(v) == 'table' then
            SMODS.Sounds[v.key].replace = nil
            SMODS.Sound.replace_sounds[k] = nil
        end
    end

    if thumb then SMODS.Atlas { key = thumb , path = thumb..".png", px = 71, py = 95} end
    
    ret.joker = SMODS.Joker {
        no_collection = true,
        unlocked = true,
        discovered = true,
        loc_vars = function (self, info_queue, card)
            info_queue[#info_queue + 1] = { set = "Other", key = "tnsmi_"..string.lower(name).."_desc" } 
        end,
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

                if sound.replace_key and not replace_map[sound.replace_key] then
                    replace_map[sound.replace_key] = { key = sound.key }
                    local obj = SMODS.Sounds[sound.key]
                    obj:create_replace_sound(sound.replace_key)
                end
            end
        end
    end
    TNSMI.config.loaded_packs.replace_map = replace_map

    SMODS.save_mod_config(TNSMI)
end

function TNSMI.get_size_mod()
    return (1 - (TNSMI.config.rows - 1) * 0.2)
end

TNSMI.SoundPacks['sp_balatro'] = {
    key = 'sp_balatro',
    atlas = 'sp_balatro',
    sound_table = {
        { key = "ambientFire1" },
        { key = "ambientFire2"  },
        { key = "ambientFire3"  },
        { key = "ambientOrgan1"  },
        { key = "button"  },
        { key = "cancel"  },
        { key = "card1"  },
        { key = "card3"  },
        { key = "cardFan2"  },
        { key = "cardSlide1"  },
        { key = "cardSlide2"  },
        { key = "chips1"  },
        { key = "chips2"  },
        { key = "coin1"  },
        { key = "coin2"  },
        { key = "coin3"  },
        { key = "coin4"  },
        { key = "coin5"  },
        { key = "coin6"  },
        { key = "coin7"  },
        { key = "crumple1"  },
        { key = "crumple2"  },
        { key = "crumple3"  },
        { key = "crumple4"  },
        { key = "crumple5"  },
        { key = "crumpleLong1"  },
        { key = "crumpleLong2"  },
        { key = "explosion_buildup1"  },
        { key = "explosion_release1"  },
        { key = "explosion1"  },
        { key = "foil1"  },
        { key = "foil2"  },
        { key = "generic1"  },
        { key = "glass1"  },
        { key = "glass2"  },
        { key = "glass3"  },
        { key = "glass4"  },
        { key = "glass5"  },
        { key = "glass6"  },
        { key = "gold_seal"  },
        { key = "gong"  },
        { key = "highlight1"  },
        { key = "highlight2"  },
        { key = "holo1"  },
        { key = "introPad1"  },
        { key = "magic_crumple"  },
        { key = "magic_crumple2"  },
        { key = "magic_crumple3"  },
        { key = "multhit1"  },
        { key = "multhit2"  },
        { key = "negative"  },
        { key = "other1"  },
        { key = "paper1"  },
        { key = "polychrome1"  },
        { key = "slice1"  },
        { key = "splash_buildup"  },
        { key = "tarot1"  },
        { key = "tarot2"  },
        { key = "timpani"  },
        { key = "voice1"  },
        { key = "voice2"  },
        { key = "voice3"  },
        { key = "voice4"  },
        { key = "voice5"  },
        { key = "voice6"  },
        { key = "voice7" },
        { key = "voice8" },
        { key = "voice9" },
        { key = "voice10" },
        { key = "voice11" },
        { key = "whoosh_long" },
        { key = "whoosh" },
        { key = "whoosh1" },
        { key = "whoosh2" },
        { key = "win" },
        { key = "music1" },
        { key = "music2" },
        { key = "music3" },
        { key = "music4" },
        { key = "music5" }
    },
}