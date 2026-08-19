Main = { supportsSpecialChars = true }
dofile("ironmon_tracker/Constants.lua")

assert(#Constants.OrderedLists.STATSTAGES == 5)
assert(table.concat(Constants.OrderedLists.STATSTAGES, ",") == "hp,atk,def,special,spe")

Tracker = {
	getOrCreateTrackedPokemon = function()
		return { sm = { hp = 1, spa = 2, spe = 3 } }
	end,
}
dofile("ironmon_tracker/Tracker.lua")
Tracker.getOrCreateTrackedPokemon = function()
	return { sm = { hp = 1, spa = 2, spe = 3 } }
end
local markings = Tracker.getStatMarkings(1)
assert(markings.hp == 1 and markings.special == 2 and markings.spe == 3)
assert(markings.spa == nil and markings.spd == nil)

print("Gen 1 stats UI smoke tests passed")
