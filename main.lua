BSFX = {
    CARDAREAS = {},
    row = 2,
    card_per_row = 6,
    page = 1,
    prompt_text_input = "",
    menu_mod = "base",
    mod_config = SMODS.current_mod.config
}
SMODS.Atlas{key = "modicon", path = "modicon.png", px = 32, py = 32}

local mod_contents = {
	"utils",
    "overrides",
    "callbacks",
    "UI",
}
for k, v in pairs(mod_contents) do
	assert(SMODS.load_file('/src/'..v..'.lua'))()
end
