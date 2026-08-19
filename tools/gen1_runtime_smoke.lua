-- Run from any directory with: lua tools/gen1_runtime_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

local bytes = {}
Memory = { readbyte = function(address) return bytes[address] or 0 end }
Gen1SpeciesMap = {
	getDexId = function(internalId) return internalId == 0x54 and 25 or nil end,
	getName = function(internalId) return internalId == 0x54 and "PIKACHU" or nil end,
}
PokemonData = { Pokemon = { [25] = { growthRate = 0 } }, Types = { UNKNOWN = "unknown", EMPTY = "" } }
Gen1DataAdapter = {
	expForLevel = function(_, level) return level ^ 3 end,
	TypeIndexMap = { [0x17] = "electric", [0x00] = "normal", [0x03] = "poison" },
}
GameSettings = {
	partyCount = 0x200,
	partyMon1 = 0x300,
	battleState = 0x400,
	enemyMon = 0x500,
	battleMon = 0x550,
	currentMap = 0x600,
	badges = 0x700,
	bagCount = 0x800,
	bagItems = 0x801,
}
Program = {
	Addresses = {},
	GameData = { PlayerTeam = {}, EnemyTeam = {} },
	DefaultPokemon = { new = function(_, value) return value end },
	validPokemonData = function(value) return value and value.pokemonID == 25 end,
	Frames = {}, recalcLeadPokemonHealingInfo = function() end,
}
MiscData = {
	PokeBalls = { [4] = true }, HealingItems = { [20] = true }, PPItems = {}, StatusItems = {}, EvolutionStones = { [10] = true },
}
Tracker = { AutoSave = {} }
CustomCode = {}
TeamViewArea = {}
StartupScreen = {}
TrackerScreen = {}

dofile(repoRoot .. "ironmon_tracker/gen1/PokemonReader.lua")
dofile(repoRoot .. "ironmon_tracker/gen1/Runtime.lua")

local function put(address, ...)
	for index, value in ipairs({ ... }) do bytes[address + index - 1] = value end
end
local function pokemonAt(address, level, hp)
	put(address, 0x54, 0, hp)
	put(address + 8, 84, 98, 86, 129)
	put(address + 12, 0x12, 0x34)
	local experience = level == 25 and 16000 or level ^ 3
	put(address + 14, math.floor(experience / 0x10000), math.floor(experience / 0x100) % 0x100, experience % 0x100)
	put(address + 27, 0xA5, 0xC7)
	put(address + 29, 30, 20, 10, 5)
	put(address + 33, level)
	put(address + 34, 0, hp, 0, 40, 0, 30, 0, 55, 0, 50)
end

bytes[GameSettings.partyCount] = 2
pokemonAt(GameSettings.partyMon1, 25, 60)
pokemonAt(GameSettings.partyMon1 + 44, 26, 62)
bytes[GameSettings.battleState] = 0
Gen1Runtime.updatePokemonTeams()
assert(Program.GameData.PlayerTeam[1].level == 25)
assert(Program.GameData.PlayerTeam[1].currentExp == 375)
assert(Program.GameData.PlayerTeam[1].totalExp == 1951)
assert(Program.GameData.PlayerTeam[2].level == 26)
assert(Program.GameData.PlayerTeam[3] == nil)
assert(Program.GameData.EnemyTeam[1] == nil)

bytes[GameSettings.battleState] = 2
put(GameSettings.enemyMon, 0x54, 0, 45)
put(GameSettings.enemyMon + 8, 84, 98, 86, 129)
put(GameSettings.enemyMon + 12, 0xA5, 0xC7)
put(GameSettings.enemyMon + 14, 30)
put(GameSettings.enemyMon + 15, 0, 70, 0, 45, 0, 35, 0, 60, 0, 55)
put(GameSettings.enemyMon + 25, 30, 20, 10, 5)
Gen1Runtime.updatePokemonTeams()
assert(Program.GameData.EnemyTeam[1].level == 30)
assert(Program.GameData.EnemyTeam[1].trainerID == -1)

put(GameSettings.battleMon + 5, 0x17, 0x17)
put(GameSettings.enemyMon + 5, 0x00, 0x03)
local ownTypes, enemyTypes = Gen1Runtime.getPokemonTypes(true), Gen1Runtime.getPokemonTypes(false)
assert(ownTypes[1] == "electric" and ownTypes[2] == "")
assert(enemyTypes[1] == "normal" and enemyTypes[2] == "poison")

bytes[GameSettings.currentMap] = 0x0C
Gen1Runtime.updateMapLocation()
assert(Program.GameData.mapId == 0x0C)
assert(Gen1Runtime.isValidMapLocation())
bytes[GameSettings.badges] = 0x25
assert(Gen1Runtime.readBadgeBits() == 0x25)

bytes[GameSettings.bagCount] = 3
put(GameSettings.bagItems, 4, 5, 20, 2, 10, 1)
Gen1Runtime.updateBagItems()
assert(Program.GameData.Items.PokeBalls[4] == 5)
assert(Program.GameData.Items.HPHeals[20] == 2)
assert(Program.GameData.Items.EvoStones[10] == 1)

print("Gen 1 runtime smoke tests passed")
