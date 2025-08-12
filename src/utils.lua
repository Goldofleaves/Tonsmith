BSFX.packs = {}

function BSFX.truncate_string(str, length)
    if length > string.len(str) then
        length = string.len(str)
    end
    local returnstring = ""
    for i = 1, length do
        returnstring = returnstring..string.sub(str, i, i)
    end
    return returnstring
end

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
    local mods = args.mods or {"None"}
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
    returntable.name = name
    returntable.mods = mods
    returntable.desc = desc
    returntable.authors = authors
    returntable.thumb = SMODS.Atlas { key = thumb , path = thumb..".png", px = 71, py = 95}
    returntable.selected = false
    BSFX.packs[name] = returntable
end


---@param name string The sound pack to load.
BSFX.toggle_pack = function(name)
    local pack = BSFX.packs[name]
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
end
