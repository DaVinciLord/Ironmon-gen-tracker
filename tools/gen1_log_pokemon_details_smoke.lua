-- Log Pokémon details: no abilities; RBY DVs / Stat Exp; short stat labels.
-- Reproduces: attempt to index nil (field 'abilities' / 'evs'); overlapping "Special"/"Spe".
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")
if repoRoot == "" then repoRoot = "./" end
if not repoRoot:match("[/\\]$") then repoRoot = repoRoot .. "/" end

Constants = {
	BLANKLINE = "--",
	SCREEN = { WIDTH = 160, HEIGHT = 144, LINESPACING = 10, RIGHT_GAP = 180, MARGIN = 5 },
	ButtonTypes = { NO_BORDER = 1, FULL_BORDER = 2, PIXELIMAGE = 3, POKEMON_ICON = 4 },
	PixelImages = { UP_ARROW = {}, DOWN_ARROW = {}, PHYSICAL = {}, SPECIAL = {} },
	OrderedLists = { STATSTAGES = { "hp", "atk", "def", "special", "spe" } },
}
Options = { ["Show Pre Evolutions"] = false, ["Show nicknames"] = false, ["Show physical special icons"] = false }
Program = { GameData = { PlayerTeam = {} }, redraw = function() end }
Utils = {
	isNilOrEmpty = function(value) return value == nil or value == "" end,
	inlineIf = function(cond, a, b) if cond then return a end return b end,
	getShortenedEvolutionsInfo = function() return {} end,
	containsText = function() return false end,
	formatSpecialCharacters = function(value) return value end,
	firstToUpper = function(s) return s and (s:sub(1, 1):upper() .. s:sub(2)) or s end,
	calcWordPixelLength = function(text) return #(text or "") * 4 end,
	shortenText = function(text, pixelWidth)
		text = text or ""
		if #(text) * 4 <= (pixelWidth or 999) then return text end
		return text:sub(1, math.max(1, math.floor((pixelWidth or 1) / 4)))
	end,
}
PokemonData = {
	isValid = function(id) return id == 1 end,
	BlankPokemon = { name = "???", evolution = {} },
	Pokemon = { [1] = { name = "Bulbasaur", evolution = {} } },
}
MoveData = { Values = { HiddenPowerId = -1 }, isValid = function() return false end, Moves = {} }
FileManager = { PostFixes = { AUTORANDOMIZED = "AutoRandomized" } }
Resources = {
	TrackerScreen = { StatHP = "HP", StatATK = "ATK", StatDEF = "DEF", StatSpecial = "SPC", StatSPE = "SPE" },
	LogOverlay = {
		LabelGymTMs = "Gym TMs",
		LabelOtherTMs = "Other TMs",
		LabelBSTTotal = "BST",
		LabelYourDVs = "Your DVs",
		LabelYourStatExp = "Your Stat Exp",
		LabelBaseStats = "Base Stats",
		LabelShowDVs = "Show DVs",
		LabelShowStatExp = "Show EVs",
		LabelShowBST = "Show BST",
	},
}
LogOverlay = {
	TabBox = { x = 2, y = 12, width = 156, height = 129 },
	viewedLog = FileManager.PostFixes.AUTORANDOMIZED,
}
LogSearchScreen = { searchText = "", FilterBy = { PokemonMove = 1 } }
SpriteData = { Types = { Idle = "idle" } }
InfoScreen = { Screens = { POKEMON_INFO = 1, MOVE_INFO = 2 }, changeScreenView = function() end }
RandomizerLog = { Data = { Pokemon = {} } }
Theme = {
	COLORS = {
		["Lower box text"] = 1,
		["Lower box border"] = 2,
		["Lower box background"] = 3,
		["Positive text"] = 4,
		["Negative text"] = 5,
	},
}
local drawnTexts = {}
Drawing = { drawText = function(_, _, text) table.insert(drawnTexts, tostring(text)) end }
gui = {
	drawRectangle = function() end,
	drawLine = function() end,
	drawPixel = function() end,
}

DataHelper = {
	buildPokemonLogDisplay = function(pokemonID)
		return {
			p = {
				id = pokemonID,
				name = "Bulbasaur",
				bst = 318,
				types = { "grass", "poison" },
				hp = 45, atk = 22, def = 49, special = 65, spe = 45,
				evos = {},
				prevos = {},
				moves = (function()
					local list = {}
					for i = 1, 14 do
						list[i] = { id = 33, level = i, name = "Tackle", isstab = false }
					end
					return list
				end)(),
				tmmoves = {},
			},
			x = { extras = { bumps = {} } },
		}
	end,
}

Program.GameData.PlayerTeam = {
	{
		pokemonID = 1,
		nickname = "",
		dvs = { hp = 8, atk = 10, def = 12, special = 15, spe = 5 },
		statExp = { hp = 100, atk = 200, def = 300, special = 400, spe = 500 },
	},
}

dofile(repoRoot .. "ironmon_tracker/ui/screens/log/LogTabPokemonDetails.lua")

assert(LogTabPokemonDetails.statGraphLabel("special") == "SPC", "Special must use the short SPC label, not 'Special'")
assert(LogTabPokemonDetails.statGraphLabel("spe") == "SPE")
assert(LogTabPokemonDetails.statGraphLabel("hp") == "HP")

local ok, err = pcall(LogTabPokemonDetails.buildZoomButtons, 1)
assert(ok, "opening log Pokémon details must not crash on Gen 1: " .. tostring(err))
assert(LogTabPokemonDetails.infoId == 1)
assert(LogTabPokemonDetails.dataSet.p.abilities == nil, "RBY log Pokémon details must not invent abilities")
assert(#LogTabPokemonDetails.TemporaryButtons > 0)

local teamMon = LogTabPokemonDetails.playerTeam[1]
assert(teamMon.dvs and teamMon.dvs.atk == 10, "party DVs must be kept for the stat graph")
assert(teamMon.statExp and teamMon.statExp.hp == 100, "party Stat Exp must be kept for the stat graph")
assert(teamMon.ivs == nil and teamMon.evs == nil, "GBA IVs/EVs must not be stored")

local data = LogTabPokemonDetails.dataSet
assert(LogTabPokemonDetails.statGraphValue(teamMon, "ShowDVs", data, "atk") == 10)
assert(LogTabPokemonDetails.statGraphValue(teamMon, "ShowStatExp", data, "hp") == 100)
assert(LogTabPokemonDetails.statGraphValue(teamMon, "ShowBST", data, "atk") == 22)
assert(LogTabPokemonDetails.statGraphValue({}, "ShowDVs", data, "atk") == 0, "missing DVs must not crash")
assert(LogTabPokemonDetails.statGraphValue({}, "ShowStatExp", data, "hp") == 0, "missing Stat Exp must not crash")

for _, view in ipairs({ "ShowBST", "ShowDVs", "ShowStatExp" }) do
	LogTabPokemonDetails.currentStatView = view
	drawnTexts = {}
	ok, err = pcall(LogTabPokemonDetails.drawStatGraph, data, 0)
	assert(ok, "drawStatGraph " .. view .. " must not crash: " .. tostring(err))
end

local labels = {}
for _, text in ipairs(drawnTexts) do
	labels[text] = true
end
assert(labels["SPC"] and labels["SPE"] and labels["HP"], "stat graph must use HP/ATK/DEF/SPC/SPE")
assert(not labels["Special"], "stat graph must not draw the unabbreviated 'Special' label")

local overlayRight = LogOverlay.TabBox.x + LogOverlay.TabBox.width
assert(overlayRight <= Constants.SCREEN.WIDTH, "log details must stay on the GB overlay, not overlap InfoScreen")
local layout = LogTabPokemonDetails.getLayout()
assert(layout.movesX + layout.movesW <= overlayRight, "move column must stay inside the GB overlay, not overlap InfoScreen")
assert(layout.statBox.x + layout.statBox.width <= layout.movesX, "stat graph must not overlap the move list")
assert(layout.arrowX + 10 <= overlayRight)
assert(layout.statBox.y >= layout.showBtnBox[2] + layout.showBtnBox[4], "stat graph must sit below the DVs button")
assert(layout.headerBox[2] + layout.headerBox[4] <= layout.showBtnBox[2] or layout.headerBox[1] + layout.headerBox[3] <= layout.showBtnBox[1],
	"Base Stats label must not overlap the DVs button")
assert(layout.movesPerPage < 12, "GB overlay cannot fit the GBA 12-move page")
assert(layout.lvTabLabel == "Lv" and layout.tmTabLabel == "TM")
assert(layout.statBox.labelW >= 16, "stat labels need enough column width to not read as HPATKDEFSPCSPE")
assert(layout.iconX + layout.iconSize <= layout.movesX, "evo/icon row must stay in the stats column, not overlap moves")
assert(layout.headerBox[2] >= LogOverlay.TabBox.y + 24, "stats stay below the reserved evo/icon row")
local layoutWithEvo = LogTabPokemonDetails.getLayout(true)
assert(layout.statBox.y == layoutWithEvo.statBox.y, "graph position must not depend on whether the Pokémon evolves")
assert(layout.movesX == layoutWithEvo.movesX and layout.movesPerPage == layoutWithEvo.movesPerPage)
assert(layoutWithEvo.iconX + layoutWithEvo.iconSize <= layoutWithEvo.movesX)
local sawCurrentIcon = false
for _, btn in pairs(LogTabPokemonDetails.TemporaryButtons) do
	if btn.type == Constants.ButtonTypes.POKEMON_ICON and btn.pokemonID == 1 then
		local visible = btn.isVisible == nil or btn:isVisible()
		if visible then
			sawCurrentIcon = true
			assert(btn.box[1] + btn.box[3] <= layout.movesX + 0.5, "Pokémon icon must stay above stats")
		end
	end
end
assert(sawCurrentIcon, "the current Pokémon icon is shown above stats even without an evolution")
local tabBottom = LogOverlay.TabBox.y + LogOverlay.TabBox.height
local lastMoveBottom = 0
for _, btn in pairs(LogTabPokemonDetails.Pager.Buttons) do
	if btn.pageVisible == 1 and btn.box then
		lastMoveBottom = math.max(lastMoveBottom, btn.box[2] + btn.box[4])
	end
end
assert(lastMoveBottom > 0 and lastMoveBottom <= tabBottom + 0.5, "visible moves must stay inside TabBox, last=" .. tostring(lastMoveBottom))

local function assertInsideOverlay(box, name)
	if type(box) ~= "table" or box[1] == nil then return end
	assert(box[1] + (box[3] or 0) <= overlayRight + 0.5,
		name .. " overflows into InfoScreen (right=" .. tostring(box[1] + (box[3] or 0)) .. ")")
end
for _, btn in pairs(LogTabPokemonDetails.Pager.Buttons) do
	assertInsideOverlay(btn.box, "move list")
	if btn.getCustomText then
		local text = btn:getCustomText()
		assert(text ~= "Gym TMs" and text ~= "Other TMs",
			"empty Gym TMs / Other TMs headers must not appear when there are no gym TMs")
	end
end
for _, btn in pairs(LogTabPokemonDetails.TemporaryButtons) do
	assertInsideOverlay(btn.box, "overlay control")
end

PokemonData.Pokemon[2] = { name = "Ivysaur", evolution = {} }
local buildDisplay = DataHelper.buildPokemonLogDisplay
DataHelper.buildPokemonLogDisplay = function(pokemonID)
	local data = buildDisplay(pokemonID)
	data.p.evos = { { id = 2 } }
	return data
end
ok, err = pcall(LogTabPokemonDetails.buildZoomButtons, 1)
assert(ok, "evo chain must not crash: " .. tostring(err))
local movesLeft = LogTabPokemonDetails.layout.movesX
local sawEvoIcon = false
for _, btn in pairs(LogTabPokemonDetails.TemporaryButtons) do
	if btn.type == Constants.ButtonTypes.POKEMON_ICON and btn.box then
		local visible = btn.isVisible == nil or btn:isVisible()
		if visible then
			sawEvoIcon = true
			assert(btn.box[1] + btn.box[3] <= movesLeft + 0.5,
				"evo/icon must stay above stats, not overlap the move list")
		end
	end
end
assert(sawEvoIcon, "evolution sprites must still be drawn above the stats")

DataHelper.buildPokemonLogDisplay = function(pokemonID)
	local data = buildDisplay(pokemonID)
	data.p.tmmoves = {
		{ tm = 34, moveId = 33, gymNum = 1, moveName = "Bide", isstab = false },
		{ tm = 2, moveId = 33, gymNum = 9, moveName = "Clone", isstab = false },
	}
	return data
end
ok, err = pcall(LogTabPokemonDetails.buildZoomButtons, 1)
assert(ok, "gym TM list must not crash: " .. tostring(err))
local tmTexts = {}
for _, btn in pairs(LogTabPokemonDetails.Pager.Buttons) do
	if btn.getCustomText then
		tmTexts[btn:getCustomText()] = true
	end
end
assert(tmTexts["Gym TMs"] and tmTexts["Other TMs"], "Gym TMs / Other TMs headers appear when gym TMs are tagged")

print("Gen 1 log Pokémon details smoke tests passed")
