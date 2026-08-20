LogTabTMs = {
	TitleResourceKey = "HeaderTabTMs", -- Usage: Resources.LogOverlay[TitleResourceKey]
	Colors = {
		text = "Default text",
		border = "Upper box border",
		boxFill = "Upper box background",
		highlight = "Intermediate text",
	},
	TabIcons = {
		TM1 = {
			x = 1, y = 1, w = 14, h = 14,
			image = FileManager.buildImagePath("icons", "tiny-tm", ".png"),
		},
	},
	-- Right-aligned leader names; keep a gap after the TM text.
	GymNameGapX = 8,
	GymNamePadRight = 2,
	GymBadgeOffsetX = 18,
	GymBadgeOffsetY = 2,
}

LogTabTMs.PagedButtons = {}
LogTabTMs.NavFilterButtons = {}
LogTabTMs.GymLabelButtons = {}

function LogTabTMs.initialize()
	LogTabTMs.buildNavigation()
end

function LogTabTMs.refreshButtons()
	for _, button in pairs(LogTabTMs.NavFilterButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabTMs.GymLabelButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
	for _, button in pairs(LogTabTMs.PagedButtons) do
		if type(button.updateSelf) == "function" then
			button:updateSelf()
		end
	end
end

function LogTabTMs.getTabIcons()
	return { LogTabTMs.TabIcons.TM1 }
end

function LogTabTMs.rebuild()
	LogTabTMs.realignGrid(LogOverlay.Windower.filterGrid)
end

function LogTabTMs.buildNavigation()
	local navHeaderX = LogOverlay.TabBox.x + 2
	local navHeaderY = LogOverlay.TabBox.y + 1
	local navItemSpacer = 6
	local filterLabelSize = Utils.calcWordPixelLength(Resources.LogOverlay.LabelFilterBy)
	local nextNavX = navHeaderX + filterLabelSize + navItemSpacer

	LogTabTMs.NavFilterButtons = {}
	for _, navFilter in ipairs(Utils.getSortedList(LogOverlay.NavFilters.TMs)) do
		local navLabelWidth = Utils.calcWordPixelLength(navFilter:getText()) + 4
		local navButton = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self) return navFilter:getText() end,
			textColor = LogTabTMs.Colors.text,
			isSelected = false,
			box = { LogOverlay.TabBox.x + nextNavX, navHeaderY, navLabelWidth, 11 },
			updateSelf = function(self)
				self.isSelected = (LogOverlay.Windower.filterGrid == navFilter.group and Utils.isNilOrEmpty(LogSearchScreen.searchText))
				self.textColor = Utils.inlineIf(self.isSelected, LogTabTMs.Colors.highlight, LogTabTMs.Colors.text)
			end,
			draw = function(self)
				if self.isSelected then
					Drawing.drawUnderline(self, Theme.COLORS[self.textColor])
				end
			end,
			onClick = function(self)
				LogTabTMs.realignGrid(navFilter.group, navFilter.sortFunc)
				Program.redraw(true)
			end,
		}
		table.insert(LogTabTMs.NavFilterButtons, navButton)
		nextNavX = nextNavX + navLabelWidth + navItemSpacer
	end
end

-- Requires gymTMs are passed in, which has info about the gym (leader, gymNumber, trainerId)
function LogTabTMs.buildPagedButtons(gymTMs)
	LogTabTMs.PagedButtons = {}

	for tmNumber, tm in pairs(RandomizerLog.Data.TMs) do
		local gymNumber, trainerId, filterGroup
		if gymTMs[tmNumber] ~= nil then
			gymNumber = gymTMs[tmNumber].gymNumber
			trainerId = gymTMs[tmNumber].trainerId
			filterGroup = "Gym TMs"
		else
			gymNumber = 0
			-- if not a gym TM, then it doesn't have a trainerId or filterGroup
		end

		local moveName = tm.name
		if MoveData.isValid(tm.moveId) then
			moveName = MoveData.Moves[tm.moveId].name
		end

		local button = {
			type = Constants.ButtonTypes.NO_BORDER,
			getText = function(self)
				local label = string.format("TM%02d  %s", tmNumber, moveName)
				if LogOverlay.Windower.filterGrid ~= "Gym TMs" or not self.box then
					return label
				end
				local tabRight = LogOverlay.TabBox.x + LogOverlay.TabBox.width - LogTabTMs.GymNamePadRight
				local maxW = tabRight - self.box[1] - 52 - LogTabTMs.GymNameGapX
				return Utils.shortenText(label, math.max(40, maxW), false)
			end,
			textColor = LogTabTMs.Colors.text,
			tmNumber = tmNumber,
			moveId = tm.moveId,
			gymNumber = gymNumber,
			trainerId = trainerId,
			group = filterGroup,
			dimensions = { width = 80, height = 11, },
			isVisible = function(self) return LogOverlay.Windower.currentPage == self.pageVisible end,
			includeInGrid = function(self)
				local shouldInclude = LogOverlay.Windower.filterGrid == LogOverlay.NavFilters.TMs.TMNumber.group or LogOverlay.Windower.filterGrid == self.group
				local shouldExclude = nil
				return shouldInclude and not shouldExclude
			end,
			onClick = function(self)
				if MoveData.isValid(self.moveId) then
					InfoScreen.changeScreenView(InfoScreen.Screens.MOVE_INFO, self.moveId) -- implied redraw
				end
			end,
		}
		table.insert(LogTabTMs.PagedButtons, button)
	end

	LogTabTMs.buildGymTMButtons()
end

function LogTabTMs.syncGymLabelBoxes()
	local tabRight = LogOverlay.TabBox.x + LogOverlay.TabBox.width - LogTabTMs.GymNamePadRight
	for _, gymButton in pairs(LogTabTMs.GymLabelButtons) do
		local tmButton = gymButton.tmButton
		if tmButton and tmButton.box then
			local minX = tmButton.box[1] + 40
			local maxW = math.max(24, tabRight - minX)
			local name = Utils.shortenText(gymButton.rawName or "", maxW, false)
			gymButton.displayName = name
			local nameW = Utils.calcWordPixelLength(name)
			-- NO_BORDER text is drawn at box[1]+1; PixelFont/Linux add another px.
			local x = tabRight - nameW - 2
			if x < minX then
				x = minX
			end
			gymButton.box = { x, tmButton.box[2], nameW + 2, 11 }
		end
	end
end

function LogTabTMs.buildGymTMButtons()
	LogTabTMs.GymLabelButtons = {}
	local gymTMNav = LogOverlay.NavFilters.TMs.GymTMs
	LogTabTMs.realignGrid(gymTMNav.group, gymTMNav.sortFunc)

	for _, tmButton in pairs(LogTabTMs.PagedButtons) do
		local trainerLog = RandomizerLog.Data.Trainers[tmButton.trainerId or -1] or {}

		if tmButton.group == "Gym TMs" then
			local badgePrefix = GameSettings.badgePrefix or "FRLG"
			local badgeName = badgePrefix .. "_badge" .. tmButton.gymNumber
			local badgeImage = FileManager.buildImagePath(FileManager.Folders.Badges, badgeName, FileManager.Extensions.BADGE)

			local gymButton = {
				type = Constants.ButtonTypes.NO_BORDER,
				tmButton = tmButton,
				rawName = (function()
					if Options["Use Custom Trainer Names"] then
						return Utils.firstToUpperEachWord(trainerLog.customName) or ""
					end
					return Utils.firstToUpperEachWord(trainerLog.name) or ""
				end)(),
				getText = function(self)
					return self.displayName or self.rawName or ""
				end,
				textColor = tmButton.textColor,
				trainerId = tmButton.trainerId,
				group = tmButton.group,
				box = { 0, 0, 40, 11 },
				isVisible = function(self)
					return LogOverlay.Windower.filterGrid == self.group
						and self.tmButton ~= nil
						and LogOverlay.Windower.currentPage == self.tmButton.pageVisible
				end,
				draw = function(self, shadowcolor)
					if self.tmButton and self.tmButton.box then
						Drawing.drawImage(
							badgeImage,
							self.tmButton.box[1] - LogTabTMs.GymBadgeOffsetX,
							self.tmButton.box[2] - LogTabTMs.GymBadgeOffsetY
						)
					end
				end,
				onClick = function(self)
					LogOverlay.Windower:changeTab(LogTabTrainerDetails, 1, nil, self.trainerId)
					if TrainerInfoScreen.buildScreen(self.trainerId) then
						TrainerInfoScreen.previousScreen = TrackerScreen
						Program.changeScreenView(TrainerInfoScreen)
					end
				end,
			}
			table.insert(LogTabTMs.GymLabelButtons, gymButton)
		end
	end
	LogTabTMs.syncGymLabelBoxes()
end

function LogTabTMs.realignGrid(gridFilter, sortFunc, startingPage)
	gridFilter = gridFilter or "Gym TMs"
	sortFunc = sortFunc or LogOverlay.NavFilters.TMs.GymTMs.sortFunc
	startingPage = startingPage or 1

	table.sort(LogTabTMs.PagedButtons, sortFunc)

	local x = LogOverlay.TabBox.x + 25
	local y = LogOverlay.TabBox.y + 14
	local colSpacer = 17
	local rowSpacer = 2
	local maxWidth = LogOverlay.TabBox.width + LogOverlay.TabBox.x
	local maxHeight = LogOverlay.TabBox.height + LogOverlay.TabBox.y

	-- Single column for fancy Gym TM display
	if gridFilter == "Gym TMs" then
		x = LogOverlay.TabBox.x + 20
		colSpacer = 200
		rowSpacer = 5
	end

	LogOverlay.Windower.filterGrid = gridFilter
	LogOverlay.Windower.totalPages = Utils.gridAlign(LogTabTMs.PagedButtons, x, y, colSpacer, rowSpacer, true, maxWidth, maxHeight)
	LogOverlay.Windower.currentPage = math.min(startingPage, LogOverlay.Windower.totalPages)

	LogTabTMs.syncGymLabelBoxes()
	LogTabTMs.refreshButtons()
end

-- USER INPUT FUNCTIONS
function LogTabTMs.checkInput(xmouse, ymouse)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTMs.NavFilterButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTMs.GymLabelButtons)
	Input.checkButtonsClicked(xmouse, ymouse, LogTabTMs.PagedButtons)
end

-- Unsure if this will actually be needed, likely some of them
function LogTabTMs.drawTab()
	local textColor = Theme.COLORS[LogTabTMs.Colors.text]
	local borderColor = Theme.COLORS[LogTabTMs.Colors.border]
	local fillColor = Theme.COLORS[LogTabTMs.Colors.boxFill]
	local shadowcolor = Utils.calcShadowColor(fillColor)

	-- Draw the Tab viewbox
	gui.defaultTextBackground(fillColor)
	gui.drawRectangle(LogOverlay.TabBox.x, LogOverlay.TabBox.y, LogOverlay.TabBox.width, LogOverlay.TabBox.height, borderColor, fillColor)

	-- Draw group filters Label
	local filterByText = Resources.LogOverlay.LabelFilterBy .. ":"
	Drawing.drawText(LogOverlay.TabBox.x + 2, LogOverlay.TabBox.y + 1, filterByText, textColor, shadowcolor)

	-- Draw the navigation
	for _, button in pairs(LogTabTMs.NavFilterButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
	for _, button in pairs(LogTabTMs.GymLabelButtons) do
		Drawing.drawButton(button, shadowcolor)
	end

	-- Draw the paged items
	for _, button in pairs(LogTabTMs.PagedButtons) do
		Drawing.drawButton(button, shadowcolor)
	end
end
