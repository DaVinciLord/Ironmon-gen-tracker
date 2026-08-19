Constants = {
	BLANKLINE = "--",
	SCREEN = { WIDTH = 240, RIGHT_GAP = 150, HEIGHT = 160, MARGIN = 5 },
	ButtonTypes = { NO_BORDER = 1, POKEMON_ICON = 2 },
}
Resources = {
	BattleDetailsScreen = { TextAllied = "Player", TextEnemy = "Enemy" },
	TrackerScreen = { LevelAbbreviation = "Lv" },
}
Drawing = {
	createUIElementBackButton = function(onClick) return { onClick = onClick, box = { 0, 0, 1, 1 } } end,
	drawBackgroundAndMargins = function() end,
	drawButton = function() end,
	drawText = function() end,
	drawNumber = function() end,
}
Theme = { COLORS = { ["Upper box border"] = 1, ["Upper box background"] = 2, ["Default text"] = 3, ["Intermediate text"] = 4 } }
gui = { defaultTextBackground = function() end, drawRectangle = function() end, drawLine = function() end }
Utils = {
	isNilOrEmpty = function(value) return value == nil or value == "" end,
	calcShadowColor = function() return 0 end,
}
PokemonData = {
	Pokemon = { [1] = { name = "Bulbasaur" }, [25] = { name = "Pikachu" } },
	BlankPokemon = {},
	isValid = function(id) return id == 1 or id == 25 end,
}
MoveData = {
	Moves = { [33] = { name = "Tackle", pp = 35 } },
	BlankMove = { name = "--", pp = 0 },
	isValid = function(id) return id == 33 end,
}
MiscData = { StatusCodeMap = { [0] = "", [5] = "PAR" } }
local own = {
	pokemonID = 1, level = 10, curHP = 20, status = 0,
	stats = { hp = 30, atk = 15, def = 14, special = 13, spe = 12 },
	statStages = { atk = 6, def = 6, special = 6, spe = 6, acc = 6, eva = 6 },
	moves = { { id = 33, pp = 21 } },
}
local enemy = {
	pokemonID = 25, level = 12, curHP = 16, status = 5,
	stats = { hp = 28, atk = 17, def = 12, special = 16, spe = 20 },
	statStages = { atk = 8, def = 6, special = 6, spe = 6, acc = 6, eva = 6 },
	moves = { { id = 33, pp = 30 } },
}
Battle = { isViewingOwn = false, inActiveBattle = function() return true end }
Tracker = { getPokemon = function(_, isOwn) return isOwn and own or enemy end }
Program = { redraw = function() end, changeScreenView = function() end }
Input = { checkButtonsClicked = function() end }
InfoScreen = { Screens = { POKEMON_INFO = 1, MOVE_INFO = 2 }, changeScreenView = function() end }
TrackerScreen = {}

dofile("ironmon_tracker/screens/BattleDetailsScreen.lua")
BattleDetailsScreen.initialize()
BattleDetailsScreen.updateData(true)
assert(BattleDetailsScreen.Data.isReady)
assert(BattleDetailsScreen.Data.DetailsSummary[0] == "HP 20/30")
assert(BattleDetailsScreen.Data.DetailsSummary[1] == "ATK +2")
assert(BattleDetailsScreen.hasDetails())
assert(BattleDetailsScreen.Buttons.Move1:getText() == "Tackle  30/35")

print("Gen 1 battle details smoke tests passed")
