BSFX.packs = {}
---Defines and creates a soundpack for BetterSFX to load.<br>
---@param args {name:string,description:string[],authors:string[],sound_table:string[],thumbnail:string,extension?:".ogg"|string}
---`name` - The Name of the sound pack.<br>
---`description` - The Description of the sound pack.<br>
---`authors` - The authors of the soundpack.
---`thumbnail` - string The thumbnail of the sound pack (Excluding the png suffix).<br>
---`sound_table` - The table of sounds to load, excluding the file extension.<br>
BSFX.Pack = function(args)
    local name = args.name or ""
    local desc = args.description or {}
    local authors = args.authors or {}
    local sound_table = args.sound_table or {}
    local thumb = args.thumbnail
    local f_extension = args.extension or ".ogg"

    local returntable = {}
    returntable.sounds = {}
    for i,sound in ipairs(sound_table) do
        returntable.sounds[i] = SMODS.Sound {
            key = sound,
            path = sound..f_extension
        }
    end
    returntable.name = name
    returntable.desc = desc
    returntable.authors = authors
    returntable.thumb = SMODS.Atlas { key = thumb , path = thumb..".png", px = 71, py = 95}
    returntable.selected = false
    BSFX.packs[name] = returntable
end

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

---@param name table The sound pack to load.
BSFX.load_pack = function(name)
    local pack = BSFX.packs[name]
    if pack.selected then
        pack.selected = false
        for _, sound in ipairs(pack.sounds) do
            sound.replace = nil
            SMODS.Sound.replace_sounds[BSFX.truncate_string(sound.path, string.len(sound.path) - 4)] = nil
        end
    else
        pack.selected = true
        for _, sound in ipairs(pack.sounds) do
            sound.replace = BSFX.truncate_string(sound.path, string.len(sound.path) - 4)
            SMODS.Sound.replace_sounds[BSFX.truncate_string(sound.path, string.len(sound.path) - 4)] = {times = -1, key = sound.key}
        end
        -- return "i did it"
    end
end
