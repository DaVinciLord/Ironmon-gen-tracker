-- Button definitions and dynamic badge/stat button setup for the combat HUD.
-- Positions are applied from TrackerScreenLayout.applyButtonBoxes() after rebuild.

TrackerScreen = TrackerScreen or {}
TrackerScreenButtons = {}

TrackerScreen.Buttons = {
	PokemonIcon = {
		type = Constants.ButtonTypes.POKEMON_ICON,
		getIconId = function(self)
			local pokemon = Tracker.getViewedPokemon() or Tracker.getDefaultPokemon()
			-- Don't return a SpriteData.Type with this, as the animation is allowed to change here
			return pokemon.pokemonID
		end,
		clickableArea = { Constants.SCREEN.WIDTH + 5, 5, 32, 27 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, -1, 32, 32 },
		isVisible = function() return true end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			if Options["Open Book Play Mode"] then
				LogOverlay.Windower:changeTab(LogTabPokemon)
				LogSearchScreen.resetSearchSortFilter()
				LogOverlay.refreshActiveTabGrid()
				LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, pokemon.pokemonID)
			end
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemon.pokemonID)
		end
	},
	ShinyEffect = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SPARKLES,
		iconColors = { "Intermediate text" },
		isHighlighted = true,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 84, Constants.SCREEN.MARGIN + 10, 12, 12 },
		isVisible = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			return pokemon.isShiny or (pokemon.hasPokerus and Battle.isViewingOwn)
		end,
		updateSelf = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if pokemon.isShiny and self.image ~= Constants.PixelImages.SPARKLES then
				self.image = Constants.PixelImages.SPARKLES
			elseif pokemon.hasPokerus and self.image ~= Constants.PixelImages.VIRUS then
				self.image = Constants.PixelImages.VIRUS
			end
			self.iconColors[1] = self.isHighlighted and "Intermediate text" or "Default text"
		end,
		onClick = function(self)
			if self.image == Constants.PixelImages.SPARKLES then
				self:activatePulsing()
			end
		end,
		pulse = function(self)
			self.isHighlighted = not self.isHighlighted
			self:updateSelf()
			Program.redraw(true)
		end,
		activatePulsing = function(self)
			-- Reset the shiny pulse effect, lasts 15 seconds
			Program.removeFrameCounter("ShinyPulse")
			Program.addFrameCounter("ShinyPulse", 45, function()
				self:pulse()
			end, 19, true)
			self:pulse()
		end,
	},
	TypeDefenses = {
		-- Invisible button area for the type defenses boxes
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 27, 30, 24, },
		isVisible = function()
			local pokemon = Tracker.getViewedPokemon() or {}
			return PokemonData.isValid(pokemon.pokemonID)
		end,
		onClick = function (self)
			local pokemon = Tracker.getViewedPokemon() or {}
			TypeDefensesScreen.buildOutPagedButtons(pokemon.pokemonID or 0)
			Program.changeScreenView(TypeDefensesScreen)
		end,
	},
	SettingsGear = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.GEAR,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + 92, 7, 7, 7 },
		isVisible = function() return true end,
		onClick = function(self)
			Program.changeScreenView(NavigationMenu)
		end
	},
	RerollBallPicker = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.DICE,
		textColor = "Default text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, Constants.SCREEN.MARGIN + 36, 13, 14 },
		isVisible = function() return TrackerScreen.canShowBallPicker() end,
		onClick = function(self)
			TrackerScreen.PokeBalls.chosenBall = -1
			Program.redraw(true)
			TrackerScreen.randomlyChooseBall()
		end
	},
	PCHealAutoTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.HEART,
		textColor = "Default text",
		iconColors = { "Default text", "Upper box background", "Upper box background" },
		box = { Constants.SCREEN.WIDTH + 87, 59, 10, 8 },
		isVisible = function() return Battle.isViewingOwn and Options["Track PC Heals"] end,
		toggleState = false,
		onClick = function(self)
			self.toggleState = not self.toggleState
			if self.toggleState then
				-- self.iconColors = { "Default text", "Positive text", "Intermediate text" }
				self.iconColors = { 0xFFF04037, 0xFFFF0000, 0xFFFFFFFF }
			else
				self.iconColors = { "Default text", "Upper box background", "Upper box background" }
			end
			Program.redraw(true)
		end
	},
	PCHealIncrement = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return "+" end,
		textColor = "Positive text",
		box = { Constants.SCREEN.WIDTH + 83, 69, 5, 5 },
		isVisible = function() return Battle.isViewingOwn and Options["Track PC Heals"] end,
		onClick = function(self)
			Tracker.Data.centerHeals = Tracker.Data.centerHeals + 1
			-- Prevent triple digit values (shouldn't go anywhere near this in survival)
			if Tracker.Data.centerHeals > 99 then Tracker.Data.centerHeals = 99 end
			Program.redraw(true)
		end
	},
	PCHealDecrement = {
		type = Constants.ButtonTypes.NO_BORDER,
		getText = function(self) return Constants.BLANKLINE end,
		textColor = "Negative text",
		box = { Constants.SCREEN.WIDTH + 83, 73, 5, 5 },
		isVisible = function() return Battle.isViewingOwn and Options["Track PC Heals"] end,
		onClick = function(self)
			Tracker.Data.centerHeals = Tracker.Data.centerHeals - 1
			-- Prevent negative values
			if Tracker.Data.centerHeals < 0 then Tracker.Data.centerHeals = 0 end
			Program.redraw(true)
		end
	},
	LogViewerQuickAccess = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAGNIFYING_GLASS,
		textColor = "Intermediate text",
		box = { Constants.SCREEN.WIDTH + 84, 64, 10, 10 },
		isVisible = function()
			local okayToShow = Battle.isViewingOwn and Options["Open Book Play Mode"]
			local hasConflict = Options["Track PC Heals"]
			return okayToShow and not hasConflict
		end,
		onClick = function(self)
			-- Default to pulling up the Routes info screen
			LogOverlay.Windower:changeTab(LogTabRoutes)
			LogSearchScreen.resetSearchSortFilter()
			LogOverlay.refreshActiveTabGrid()
			-- If a route is available, show that one specifically
			local mapId = TrackerAPI.getMapId()
			if RouteData.hasAnyEncounters(mapId) then
				LogOverlay.Windower:changeTab(LogTabRouteDetails, 1, 1, mapId)
			end
			Program.redraw(true)
		end
	},
	InvisibleStatsArea = {
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + 103, Constants.SCREEN.MARGIN, 44, 75 },
		isVisible = function() return Options["Open Book Play Mode"] and not Battle.isViewingOwn end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			LogOverlay.Windower:changeTab(LogTabPokemon)
			LogOverlay.Windower:changeTab(LogTabPokemonDetails, 1, 1, pokemon.pokemonID)
			InfoScreen.changeScreenView(InfoScreen.Screens.POKEMON_INFO, pokemon.pokemonID)
		end,
	},
	RouteDetails = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		textColor = "Default text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 57, 96, 23 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 63, 8, 12 },
		isVisible = function() return not Battle.isViewingOwn end,
		onClick = function(self)
			-- Only activate for wild encounter battles
			if not Battle.isWildEncounter then
				return
			end
			if not RouteData.hasRouteEncounterArea(Program.GameData.mapId, Battle.CurrentRoute.encounterArea) then
				return
			end
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, {
				mapId = Program.GameData.mapId,
				encounterArea = Battle.CurrentRoute.encounterArea,
			})
		end,
	},
	TrainerDetails = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.BATTLE_BALLS,
		iconColors = Constants.PixelImages.BATTLE_BALLS.iconColors,
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 57, 96, 23 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 78, 61, 16, 16 },
		isVisible = function() return not Battle.isViewingOwn end,
		onClick = function(self)
			-- Only activate for trainer battles
			if Battle.isWildEncounter then
				return
			end
			local trainerId = TrackerAPI.getOpponentTrainerId()
			if TrainerInfoScreen.buildScreen(trainerId) then
				Program.changeScreenView(TrainerInfoScreen)
			end
		end,
	},
	HealsInBag = {
		-- Invisible clickable button
		type = Constants.ButtonTypes.NO_BORDER,
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN, Constants.SCREEN.MARGIN + 54, 54, 21 },
		isVisible = function() return Battle.isViewingOwn end,
		onClick = function(self)
			HealsInBagScreen.changeTab(HealsInBagScreen.Tabs.All)
			Program.changeScreenView(HealsInBagScreen)
		end
	},
	MovesHistory = {
		-- Invisible clickable button
		type = Constants.ButtonTypes.NO_BORDER,
		textColor = "Header text", -- set later after highlight color is calculated
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 81, 75, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 81, 75, 10 },
		boxColors = { "Header text", "Main background" },
		isVisible = function()
			local pokemon = Tracker.getViewedPokemon() or {}
			return PokemonData.isValid(pokemon.pokemonID)
		end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			local hasMoves = MoveHistoryScreen.buildOutHistory(pokemon.pokemonID, pokemon.level)
			if hasMoves then
				Program.changeScreenView(MoveHistoryScreen)
			end
		end,
	},
	CatchRates = {
		-- Invisible clickable button
		type = Constants.ButtonTypes.NO_BORDER,
		textColor = "Header text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 77, 81, 50, 10 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 77, 81, 50, 10 },
		boxColors = { "Header text", "Main background" },
		isVisible = function()
			return Options["Show Poke Ball catch rate"] and not Battle.isViewingOwn and Battle.isWildEncounter
		end,
		onClick = function(self)
			local pokemon = TrackerAPI.getEnemyPokemon()
			if CatchRatesScreen.buildScreen(pokemon) then
				CatchRatesScreen.previousScreen = TrackerScreen
				Program.changeScreenView(CatchRatesScreen)
			end
		end,
	},
	NotepadTracking = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.NOTEPAD,
		getText = function(self) return string.format("(%s)", Resources.TrackerScreen.LeaveANote) end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 11, 11 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.NOTES and not Battle.isViewingOwn end,
		onClick = function(self)
			local pokemon = Tracker.getViewedPokemon() or {}
			if not PokemonData.isValid(pokemon.pokemonID) then
				return
			end
			TrackerScreen.openNotePadWindow(pokemon.pokemonID)
		end
	},
	LastAttackSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SWORD_ATTACK,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		iconColors = { "Lower box text" },
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 140, 13, 13 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.LAST_ATTACK end,
		onClick = function(self)
			-- Eventually clicking this will show a Move History screen
		end
	},
	BattleDetailsSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SPARKLES,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 140, 12, 12 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.BATTLE_DETAILS end,
		onClick = function(self)
			BattleDetailsScreen.updateData(true)
			Program.changeScreenView(BattleDetailsScreen)
		end,
	},
	RouteSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.MAP_PINDROP,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 8, 12 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.ROUTE_INFO end,
		onClick = function(self)
			local routeInfo = {
				mapId = Program.GameData.mapId,
				encounterArea = Battle.CurrentRoute.encounterArea,
			}
			InfoScreen.changeScreenView(InfoScreen.Screens.ROUTE_INFO, routeInfo)
		end
	},
	PedometerStepText = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.CLOCK,
		getText = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			local formattedStepCount = Utils.formatNumberWithCommas(stepCount)
			return string.format("%s: %s", Resources.TrackerScreen.PedometerSteps, formattedStepCount)
		end,
		textColor = "Lower box text",
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 3, 141, 10, 10 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		updateSelf = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			if stepCount > 999999 then -- 1,000,000 is the arbitrary cutoff
				stepCount = 999999
			end
			if Program.Pedometer.goalSteps ~= 0 and stepCount >= Program.Pedometer.goalSteps then
				self.textColor = "Positive text"
			else
				self.textColor = "Lower box text"
			end
		end,
	},
	PedometerGoal = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self) return Resources.TrackerScreen.PedometerGoal end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, 140, 23, 11 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 81, 140, 23, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		updateSelf = function(self)
			if Program.Pedometer.goalSteps == 0 then
				self.textColor = "Lower box text"
			else
				self.textColor = "Intermediate text"
			end
		end,
		onClick = function(self) TrackerScreen.openEditStepGoalWindow() end
	},
	PedometerReset = {
		type = Constants.ButtonTypes.FULL_BORDER,
		getText = function(self)
			local stepCount = Program.Pedometer:getCurrentStepcount()
			if stepCount <= 0 then
				return Resources.TrackerScreen.PedometerTotal
			else
				return Resources.TrackerScreen.PedometerReset
			end
		end,
		textColor = "Lower box text",
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, 140, 28, 11 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 108, 140, 28, 11 },
		boxColors = { "Lower box border", "Lower box background" },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.PEDOMETER end,
		onClick = function(self)
			if self:getText() == Resources.TrackerScreen.PedometerReset then
				Program.Pedometer.lastResetCount = Program.Pedometer.totalSteps
			elseif self:getText() == Resources.TrackerScreen.PedometerTotal then
				Program.Pedometer.lastResetCount = 0
			end
			Program.redraw(true)
		end
	},
	TrainerSummary = {
		type = Constants.ButtonTypes.PIXELIMAGE,
		image = Constants.PixelImages.SWORD_ATTACK,
		getText = function(self) return self.updatedText or "" end,
		textColor = "Lower box text",
		iconColors = { "Positive text" },
		clickableArea = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 1, 140, 138, 12 },
		box = { Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 4, 140, 13, 13 },
		isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.TRAINERS end,
		onClick = function(self)
			if TrainersOnRouteScreen.buildScreen(TrackerAPI.getMapId()) then
				Program.changeScreenView(TrainersOnRouteScreen)
			end
		end
	},
}

-- This is also a priority list, lower the number has more priority of showing up before the others; must be sequential
TrackerScreen.CarouselTypes = {
	BADGES = 1, -- Outside of battle
	TRAINERS = 2, -- Immediately after a battle
	LAST_ATTACK = 3, -- During battle, only between turns
	ROUTE_INFO = 4, -- During battle, only if encounter is a wild pokemon
	NOTES = 5, -- During battle
	BATTLE_DETAILS = 6, -- During battle
	PEDOMETER = 7, -- Outside of battle
}

TrackerScreen.carouselIndex = 1
TrackerScreen.tipMessageIndex = 0
TrackerScreen.CarouselItems = {}

TrackerScreen.PokeBalls = {
	chosenBall = -1,
	ColorList = { Drawing.Colors.BLACK, 0xFFF04037, Drawing.Colors.WHITE, }, -- Colors used to draw all Pokeballs
	ColorListGray = { Drawing.Colors.BLACK, Utils.calcGrayscale(0xFFF04037, 0.6), Drawing.Colors.WHITE, },
	ColorListFainted = { Drawing.Colors.BLACK, 0x22F04037, 0x44FFFFFF, },
	ColorListMasterBall = { Drawing.Colors.BLACK, 0xFFA040B8, Drawing.Colors.WHITE, 0xFFF86088, 0xFFCB5C95 },
	getLabel = function(ballIndex)
		if ballIndex == 1 then
			return Resources.TrackerScreen.RandomBallLeft
		elseif ballIndex == 2 then
			return Resources.TrackerScreen.RandomBallMiddle
		elseif ballIndex == 3 then
			return Resources.TrackerScreen.RandomBallRight
		else
			return Constants.BLANKLINE
		end
	end,
	Left = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 17,
		y = Constants.SCREEN.MARGIN + 18,
	},
	Middle = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 40,
		y = Constants.SCREEN.MARGIN + 26,
	},
	Right = {
		x = Constants.SCREEN.WIDTH + Constants.SCREEN.MARGIN + 63,
		y = Constants.SCREEN.MARGIN + 18,
	},
}

---Creates stat-marking and badge buttons (needs GameSettings). Called via FileManager initialize.
function TrackerScreenButtons.initialize()
	local heightOffset = 9
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES) do
		TrackerScreen.Buttons[statKey] = {
			type = Constants.ButtonTypes.STAT_STAGE,
			getText = function(self) return Constants.STAT_STATES[self.statState].text end,
			textColor = "Default text",
			box = { Constants.SCREEN.WIDTH + 129, heightOffset, 8, 8 },
			boxColors = { "Upper box border", "Upper box background" },
			statStage = statKey,
			statState = 0,
			isVisible = function() return Battle.inActiveBattle() and not Battle.isViewingOwn and not PokemonData.canShowUnknownStats() end,
			onClick = function(self)
				self.statState = ((self.statState + 1) % 4)
				self.textColor = Constants.STAT_STATES[self.statState].textColor

				local pokemon = Battle.getViewedPokemon(false)
				if pokemon ~= nil then
					Tracker.TrackStatMarking(pokemon.pokemonID, self.statStage, self.statState)
				end
				Program.redraw(true)
			end
		}
		heightOffset = heightOffset + 10
	end

	local badgeWidth = 16
	local badgePrefix = GameSettings.badgePrefix or (Constants.Badges[GameSettings.game] or {}).Prefix or "FRLG"
	local badgeInfoTable = { Prefix = badgePrefix, IconOffsets = GameSettings.badgeXOffsets or { 0, 0, 0, 0, 0, 0, 0, 0 } }
	local kerningOffsets = badgeInfoTable.IconOffsets or {}
	for index = 1, 8, 1 do
		local badgeName = "badge" .. index
		local xOffset = Constants.SCREEN.WIDTH + 7 + ((index - 1) * (badgeWidth + 1)) + (kerningOffsets[index] or 0)

		TrackerScreen.Buttons[badgeName] = {
			type = Constants.ButtonTypes.IMAGE,
			image = FileManager.buildImagePath(FileManager.Folders.Badges, badgePrefix .. "_" .. badgeName .. "_OFF", FileManager.Extensions.BADGE),
			box = { xOffset, 138, badgeWidth, badgeWidth },
			badgeIndex = index,
			badgeState = 0,
			isVisible = function() return TrackerScreen.carouselIndex == TrackerScreen.CarouselTypes.BADGES end,
			updateState = function(self, state)
				if self.badgeState ~= state then
					self.badgeState = state
					local badgeOff = Utils.inlineIf(self.badgeState == 0, "_OFF", "")
					local name = badgePrefix .. "_badge" .. self.badgeIndex .. badgeOff
					self.image = FileManager.buildImagePath(FileManager.Folders.Badges, name, FileManager.Extensions.BADGE)
				end
			end
		}
	end
end

