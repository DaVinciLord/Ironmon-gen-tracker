-- Native Generation 1 battle details. RBY battles have no abilities, held
-- items, weather, field effects or double-battle side state.
BattleDetailsScreen = {
	Key = "BattleDetailsScreen",
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Data = { isReady = false, DetailsSummary = {}, Pokemon = {} },
	viewingOwn = false,
}

local SCREEN = BattleDetailsScreen
local CANVAS = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
	Y = Constants.SCREEN.MARGIN,
	W = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
}

local function getViewedPokemon()
	return SCREEN.Data.Pokemon[SCREEN.viewingOwn and 0 or 1]
end

local function stageText(stage)
	stage = tonumber(stage) or 6
	local delta = stage - 6
	if delta > 0 then return "+" .. delta end
	if delta < 0 then return tostring(delta) end
	return "--"
end

local function buildSummary(pokemon)
	if not pokemon or not PokemonData.isValid(pokemon.pokemonID) then return "" end
	for _, statKey in ipairs({ "atk", "def", "special", "spe", "acc", "eva" }) do
		local stage = (pokemon.statStages or {})[statKey] or 6
		if stage ~= 6 then
			return string.format("%s %s", statKey:upper(), stageText(stage))
		end
	end
	local status = MiscData.StatusCodeMap[pokemon.status or 0]
	if not Utils.isNilOrEmpty(status) then return status end
	return string.format("HP %s/%s", pokemon.curHP or 0, (pokemon.stats or {}).hp or 0)
end

SCREEN.Buttons = {
	Own = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return Resources[SCREEN.Key].TextAllied or "Player" end,
		box = { CANVAS.X + 2, CANVAS.Y + 2, 62, 13 },
		onClick = function() SCREEN.viewingOwn = true; SCREEN.refreshButtons(); Program.redraw(true) end,
	},
	Enemy = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function() return Resources[SCREEN.Key].TextEnemy or "Enemy" end,
		box = { CANVAS.X + 72, CANVAS.Y + 2, 62, 13 },
		onClick = function() SCREEN.viewingOwn = false; SCREEN.refreshButtons(); Program.redraw(true) end,
	},
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconId = function() return (getViewedPokemon() or {}).pokemonID or 0 end,
		clickableArea = { CANVAS.X + 4, CANVAS.Y + 21, 32, 27 },
		box = { CANVAS.X + 4, CANVAS.Y + 15, 32, 32 },
		onClick = function()
			local pokemon = getViewedPokemon() or {}
			if PokemonData.isValid(pokemon.pokemonID) then
				InfoScreen.previousScreenFinal = SCREEN
				InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemon.pokemonID)
			end
		end,
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or TrackerScreen)
		SCREEN.previousScreen = nil
	end),
}

for slot = 1, 4 do
	SCREEN.Buttons["Move" .. slot] = {
		type = Constants.ButtonTypes.NO_BORDER,
		moveId = 0,
		getText = function(self)
			local pokemon = getViewedPokemon() or {}
			local move = (pokemon.moves or {})[self.slot] or {}
			local moveInfo = MoveData.Moves[move.id or 0] or MoveData.BlankMove
			if not MoveData.isValid(move.id) then return Constants.BLANKLINE end
			return string.format("%s  %s/%s", moveInfo.name, move.pp or 0, moveInfo.pp or 0)
		end,
		slot = slot,
		box = { CANVAS.X + 3, CANVAS.Y + 91 + ((slot - 1) * 11), 132, 11 },
		onClick = function(self)
			local pokemon = getViewedPokemon() or {}
			local move = (pokemon.moves or {})[self.slot] or {}
			if MoveData.isValid(move.id) then
				InfoScreen.previousScreenFinal = SCREEN
				InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, move.id)
			end
		end,
	}
end

function BattleDetailsScreen.initialize()
	SCREEN.clearBuiltData()
end

function BattleDetailsScreen.clearBuiltData()
	SCREEN.Data = { isReady = false, DetailsSummary = {}, Pokemon = {} }
end

function BattleDetailsScreen.updateData(force)
	if not Battle.inActiveBattle() then
		SCREEN.clearBuiltData()
		return
	end
	local own = Tracker.getPokemon(1, true)
	local enemy = Tracker.getPokemon(1, false)
	SCREEN.Data.Pokemon[0] = own
	SCREEN.Data.Pokemon[1] = enemy
	SCREEN.Data.DetailsSummary[0] = buildSummary(own)
	SCREEN.Data.DetailsSummary[1] = buildSummary(enemy)
	SCREEN.Data.isReady = own ~= nil or enemy ~= nil
	if force then SCREEN.viewingOwn = Battle.isViewingOwn end
	SCREEN.refreshButtons()
end

function BattleDetailsScreen.hasDetails()
	if not SCREEN.Data.isReady then SCREEN.updateData() end
	return Battle.inActiveBattle() and SCREEN.Data.isReady
end

function BattleDetailsScreen.refreshButtons()
	SCREEN.Buttons.Own.textColor = SCREEN.viewingOwn and SCREEN.Colors.highlight or SCREEN.Colors.text
	SCREEN.Buttons.Enemy.textColor = not SCREEN.viewingOwn and SCREEN.Colors.highlight or SCREEN.Colors.text
	for _, button in pairs(SCREEN.Buttons) do
		button.boxColors = button.boxColors or { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		button.textColor = button.textColor or SCREEN.Colors.text
	end
end

function BattleDetailsScreen.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
end

function BattleDetailsScreen.drawScreen()
	if not Battle.inActiveBattle() then
		Program.changeScreenView(TrackerScreen)
		return
	end
	SCREEN.updateData()
	Drawing.drawBackgroundAndMargins()
	local border = Theme.COLORS[SCREEN.Colors.border]
	local fill = Theme.COLORS[SCREEN.Colors.boxFill]
	local text = Theme.COLORS[SCREEN.Colors.text]
	local highlight = Theme.COLORS[SCREEN.Colors.highlight]
	local shadow = Utils.calcShadowColor(fill)
	gui.defaultTextBackground(fill)
	gui.drawRectangle(CANVAS.X, CANVAS.Y, CANVAS.W, CANVAS.H, border, fill)
	gui.drawLine(CANVAS.X + 69, CANVAS.Y + 1, CANVAS.X + 69, CANVAS.Y + 15, border)

	for _, button in pairs(SCREEN.Buttons) do Drawing.drawButton(button, shadow) end

	local pokemon = getViewedPokemon() or {}
	if not PokemonData.isValid(pokemon.pokemonID) then return end
	local info = PokemonData.Pokemon[pokemon.pokemonID] or PokemonData.BlankPokemon
	Drawing.drawText(CANVAS.X + 39, CANVAS.Y + 20, info.name or Constants.BLANKLINE, highlight, shadow)
	Drawing.drawText(CANVAS.X + 39, CANVAS.Y + 31,
		string.format("%s.%s  HP %s/%s", Resources.TrackerScreen.LevelAbbreviation, pokemon.level or 0,
			pokemon.curHP or 0, (pokemon.stats or {}).hp or 0), text, shadow)
	local status = MiscData.StatusCodeMap[pokemon.status or 0]
	if not Utils.isNilOrEmpty(status) then Drawing.drawText(CANVAS.X + 39, CANVAS.Y + 42, status, highlight, shadow) end

	local stats = pokemon.stats or {}
	local stages = pokemon.statStages or {}
	local statRows = {
		{ "HP", "hp" }, { "ATK", "atk" }, { "DEF", "def" },
		{ "SPECIAL", "special" }, { "SPE", "spe" },
	}
	for i, row in ipairs(statRows) do
		local y = CANVAS.Y + 53 + ((i - 1) * 8)
		Drawing.drawText(CANVAS.X + 4, y, row[1], text, shadow)
		Drawing.drawNumber(CANVAS.X + 72, y, stats[row[2]] or 0, 3, text, shadow)
		if row[2] ~= "hp" then Drawing.drawText(CANVAS.X + 83, y, stageText(stages[row[2]]), highlight, shadow) end
	end
	Drawing.drawText(CANVAS.X + 102, CANVAS.Y + 61, "ACC " .. stageText(stages.acc), text, shadow)
	Drawing.drawText(CANVAS.X + 102, CANVAS.Y + 72, "EVA " .. stageText(stages.eva), text, shadow)
end

return BattleDetailsScreen
