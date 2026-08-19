Program = {
	currentScreen = {},
	currentOverlay = nil, -- set to nil when not in use
	updateRequired = false,
	inStartMenu = false,
	inCatchingTutorial = false,
	hasCheckedGameSettings = false,
	hasCompletedTutorial = false,
	isViewingStarter = false,
	activeFormId = 0,
	lastActiveTimestamp = 0,
	overridePackAnimationDraw = false,
	clientFpsMultiplier = 1,
	Frames = {
		waitToDraw = 30, -- counts down
		highAccuracyUpdate = 10, -- counts down
		lowAccuracyUpdate = 30, -- counts down
		three_sec_update = 180, -- counts down
		saveData = 3600, -- counts down
		carouselActive = 0, -- counts up
		Others = {}, -- list of other frame counter objects
	},
	DebugDrawing = {},
	Addresses = {
		sizeofPokemonStruct = 44,
	},
	Values = {},
}

Program.GameData = {
	mapId = 0, -- was previously Battle.CurrentRoute.mapId
	wildBattles = -999, -- used to track differences in GAME STATS
	trainerBattles = -999, -- used to track differences in GAME STATS
	friendshipRequired = 220,
	PlayerTeam = {}, -- [SlotOnTeam:number] = Pokemon:table(DefaultPokemon)
	EnemyTeam = {}, -- [SlotOnTeam:number] = Pokemon:table(DefaultPokemon)
	-- All items currently found in the player's bag
	Items = {
		healingTotal = 0, -- A calculation of total HP heals
		healingPercentage = 0, -- A calculation of percentage heals
		-- Each of the below: map of [itemId] -> quanity of item
		PokeBalls = {},
		HPHeals = {},
		PPHeals = {},
		StatusHeals = {},
		EvoStones = {},
		Other = {},
	},
}

Program.GameTimer = {
	timeLastChecked = 0, -- Number of seconds
	showPauseTipUntil = 0, -- Displays "how to pause timer" tip until this time occurs; number of seconds
	hasStarted = false, -- Used to determine if the game has started (not in Title menus)
	isPaused = false, -- Used to manually pause the timer
	readyToDraw = false, -- Anytime the timer changes, it needs to be redrawn
	textColor = 0xFFFFFFFF,
	pauseColor = 0xFFFFFF00,
	notStartedColor = 0xFFAAAAAA,
	boxColor = 0x78000000,
	margin = 0,
	padding = 2,
	location = "LowerRight",
	box = {
		x = Constants.SCREEN.WIDTH,
		y = Constants.SCREEN.HEIGHT,
		width = 20,
		height = Constants.Font.SIZE,
	},
	getText = function(self)
		return Utils.formatTime(Tracker.Data.playtime or 0)
	end,
	initialize = function(self)
		self.hasStarted = false
		self.location = Options["Game timer location"] or "LowerRight"
		self.box.height = Constants.Font.SIZE - 4 + (2 * self.padding)
		self:update()
	end,
	start = function(self)
		self.hasStarted = true
		self.isPaused = false
		self.timeLastChecked = os.time()
		self.showPauseTipUntil = self.timeLastChecked
	end,
	pause = function(self)
		if not self.hasStarted then return end
		self.isPaused = true
	end,
	unpause = function(self)
		if self.isPaused then
			self.timeLastChecked = os.time()
		end
		self.isPaused = false
	end,
	update = function(self)
		local currTime = os.time()
		local prevTime = self.timeLastChecked
		self.timeLastChecked = currTime
		if self.hasStarted and not self.isPaused then
			local timeDelta = math.floor(os.difftime(currTime, prevTime))
			-- If emulator itself is paused-unpaused, don't add all that "paused time"
			if timeDelta > 0 then
				Tracker.Data.playtime = Tracker.Data.playtime + 1
			end
			self.readyToDraw = (timeDelta ~= 0)
		end

		self.box.width = Utils.calcWordPixelLength(self:getText() or "") - 1 + (2 * self.padding)
		self:updateLocationCoords()
	end,
	updateLocationCoords = function(self)
		if self.location == "UpperLeft" or self.location == "LowerLeft" then
			self.box.x = math.max(self.margin, 0)
		elseif self.location == "UpperCenter" or self.location == "LowerCenter" then
			self.box.x = math.floor(math.max((Constants.SCREEN.WIDTH - self.box.width) / 2 - 1, 0))
		else -- Lower-X
			self.box.x = math.max(Constants.SCREEN.WIDTH - self.box.width - self.margin - 1, 0)
		end
		if self.location == "UpperLeft" or self.location == "UpperCenter" or self.location == "UpperRight" then
			self.box.y = math.max(self.margin, 0)
		else -- Lower-Y
			self.box.y = math.max(Constants.SCREEN.HEIGHT - self.box.height - self.margin - 1, 0)
		end
	end,
	reset = function(self)
		Tracker.Data.playtime = 0
		self.hasStarted = false
		self.readyToDraw = false
		self:unpause()
	end,
	checkInput = function(self, xmouse, ymouse)
		-- Don't pause if either game screen overlay is covering the screen
		if not Options["Display play time"] or Program.isScreenOverlayOpen() then return end
		local clicked = Input.isMouseInArea(xmouse, ymouse, self.box.x, self.box.y, self.box.width, self.box.height)
		if clicked then
			if self.isPaused then
				self:unpause()
			else
				self:pause()
			end
			self.readyToDraw = true
		end
	end,
	draw = function(self)
		self.readyToDraw = false
		if Options["Display play time"] then
			local x, y, width, height = self.box.x, self.box.y, self.box.width, self.box.height
			local formattedTime = self:getText()
			local color = self.textColor
			if not self.hasStarted then
				color = self.notStartedColor
			elseif self.isPaused then
				color = self.pauseColor
			end
			gui.drawRectangle(x, y, width, height, self.boxColor, self.boxColor)
			Drawing.drawText(x, y - 1, formattedTime, color)

			if self.showPauseTipUntil > self.timeLastChecked then
				width = Utils.calcWordPixelLength(Resources.ExtrasScreen.TimerPauseTip) - 1 + (2 * self.padding)
				x = math.max(self.box.x + self.box.width - width - self.margin, 0)
				y = math.max(self.box.y - self.box.height - self.margin - 2, self.box.height + self.margin + 2)
				gui.drawRectangle(x, y, width, height, self.boxColor, self.boxColor)
				Drawing.drawText(x, y - 1, Resources.ExtrasScreen.TimerPauseTip, self.textColor)
			end
		end
	end,
}

Program.ActiveRepel = {
	inUse = false,
	stepCount = 0,
	duration = 100,
	shouldDisplay = function(self)
		local enabledAndAllowed = Options["Display repel usage"] and Program.ActiveRepel.inUse and Program.isValidMapLocation()
		local hasConflict = Battle.inActiveBattle() or Program.inStartMenu or Program.isScreenOverlayOpen() or GameOverScreen.status ~= GameOverScreen.Statuses.STILL_PLAYING
		local inHallOfFame = Program.GameData.mapId ~= nil and RouteData.Locations.IsInHallOfFame[Program.GameData.mapId]
		return enabledAndAllowed and not hasConflict and not inHallOfFame
	end,
	draw = function(self)
		if self:shouldDisplay() then
			Drawing.drawRepelUsage()
		end
	end,
}

Program.Pedometer = {
	totalSteps = 0, -- updated from GAME_STATS
	lastResetCount = 0, -- num steps since last "reset", for counting new steps
	goalSteps = 0, -- num steps that is set by the user as a milestone goal to reach, 0 to disable
	initialize = function(self)
		self.totalSteps = 0
		self.lastResetCount = 0
		self.goalSteps = 0
	end,
	getCurrentStepcount = function(self)
		return math.max(self.totalSteps - self.lastResetCount, 0)
	end,
	isInUse = function(self)
		local enabledAndAllowed = Options["Display pedometer"] and Program.isValidMapLocation()
		local hasConflict = Battle.inActiveBattle() or GameOverScreen.status ~= GameOverScreen.Statuses.STILL_PLAYING
		return enabledAndAllowed and not hasConflict
	end,
}

Program.AutoSaver = {
	knownSaveCount = 0,
	updateSaveCount = function(self) -- returns true if the savecount has been updated
		local currentSaveCount = Utils.getGameStat(Constants.GAME_STATS.SAVED_GAME) or 0
		local saveSuccessCountdown = Memory.readbyte(GameSettings.sSaveDialogDelay) or 0
		-- Starts at 60 on success, then immediately decrements to 59 before checking if the save menu should close
		if saveSuccessCountdown == 60 and currentSaveCount > self.knownSaveCount and currentSaveCount < 99999 then
			self.knownSaveCount = currentSaveCount
			return true
		end
		return false
	end,
	checkForNextSave = function(self)
		if self:updateSaveCount() then
			-- Force Tracker Data to also save
			Program.Frames.saveData = 0

			-- Flush saveRAM only for Bizhawk
			if Main.IsOnBizhawk() then
				client.saveram()
			end
		end
	end
}

function Program.initialize()
	-- If an update is available, offer that up first before going to the Tracker StartupScreen
	if Main.Version.showUpdate then
		Program.currentScreen = UpdateScreen
	else
		Program.currentScreen = StartupScreen
	end
	Program.currentOverlay = nil

	if Main.IsOnBizhawk() then
		Program.clientFpsMultiplier = math.max(client.get_approx_framerate() / 60, 1) -- minimum of 1
	else
		Program.clientFpsMultiplier = 1
	end

	-- Reset variables when a new game is loaded
	Program.updateRequired = false
	Program.inStartMenu = false
	Program.inCatchingTutorial = false
	Program.hasCheckedGameSettings = false
	Program.hasCompletedTutorial = false
	Program.isViewingStarter = false
	Program.lastActiveTimestamp = os.time()
	Program.overridePackAnimationDraw = false
	Program.Frames.waitToDraw = 1
	Program.Frames.highAccuracyUpdate = 0
	Program.Frames.lowAccuracyUpdate = 0
	Program.Frames.three_sec_update = 0
	Program.Frames.saveData = 3600
	Program.Frames.carouselActive = 0
	Program.Frames.Others = {}

	Program.GameData.PlayerTeam = {}
	Program.GameData.EnemyTeam = {}

	Program.Addresses.sizeofPokemonStruct = Gen1PokemonReader.PartyStructSize

	Program.Pedometer:initialize()
	Program.GameTimer:initialize()
	Program.AutoSaver:updateSaveCount()

	Program.addFrameCounter("Tracker:AutoSave.loadFromFile", 1, Tracker.AutoSave.loadFromFile, 1, true)
	Program.addFrameCounter("Program:DelayedStartup", 60, Program.delayedStartup, 1, true)
end

function Program.delayedStartup()
	Options.alertImportantChanges()
end

function Program.mainLoop()
	if Main.loadNextSeed and not Main.IsOnBizhawk() then -- required escape for mGBA
		Main.LoadNextRom()
		return
	end
	Input.checkForInput()
	Program.update()
	Network.update()
	Battle.update()
	CustomCode.afterEachFrame()
	Program.redraw(false)
	Program.stepFrames() -- TODO: Really want a better way to handle this
	if Program.updateRequired then
		Program.updateRequired = false
	end
end

-- 'forced' = true will force a draw, skipping the normal frame wait time
function Program.redraw(forced)
	local shouldDraw = (forced == true) or (Program.Frames.waitToDraw <= 0) or Program.GameTimer.readyToDraw

	if not shouldDraw then
		if Program.Frames.waitToDraw > 0 then
			Program.Frames.waitToDraw = Program.Frames.waitToDraw - 1
		end
		return
	end

	-- Only redraw the screen every half second (60 frames/sec)
	Program.Frames.waitToDraw = 30

	if Main.IsOnBizhawk() then
		Program.ActiveRepel:draw()
		Program.GameTimer:draw()

		if Program.currentOverlay and type(Program.currentOverlay.drawScreen) == "function" then
			Program.currentOverlay.drawScreen()
		end
		if Program.currentScreen and type(Program.currentScreen.drawScreen) == "function" then
			Program.currentScreen.drawScreen()
		end

		if TeamViewArea.isDisplayed() then
			TeamViewArea.drawScreen()
		end
	elseif MGBA and MGBA.ScreenUtils then
		MGBA.ScreenUtils.updateTextBuffers()
	end

	local _drawAnimations = function()
		-- Draw any screen-specific animations if they are defined
		if Program.currentScreen and type(Program.currentScreen.drawAnimations) == "function" then
			Program.currentScreen.drawAnimations()
		end
	end

	if Program.overridePackAnimationDraw then
		_drawAnimations()
		CustomCode.afterRedraw()
	else
		-- Default to drawing on top of any drawings that extensions do
		CustomCode.afterRedraw()
		_drawAnimations()
	end

	for _, debugDrawFunc in pairs(Program.DebugDrawing) do
		if type(debugDrawFunc) == "function" then
			debugDrawFunc()
		end
	end

	SpriteData.cleanupActiveIcons()
end

function Program.changeScreenView(screen)
	Program.lastActiveTimestamp = os.time()
	if screen and type(screen.refreshButtons) == "function" then
		screen:refreshButtons()
	end
	Program.currentScreen = screen
	Program.redraw(true)
end

---Opens an overlay screen, which draws over the actual game screen itself
---@param screen table
---@param redraw? boolean Optional, if true will redraw the screen
function Program.openOverlayScreen(screen, redraw)
	Program.lastActiveTimestamp = os.time()
	-- Close any open screen if different
	if Program.currentOverlay and Program.currentOverlay ~= screen then
		Program.closeScreenOverlay()
	end
	-- Change to the screen
	Program.currentOverlay = screen
	if screen and type(screen.open) == "function" then
		screen:open()
	end
	if redraw then
		Program.redraw(true)
	end
end

---Returns true if there is a screen overlay open; false otherwise
---@return boolean
function Program.isScreenOverlayOpen()
	return Program.currentOverlay ~= nil
end

---Closes/removes any open screen overlay. If that overlay screen has a `close` function, it calls that first.
function Program.closeScreenOverlay()
	if Program.currentOverlay and type(Program.currentOverlay.close) == "function" then
		Program.currentOverlay:close()
	end
	Program.currentOverlay = nil
end

-- Deprecated
function Program.destroyActiveForm()
	ExternalUI.BizForms.destroyForm()
end

function Program.update()
	-- Be careful adding too many things to this 10 frame update
	if Program.Frames.highAccuracyUpdate == 0 or Program.updateRequired then
		if Main.IsOnBizhawk() then
			Program.clientFpsMultiplier = math.max(client.get_approx_framerate() / 60, 1) -- minimum of 1
		end

		Program.updateMapLocation() -- trying this here to solve many future problems
		Program.snapshotRodItem()

		if not Program.GameTimer.hasStarted and Program.isValidMapLocation() then
			Program.GameTimer:start()
		end
		Program.GameTimer:update()
		if not CrashRecoveryScreen.started and Program.isValidMapLocation() then
			CrashRecoveryScreen.startSavingBackups()
		end

		-- If the lead Pokemon changes, then update the animated Pokemon picture box
		if Options["Animated Pokemon popout"] and Program.isValidMapLocation() then
			local leadPokemon = Tracker.getPokemon(Battle.Combatants.LeftOwn, true) or {}
			if PokemonData.isValid(leadPokemon.pokemonID) then
				if leadPokemon.pokemonID ~= Drawing.AnimatedPokemon.pokemonID then
					Drawing.AnimatedPokemon:setPokemon(leadPokemon.pokemonID)
				elseif Drawing.AnimatedPokemon.requiresRelocating then
					Drawing.AnimatedPokemon:relocatePokemon()
				end
			end
		end

		if SetupScreen.inProcessOfBinding() then
			local inputsPressed = SetupScreen.checkCurrentJoypadInput()
			if #inputsPressed > 0 then
				Program.redraw(true)
			end
		end
	end

	-- Don't bother reading game data before a game even begins
	if not Program.isValidMapLocation() then
		return
	end

	-- Get any "new" information from game memory for player's pokemon team every half second (60 frames/sec)
	if Program.Frames.lowAccuracyUpdate == 0 or Program.updateRequired then
		Program.updateCatchingTutorial()

		if not Program.inCatchingTutorial and not Program.isInEvolutionScene() then
			Program.updatePokemonTeams()
			TeamViewArea.buildOutPartyScreen()

			if Program.currentScreen == StartupScreen then
				-- If the game hasn't started yet, show the start-up screen instead of the main Tracker screen
				Program.currentScreen = TrackerScreen
			elseif Options["Show starter ball info"] and RouteData.Locations.IsInLab[TrackerAPI.getMapId()] then
				Program.checkForStarterSelection()
			end

			if Network.isConnected() then
				EventHandler.runEventFunc("CMD_BallQueue", "TryDisplayMessage")
			end

			if not Program.hasCheckedGameSettings then
				Program.hasCheckedGameSettings = true
				if Options["Override Button Mode to LR"] then
					Program.changeGameSettingForLR()
				end
			end

			-- Check if summary screen has being shown
			if not Tracker.Data.hasCheckedSummary then
				if GameSettings.sMonSummaryScreen and Memory.readbyte(GameSettings.sMonSummaryScreen) ~= 0 then
					Tracker.Data.hasCheckedSummary = true
				end
			end

			-- Check if a Pokemon in the player's party is learning a move, if so track it
			local learnedInfoTable = Program.getLearnedMoveInfoTable()
			if learnedInfoTable.pokemonID ~= nil then
				Tracker.TrackMove(learnedInfoTable.pokemonID, learnedInfoTable.moveId, learnedInfoTable.level)
			end

			if Options["Display repel usage"] and not Battle.inActiveBattle() then
				-- Check if the player is in the start menu (for hiding the repel usage icon)
				Program.inStartMenu = Program.isInStartMenu()
				-- Check for active repel and steps remaining
				if not Program.inStartMenu then
					Program.updateRepelSteps()
				end
			end

			-- Update step count only if the option is enabled
			if Program.Pedometer:isInUse() and GameSettings.gameStatsOffset then
				Program.Pedometer.totalSteps = Utils.getGameStat(Constants.GAME_STATS.STEPS)
			end

			Program.AutoSaver:checkForNextSave()
			TimeMachineScreen.checkCreatingRestorePoint()
		end

		if Input.joypadUsedRecently then
			Program.lastActiveTimestamp = os.time()
			SpriteData.checkForIdleSleeping(0)
		end
	end

	-- Only update "Heals in Bag", Evolution Stones, "PC Heals", and "Badge Data" info every 3 seconds (3 seconds * 60 frames/sec)
	if Program.Frames.three_sec_update == 0 or Program.updateRequired then
		Program.updateBagItems()
		Program.updatePCHeals()
		Program.updateBadgesObtained()
		CrashRecoveryScreen.trySaveBackup()

		if not Input.joypadUsedRecently then
			local secondsSinceLastActive = math.max(os.time() - Program.lastActiveTimestamp, 0)
			SpriteData.checkForIdleSleeping(secondsSinceLastActive)
		else
			-- Reset the joypad button tracking, checking only once every 3 seconds if active
			Input.joypadUsedRecently = false
		end
	end

	-- Only save tracker data every 1 minute (60 seconds * 60 frames/sec) and after every battle (set elsewhere)
	if Program.Frames.saveData == 0 then
		Tracker.AutoSave.saveToFile()
	end

	if Program.Frames.lowAccuracyUpdate == 0 or Program.updateRequired then
		CustomCode.afterProgramDataUpdate()
	end
end

---Signals Program, and Battle, to read in the game data again (useful for when loading a Tracker save state)
function Program.updateDataNextFrame()
	Program.updateRequired = true
end

function Program.stepFrames()
	Program.Frames.highAccuracyUpdate = (Program.Frames.highAccuracyUpdate - 1) % 10
	Program.Frames.lowAccuracyUpdate = (Program.Frames.lowAccuracyUpdate - 1) % 30
	Program.Frames.three_sec_update = (Program.Frames.three_sec_update - 1) % 180
	Program.Frames.saveData = (Program.Frames.saveData - 1) % 3600
	Program.Frames.carouselActive = Program.Frames.carouselActive + 1

	local toRemove = {}
	for label, framecounter in pairs(Program.Frames.Others or {}) do
		if type(framecounter.step) == "function" then
			framecounter:step()
		end
		if framecounter.finished then
			table.insert(toRemove, label)
		end
	end
	for _, label in ipairs(toRemove) do
		Program.removeFrameCounter(label)
	end

	SpriteData.updateActiveIcons()
end

--- Creates a frame counter that counts down N frames (or emulation steps), and repeats indefinitely.
--- @param label string The name key for this counter, referenced by Program.Frames.Other[label]
--- @param frames integer The number of frames, N, to count down. When it reaches 0, it restarts.
--- @param callFunc function? [Optional] Function to call each time the counter reaches 0, up to 'numExecutions' times.
--- @param numExecutions number? [Optional] If provided, will execute the 'callFunc' a total of that many times; otherwise no limit (default:unlimited)
--- @param scaleWithSpeedup boolean? [Optional] If true, syncs the counter to real time instead of the client's frame rate, ignoring speedup (default:false)
--- @return table? FrameCounter Returns the created frame counter
function Program.addFrameCounter(label, frames, callFunc, numExecutions, scaleWithSpeedup)
	if label == nil or (frames or 0) <= 0 then return nil end
	Program.Frames.Others[label] = {
		framesElapsed = 0.0,
		maxFrames = frames,
		callFunc = callFunc,
		timesExecuted = 0,
		maxExecutions = numExecutions,
		finished = false,
		paused = false,
		pause = function(self) self.paused = true end,
		unpause = function(self) self.paused = false end,
		step = function(self)
			if self.paused then return end
			-- Sync with client frame rate (turbo/unthrottle)
			local delta = scaleWithSpeedup and (1.0 / Program.clientFpsMultiplier) or 1
			self.framesElapsed = self.framesElapsed + delta
			if self.framesElapsed >= self.maxFrames then
				self.framesElapsed = 0.0
				if type(self.callFunc) == "function" then
					if self.maxExecutions then
						self.timesExecuted = self.timesExecuted + 1
						if self.timesExecuted >= self.maxExecutions then
							self.finished = true
						end
					end
					pcall(self.callFunc)
				end
			end
		end,
	}
	return Program.Frames.Others[label]
end

function Program.removeFrameCounter(label)
	if label == nil then return end
	Program.Frames.Others[label] = nil
end

---Adds a drawing function for testing that will be called every time the screen is redrawn.
---@param label string
---@param drawFunc function
function Program.addDebugDrawing(label, drawFunc)
	if not label or not drawFunc or not Main.IsOnBizhawk() then return end
	Program.DebugDrawing[label] = drawFunc
end

---Removes a previously added debug drawing function.
---@param label string
function Program.removeDebugDrawing(label)
	if not label or not Main.IsOnBizhawk() then return end
	Program.DebugDrawing[label] = nil
end

function Program.checkForStarterSelection()
	Gen1Runtime.checkForStarterSelection()
end
function Program.getPlayerMapTile()
	return Gen1Runtime.getPlayerTilePosition()
end
function Program.getPlayerTilePosition()
	return Gen1Runtime.getPlayerTilePosition()
end
function Program.readFlashLevel()
	return Gen1Runtime.readFlashLevel()
end
function Program.updateRepelSteps()
	Gen1Runtime.updateRepelSteps()
end
function Program.updatePokemonTeams()
	Gen1Runtime.updatePokemonTeams()
end
function Program.readNewPokemon(startAddress, personality)
	return Gen1Runtime.readPartyPokemon(startAddress)
end
function Program.readTrainerGameData(trainerId)
	return Gen1TrainerData.readTrainer(trainerId)
end
function Program.getTeamCounts()
	local numAlive, total = 0, 0
	for i = 1, 6, 1 do
		local pokemon = Tracker.getPokemon(i, false) or {}
		if PokemonData.isValid(pokemon.pokemonID) then
			total = total + 1
			if (pokemon.curHP or 0) > 0 then
				numAlive = numAlive + 1
			end
		end
	end

	return numAlive, total
end

-- Returns two exp values that describe the amount of experience points needed to reach the next level.
-- currentExp: A value between 0 and 'totalExp'
-- totalExp: The amount of exp needed to reach the next level
function Program.getNextLevelExp(pokemonID, level, experience)
	if not PokemonData.isValid(pokemonID) or not level or level >= 100 or not experience then
		return 0, 100
	end
	local internal = PokemonData.Pokemon[pokemonID] or {}
	local atLevel = Gen1DataAdapter.expForLevel(internal.growthRate, level)
	local atNextLevel = Gen1DataAdapter.expForLevel(internal.growthRate, level + 1)
	return math.max(0, math.min(experience - atLevel, atNextLevel - atLevel)), math.max(1, atNextLevel - atLevel)
end
function Program.updatePCHeals()
	Gen1Runtime.updatePCHeals()
end
function Program.readBadgeBits()
	return Gen1Runtime.readBadgeBits()
end
function Program.updateBadgesObtained()
	-- Don't bother checking badge data if in the pre-game intro screen (where old data exists)
	if not Program.isValidMapLocation() then
		return 0
	end

	local badgeBits = Program.readBadgeBits()
	local newBadgeObtained = 0
	for index = 1, 8, 1 do
		local badgeName = "badge" .. index
		local badgeButton = TrackerScreen.Buttons[badgeName]
		local badgeState = Utils.getbits(badgeBits, index - 1, 1)
		if badgeButton then
			if badgeButton.badgeState ~= badgeState then
				newBadgeObtained = index
			end
			badgeButton:updateState(badgeState)
		end
	end
	return newBadgeObtained
end

function Program.snapshotRodItem()
	Gen1Runtime.snapshotRodItem()
end

function Program.getStarterChoice()
	return Gen1Runtime.getStarterChoice()
end

function Program.updateMapLocation()
	Gen1Runtime.updateMapLocation()
end
function Program.isValidMapLocation()
	return Gen1Runtime.isValidMapLocation()
end
function Program.HandleExit()
	if not Main.IsOnBizhawk() then
		return
	end

	Drawing.clearImageCache()
	Drawing.clearGUI()
	client.SetGameExtraPadding(0, 0, 0, 0)
	forms.destroyall()

	Main.ExitSafely(false)
end

-- Returns focus back to Bizhawk, using the name of the rom as the name of the Bizhawk window
function Program.focusBizhawkWindow()
	if not Main.IsOnBizhawk() then return end
	local bizhawkWindowName = GameSettings.getRomName()
	if not Utils.isNilOrEmpty(bizhawkWindowName) then
		local command = string.format("AppActivate(%s)", bizhawkWindowName)
		FileManager.tryOsExecute(command)
	end
end

function Program.getLearnedMoveInfoTable()
	return Gen1Runtime.getLearnedMoveInfoTable()
end

function Program.getPokemonTypes(isOwn, isLeft)
	return Gen1Runtime.getPokemonTypes(isOwn)
end
function Program.updateCatchingTutorial()
	Gen1Runtime.updateCatchingTutorial()
end
function Program.isInEvolutionScene()
	return Gen1Runtime.isInEvolutionScene()
end
function Program.isInStartMenu()
	return Gen1Runtime.isInStartMenu()
end
function Program.changeGameSettingForLR(forced)
	Gen1Runtime.changeGameSettingForLR()
end
function Program.validPokemonData(pokemonData)
	if pokemonData == nil then return false end

	-- If the Pokemon exists, but it's ID is invalid
	if not PokemonData.isValid(pokemonData.pokemonID) and pokemonData.pokemonID ~= 0 then -- 0 = blank pokemon id
		return false
	end

	-- If the Pokemon is holding an item, and that item is invalid
	if pokemonData.heldItem ~= nil and (pokemonData.heldItem < 0 or pokemonData.heldItem > MiscData.getTotalItems()) then
		return false
	end

	-- For each of the Pokemon's moves that isn't blank, is that move real
	for _, move in pairs(pokemonData.moves) do
		if not MoveData.isValid(move.id) and move.id ~= 0 then -- 0 = blank move id
			return false
		end
	end

	return true
end

-- Gets the extra pixels for screen rounding
function Program.getExtras()
	return Gen1Runtime.getExtras()
end
function Program.isInSafariZone(saveBlock1Addr)
	return Gen1Runtime.isInSafariZone()
end
function Program.hasDefeatedTrainer(trainerId, saveBlock1Addr)
	return Gen1TrainerData.hasDefeatedTrainer(trainerId)
end
function Program.getDefeatedTrainersByLocation(mapId, saveBlock1Addr)
	return Gen1TrainerData.getDefeatedTrainersByLocation(mapId)
end
function Program.getDefeatedTrainersByCombinedArea(mapIdList, saveBlock1Addr)
	return Gen1TrainerData.getDefeatedTrainersByCombinedArea(mapIdList)
end
function Program.getMoveIdFromTMHMNumber(tmhmNumber, isHM)
	return Gen1Runtime.getMoveIdFromTMHMNumber(tmhmNumber, isHM)
end
function Program.updateBagItems()
	Gen1Runtime.updateBagItems()
end
function Program.recalcLeadPokemonHealingInfo()
	if not Battle.isViewingOwn then
		return
	end
	local leadPokemon = Battle.getViewedPokemon(true)
	local maxHP = leadPokemon and leadPokemon.stats and leadPokemon.stats.hp or 0
	if maxHP == 0 then
		return
	end

	local items = Program.GameData.Items
	items.healingTotal = 0
	items.healingPercentage = 0
	items.healingValue = 0

	for itemID, quantity in pairs(items.HPHeals or {}) do
		-- An arbitrary max value to prevent erroneous game data reads
		if quantity <= 999 then
			local healItemData = MiscData.HealingItems[itemID] or {}
			local percentageAmt = 0
			if healItemData.type == MiscData.HealingType.Constant then
				-- Healing is in a percentage compared to the mon's max HP
				percentageAmt = quantity * math.min(healItemData.amount / maxHP * 100, 100) -- max of 100
			elseif healItemData.type == MiscData.HealingType.Percentage then
				percentageAmt = quantity * healItemData.amount
			end
			items.healingTotal = items.healingTotal + quantity
			items.healingPercentage = items.healingPercentage + percentageAmt
			items.healingValue = items.healingValue + math.floor(percentageAmt * maxHP / 100 + 0.5)
		end
	end
end

---Returns sorted lists of obtained TM & HM items in the bag
---@return table tms, table hms
function Program.getTMsHMsBagItems()
	return Gen1Runtime.getTMsHMsBagItems()
end

---@class IPokemon
Program.DefaultPokemon = {
	nickname = "",
	trainerID = 0,
	pokemonID = 0,
	experience = 0,
	currentExp = 0,
	totalExp = 100,
	level = 0,
	status = 0,
	sleep_turns = 0,
	curHP = 0,
	stats = { hp = 0, atk = 0, def = 0, special = 0, spe = 0 },
	statStages = { atk = 6, def = 6, special = 6, spe = 6, acc = 6, eva = 6 },
	moves = {
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
		{ id = 0, level = 1, pp = 0 },
	},
	statExp = { hp = 0, atk = 0, def = 0, special = 0, spe = 0 },
	dvs = { hp = 0, atk = 0, def = 0, special = 0, spe = 0 },
}

---Creates and returns a new IPokemon object
---@param o? table Optional initial object table
---@return IPokemon pokemon An IPokemon object
function Program.DefaultPokemon:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

---A Trainer data struct read in from game memory
---@class ITrainer
Program.GameTrainer = {
	trainerId = 0, -- The internal ID number of the trainer
	defeated = false, -- If the player has defeated this trainer; requires a separate game data read
	-- /*0x00*/ u8 partyFlags;
	partyFlags = 0,
	-- /*0x01*/ u8 trainerClass;
	trainerClass = "",
	-- /*0x02*/ u8 encounterMusic_gender; // last bit is gender
	gender = 0,
	-- /*0x03*/ u8 trainerPic;
	trainerPic = 0,
	-- /*0x04*/ u8 trainerName[12];
	trainerName = "", -- size: 12
	-- /*0x10*/ u16 items[MAX_TRAINER_ITEMS];
	items = {}, -- value: itemId, size: 4
	-- /*0x18*/ bool8 doubleBattle;
	doubleBattle = false,
	-- /*0x1C*/ u32 aiFlags;
	aiFlags = 0,
	-- /*0x20*/ u8 partySize;
	partySize = 0,
	-- /*0x24*/ const union TrainerMonPtr party; (pointer)
	party = {
		-- Example party member: { pokemonID=1, level=5, ivs=31, heldItem=13, moves={33,45,0,0} }
	},
}

---Creates and returns a new ITrainer object
---@param o? table Optional initial object table
---@return ITrainer trainer An ITrainer object
function Program.GameTrainer:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	return o
end
