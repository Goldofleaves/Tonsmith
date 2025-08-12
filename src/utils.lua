BSFX.packs = {}

---Defines and creates a vanilla soundpack for BetterSFX to load.<br>
---@param args {name:string,mods:string[],description:string[],authors:string[],sound_table:table[],thumbnail:string,extension?:".ogg"|string}
---`name` - The Name of the sound pack.<br>
---`description` - The Description of the sound pack.<br>
---`authors` - The authors of the soundpack.<br>
---`thumbnail` - string The thumbnail of the sound pack (Excluding the png suffix).<br>
---`sound_table` - The table of sounds to load, excluding the file extension.<br>
---`extension` - The file extention.<br>
BSFX.Pack = function(args)
    local name = args.name or ""
    local desc = args.description or {}
    local authors = args.authors or {}
    local sound_table = args.sound_table or {}
    local mods = args.mods or {"Vanilla"}
    local thumb = args.thumbnail
    local returntable = {}
    returntable.sounds = {}
    for i,sound in ipairs(sound_table) do
        sound.name = sound.name or ""
        sound.extention = sound.extention or ".ogg"
        sound.prefix = sound.prefix or ""
        returntable.sounds[i] = {SMODS.Sound {
            key = sound.name,
            path = sound.name..sound.extention },
            sound.prefix..sound.name }
    end
    local loc_desc = desc
    table.insert(loc_desc, 1, "{X:green,C:white}Description:")
    local authors_desc = {"{X:chips,C:white}Authors:"}
    for k, v in ipairs(authors) do
        if authors[k + 1]then
            authors_desc[k + 1] = "{C:attention}"..authors[k].."{},"
        else
            authors_desc[k + 1] = "{C:attention}"..authors[k]
        end
    end
    local mods_desc = {"{X:legendary,C:white}Mods:"}
    for k, v in ipairs(mods) do
        if mods[k + 1]then
            mods_desc[k + 1] = "{C:attention}"..mods[k].."{},"
        else
            mods_desc[k + 1] = "{C:attention}"..mods[k]
        end
    end
    SMODS.Atlas { key = thumb , path = thumb..".png", px = 71, py = 95}
    returntable.joker = SMODS.Joker {
        no_collection = true,
        unlocked = true,
        discovered = true,
        key = name,
        in_pool = function(self, args)
            return false
        end,
        set_card_type_badge = function (self, card, badges)
            badges[1] = nil
        end,
        atlas = thumb,
        pos = { x = 0, y = 0 },
        loc_txt = {
            name = name,
            text = {loc_desc, authors_desc, mods_desc}
        }
    }
    returntable.name = name
    returntable.selected = false
    returntable.mod_prefix = SMODS.current_mod.prefix
    table.insert(BSFX.packs,returntable)
end


---@param name string The sound pack to load.
BSFX.toggle_pack = function(name)
    for _, pack in ipairs(BSFX.packs) do
        if pack.name == name then
            if pack.selected then
                pack.selected = false
                for _, sound in ipairs(pack.sounds) do
                    sound[1].replace = nil
                    SMODS.Sound.replace_sounds[sound[2]] = nil
                end
            else
                pack.selected = true
                for _, sound in ipairs(pack.sounds) do
                    sound[1].replace = sound[2]
                    SMODS.Sound.replace_sounds[sound[2]] = {times = -1, key = sound[1].key}
                end
                -- return "i did it"
            end
                if next(BSFX.CARDAREAS) then
                BSFX.load_cards()
            end
        end
    end
end
