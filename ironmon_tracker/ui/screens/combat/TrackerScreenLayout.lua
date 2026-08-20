-- Geometry for the right-gap combat HUD, built with the ui/widgets layout kit.
-- Button hitboxes are synced from these regions via applyButtonBoxes().

TrackerScreenLayout = {}

TrackerScreenLayout.Constants = {
	POKEMON_INFO_WIDTH = 96,
	POKEMON_INFO_HEIGHT = 52,
	HEALS_ROUTE_HEIGHT = 23,
	-- Distance from game-screen right edge (Constants.SCREEN.WIDTH) to the stats column
	STATS_OFFSET_FROM_GAME = 101,
	STATS_HEIGHT = 75,
	MOVES_HEADER_HEIGHT = 13,
	MOVES_BOX_HEIGHT = 44,
	CAROUSEL_HEIGHT = 19,
	-- Gap between heals/route block and the moves header (Besteon used 81 - 80 = 1)
	SECTION_GAP = 1,
}

local boxes = nil
local frames = nil

local function rectFromFrame(frame)
	local pos = frame.getPosition()
	local size = frame.getSize()
	return { x = pos.x, y = pos.y, w = size.width, h = size.height }
end

local function makeRegion(x, y, w, h, borderKey, fillKey)
	local box = Box.create({ x = x, y = y }, { width = w, height = h }, borderKey, fillKey)
	return Frame.create(box, nil, nil, true)
end

local function setBox(button, x, y, w, h)
	if button == nil then return end
	button.box = { x, y, w, h }
end

local function setClickable(button, x, y, w, h)
	if button == nil then return end
	button.clickableArea = { x, y, w, h }
end

---Rebuilds the frame tree and caches absolute rectangles for drawing.
function TrackerScreenLayout.rebuild()
	local C = TrackerScreenLayout.Constants
	local m = Constants.SCREEN.MARGIN
	local originX = Constants.SCREEN.WIDTH + m
	local originY = m
	local panelW = Constants.SCREEN.RIGHT_GAP - (2 * m)
	local statsX = Constants.SCREEN.WIDTH + C.STATS_OFFSET_FROM_GAME
	local statsW = Constants.SCREEN.RIGHT_GAP - C.STATS_OFFSET_FROM_GAME - m

	local healsBottom = originY + C.POKEMON_INFO_HEIGHT + C.HEALS_ROUTE_HEIGHT
	local movesHeaderY = healsBottom + C.SECTION_GAP
	local movesBoxY = movesHeaderY + C.MOVES_HEADER_HEIGHT - 2 -- matches old 92 when header is 81

	local trackerH = (Drawing and Drawing.getTrackerHeight and Drawing.getTrackerHeight())
		or (Constants.SCREEN.HEIGHT + (Constants.SCREEN.DOWN_GAP or 0))
	local carouselY = trackerH - m - C.CAROUSEL_HEIGHT
	-- Keep legacy 136 when the padded height is the standard GB panel (159 → 135 would shift
	-- badges by 1px); prefer the bottom of the tracker panel without overlapping moves.
	local minCarouselY = movesBoxY + C.MOVES_BOX_HEIGHT
	if carouselY < minCarouselY then
		carouselY = minCarouselY
	end

	frames = {
		pokemonInfo = makeRegion(originX, originY, C.POKEMON_INFO_WIDTH, C.POKEMON_INFO_HEIGHT, "Upper box border", "Upper box background"),
		healsRoute = makeRegion(originX, originY + C.POKEMON_INFO_HEIGHT, C.POKEMON_INFO_WIDTH, C.HEALS_ROUTE_HEIGHT, "Upper box border", "Upper box background"),
		stats = makeRegion(statsX, originY, statsW, C.STATS_HEIGHT, "Upper box border", "Upper box background"),
		moves = makeRegion(originX, movesBoxY, panelW, C.MOVES_BOX_HEIGHT, "Lower box border", "Lower box background"),
		carousel = makeRegion(originX, carouselY, panelW, C.CAROUSEL_HEIGHT, "Lower box border", "Lower box background"),
	}

	boxes = {
		originX = originX,
		originY = originY,
		panelW = panelW,
		pokemonInfo = rectFromFrame(frames.pokemonInfo),
		healsRoute = rectFromFrame(frames.healsRoute),
		stats = rectFromFrame(frames.stats),
		moves = rectFromFrame(frames.moves),
		carousel = rectFromFrame(frames.carousel),
		movesHeaderY = movesHeaderY,
		statLabelX = statsX + 1,
		statLabelY = originY + 2,
	}

	TrackerScreenLayout.applyButtonBoxes()
end

---@return table boxes absolute { x, y, w, h } for each HUD region
function TrackerScreenLayout.get()
	if boxes == nil then
		TrackerScreenLayout.rebuild()
	end
	return boxes
end

---Draws the structural HUD frames (pokemon / heals / stats / moves / carousel).
function TrackerScreenLayout.drawFrames()
	if frames == nil then
		TrackerScreenLayout.rebuild()
	end
	frames.pokemonInfo.show()
	frames.healsRoute.show()
	frames.stats.show()
	frames.moves.show()
	frames.carousel.show()
end

---Writes absolute hitboxes onto TrackerScreen.Buttons / PokeBalls from the cached layout.
function TrackerScreenLayout.applyButtonBoxes()
	if boxes == nil or TrackerScreen == nil or TrackerScreen.Buttons == nil then
		return
	end

	local B = TrackerScreen.Buttons
	local info = boxes.pokemonInfo
	local heals = boxes.healsRoute
	local stats = boxes.stats
	local carousel = boxes.carousel
	local headerY = boxes.movesHeaderY
	local ox, oy = boxes.originX, boxes.originY

	setBox(B.PokemonIcon, info.x, oy - 6, 32, 32)
	setClickable(B.PokemonIcon, info.x, oy, 32, 27)
	setBox(B.ShinyEffect, info.x + 84, oy + 10, 12, 12)
	setBox(B.TypeDefenses, info.x, oy + 27, 30, 24)
	setBox(B.SettingsGear, info.x + 87, oy + 2, 7, 7)
	setBox(B.RerollBallPicker, info.x + 81, oy + 36, 13, 14)

	setBox(B.PCHealAutoTracking, heals.x + 82, heals.y + 2, 10, 8)
	setBox(B.PCHealIncrement, heals.x + 78, heals.y + 12, 5, 5)
	setBox(B.PCHealDecrement, heals.x + 78, heals.y + 16, 5, 5)
	setBox(B.LogViewerQuickAccess, heals.x + 79, heals.y + 7, 10, 10)
	setClickable(B.RouteDetails, heals.x + 1, heals.y, heals.w, heals.h)
	setBox(B.RouteDetails, heals.x + 3, heals.y + 6, 8, 12)
	setClickable(B.TrainerDetails, heals.x + 1, heals.y, heals.w, heals.h)
	setBox(B.TrainerDetails, heals.x + 78, heals.y + 4, 16, 16)
	setBox(B.HealsInBag, heals.x, heals.y + 2, 54, 21)

	setBox(B.InvisibleStatsArea, stats.x + 2, stats.y, 44, stats.h)

	setClickable(B.MovesHistory, ox + 1, headerY, 75, 10)
	setBox(B.MovesHistory, ox + 1, headerY, 75, 10)
	setClickable(B.CatchRates, ox + 77, headerY, 50, 10)
	setBox(B.CatchRates, ox + 77, headerY, 50, 10)

	local cy = carousel.y
	local carouselClick = { ox + 1, cy + 4, 138, 12 }
	for _, name in ipairs({
		"NotepadTracking", "LastAttackSummary", "BattleDetailsSummary",
		"RouteSummary", "TrainerSummary",
	}) do
		setClickable(B[name], carouselClick[1], carouselClick[2], carouselClick[3], carouselClick[4])
	end
	setBox(B.NotepadTracking, ox + 4, cy + 4, 11, 11)
	setBox(B.LastAttackSummary, ox + 3, cy + 4, 13, 13)
	setBox(B.BattleDetailsSummary, ox + 3, cy + 4, 12, 12)
	setBox(B.RouteSummary, ox + 4, cy + 4, 8, 12)
	setBox(B.TrainerSummary, ox + 4, cy + 4, 13, 13)
	setBox(B.PedometerStepText, ox + 3, cy + 5, 10, 10)
	setClickable(B.PedometerGoal, ox + 81, cy + 4, 23, 11)
	setBox(B.PedometerGoal, ox + 81, cy + 4, 23, 11)
	setClickable(B.PedometerReset, ox + 108, cy + 4, 28, 11)
	setBox(B.PedometerReset, ox + 108, cy + 4, 28, 11)

	-- Stat marking squares (created in initialize)
	local heightOffset = oy + 4
	for _, statKey in ipairs(Constants.OrderedLists.STATSTAGES or {}) do
		if B[statKey] then
			setBox(B[statKey], stats.x + 28, heightOffset, 8, 8)
			heightOffset = heightOffset + 10
		end
	end

	-- Gym badges
	local badgeWidth = 16
	local badgePrefix = (GameSettings and GameSettings.badgePrefix)
		or ((Constants.Badges and Constants.Badges[GameSettings and GameSettings.game] or {}).Prefix)
		or "FRLG"
	local badgeInfoTable = { Prefix = badgePrefix, IconOffsets = (GameSettings and GameSettings.badgeXOffsets) or { 0, 0, 0, 0, 0, 0, 0, 0 } }
	local kerningOffsets = badgeInfoTable.IconOffsets or {}
	for index = 1, 8, 1 do
		local badge = B["badge" .. index]
		if badge then
			local xOffset = Constants.SCREEN.WIDTH + 7 + ((index - 1) * (badgeWidth + 1)) + (kerningOffsets[index] or 0)
			setBox(badge, xOffset, cy + 2, badgeWidth, badgeWidth)
		end
	end

	if TrackerScreen.PokeBalls then
		local balls = TrackerScreen.PokeBalls
		if balls.Left then balls.Left.x, balls.Left.y = ox + 17, oy + 18 end
		if balls.Middle then balls.Middle.x, balls.Middle.y = ox + 40, oy + 26 end
		if balls.Right then balls.Right.x, balls.Right.y = ox + 63, oy + 18 end
	end
end
