BSFX = {
    CARDAREAS = {},
    row = 2,
    card_per_row = 7,
    page = 1,
    prompt_text_input = "",
    menu_mod = "base",
}
SMODS.Atlas{key = "modicon", path = "modicon.png", px = 32, py = 32}

local ref = SMODS.create_mod_badges
function SMODS.create_mod_badges(obj, badges)
    if obj and type(obj.config.extra) ~= "nil" and not obj.config.extra.BSFX then
        ref(obj, badges)
    else
        -- print("i did it")
    end
    if obj and type(obj.config.extra) == "nil" then
        ref(obj, badges)
    end
end

local mod_contents = {
	"utils",
    "overrides",
    "callbacks",
    "UI",
}
for k, v in pairs(mod_contents) do
	assert(SMODS.load_file('/src/'..v..'.lua'))()
end
