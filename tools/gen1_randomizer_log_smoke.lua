Main = { supportsSpecialChars = true }
Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
RouteData = { EncounterArea = { TRAINER = 1, LAND = 2, SURFING = 3, ROCKSMASH = 4, OLDROD = 5, GOODROD = 6, SUPERROD = 7 }, Info = {} }
GameSettings = { game = 2, language = "French" }
Resources = { currentLanguage = { Key = "ENGLISH" }, Languages = {}, Default = {} }
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
Gen1TrainerData = { GlobalLogIdToTrainerId = { [1] = 0x0101 } }
FileManager = {}

dofile("ironmon_tracker/data/PokemonData.lua")
dofile("ironmon_tracker/data/MoveData.lua")
dofile("ironmon_tracker/data/RandomizerLog.lua")
dofile("ironmon_tracker/gen1/RandomizerLog.lua")
RandomizerLog.initBlankData()
RandomizerLog.PokemonNameToIdMap = {}

RandomizerLog.Sectors.BaseStatsItems.LineNumber = 1
RandomizerLog.parseBaseStatsItems({ "header", "  1|BULBIZARRE|GRASS/POISON| 80| 72| 36| 52| 13", "" })
local bulbasaur = RandomizerLog.Data.Pokemon[1]
assert(bulbasaur.BaseStats.hp == 80 and bulbasaur.BaseStats.spe == 52 and bulbasaur.BaseStats.special == 13)
assert(bulbasaur.BaseStats.spa == nil and bulbasaur.BaseStats.spd == nil)

RandomizerLog.MoveNameToIdMap = { ["charge"] = 33 }
RandomizerLog.Sectors.MoveSets.LineNumber = 1
RandomizerLog.parseMoveSets({
	"001 BULBIZARRE -> SMOGO", "HP 80", "ATK 72", "DEF 36", "SPEC 13", "SPE 52",
	"Level 7 : CHARGE", "", "--TM Moves--",
})
assert(#bulbasaur.MoveSet == 1 and bulbasaur.MoveSet[1].level == 7 and bulbasaur.MoveSet[1].moveId == 33)

RandomizerLog.Sectors.Trainers.LineNumber = 1
RandomizerLog.parseTrainers({ "#1 (GAMIN => Nurse)@39E32 - BULBIZARRE Lv17", "" })
assert(RandomizerLog.Data.Trainers[0x0101].party[1].pokemonID == 1)
assert(RandomizerLog.Data.Trainers[1] == nil, "global UPR trainer ids must be remapped to native class/number ids")

print("Gen 1 randomizer log smoke tests passed")
