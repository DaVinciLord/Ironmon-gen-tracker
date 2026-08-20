-- Geometry for the GB-screen log overlay (TabBar + TabBox), built with the ui/widgets kit.
-- Keeps LogOverlay.TabBox in sync for existing tabs; Pokémon / Trainers grids read helpers here.

LogOverlayLayout = {}

LogOverlayLayout.Constants = {
	-- Pokémon icon grid (LogTabPokemon.realignGrid)
	POKEMON_ICON_SIZE = 32,
	POKEMON_COL_SPACER = 23,
	POKEMON_ROW_SPACER = 4,
	POKEMON_NAME_OFFSET_Y = 2, -- names sit above each icon
	-- Trainers portrait grid (LogTabTrainers.realignGrid / buildNavigation)
	TRAINERS_GRID_OFFSET_X = 12,
	TRAINERS_GRID_OFFSET_Y = 18,
	TRAINERS_COL_SPACER = 12,
	TRAINERS_ROW_SPACER = 16,
	TRAINERS_NAV_OFFSET_X = 2,
	TRAINERS_NAV_OFFSET_Y = 1,
	TRAINERS_NAV_SPACER = 3,
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

local function trackerHeight()
	if Drawing and Drawing.getTrackerHeight then
		return Drawing.getTrackerHeight()
	end
	return Constants.SCREEN.HEIGHT + (Constants.SCREEN.DOWN_GAP or 0)
end

---Rebuilds tab bar / content box. TabBox height includes DOWN_GAP so trainer row 2 is not clipped.
function LogOverlayLayout.rebuild()
	local m = (LogOverlay and LogOverlay.margin) or 2
	local tabH = (LogOverlay and LogOverlay.tabHeight) or 12
	local panelW = Constants.SCREEN.WIDTH - (m * 2)
	-- TabBox.height = Drawing.getTrackerHeight() - LogOverlay.tabHeight - m - 1
	local tabBoxH = trackerHeight() - tabH - m - 1

	frames = {
		tabBar = makeRegion(m, 0, panelW, tabH, "Upper box background", "Main background"),
		tabBox = makeRegion(m, tabH, panelW, tabBoxH, "Upper box border", "Upper box background"),
	}

	boxes = {
		margin = m,
		tabHeight = tabH,
		tabBar = rectFromFrame(frames.tabBar),
		tabBox = rectFromFrame(frames.tabBox),
	}
end

---@return table boxes absolute regions for the log overlay chrome
function LogOverlayLayout.get()
	if boxes == nil then
		LogOverlayLayout.rebuild()
	end
	return boxes
end

---Writes layout rectangles onto LogOverlay.TabBox (legacy consumers).
function LogOverlayLayout.applyToOverlay()
	if LogOverlay == nil or LogOverlay.TabBox == nil then
		return
	end
	local layout = LogOverlayLayout.get()
	local box = layout.tabBox
	LogOverlay.TabBox.x = box.x
	LogOverlay.TabBox.y = box.y
	LogOverlay.TabBox.width = box.w
	LogOverlay.TabBox.height = box.h
end

---Draws the structural TabBox frame (optional; tabs often draw their own fill).
function LogOverlayLayout.drawTabBox()
	if frames == nil then
		LogOverlayLayout.rebuild()
	end
	frames.tabBox.show()
end

---Centered Pokémon icon grid origin + spacers inside TabBox.
---@return number x, number y, number colSpacer, number rowSpacer, number maxWidth, number maxHeight
function LogOverlayLayout.pokemonGridMetrics()
	local C = LogOverlayLayout.Constants
	local box = LogOverlayLayout.get().tabBox
	local iconSize = C.POKEMON_ICON_SIZE
	local colSpacer = C.POKEMON_COL_SPACER
	local rowSpacer = C.POKEMON_ROW_SPACER
	local nameOffsetY = C.POKEMON_NAME_OFFSET_Y

	local maxWidth = box.x + box.w
	local maxHeight = box.y + box.h

	local cols = math.max(1, math.floor((box.w + colSpacer) / (iconSize + colSpacer)))
	local gridWidth = cols * iconSize + (cols - 1) * colSpacer
	local x = box.x + math.floor((box.w - gridWidth) / 2 + 0.5)

	local availHeight = math.max(iconSize, box.h - nameOffsetY)
	local rows = math.max(1, math.floor((availHeight + rowSpacer) / (iconSize + rowSpacer)))
	local gridHeight = rows * iconSize + (rows - 1) * rowSpacer
	local y = box.y + nameOffsetY + math.floor((availHeight - gridHeight) / 2 + 0.5)

	return x, y, colSpacer, rowSpacer, maxWidth, maxHeight
end

---Trainers portrait grid origin + spacers inside TabBox.
---@return number x, number y, number colSpacer, number rowSpacer, number maxWidth, number maxHeight
function LogOverlayLayout.trainersGridMetrics()
	local C = LogOverlayLayout.Constants
	local box = LogOverlayLayout.get().tabBox
	local x = box.x + C.TRAINERS_GRID_OFFSET_X
	local y = box.y + C.TRAINERS_GRID_OFFSET_Y
	return x, y, C.TRAINERS_COL_SPACER, C.TRAINERS_ROW_SPACER, box.x + box.w, box.y + box.h
end

---@return number startX, number startY, number itemSpacer
function LogOverlayLayout.trainersNavMetrics()
	local C = LogOverlayLayout.Constants
	local box = LogOverlayLayout.get().tabBox
	return box.x + C.TRAINERS_NAV_OFFSET_X, box.y + C.TRAINERS_NAV_OFFSET_Y, C.TRAINERS_NAV_SPACER
end
