BSFX = {}
SMODS.Atlas{key = "modicon", path = "modicon.png", px = 32, py = 32}

local mod_contents = {
	"utils&funcs"
}
for k, v in pairs(mod_contents) do
	assert(SMODS.load_file('/'..v..'.lua'))()
end