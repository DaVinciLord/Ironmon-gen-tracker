-- Abilities do not exist in Generation 1.
AbilityData = AbilityData or { isValid = function() return false end, Values = {} }

BattleDetailsScreen = {
	Key = "BattleDetailsScreen",
	Colors = {
		text = "Default text",
		highlight = "Intermediate text",
		border = "Upper box border",
		boxFill = "Upper box background",
	},
	Data = {
		-- The Resource key representing the current terrain used for the battle
		TerrainKey = "",
		-- The Resource key representing the current active weather in the battle (if any)
		WeatherKey = "",
		-- A short one/two word summary of top-most battle detail for each battler (index: 0-3)
		DetailsSummary = {},
		-- All known battle details affecting the entire battle field
		FieldDetails = {},
		-- All known battle details affecting each side, for ally or enemy (index: 0-1)
		PerSideDetails = {},
		-- All known battle details for each battler (index: 0-3)
		PerMonDetails = {},
	},
	Addresses = {
		offsetBattleMonsStatus2 = 0x50, -- gBattleMons
		offsetBattleStructWrappedBy = 0x14,
		sizeofStatus3 = 0x4,
		sizeofSideStatuses = 0x2,
		sizeofSideTimers = 0xC,
		sizeofDisableStruct = 0x1C,
		offsetTimerReflect = 0x0,
		offsetTimerLightScreen = 0x2,
		offsetTimerSpikes = 0xA,
		offsetTimerSafeguard = 0x6,
		offsetTimerMist = 0x4,
		offsetWishStructFutureCounter = 0x0,
		offsetWishStructFutureSource = 0x4,
		offsetWishStructWishCounter = 0x20,
		offsetWishStructWishSource = 0x24,
		offsetWishStructKnockOff = 0x29,
	},
	viewingIndividualStatuses = true,
	viewingSideStauses = false,
	viewedMonIndex = 0,
	viewedSideIndex = 0,
}
local SCREEN = BattleDetailsScreen
local CANVAS = {
	X = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN,
	Y = Constants.SCREEN.MARGIN,
	W = Constants.SCREEN.RIGHT_GAP - (Constants.SCREEN.MARGIN * 2),
	H = Constants.SCREEN.HEIGHT - (Constants.SCREEN.MARGIN * 2),
}

-- Holds functions that read in battle details from game data
SCREEN.GameFuncs = {}

-- Map number values from game data to names (Resource keys)
SCREEN.Maps = {
	WeatherToNameKey = {
		[0] = "WeatherRain", -- Temporary
		[1] = "WeatherRain", -- Downpour
		[2] = "WeatherRain", -- Permanent
		[3] = "WeatherSandstorm", -- Temporary
		[4] = "WeatherSandstorm", -- Permanent
		[5] = "WeatherSunlight", -- Temporary
		[6] = "WeatherSunlight", -- Permanent
		[7] = "WeatherHail", -- Temporary
		["default"] = "WeatherDefault",
	},
	TerrainToNameKey = {
		[0] = "TerrainGrass",
		[1] = "TerrainKey", -- Long Grass
		[2] = "TerrainSand",
		[3] = "TerrainUnderwater",
		[4] = "TerrainWater",
		[5] = "TerrainPond",
		[6] = "TerrainMountain",
		[7] = "TerrainCave",
		["default"] = "TerrainDefault",
	},
}

SCREEN.Pager = {
	Buttons = {},
	currentPage = 0,
	totalPages = 0,
	defaultSort = function(a, b) return a.index < b.index end, -- Order by appearance
	realignButtonsToGrid = function(self, x, y, colSpacer, rowSpacer)
		table.sort(self.Buttons, self.defaultSort)
		local cutoffX = Constants.SCREEN.WIDTH + Constants.SCREEN.RIGHT_GAP - Constants.SCREEN.MARGIN
		local cutoffY = Constants.SCREEN.HEIGHT - 20
		local totalPages = Utils.gridAlign(self.Buttons, x, y, colSpacer, rowSpacer, true, cutoffX, cutoffY)
		self.currentPage = 1
		self.totalPages = totalPages or 1
	end,
	getPageText = function(self)
		if self.totalPages <= 1 then return Resources.AllScreens.Page end
		local buffer = Utils.inlineIf(self.currentPage > 9, "", " ") .. Utils.inlineIf(self.totalPages > 9, "", " ")
		return buffer .. string.format("%s/%s", self.currentPage, self.totalPages)
	end,
	prevPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = ((self.currentPage - 2 + self.totalPages) % self.totalPages) + 1
		Program.redraw(true)
	end,
	nextPage = function(self)
		if self.totalPages <= 1 then return end
		self.currentPage = (self.currentPage % self.totalPages) + 1
		Program.redraw(true)
	end,
}

SCREEN.Buttons = {
	LabelTerrain = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local value = SCREEN.Data.isReady and Resources[SCREEN.Key][SCREEN.Data.TerrainKey] or Constants.BLANKLINE
			return string.format("%s: %s", Resources[SCREEN.Key].TextTerrain, value)
		end,
		box = {	CANVAS.X + 1, CANVAS.Y + 18, 60, 11 },
	},
	LabelWeather = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local value = SCREEN.Data.isReady and Resources[SCREEN.Key][SCREEN.Data.WeatherKey] or Constants.BLANKLINE
			return string.format("%s: %s", Resources[SCREEN.Key].TextWeather, value)
		end,
		box = {	CANVAS.X + 1, CANVAS.Y + 29, 60, 11 },
	},
	LabelTurnCount = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			local value = SCREEN.Data.isReady and ((Battle.turnCount or 0) + 1) or Constants.BLANKLINE
			return string.format("%s: %s", Resources[SCREEN.Key].TextTurn, value)
		end,
		box = {	CANVAS.X + 1, CANVAS.Y + 40, 60, 11 },
	},
	ViewedDetailsHeader = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function()
			if SCREEN.viewingIndividualStatuses then
				if SCREEN.viewedMonIndex % 2 == 0 then
					return string.format("%s %s", Resources[SCREEN.Key].TextAllied, Resources.AllScreens.Pokemon)
				else
					return string.format("%s %s", Resources[SCREEN.Key].TextEnemy, Resources.AllScreens.Pokemon)
				end
			elseif SCREEN.viewingSideStauses then
				if SCREEN.viewedSideIndex % 2 == 0 then
					return string.format("%s %s", Resources[SCREEN.Key].TextAllied, Resources[SCREEN.Key].TextTeam)
				else
					return string.format("%s %s", Resources[SCREEN.Key].TextEnemy, Resources[SCREEN.Key].TextTeam)
				end
			else
				return Resources[SCREEN.Key].TextField
			end
		end,
		textColor = SCREEN.Colors.highlight,
		box = {	CANVAS.X + 2, CANVAS.Y + 53, 60, 11 },
		isVisible = function(self) return SCREEN.Data.isReady end,
		updateSelf = function(self)
			-- Update width as text changes
			self.box[3] = 4 + Utils.calcWordPixelLength(self:getText())
		end,
		draw = function(self, shadowcolor)
			Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
		end,
	},
	CurrentPage = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return SCREEN.Pager:getPageText() end,
		box = { CANVAS.X + 56, CANVAS.Y + 135, 50, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
	},
	PrevPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.LEFT_ARROW,
		box = { CANVAS.X + 46, CANVAS.Y + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:prevPage()
		end
	},
	NextPage = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.RIGHT_ARROW,
		box = { CANVAS.X + 86, CANVAS.Y + 136, 10, 10, },
		isVisible = function() return SCREEN.Pager.totalPages > 1 end,
		onClick = function(self)
			SCREEN.Pager:nextPage()
		end
	},
	Back = Drawing.createUIElementBackButton(function()
		Program.changeScreenView(SCREEN.previousScreen or TrackerScreen)
		SCREEN.previousScreen = nil
	end),
}

SCREEN.TeamBallBox = {
	FieldView = {
		index = 1,
		type = Constants.ButtonTypes.NO_BORDER,
		image = Constants.PixelImages.RIGHT_TRIANGLE,
		clickableArea = { CANVAS.X + 91, CANVAS.Y + 19, 9, 30 },
		box = { CANVAS.X + 91, CANVAS.Y + 19, 44, 30},
		isVisible = function() return SCREEN.Data.isReady end,
		isSelected = function() return not SCREEN.viewingSideStauses and not SCREEN.viewingIndividualStatuses end,
		updateSelf = function(self)
			if self:isSelected() then
				self.index = 999
				self.textColor = SCREEN.Colors.highlight
				self.boxColors[1] = SCREEN.Colors.highlight
			else
				self.index = 1
				self.textColor = SCREEN.Colors.text
				self.boxColors[1] = SCREEN.Colors.border
			end
		end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = false
			SCREEN.viewedSideIndex = 0
			SCREEN.viewedMonIndex = 0
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local iconColor = Theme.COLORS[self.textColor]
			local borderColor = Theme.COLORS[self.boxColors[1]]
			-- Draw right/bottom shadows
			gui.drawLine(x + 1, y + h + 1, x + w + 1, y + h + 1, shadowcolor)
			gui.drawLine(x + w + 1, y + 1, x + w + 1, y + h + 1, shadowcolor)
			-- Draw full border rectangle
			gui.drawRectangle(x, y, w, h, borderColor)
			Drawing.drawImageAsPixels(self.image, x + 2, y + 11, iconColor, shadowcolor)
		end,
	},
	EnemyTeam = {
		index = 2,
		type = Constants.ButtonTypes.NO_BORDER,
		image = Constants.PixelImages.RIGHT_TRIANGLE,
		clickableArea = { CANVAS.X + 100, CANVAS.Y + 19, 6, 15 },
		box = { CANVAS.X + 100, CANVAS.Y + 19, 35, 15 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			-- Increase clickable area for team boxes in single battles to include the unused pokeballs
			local clickBox = self.clickableArea
			if Battle.numBattlers == 2 then
				clickBox[3] = 20
			else
				clickBox[3] = 6
			end
			if self:isSelected() then
				self.index = 999
				self.textColor = SCREEN.Colors.highlight
				self.boxColors[1] = SCREEN.Colors.highlight
			else
				self.index = 2
				self.textColor = SCREEN.Colors.text
				self.boxColors[1] = SCREEN.Colors.border
			end
		end,
		isSelected = function() return SCREEN.viewingSideStauses and SCREEN.viewedSideIndex == 1 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = true
			SCREEN.viewedSideIndex = 1
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local iconColor = Theme.COLORS[self.textColor]
			local borderColor = Theme.COLORS[self.boxColors[1]]
			gui.drawRectangle(x, y, w, h, borderColor)
			Drawing.drawImageAsPixels(self.image, x + 2, y + 3, iconColor, shadowcolor)
		end,
	},
	AllyTeam = {
		index = 3,
		type = Constants.ButtonTypes.NO_BORDER,
		image = Constants.PixelImages.LEFT_TRIANGLE,
		clickableArea = { CANVAS.X + 114, CANVAS.Y + 34, 20, 15 },
		box = { CANVAS.X + 100, CANVAS.Y + 34, 35, 15 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			-- Increase clickable area for team boxes in single battles to include the unused pokeballs
			local clickBox = self.clickableArea
			if Battle.numBattlers == 2 then
				clickBox[1] = CANVAS.X + 114
				clickBox[3] = 20
			else
				clickBox[1] = CANVAS.X + 129
				clickBox[3] = 6
			end
			if self:isSelected() then
				self.index = 999
				self.textColor = SCREEN.Colors.highlight
				self.boxColors[1] = SCREEN.Colors.highlight
			else
				self.index = 3
				self.textColor = SCREEN.Colors.text
				self.boxColors[1] = SCREEN.Colors.border
			end
		end,
		isSelected = function() return SCREEN.viewingSideStauses and SCREEN.viewedSideIndex == 0 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = false
			SCREEN.viewingSideStauses = true
			SCREEN.viewedSideIndex = 0
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local iconColor = Theme.COLORS[self.textColor]
			local borderColor = Theme.COLORS[self.boxColors[1]]
			gui.drawRectangle(x, y, w, h, borderColor)
			Drawing.drawImageAsPixels(self.image, x + 29, y + 3, iconColor, shadowcolor)
		end,
	},
	LeftOther = {
		index = 4,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 122, CANVAS.Y + 21, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 1 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 1
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
	RightOther = {
		index = 5,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 109, CANVAS.Y + 21, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			if Battle.numBattlers == 4 then
				self.iconColors = TrackerScreen.PokeBalls.ColorList
			else
				self.iconColors = { 0xFF000000, 0xFFB3B3B3, 0xFFFFFFFF, }
			end
		end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 3 end,
		onClick = function(self)
			if self:isSelected() or Battle.numBattlers < 4 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 3
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
	LeftOwn = {
		index = 6,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 102, CANVAS.Y + 36, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 0 end,
		onClick = function(self)
			if self:isSelected() then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 0
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
	RightOwn = {
		index = 7,
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.POKEBALL,
		iconColors = TrackerScreen.PokeBalls.ColorList,
		box = { CANVAS.X + 115, CANVAS.Y + 36, 13, 13 },
		isVisible = function() return SCREEN.Data.isReady end,
		updateSelf = function(self)
			if Battle.numBattlers == 4 then
				self.iconColors = TrackerScreen.PokeBalls.ColorList
			else
				self.iconColors = { 0xFF000000, 0xFFB3B3B3, 0xFFFFFFFF, }
			end
		end,
		isSelected = function() return SCREEN.viewingIndividualStatuses and SCREEN.viewedMonIndex == 2 end,
		onClick = function(self)
			if self:isSelected() or Battle.numBattlers < 4 then return end
			SCREEN.viewingIndividualStatuses = true
			SCREEN.viewingSideStauses = false
			SCREEN.viewedMonIndex = 2
			SCREEN.buildPagedButtons()
			Program.redraw(true)
		end,
		draw = function(self, shadowcolor)
			if not self:isSelected() then return end
			local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			local highlight = Theme.COLORS[SCREEN.Colors.highlight]
			Drawing.drawSelectionIndicators(x, y, w - 2, h - 2, highlight, 1, 3, 0)
		end,
	},
}

function SCREEN.initialize()
	for _, button in pairs(SCREEN.Buttons) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end
	for _, button in pairs(SCREEN.TeamBallBox) do
		if button.textColor == nil then
			button.textColor = SCREEN.Colors.text
		end
		if button.boxColors == nil then
			button.boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill }
		end
	end
	SCREEN.clearBuiltData()
end

function SCREEN.hasDetails()
	local viewIndex = Battle.getViewedIndex() or 0
	return not Utils.isNilOrEmpty(SCREEN.Data.DetailsSummary[viewIndex])
end

function SCREEN.updateData(buildPagedButtons)
	if not Battle.inActiveBattle() then
		if SCREEN.Data.isReady then
			SCREEN.clearBuiltData()
		end
		return
	end

	SCREEN.clearBuiltData()

	-- Read in battle details data from the game
	SCREEN.GameFuncs.readFieldEffects()
	for i = 0, Battle.numBattlers - 1, 1 do
		-- SCREEN.GameFuncs.readOther(i) -- info not currently recorded
		SCREEN.GameFuncs.readStatus2(i)
		SCREEN.GameFuncs.readStatus3(i)
		SCREEN.GameFuncs.readSideStatuses(i)
		SCREEN.GameFuncs.readDisableStruct(i)
		SCREEN.GameFuncs.readWishStruct(i)
		SCREEN.summarizeDetails(i)
	end

	SCREEN.Data.isReady = true

	-- If viewing this screen, build pager buttons to display known battle details
	if buildPagedButtons or Program.currentScreen == SCREEN then
		SCREEN.buildPagedButtons()
	end
end

---@param index number Must be [0-3], inclusively; represent which of the 4 battle mons to load details for
function SCREEN.summarizeDetails(index)
	if not index or index < 0 or index > 3 then
		return
	end
	local sideIndex = index % 2

	-- Summarize battle details by getting the first relevant item
	local firstDetail = SCREEN.Data.PerMonDetails[index][1]
		or SCREEN.Data.PerSideDetails[sideIndex][1]
		or SCREEN.Data.FieldDetails[1]

	if firstDetail and type(firstDetail.getText) == "function" then
		local summaryText = firstDetail:getText()
		-- Trim whitespace
		summaryText = summaryText:match("^%s*(.-)%s*$") or ""
		-- Shorten to fit on screen
		summaryText = Utils.shortenText(summaryText, 123, true)
		SCREEN.Data.DetailsSummary[index] = summaryText
	else
		SCREEN.Data.DetailsSummary[index] = ""
	end
end

function SCREEN.buildPagedButtons()
	if not SCREEN.Data.isReady then
		return
	end

	local detailsToUse = {}
	if SCREEN.viewingIndividualStatuses then
		for _, v in ipairs(SCREEN.Data.PerMonDetails[SCREEN.viewedMonIndex] or {}) do
			table.insert(detailsToUse, v)
		end
	end
	if SCREEN.viewingSideStauses then
		for _, v in ipairs(SCREEN.Data.PerSideDetails[SCREEN.viewedSideIndex] or {}) do
			table.insert(detailsToUse, v)
		end
	end
	for _, v in ipairs(SCREEN.Data.FieldDetails or {}) do
		table.insert(detailsToUse, v)
	end

	SCREEN.Pager.Buttons = {}
	for i, detail in ipairs(detailsToUse) do
		local button = {
			index = i,
			detail = detail,
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return string.format("- %s", detail:getText()) end,
			textColor = SCREEN.Colors.text,
			dimensions = { width = 100, height = 11 },
			boxColors = { SCREEN.Colors.border, SCREEN.Colors.boxFill },
			isVisible = function(self) return self.pageVisible == SCREEN.Pager.currentPage end,
			-- updateSelf = function(self)
			-- end,
			onClick = function(self)
				-- TODO: consider checking left/right halves of the button for multiple clickable ids
				if MoveData.isValid(detail.MoveId) then
					InfoScreen.previousScreenFinal = SCREEN
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, detail.MoveId)
				elseif PokemonData.isValid(detail.PokemonId) then
					InfoScreen.previousScreenFinal = SCREEN
					InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, detail.PokemonId)
				elseif AbilityData.isValid(detail.AbilityId) then
					InfoScreen.previousScreenFinal = SCREEN
					InfoScreen.changeScreenView(InfoScreen.Screens.ABILITY_INFO, detail.AbilityId)
				end
			end,
			-- draw = function(self, shadowcolor)
			-- 	local x, y, w, h = self.box[1], self.box[2], self.box[3], self.box[4]
			-- end,
		}
		table.insert(SCREEN.Pager.Buttons, button)
	end

	local detailsHeaderBtn = SCREEN.Buttons.ViewedDetailsHeader
	local X = CANVAS.X
	local Y = detailsHeaderBtn.box[2] + detailsHeaderBtn.box[4] + 1
	SCREEN.Pager:realignButtonsToGrid(X, Y, 20, 0)

	SCREEN.refreshButtons()
end

function SCREEN.clearBuiltData(clearViewIndex)
	SCREEN.Data = {
		isReady = false,
		TerrainKey = SCREEN.Maps.TerrainToNameKey["default"],
		WeatherKey = SCREEN.Maps.WeatherToNameKey["default"],

		DetailsSummary = {
			[0] = "",
			[1] = "",
			[2] = "",
			[3] = "",
		},

		-- List of IBattleDetail; details about the battle field itself (i.e. Pay Day, Mud Sport)
		FieldDetails = {},

		-- List of IBattleDetail; details per each side (ally / enemy)
		PerSideDetails = {
			[0] = {},
			[1] = {},
		},

		-- List of IBattleDetail; details per individual Pokémon (of the 4 total in battle)
		PerMonDetails = {
			[0] = {},
			[1] = {},
			[2] = {},
			[3] = {},
		},
	}

	SCREEN.Pager.Buttons = {}
	SCREEN.Pager.currentPage = 1
	SCREEN.Pager.totalPages = 1

	-- Only reset viewing index if not viewing this screen already
	if clearViewIndex or Program.currentScreen ~= SCREEN then
		SCREEN.resetViewIndex()
	end
end

function SCREEN.resetViewIndex()
	SCREEN.viewingIndividualStatuses = true
	SCREEN.viewingSideStauses = false
	SCREEN.viewedMonIndex = Battle.getViewedIndex() -- [Index: 0-3]
	SCREEN.viewedSideIndex = SCREEN.viewedMonIndex % 2 -- 0: Ally, 1: Enemy
end

function SCREEN.refreshButtons()
	for _, button in pairs(SCREEN.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(SCREEN.TeamBallBox) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function SCREEN.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.Pager.Buttons)
	Input.checkButtonsClicked(xmouse, ymouse, SCREEN.TeamBallBox)
end

function SCREEN.drawScreen()
	Drawing.drawBackgroundAndMargins()

	local canvas = {
		x = CANVAS.X,
		y = CANVAS.Y,
		width = CANVAS.W,
		height = CANVAS.H,
		text = Theme.COLORS[SCREEN.Colors.text],
		border = Theme.COLORS[SCREEN.Colors.border],
		fill = Theme.COLORS[SCREEN.Colors.boxFill],
		shadow = Utils.calcShadowColor(Theme.COLORS[SCREEN.Colors.boxFill]),
	}

	-- Draw top border box
	gui.defaultTextBackground(canvas.fill)
	gui.drawRectangle(canvas.x, canvas.y, canvas.width, canvas.height, canvas.border, canvas.fill)

	-- Draw header text
	local headerText = Utils.toUpperUTF8(Resources[SCREEN.Key].Title)
	-- local headerColor = Theme.COLORS["Header text"]
	-- local headerShadow = Utils.calcShadowColor(Theme.COLORS["Main background"])
	if Theme.DRAW_TEXT_SHADOWS then
		Drawing.drawText(canvas.x + 1, canvas.y + 1, headerText, canvas.shadow, nil, Constants.Font.HEADERSIZE)
	end
	Drawing.drawText(canvas.x, canvas.y, headerText, canvas.text, canvas.shadow, Constants.Font.HEADERSIZE)

	-- Draw all buttons
	for _, button in pairs(SCREEN.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	for _, button in pairs(SCREEN.Pager.Buttons) do
		Drawing.drawButton(button, canvas.shadow)
	end
	local sortedButtons = Utils.getSortedList(SCREEN.TeamBallBox)
	for _, button in pairs(sortedButtons) do
		Drawing.drawButton(button, canvas.shadow)
	end
end

-- Object Prototypes
---@class IBattleDetail
SCREEN.IBattleDetail = {
	-- The associated Resources key for this battle effect
	ResourceKey = "",
	-- The value to store for this battle effect (if any)
	Value = "NO_VALUE",
	-- Optional id of the move, if any is associated with this battle detail
	MoveId = 0,
	-- Optional id of the Pokémon, if any is associated with this battle detail
	PokemonId = 0,
	-- Optional id of the ability, if any is associated with this battle detail
	AbilityId = 0,

	-- Returns this effect's value (if any)
	getValue = function(self)
		if not self.Value or self.Value == "NO_VALUE" then
			return nil
		end
		return self.Value
	end,
	-- Returns this effect's text as it's expected to be formatted
	getText = function(self)
		if self:getValue() then
			return string.format("%s: %s", Resources[SCREEN.Key][self.ResourceKey or ""] or "", self:getValue())
		else
			return Resources[SCREEN.Key][self.ResourceKey or ""] or ""
		end
	end,
}
---Creates and returns a new IBattleDetail object
---@param o? table Optional initial object table
---@return IBattleDetail battleeffect An IBattleDetail object
function SCREEN.IBattleDetail:new(o)
	o = o or {}
	o.ResourceKey = o.ResourceKey or ""
	o.Value = o.Value or -99999
	o.MoveId = o.MoveId or 0
	o.PokemonId = o.PokemonId or 0
	setmetatable(o, self)
	self.__index = self
	return o
end

-- Functions to read in game data (RBY WRAM; pret pokered battle status bits)
local function testBit(byte, bitIndex)
	byte = tonumber(byte) or 0
	return math.floor(byte / (2 ^ bitIndex)) % 2 == 1
end

local function readBCD3(address)
	if not address then return 0 end
	local function digit(value)
		value = tonumber(value) or 0
		return math.floor(value / 16) * 10 + (value % 16)
	end
	return digit(Memory.readbyte(address)) * 10000
		+ digit(Memory.readbyte(address + 1)) * 100
		+ digit(Memory.readbyte(address + 2))
end

local function moveName(moveId)
	return Resources.Game.MoveNames[moveId or 0] or Constants.BLANKLINE
end

local function monDetails(index)
	SCREEN.Data.PerMonDetails[index] = SCREEN.Data.PerMonDetails[index] or {}
	return SCREEN.Data.PerMonDetails[index]
end

local function sideDetails(index)
	SCREEN.Data.PerSideDetails[index] = SCREEN.Data.PerSideDetails[index] or {}
	return SCREEN.Data.PerSideDetails[index]
end

local function addMove(list, moveId)
	table.insert(list, SCREEN.IBattleDetail:new({
		MoveId = moveId,
		getText = function() return moveName(moveId) end,
	}))
end

local function addText(list, getter)
	table.insert(list, SCREEN.IBattleDetail:new({ getText = getter }))
end

local function statusBase(index)
	if index % 2 == 0 then
		return GameSettings.playerBattleStatus1
	end
	return GameSettings.enemyBattleStatus1
end

function SCREEN.GameFuncs.readTerrain()
	SCREEN.Data.TerrainKey = SCREEN.Maps.TerrainToNameKey["default"]
end

function SCREEN.GameFuncs.readWeather()
	SCREEN.Data.WeatherKey = SCREEN.Maps.WeatherToNameKey["default"]
	SCREEN.Data.WeatherTurns = 0
end

function SCREEN.GameFuncs.readFieldEffects()
	SCREEN.GameFuncs.readTerrain()
	SCREEN.GameFuncs.readWeather()
	local payday = readBCD3(GameSettings.paydayMoney)
	if payday ~= 0 then
		table.insert(SCREEN.Data.FieldDetails, SCREEN.IBattleDetail:new({
			Value = payday,
			MoveId = MoveData.Values.PayDayId or 6,
			getText = function(self)
				return string.format("%s (%s)", moveName(MoveData.Values.PayDayId or 6), self.Value)
			end,
		}))
	end
end

function SCREEN.GameFuncs.readStatus2(index)
	if not index or index < 0 or index > 1 then return end
	local base = statusBase(index)
	if not base then return end
	local status1 = Memory.readbyte(base) or 0
	local status2 = Memory.readbyte(base + 1) or 0
	local details = monDetails(index)
	if testBit(status1, 0) then addMove(details, MoveData.Values.BideId or 117) end
	if testBit(status1, 1) then
		addText(details, function() return Resources[SCREEN.Key].EffectMustAttack end)
	end
	if testBit(status1, 5) then
		addText(details, function() return Resources[SCREEN.Key].EffectTrapped end)
	end
	if testBit(status1, 7) then
		addText(details, function()
			return string.format("%s (1- 4 %ss)", Resources[SCREEN.Key].EffectConfused, Resources[SCREEN.Key].TextTurn)
		end)
	end
	if testBit(status2, 1) then addMove(details, MoveData.Values.MistId or 54) end
	if testBit(status2, 2) then addMove(details, MoveData.Values.FocusEnergyId or 116) end
	if testBit(status2, 4) then addMove(details, MoveData.Values.SubstituteId or 164) end
	if testBit(status2, 5) then
		addText(details, function() return Resources[SCREEN.Key].EffectCannotAct end)
	end
	if testBit(status2, 6) then addMove(details, MoveData.Values.RageId or 99) end
	if testBit(status2, 7) then addMove(details, MoveData.Values.LeechSeedId or 73) end
end

function SCREEN.GameFuncs.readStatus3(index)
	if not index or index < 0 or index > 1 then return end
	local base = statusBase(index)
	if not base then return end
	local status3 = Memory.readbyte(base + 2) or 0
	local details = monDetails(index)
	if testBit(status3, 3) then addMove(details, MoveData.Values.TransformId or 144) end
end

function SCREEN.GameFuncs.readSideStatuses(index)
	if not index or index < 0 or index > 1 then return end
	local base = statusBase(index)
	if not base then return end
	local status2 = Memory.readbyte(base + 1) or 0
	local status3 = Memory.readbyte(base + 2) or 0
	local details = sideDetails(index)
	if testBit(status2, 1) then addMove(details, MoveData.Values.MistId or 54) end
	if testBit(status3, 1) then addMove(details, MoveData.Values.LightScreenId or 113) end
	if testBit(status3, 2) then addMove(details, MoveData.Values.ReflectId or 115) end
end

function SCREEN.GameFuncs.readDisableStruct(index)
	if not index or index < 0 or index > 1 then return end
	local address = (index % 2 == 0) and GameSettings.playerDisabledMoveNumber or GameSettings.enemyDisabledMoveNumber
	if not address then return end
	local moveId = Memory.readbyte(address) or 0
	if not MoveData.isValid or not MoveData.isValid(moveId) then return end
	table.insert(monDetails(index), SCREEN.IBattleDetail:new({
		MoveId = moveId,
		getText = function()
			return string.format("%s (%s)", moveName(MoveData.Values.DisableId or 50), moveName(moveId))
		end,
	}))
end

function SCREEN.GameFuncs.readWishStruct(index)
end

function SCREEN.GameFuncs.readOther(index)
end
