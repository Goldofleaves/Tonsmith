SMODS.Atlas({key = 'default_music_pack', path = 'default_music_pack.png', px = 71, py = 75, prefix_config = false})

---Defines and creates a vanilla soundpack for tonsmith to load.<br>
---[<u>View documentation<u>](https://github.com/Goldofleaves/tonsmith/wiki#tnsmipack_vanilla)
---@param args {name:string,mods:string[],description:{},authors:string[],sound_table:table[],thumbnail:string,extension?:".ogg"|string}
TNSMI.SoundPacks = {}
TNSMI.SoundPack = SMODS.GameObject:extend ({
    obj_buffer = {},
    set = 'SoundPack',
    obj_table = TNSMI.SoundPacks,
    class_prefix = "sp",
    atlas = 'default_music_pack',
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

        TNSMI.SoundPack.super.register(self)
    end,
    inject = function(self)
        if not G.ASSET_ATLAS[self.atlas] and not G.ANIMATION_ATLAS[self.atlas] then
            SMODS.Atlas({ key = self.atlas , path = self.atlas..".png", px = 71, py = 95, prefix_config = false})
        end

        for _, v in ipairs(self.sound_table) do
            if v.key and not v.replace_key and not v.select_music_track then
                v.replace_key = v.key
            end

            if not v.key and v.replace_key then v.key = v.replace_key end

            local path = v.path or v.file
            if not path then
                path = (v.key..'.ogg')
            elseif not string.find(path, '.ogg') and not string.find(path, '.wav') then
                path = path..'.ogg'
            end
            v.key = self.mod.prefix..v.key

            -- TODO: prefix config

            local select_music_track = v.select_music_track
            if string.find(v.key, "music") and not select_music_track then
                -- simple priority selection from highest to lowest
                select_music_track = function()
                    for i = #TNSMI.config.loaded_packs, 1, -1 do
                        if TNSMI.config.loaded_packs[i] == self.key then return i end
                    end
                end
            end

            if not v.req_mod or next(SMODS.find_mod(v.req_mod)) then
                SMODS.Sound {
                    key = v.key,
                    path = path,
                    pitch = v.pitch or self.pitch,
                    volume = v.volume or self.volume,
                    sync = v.sync,
                    select_music_track = v.music_track,
                    prefix_config = false
                }
            end

        end

        TNSMI.SoundPacks[self.key] = self
    end,
})

---@param name string The sound pack to load.
function TNSMI.toggle_pack(key, toggle)
    local pack = TNSMI.SoundPacks[key]

    if not toggle then -- Disable pack
        for i = #TNSMI.config.loaded_packs, 1, -1 do
            if TNSMI.config.loaded_packs[i] == pack.key then
                table.remove(TNSMI.config.loaded_packs, i)
                break
            end
        end
    else
        table.insert(TNSMI.config.loaded_packs, pack.key)
    end

    TNSMI.save_soundpack()
end

function TNSMI.save_soundpacks()
    -- resets all existing replace sounds
    local replace_map = TNSMI.config.loaded_packs.replace_map or {}
    for k, v in pairs (replace_map) do
        SMODS.Sounds[v.key].replace = nil
        SMODS.Sound.replace_sounds[k] = nil
    end

    replace_map = {}
    TNSMI.config.loaded_packs = {}
    for i, v in ipairs(TNSMI.cardareas.priority.cards) do
        -- Save the priority to the config file.
        local priority = TNSMI.cardareas.priority.cards - i - 1
        TNSMI.config.loaded_packs[priority] = v.params.soundpack
        local pack = TNSMI.SoundPacks[v.params.soundpack]


        for _, sound in ipairs(pack.sounds) do
            if sound.replace_key and not replace_map[sound.replace_key] then
                replace_map[sound.replace_key] = { key = sound.key, priority = priority}
                local obj = SMODS.Sounds[sound.key]
                obj:create_replace_sound(obj.replace_key)
            end
        end
    end
    TNSMI.config.loaded_packs.replace_map = {}

    SMODS.save_mod_config(TNSMI)
    G.FUNCS.reload_soundpack_cards()
end