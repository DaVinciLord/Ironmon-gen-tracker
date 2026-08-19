local logPath = assert(arg[1], "usage: lua tools/gen1_log_routes_integration.lua <randomizer.log>")

Main = { supportsSpecialChars = true }
Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
RouteData = {
	EncounterArea = { TRAINER=1, LAND=2, SURFING=3, ROCKSMASH=4, OLDROD=5, GOODROD=6, SUPERROD=7 },
	Info = {},
}
for id = 0, 0xF8 do RouteData.Info[id] = { id = id, name = string.format("Map %02X", id) } end
GameSettings = { game = 1, language = "French" }
Resources = { currentLanguage = { Key = "FRENCH" }, Languages = {}, Default = {} }
Utils = {
	formatSpecialCharacters = function(value) return value end,
	toLowerUTF8 = function(value) return value and value:lower() end,
	toUpperUTF8 = function(value) return value and value:upper() end,
	firstToUpper = function(value) return value and value:gsub("^%l", string.upper) end,
	isNilOrEmpty = function(value) return value == nil or value == "" end,
	split = function(value, separator)
		local result = {}
		for part in tostring(value):gmatch("[^" .. separator .. "]+") do result[#result + 1] = part end
		return result
	end,
	tempDisableBizhawkSound = function() end,
	tempEnableBizhawkSound = function() end,
}
TrainerData = {
	getExcludedTrainers = function() return {} end,
	shouldUseTrainer = function() return true end,
}
Gen1TrainerData = { GlobalLogIdToTrainerId = {} }
for id = 1, 500 do Gen1TrainerData.GlobalLogIdToTrainerId[id] = id end
FileManager = {
	readLinesFromFile = function(path)
		local lines = {}
		for line in io.lines(path) do lines[#lines + 1] = line end
		return lines
	end,
}

dofile("ironmon_tracker/data/PokemonData.lua")
dofile("ironmon_tracker/data/MoveData.lua")
dofile("ironmon_tracker/data/RandomizerLog.lua")
dofile("ironmon_tracker/gen1/RandomizerLog.lua")

assert(RandomizerLog.parseLog(logPath), "randomizer log parsing failed")

local route1 = RandomizerLog.Data.Routes[0x0C]
assert(route1 and route1.EncountersAreas.GrassCave, "Route 1 grass encounters missing")
assert(route1.numWilds > 0, "Route 1 encounter list is empty")
local pallet = RandomizerLog.Data.Routes[0x00]
assert(pallet and pallet.EncountersAreas.OldRod, "global Old Rod encounters missing")
assert(pallet.EncountersAreas.GoodRod, "global Good Rod encounters missing")
assert(pallet.EncountersAreas.SuperRod, "Pallet Super Rod encounters missing")
local safari = RandomizerLog.Data.Routes[0xDC]
assert(safari and safari.EncountersAreas.GrassCave and safari.EncountersAreas.SuperRod,
	"Safari Zone encounter sets missing")

local populated = 0
for _, route in pairs(RandomizerLog.Data.Routes) do
	for _, area in pairs(route.EncountersAreas or {}) do
		if next(area.pokemon or {}) then populated = populated + 1 end
	end
end
assert(populated >= 80, "too few RBY encounter areas parsed: " .. populated)
local trainerCount, tmCount = 0, 0
for _ in pairs(RandomizerLog.Data.Trainers) do trainerCount = trainerCount + 1 end
for _ in pairs(RandomizerLog.Data.TMs) do tmCount = tmCount + 1 end
assert(trainerCount >= 300, "too few trainer teams parsed: " .. trainerCount)
assert(tmCount == 50, "expected 50 Gen 1 TMs, got " .. tmCount)
print(string.format("Gen 1 log integration passed: %d encounter areas, %d trainers, %d TMs",
	populated, trainerCount, tmCount))
