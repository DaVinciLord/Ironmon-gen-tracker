Main = { supportsSpecialChars = true }
dofile("ironmon_tracker/constants/Constants.lua")

assert(#Constants.OrderedLists.STATSTAGES == 5)
assert(table.concat(Constants.OrderedLists.STATSTAGES, ",") == "hp,atk,def,special,spe")

Tracker = {
	getOrCreateTrackedPokemon = function()
		return { sm = { hp = 1, spa = 2, spe = 3 } }
	end,
}
dofile("ironmon_tracker/core/Tracker.lua")
Tracker.getOrCreateTrackedPokemon = function()
	return { sm = { hp = 1, spa = 2, spe = 3 } }
end
local markings = Tracker.getStatMarkings(1)
assert(markings.hp == 1 and markings.special == 2 and markings.spe == 3)
assert(markings.spa == nil and markings.spd == nil)

local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*a")
	file:close()
	return content
end

local french = read("ironmon_tracker/Languages/French.lua")
local special = french:match("StatSpecial%s*=%s*\"([^\"]+)\"")
local speed = french:match("StatSPE%s*=%s*\"([^\"]+)\"")
assert(special == "SPC", "French Special must be SPC, got " .. tostring(special))
assert(speed == "SPE", "French Speed must stay SPE, got " .. tostring(speed))
assert(special ~= speed, "Special and Speed labels must differ")

local trackerScreen = read("ironmon_tracker/ui/screens/combat/TrackerScreen.lua")
assert(not trackerScreen:find("HELD ITEM AND ABILITIES", 1, true),
	"the main tracker must not draw GBA held-item/ability rows")
assert(not trackerScreen:find("data.p.line1", 1, true) and not trackerScreen:find("data.p.line2", 1, true),
	"ability/item placeholder lines must not be drawn")

local dataHelper = read("ironmon_tracker/data/DataHelper.lua")
assert(not dataHelper:find("data.p.line1", 1, true) and not dataHelper:find("data.p.line2", 1, true),
	"DataHelper must not fill blank ability/item rows")

print("Gen 1 stats UI smoke tests passed")
