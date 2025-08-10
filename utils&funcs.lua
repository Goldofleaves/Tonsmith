BSFX.packs = {}
---@param name string The Name of the sound pack.
---@param desc table The Description of the sound pack.
---@param thumb string The thumbnail of the sound pack (Excluding the png suffix).
---@param sound_table table The table of sounds to load.
BSFX.pack = function(name, desc, thumb, sound_table)
    name = name or ""
    sound_table = sound_table or {}
    local returntable = {}
    returntable.sounds = {}
    for i,sound in ipairs(sound_table) do
        returntable.sounds[i] = SMODS.Sound {
            key = sound,
            path = sound..".ogg"
        }
    end
    returntable.desc = desc
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
BSFX.load_mod = function(name)
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