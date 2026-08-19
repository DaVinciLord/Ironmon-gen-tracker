-- Run from any directory with: lua tools/gen1_runtime_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

local bytes = {}
Memory = { readbyte = function(address) return bytes[address] or 0 end }
SpeciesMap = {
	getDexId = function(internalId) return internalId == 0x54 and 25 or nil end,
	getName = function(internalId) return internalId == 0x54 and "PIKACHU" or nil end,
}
PokemonData = {
	Pokemon = { [25] = { growthRate = 0 } },
	Types = { UNKNOWN = "unknown", EMPTY = "" },
	isValid = function(id) return id == 25 end,
}
MoveData = { isValid = function() return true end }
DataAdapter = {
	expForLevel = function(_, level) return level ^ 3 end,
	TypeIndexMap = { [0x17] = "electric", [0x00] = "normal", [0x03] = "poison" },
}
GameSettings = {
	usesStarterChoice = function() return true end,
	partyCount = 0x200,
	partyMon1 = 0x300,
	battleState = 0x400,
	enemyMon = 0x500,
	battleMon = 0x550,
	currentMap = 0x600,
	badges = 0x700,
	bagCount = 0x800,
	bagItems = 0x801,
	tmMoves = 0x900,
}
Constants = { SCREEN = { WIDTH = 0, HEIGHT = 0 }, Font = { SIZE = 9 }, GAME_STATS = {} }
Main = { IsOnBizhawk = function() return false end, Version = {} }
Utils = { getGameStat = function() return 0 end }
MiscData = {
	PokeBalls = { [4] = true }, HealingItems = { [20] = true }, PPItems = {}, StatusItems = {}, EvolutionStones = { [10] = true },
	TMs = { [0xC9] = true }, HMs = { [0xC4] = true },
	getTotalItems = function() return 255 end,
}
Battle = { isViewingOwn = false, inActiveBattle = function() return false end, getViewedPokemon = function() return nil end }
Tracker = { AutoSave = {}, getPokemon = function() return nil end }
CustomCode = {}
TeamViewArea = {}
StartupScreen = {}
TrackerScreen = { Buttons = {} }
Options = {}
GameOverScreen = { Statuses = { STILL_PLAYING = 0 }, status = 0 }
RouteData = { Locations = {} }
Input = {}
Drawing = {}
FileManager = {}
Network = {}
CrashRecoveryScreen = {}
SetupScreen = {}
TimeMachineScreen = {}
SpriteData = {}
EventHandler = {}
UpdateScreen = {}
ExternalUI = { BizForms = {} }

dofile(repoRoot .. "ironmon_tracker/memory/PokemonDataReader.lua")
dofile(repoRoot .. "ironmon_tracker/core/Program.lua")

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
Program.updatePokemonTeams()
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
Program.updatePokemonTeams()
assert(Program.GameData.EnemyTeam[1].level == 30)
assert(Program.GameData.EnemyTeam[1].trainerID == -1)

put(GameSettings.battleMon + 5, 0x17, 0x17)
put(GameSettings.enemyMon + 5, 0x00, 0x03)
local ownTypes, enemyTypes = Program.getPokemonTypes(true), Program.getPokemonTypes(false)
assert(ownTypes[1] == "electric" and ownTypes[2] == "")
assert(enemyTypes[1] == "normal" and enemyTypes[2] == "poison")

bytes[GameSettings.currentMap] = 0x0C
Program.updateMapLocation()
assert(Program.GameData.mapId == 0x0C)
assert(Program.isValidMapLocation())

-- Pallet Town is map 0. The working Yellow FR tracker still updated the party.
bytes[GameSettings.currentMap] = 0
bytes[GameSettings.partyCount] = 0
Program.updateMapLocation()
assert(Program.GameData.mapId == 0)
assert(Program.isValidMapLocation(), "Pallet Town (map 0) is a real in-game location")
Program.updatePokemonTeams()
assert(Program.GameData.PlayerTeam[1] and Program.GameData.PlayerTeam[1].level == 25,
	"party must be read from species slots even if partyCount reads as 0")
assert((Program.GameData.PlayerTeam[1].personality or 0) ~= 0)
bytes[GameSettings.badges] = 0x25
assert(Program.readBadgeBits() == 0x25)

bytes[GameSettings.bagCount] = 5
put(GameSettings.bagItems, 4, 5, 20, 2, 10, 1, 0xC9, 1, 0xC4, 1)
Program.updateBagItems()
assert(Program.GameData.Items.PokeBalls[4] == 5)
assert(Program.GameData.Items.HPHeals[20] == 2)
assert(Program.GameData.Items.EvoStones[10] == 1)
put(GameSettings.tmMoves, 33)
put(GameSettings.tmMoves + 50, 15)
assert(Program.getMoveIdFromTMHMNumber(1, false) == 33)
assert(Program.getMoveIdFromTMHMNumber(1, true) == 15)
local tms, hms = Program.getTMsHMsBagItems()
assert(tms[1].id == 0xC9 and hms[1].id == 0xC4)

-- Hide-until-summary is a GBA RAM flag. Gen 1 profiles have no equivalent, so
-- leaving hasCheckedSummary false hides own stats forever.
Tracker.Data = { hasCheckedSummary = false }
GameSettings.sMonSummaryScreen = nil
Program.checkSummaryScreen()
assert(Tracker.Data.hasCheckedSummary,
	"without a summary-screen address, Gen 1 must reveal stats instead of hiding them forever")

Tracker.Data.hasCheckedSummary = false
GameSettings.sMonSummaryScreen = 0xA00
bytes[0xA00] = 0
Program.checkSummaryScreen()
assert(not Tracker.Data.hasCheckedSummary, "a zero GBA summary flag must keep stats hidden")
bytes[0xA00] = 1
Program.checkSummaryScreen()
assert(Tracker.Data.hasCheckedSummary, "a non-zero GBA summary flag must reveal stats")

print("Gen 1 runtime smoke tests passed")
