BSFX.packs = {}
---Defines and creates a vanilla soundpack for BetterSFX to load.<br>
---@param args {name:string,description:string[],authors:string[],sound_table:table[],thumbnail:string,extension?:".ogg"|string}
---`name` - The Name of the sound pack.<br>
---`description` - The Description of the sound pack.<br>
---`authors` - The authors of the soundpack.<br>
---`thumbnail` - string The thumbnail of the sound pack (Excluding the png suffix).<br>
---`sound_table` - The table of sounds to load, excluding the file extension.<br>
---`extension` - The file extention.<br>
BSFX.Pack_Vanilla = function(args)
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
    returntable.modded = false
    BSFX.packs[name] = returntable
end

---Defines and creates a modded soundpack for BetterSFX to load.<br>
---@param args {name:string,modprefix:string,description:string[],authors:string[],sound_table:table[],thumbnail:string,extension?:".ogg"|string}
---`name` - The Name of the sound pack.<br>
---`modprefix` - The mod prefix the sound pack replaces. Includes the "_" (Underscore).<br>
---`mod` - The mod whos sound you replace..<br>
---`description` - The Description of the sound pack.<br>
---`authors` - The authors of the soundpack.<br>
---`thumbnail` - string The thumbnail of the sound pack (Excluding the png suffix).<br>
---`sound_table` - The table of sounds to load, excluding the file extension.<br>
---`extension` - The file extention.<br>
BSFX.Pack_Modded = function(args)
    local name = args.name or ""
    local desc = args.description or {}
    local prefix = args.modprefix or "_"
    local authors = args.authors or {}
    local sound_table = args.sound_table or {}
    local thumb = args.thumbnail
    local f_extension = args.extension or ".ogg"

    local returntable = {}
    returntable.sounds = {}
    for i,sound in ipairs(sound_table) do
        returntable.sounds[i] = {SMODS.Sound {
            key = sound[1],
            path = sound[1]..f_extension
        }, prefix..sound[2]}
    end
    returntable.name = name
    returntable.desc = desc
    returntable.authors = authors
    returntable.thumb = SMODS.Atlas { key = thumb , path = thumb..".png", px = 71, py = 95}
    returntable.selected = false
    returntable.modded = true
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
BSFX.toggle_pack = function(name)
    local pack = BSFX.packs[name]
    if not pack.modded then
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
    else
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
end