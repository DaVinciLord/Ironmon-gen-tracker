-- Geometry for the right-gap combat HUD, built with the ui/widgets layout kit.
-- Pixel values match the Besteon Gen 1 panel so existing button hitboxes stay valid.
-- Future polish can retune Constants here without hunting magic numbers in TrackerScreen.

TrackerScreenLayout = {}

TrackerScreenLayout.Constants = {
	POKEMON_INFO_WIDTH = 96,
	POKEMON_INFO_HEIGHT = 52,
	HEALS_ROUTE_HEIGHT = 23,
	-- Distance from game-screen right edge (Constants.SCREEN.WIDTH) to the stats column
	STATS_OFFSET_FROM_GAME = 101,
	STATS_HEIGHT = 75,
	MOVES_HEADER_Y = 81,
	MOVES_HEADER_HEIGHT = 13,
	MOVES_BOX_Y = 92,
	MOVES_BOX_HEIGHT = 44,
	CAROUSEL_Y = 136,
	CAROUSEL_HEIGHT = 19,
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

---Rebuilds the frame tree and caches absolute rectangles for drawing.
function TrackerScreenLayout.rebuild()
	local C = TrackerScreenLayout.Constants
	local m = Constants.SCREEN.MARGIN
	local originX = Constants.SCREEN.WIDTH + m
	local originY = m
	local panelW = Constants.SCREEN.RIGHT_GAP - (2 * m)
	local statsX = Constants.SCREEN.WIDTH + C.STATS_OFFSET_FROM_GAME
	local statsW = Constants.SCREEN.RIGHT_GAP - C.STATS_OFFSET_FROM_GAME - m

	frames = {
		pokemonInfo = makeRegion(originX, originY, C.POKEMON_INFO_WIDTH, C.POKEMON_INFO_HEIGHT, "Upper box border", "Upper box background"),
		healsRoute = makeRegion(originX, originY + C.POKEMON_INFO_HEIGHT, C.POKEMON_INFO_WIDTH, C.HEALS_ROUTE_HEIGHT, "Upper box border", "Upper box background"),
		stats = makeRegion(statsX, originY, statsW, C.STATS_HEIGHT, "Upper box border", "Upper box background"),
		moves = makeRegion(originX, C.MOVES_BOX_Y, panelW, C.MOVES_BOX_HEIGHT, "Lower box border", "Lower box background"),
		carousel = makeRegion(originX, C.CAROUSEL_Y, panelW, C.CAROUSEL_HEIGHT, "Lower box border", "Lower box background"),
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
		movesHeaderY = C.MOVES_HEADER_Y,
		statLabelX = statsX + 1,
		statLabelY = 7,
	}
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
