-- Run from any directory with: lua tools/gen1_battle_details_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")
if repoRoot == "" then repoRoot = "./" end
if not repoRoot:match("[/\\]$") then repoRoot = repoRoot .. "/" end

Constants = {
	BLANKLINE = "--",
	SCREEN = { WIDTH = 240, RIGHT_GAP = 150, HEIGHT = 160, MARGIN = 5 },
	ButtonTypes = { NO_BORDER = 1, PIXELIMAGE = 2 },
	Font = { HEADERSIZE = 15 },
	PixelImages = { LEFT_ARROW = {}, RIGHT_ARROW = {}, LEFT_TRIANGLE = {}, RIGHT_TRIANGLE = {}, POKEBALL = {} },
}
Resources = {
	BattleDetailsScreen = {
		Title = "Battle Details",
		TextTurn = "Turn",
		TextTerrain = "Terrain",
		TextWeather = "Weather",
		TextAllied = "Allied",
		TextEnemy = "Enemy",
		TextTeam = "Team",
		TextField = "Field Effects",
		TextTurnsRemaining = "Left",
		EffectConfused = "Confused",
		EffectMustAttack = "Must Attack",
		EffectTrapped = "Trapped",
		EffectCannotAct = "Recharging",
		TerrainDefault = "Building",
		WeatherDefault = "None",
	},
	AllScreens = { Pokemon = "Pokémon", Page = "Page" },
	Game = { MoveNames = { [6] = "Pay Day", [50] = "Disable", [73] = "Leech Seed", [33] = "Tackle" } },
}
Drawing = {
	createUIElementBackButton = function(onClick) return { onClick = onClick, box = { 0, 0, 1, 1 } } end,
	drawBackgroundAndMargins = function() end,
	drawButton = function() end,
	drawText = function() end,
	drawUnderline = function() end,
	drawImageAsPixels = function() end,
}
Theme = {
	DRAW_TEXT_SHADOWS = false,
	COLORS = { ["Upper box border"] = 1, ["Upper box background"] = 2, ["Default text"] = 3, ["Intermediate text"] = 4 },
}
gui = { defaultTextBackground = function() end, drawRectangle = function() end, drawLine = function() end }
Utils = {
	isNilOrEmpty = function(value) return value == nil or value == "" end,
	calcShadowColor = function() return 0 end,
	toUpperUTF8 = function(text) return string.upper(text or "") end,
	shortenText = function(text) return text end,
	calcWordPixelLength = function() return 40 end,
	inlineIf = function(cond, a, b) if cond then return a end return b end,
	getSortedList = function(list)
		local sorted = {}
		for _, value in pairs(list) do table.insert(sorted, value) end
		return sorted
	end,
	gridAlign = function() return 1 end,
}
MoveData = {
	Values = { PayDayId = 6, DisableId = 50, LeechSeedId = 73 },
	isValid = function(id) return id == 33 or id == 50 or id == 73 or id == 6 end,
}
PokemonData = { isValid = function() return true end }
local bytes = {}
Memory = { readbyte = function(address) return bytes[address] or 0 end, readword = function() return 0 end, readdword = function() return 0 end }
GameSettings = {
	playerBattleStatus1 = 0x300,
	enemyBattleStatus1 = 0x310,
	paydayMoney = 0x320,
	playerDisabledMoveNumber = 0x330,
	enemyDisabledMoveNumber = 0x331,
}
Battle = {
	isViewingOwn = true,
	numBattlers = 2,
	turnCount = 0,
	inActiveBattle = function() return true end,
	getViewedIndex = function() return Battle.isViewingOwn and 0 or 1 end,
	IndexMap = { [0] = "LeftOwn", [1] = "LeftOther" },
	Combatants = { LeftOwn = 1, LeftOther = 1 },
}
Program = { currentScreen = nil, redraw = function() end, changeScreenView = function() end }
Input = { checkButtonsClicked = function() end }
TrackerScreen = { PokeBalls = { ColorList = {}, ColorListFainted = {}, ColorListMasterBall = {} } }

dofile(repoRoot .. "ironmon_tracker/screens/BattleDetailsScreen.lua")
BattleDetailsScreen.initialize()
BattleDetailsScreen.updateData(true)
assert(BattleDetailsScreen.Data.isReady)
assert(BattleDetailsScreen.Data.DetailsSummary[0] == "")
assert(BattleDetailsScreen.Data.DetailsSummary[1] == "")
assert(not BattleDetailsScreen.hasDetails(), "no invented HP/stat summary")

bytes[GameSettings.playerBattleStatus1 + 1] = 128 -- SEEDED
BattleDetailsScreen.updateData(true)
assert(BattleDetailsScreen.Data.DetailsSummary[0] == "Leech Seed")
assert(BattleDetailsScreen.hasDetails())

Battle.isViewingOwn = false
assert(not BattleDetailsScreen.hasDetails(), "enemy without details stays closed")

bytes[GameSettings.enemyBattleStatus1 + 1] = 128
BattleDetailsScreen.updateData(true)
assert(BattleDetailsScreen.Data.DetailsSummary[1] == "Leech Seed")
assert(BattleDetailsScreen.hasDetails())

print("Gen 1 battle details smoke tests passed")
