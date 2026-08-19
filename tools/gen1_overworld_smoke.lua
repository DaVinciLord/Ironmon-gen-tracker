-- Run from any directory with: lua tools/gen1_overworld_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

local bytes = {}
Memory = {
	readbyte = function(address) return bytes[address] or 0 end,
	readword = function(address)
		return (bytes[address] or 0) + (bytes[address + 1] or 0) * 0x100
	end,
}
Constants = {
	BLANKLINE = "-",
	SCREEN = { WIDTH = 0, HEIGHT = 0, LINESPACING = 12, MARGIN = 0 },
	Font = { SIZE = 9 },
	GAME_STATS = {},
}
Utils = { formatSpecialCharacters = function(s) return s end, getGameStat = function() return 0 end }
Main = { IsOnBizhawk = function() return false end, Version = {}, ExitSafely = function() end, loadNextSeed = false }
TrainerData = {
	Classes = setmetatable({ Unknown = { filename = "unknown" } }, {
		__index = function(self) return self.Unknown end,
	}),
	IsRand = {},
	Trainers = {},
	OrderedIds = {},
	GymTMs = {},
	CommonTrainers = {},
	FinalTrainer = {},
}
Program = {
	GameData = { mapId = 0x0C, PlayerTeam = {}, EnemyTeam = {} },
	GameTrainer = { new = function(_, value) return value end },
	isValidMapLocation = function() return true end,
	Frames = {},
	redraw = function() end,
	Addresses = {},
	ActiveRepel = { inUse = false, stepCount = 0, duration = 100 },
	Pedometer = { isInUse = function() return false end },
	recalcLeadPokemonHealingInfo = function() end,
	DefaultPokemon = { new = function(_, value) return value end },
	validPokemonData = function() return true end,
}
TrackerAPI = {}
Tracker = {
	Data = { defeatedTrainers = {}, centerHeals = 0, gameStatsHeals = 0 },
	DefaultData = { defeatedTrainers = {} },
	getPokemon = function() return nil end,
	resetBattleNotes = function() end,
	recordLastLevelsSeen = function() end,
	TrackEncounter = function() end,
	TrackRouteEncounter = function(mapId, area, pokemonID)
		Tracker.lastRoute = { mapId, area, pokemonID }
	end,
	TrackMove = function() end,
	AutoSave = {},
}
Battle = {
	inBattleScreen = false, dataReady = false, isViewingOwn = true, isViewingLeft = true,
	Combatants = {}, CurrentRoute = {}, trySwapScreenBackToMain = function() end,
}
Options = { ["Auto swap to enemy"] = false, ["Track PC Heals"] = false, ["Display repel usage"] = true }
Input = { StatHighlighter = { resetSelectedStat = function() end } }
CustomCode = { afterBattleBegins = function() end, afterBattleEnds = function() end, afterBattleDataUpdate = function() end }
GameOverScreen = {
	createTempSaveState = function() end,
	openIfEnded = function() end,
	updateDefeatedTrainersCount = function()
		GameOverScreen.numDefeatedTrainers = TrainerData.countDefeated()
	end,
}
TeamViewArea = {}
StartupScreen = {}
TrackerScreen = { Buttons = { PCHealAutoTracking = { toggleState = false } } }
MiscData = {
	PokeBalls = {}, HealingItems = {}, PPItems = {}, StatusItems = {}, EvolutionStones = {},
	TMs = {}, HMs = {},
}
PokemonData = { Pokemon = {}, Types = { UNKNOWN = "unknown", EMPTY = "" } }
SpeciesMap = { getDexId = function(id) return id end, getName = function() return "" end }
DataAdapter = { expForLevel = function() return 0 end, TypeIndexMap = {} }
PokemonDataReader = { PartyStructSize = 44, readPartyPokemon = function() end, readBattlePokemon = function() end }

GameSettings = {
	currentProfile = { version = "Red" },
	usesStarterChoice = function() return true end,
	battleState = 0x100, trainerClass = 0x101, trainerNumber = 0x102,
	enemyMove = 0x103, partyCount = 0x104, playerStatStages = 0x200,
	walkBikeSurf = 0x300, curItem = 0x301, battleType = 0x302, battleResult = 0x303,
	moveNum = 0x304, whichPokemon = 0x305, evolutionOccurred = 0x306,
	repelSteps = 0x307, safariBalls = 0x308, safariSteps = 0x309,
	playerY = 0x30A, playerX = 0x30B, joyIgnore = 0x30C, playerStarter = 0x30D,
	badges = 0x30E, currentMap = 0x30F, partyMon1 = 0x400, bagCount = 0x500, bagItems = 0x501,
	tmMoves = 0x600, enemyMon = 0x700, battleMon = 0x800, trainers = 0x900,
}

dofile(repoRoot .. "ironmon_tracker/data/RouteData.lua")
dofile(repoRoot .. "ironmon_tracker/data/TrainerData.lua")
dofile(repoRoot .. "ironmon_tracker/core/Program.lua")
Program.redraw = function() end
Program.GameData.mapId = 0x0C
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
dofile(repoRoot .. "ironmon_tracker/core/Battle.lua")

RouteData.initialize()
TrainerData.initialize()
bytes[GameSettings.partyCount] = 1

assert(RouteData.Info[0x0C][RouteData.EncounterArea.LAND])
assert(RouteData.Info[0x00][RouteData.EncounterArea.SURFING], "Pallet Town must expose surfing")
assert(RouteData.Info[0x00][RouteData.EncounterArea.OLDROD], "global Old Rod must live on Pallet, not 0x100")
assert(RouteData.Info[0x00][RouteData.EncounterArea.GOODROD])
assert(RouteData.Info[0x00][RouteData.EncounterArea.SUPERROD])
assert(RouteData.Info[0x1E][RouteData.EncounterArea.SURFING], "Route 19 is water")
assert(not RouteData.Info[0x100], "synthetic 0x100 must not be a real map")
assert(RouteData.CombinedAreas.MtMoon and #RouteData.CombinedAreas.MtMoon == 3)
assert(RouteData.Info[0x36].name == "Pewter Gym")
assert(RouteData.Locations.IsInSafariZone[0xDC])
assert(RouteData.Locations.CanObtainBadge[0x36])

-- Encounter classification
bytes[GameSettings.walkBikeSurf] = 0
bytes[GameSettings.curItem] = 0
assert(RouteData.getCurrentEncounterArea() == RouteData.EncounterArea.LAND)
bytes[GameSettings.walkBikeSurf] = 2
assert(RouteData.getCurrentEncounterArea() == RouteData.EncounterArea.SURFING)
bytes[GameSettings.walkBikeSurf] = 0
bytes[GameSettings.curItem] = 76
assert(RouteData.getCurrentEncounterArea() == RouteData.EncounterArea.OLDROD)
bytes[GameSettings.curItem] = 77
assert(RouteData.getCurrentEncounterArea() == RouteData.EncounterArea.GOODROD)
bytes[GameSettings.curItem] = 78
assert(RouteData.getCurrentEncounterArea() == RouteData.EncounterArea.SUPERROD)

local enemy = { pokemonID = 16, level = 3, curHP = 12, stats = { hp = 12, atk = 6, def = 6, spe = 6, special = 6 }, moves = { { id = 16 } } }
Tracker.getPokemon = function(_, isOwn)
	if isOwn then return { pokemonID = 25, level = 5, curHP = 20, stats = {} } end
	return enemy
end

bytes[GameSettings.curItem] = 78
bytes[GameSettings.battleState] = 1
Program.GameData.mapId = 0x00
Battle.begin(1, enemy)
assert(Tracker.lastRoute[2] == RouteData.EncounterArea.SUPERROD, "wild Super Rod must not collapse into LAND")
assert(Battle.CurrentRoute.encounterArea == RouteData.EncounterArea.SUPERROD)

bytes[GameSettings.curItem] = 0
bytes[GameSettings.walkBikeSurf] = 0
Battle.endCurrentBattle()
Program.GameData.mapId = 0x0C
Battle.begin(1, enemy)
assert(Tracker.lastRoute[2] == RouteData.EncounterArea.LAND, "later grass battles must not reuse the previous rod")

-- Defeated trainers
local youngster = TrainerData.makeId(1, 1)
bytes[GameSettings.battleState] = 2
bytes[GameSettings.trainerClass] = 1
bytes[GameSettings.trainerNumber] = 1
bytes[GameSettings.battleResult] = 0
Battle.begin(2, enemy)
Battle.endCurrentBattle()
assert(Program.hasDefeatedTrainer(youngster), "winning a trainer battle must persist the defeat")
assert(Tracker.Data.defeatedTrainers[youngster])

local second = TrainerData.makeId(1, 2)
bytes[GameSettings.trainerNumber] = 2
bytes[GameSettings.battleResult] = 1
Tracker.getPokemon = function(_, isOwn)
	if isOwn then return { pokemonID = 25, level = 5, curHP = 0, stats = {} } end
	return enemy
end
Battle.begin(2, enemy)
Battle.endCurrentBattle()
assert(not Program.hasDefeatedTrainer(second), "a lost trainer battle must not count as defeated")

bytes[GameSettings.badges] = 0x01
assert(Program.hasDefeatedTrainer(TrainerData.makeId(34, 1)), "Boulder Badge implies Brock is defeated")
local pewters = RouteData.Info[0x36].trainers
assert(pewters and pewters[1] == TrainerData.makeId(34, 1))
local defeated, total = Program.getDefeatedTrainersByLocation(0x36)
assert(total >= 1 and #defeated >= 1)

GameOverScreen.updateDefeatedTrainersCount()
assert(GameOverScreen.numDefeatedTrainers >= 1)

-- Move learning
Tracker.getPokemon = function(slot)
	if slot == 1 then
		return { pokemonID = 25, level = 6, moves = { { id = 84 } } }
	end
end
bytes[GameSettings.moveNum] = 86 -- Thunder Wave? any unused id
bytes[GameSettings.whichPokemon] = 0
bytes[GameSettings.partyCount] = 1
Program.GameData.PlayerTeam[1] = { pokemonID = 25, level = 5 }
local learned = Program.getLearnedMoveInfoTable()
assert(learned.pokemonID == 25 and learned.moveId == 86 and learned.level == 6)

bytes[GameSettings.moveNum] = 5
Program.GameData.PlayerTeam[1].level = 6
learned = Program.getLearnedMoveInfoTable()
assert(learned.pokemonID == nil, "a TM/item move must not be reported without a level-up")

-- Overworld helpers
bytes[GameSettings.repelSteps] = 50
Program.updateRepelSteps()
assert(Program.ActiveRepel.inUse and Program.ActiveRepel.stepCount == 50)
bytes[GameSettings.safariBalls] = 12
bytes[GameSettings.currentMap] = 0xDC
Program.GameData.mapId = 0xDC
assert(Program.isInSafariZone())
bytes[GameSettings.playerY] = 8
bytes[GameSettings.playerX] = 4
local pos = Program.getPlayerTilePosition()
assert(pos.y == 8 and pos.x == 4)
bytes[GameSettings.evolutionOccurred] = 1
assert(Program.isInEvolutionScene())
bytes[GameSettings.evolutionOccurred] = 0
bytes[GameSettings.joyIgnore] = 1
bytes[GameSettings.battleState] = 0
assert(Program.isInStartMenu())
bytes[GameSettings.playerStarter] = 0xB0
assert(Program.getStarterChoice() == 0xB0)
assert(Program.changeGameSettingForLR() == nil)

print("Gen 1 overworld smoke tests passed")
