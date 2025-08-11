BSFX = {
    CARDAREAS = {}
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