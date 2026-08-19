-- Run from any directory with: lua tools/gen1_battle_runtime_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

local bytes, trackedMoves, encounters = {}, {}, {}
local saveStatesCreated, endedTrainerId = 0, nil
Memory = { readbyte = function(address) return bytes[address] or 0 end }
GameSettings = { battleState = 0x100, enemyMove = 0x101, partyCount = 0x102, playerStatStages = 0x200 }
local own = { pokemonID = 25, level = 30, curHP = 60, stats = {}, moves = {} }
local enemy = { pokemonID = 94, level = 32, curHP = 70, stats = { hp = 70, atk = 60, def = 50, spe = 80, special = 90 }, moves = {
	{ id = 94 }, { id = 95 }, { id = 109 }, { id = 122 },
} }
Tracker = {
	getPokemon = function(_, isOwn) return isOwn and own or enemy end,
	resetBattleNotes = function() end,
	recordLastLevelsSeen = function() end,
	TrackEncounter = function(id, wild) table.insert(encounters, { id, wild }) end,
	TrackRouteEncounter = function() end,
	TrackMove = function(id, move, level) table.insert(trackedMoves, { id, move, level }) end,
}
Program = { Frames = {}, GameData = { mapId = 12 }, redraw = function() end, isValidMapLocation = function() return true end }
Options = { ["Auto swap to enemy"] = true }
Input = { StatHighlighter = { resetSelectedStat = function() end } }
CustomCode = { afterBattleBegins = function() end, afterBattleEnds = function() end, afterBattleDataUpdate = function() end }
RouteData = { EncounterArea = { LAND = "Land" } }
TrainerData = {
	getCurrentTrainerId = function() return 0x2B02 end,
	FinalTrainer = {},
}
GameOverScreen = {
	createTempSaveState = function() saveStatesCreated = saveStatesCreated + 1 end,
	openIfEnded = function(trainerId) endedTrainerId = trainerId end,
}
InfoScreen = { clearScreenData = function() end }
TrainerInfoScreen = {}
TrainersOnRouteScreen = {}
RandomEvosScreen = {}
MoveHistoryScreen = {}
CatchRatesScreen = {}
TypeDefensesScreen = {}
CoverageCalcScreen = {}
HealsInBagScreen = {}
BattleDetailsScreen = { clearBuiltData = function() end }
TrackerScreen = {}

dofile(repoRoot .. "ironmon_tracker/core/Battle.lua")

bytes[GameSettings.partyCount] = 1
bytes[GameSettings.battleState] = 1
bytes[GameSettings.enemyMove] = 0
Battle.updateBattleStatus()
assert(Battle.inActiveBattle() and Battle.isWildEncounter)
assert(Battle.isViewingOwn == false, "Auto swap must show the enemy")
assert(#encounters == 1 and encounters[1][1] == 94 and encounters[1][2] == true)
assert(saveStatesCreated == 1 and Battle.opposingTrainerId == 0)

bytes[GameSettings.enemyMove] = 95
Battle.updateHighAccuracy()
assert(#trackedMoves == 1 and trackedMoves[1][2] == 95)
bytes[GameSettings.enemyMove] = 50 -- not in the enemy's actual moveset
Battle.updateHighAccuracy()
assert(#trackedMoves == 1, "Mimic/Transform-only moves must not be attributed to the species")

for offset, value in ipairs({ 8, 7, 6, 9, 5, 10 }) do
	bytes[GameSettings.playerStatStages + offset - 1] = value
	bytes[GameSettings.playerStatStages + 0x14 + offset - 1] = 14 - value
end
Battle.updateLowAccuracy()
assert(own.statStages.atk == 7 and own.statStages.special == 8 and own.statStages.eva == 9)
assert(enemy.statStages.atk == 5 and enemy.statStages.special == 4 and enemy.statStages.eva == 3)

bytes[GameSettings.battleState] = 0
Battle.updateBattleStatus()
assert(not Battle.inActiveBattle() and Battle.isViewingOwn)
assert(own.statStages.special == 6)
assert(endedTrainerId == 0, "Wild battles must not retain a trainer id")

bytes[GameSettings.battleState] = 2
Battle.begin(2, enemy)
assert(Battle.opposingTrainerId == 0x2B02 and saveStatesCreated == 2)
Battle.endCurrentBattle()
assert(endedTrainerId == 0x2B02, "Trainer id must survive until the native game-over check")

print("Gen 1 battle runtime smoke tests passed")
