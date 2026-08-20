-- Geometry for the GB-screen log overlay (TabBar + TabBox), built with the ui/widgets kit.
-- Keeps LogOverlay.TabBox in sync; tab grids / nav / misc buttons read helpers here.

LogOverlayLayout = {}

LogOverlayLayout.Constants = {
	-- Pokémon icon grid (LogTabPokemon.realignGrid)
	POKEMON_ICON_SIZE = 32,
	POKEMON_COL_SPACER = 20, -- slightly tighter columns for clearer centering on GB
	POKEMON_ROW_SPACER = 6, -- more vertical breathing room (NDS-like)
	POKEMON_NAME_OFFSET_Y = 3, -- names sit above each icon
	-- Trainers portrait grid
	TRAINERS_GRID_OFFSET_X = 12,
	TRAINERS_GRID_OFFSET_Y = 18,
	TRAINERS_COL_SPACER = 12,
	TRAINERS_ROW_SPACER = 16,
	TRAINERS_NAV_OFFSET_X = 2,
	TRAINERS_NAV_OFFSET_Y = 1,
	TRAINERS_NAV_SPACER = 3,
	-- Routes list
	ROUTES_GRID_OFFSET_X = 3,
	ROUTES_GRID_OFFSET_Y = 17,
	ROUTES_COL_SPACER = 999, -- single column
	ROUTES_ROW_SPACER = 0,
	ROUTES_HEADER_OFFSET_X = 3,
	ROUTES_HEADER_OFFSET_Y = 1,
	ROUTES_BAR_HEIGHT = 21,
	-- Column widths for GB TabBox (~156). Location column absorbs the remainder.
	ROUTES_COL_ICON = 16,
	ROUTES_COL_WILD_COUNT = 14,
	ROUTES_COL_WILD_LV = 28,
	ROUTES_COL_TRAINER_COUNT = 14,
	ROUTES_COL_TRAINER_LV = 28,
	ROUTES_COL_LOCATION_MIN = 36,
	-- TMs
	TMS_NAV_OFFSET_X = 2,
	TMS_NAV_OFFSET_Y = 1,
	TMS_NAV_SPACER = 6,
	TMS_GRID_OFFSET_X = 25,
	TMS_GRID_OFFSET_Y = 14,
	TMS_COL_SPACER = 17,
	TMS_ROW_SPACER = 2,
	TMS_GYM_GRID_OFFSET_X = 20,
	TMS_GYM_COL_SPACER = 200,
	TMS_GYM_ROW_SPACER = 5,
	-- Route details
	ROUTE_DETAILS_TITLE_OFFSET_X = 3,
	ROUTE_DETAILS_TITLE_OFFSET_Y = 2,
	ROUTE_DETAILS_SIDE_NAV_WIDTH = 69,
	ROUTE_DETAILS_ENC_LABEL_OFFSET_Y = 7,
	ROUTE_DETAILS_NAV_HEADER_Y = 62, -- absolute (legacy Besteon)
	ROUTE_DETAILS_TRAINER_GRID_OFFSET_X = 7,
	ROUTE_DETAILS_TRAINER_GRID_OFFSET_Y = 28,
	ROUTE_DETAILS_POKE_GRID_OFFSET_X = 7,
	ROUTE_DETAILS_POKE_GRID_OFFSET_Y = 21,
	ROUTE_DETAILS_COL_SPACER = 24,
	ROUTE_DETAILS_ROW_SPACER = 32,
	-- Trainer details party
	TRAINER_DETAILS_PARTY_LIST_OFFSET_X = 1,
	TRAINER_DETAILS_PARTY_LIST_OFFSET_Y = 78,
	TRAINER_DETAILS_MOVES_OFFSET_X = 58,
	TRAINER_DETAILS_MOVES_OFFSET_Y = 2,
	TRAINER_DETAILS_BADGE_OFFSET_X = 44,
	TRAINER_DETAILS_BADGE_OFFSET_Y = 2,
	TRAINER_DETAILS_PORTRAIT_OFFSET_Y = 20,
	-- Misc checkboxes / labels
	MISC_CHECK_OFFSET_X = 5,
	MISC_CHECK_START_Y = 5,
	MISC_CHECK_ROW = 12,
	MISC_SHARE_WIDTH = 52,
	MISC_SHARE_OFFSET_Y = 4,
	MISC_LABEL_OFFSET_X = 3,
	MISC_LABEL_START_Y = 55,
	MISC_LABEL_ROW = 12,
	MISC_LABEL_WIDTH = 100,
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

local function tabBox()
	return LogOverlayLayout.get().tabBox
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

---@return number x, number y, number w, number h
function LogOverlayLayout.tabBoxXYWH()
	local box = tabBox()
	return box.x, box.y, box.w, box.h
end

---Centered Pokémon icon grid origin + spacers inside TabBox.
function LogOverlayLayout.pokemonGridMetrics()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
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

function LogOverlayLayout.trainersGridMetrics()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	local x = box.x + C.TRAINERS_GRID_OFFSET_X
	local y = box.y + C.TRAINERS_GRID_OFFSET_Y
	return x, y, C.TRAINERS_COL_SPACER, C.TRAINERS_ROW_SPACER, box.x + box.w, box.y + box.h
end

function LogOverlayLayout.trainersNavMetrics()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	return box.x + C.TRAINERS_NAV_OFFSET_X, box.y + C.TRAINERS_NAV_OFFSET_Y, C.TRAINERS_NAV_SPACER
end

function LogOverlayLayout.routesGridMetrics()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	local x = box.x + C.ROUTES_GRID_OFFSET_X
	local y = box.y + C.ROUTES_GRID_OFFSET_Y
	return x, y, C.ROUTES_COL_SPACER, C.ROUTES_ROW_SPACER, box.x + box.w, box.y + box.h
end

---Full-width route row metrics that fit the GB TabBox (GBA used 230px bars).
---Width accounts for the grid's left inset so startX + width stays within TabBox.
---@return number width, number height, number locationColW
function LogOverlayLayout.routesBarMetrics()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	local width = math.max(80, box.w - C.ROUTES_GRID_OFFSET_X)
	local fixed = C.ROUTES_COL_ICON
		+ C.ROUTES_COL_WILD_COUNT
		+ C.ROUTES_COL_WILD_LV
		+ C.ROUTES_COL_TRAINER_COUNT
		+ C.ROUTES_COL_TRAINER_LV
	local locationW = math.max(C.ROUTES_COL_LOCATION_MIN, width - fixed)
	if locationW + fixed > width then
		locationW = math.max(24, width - fixed)
	end
	return width, C.ROUTES_BAR_HEIGHT, locationW
end

---@param colRelX number column x relative to route bar width (legacy col.x)
---@return number absX, number absY
function LogOverlayLayout.routesHeaderCell(colRelX)
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	return box.x + colRelX + C.ROUTES_HEADER_OFFSET_X, box.y + C.ROUTES_HEADER_OFFSET_Y
end

---TM nav: startX already includes filter-label width; do not add TabBox.x again.
function LogOverlayLayout.tmsNavMetrics()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	return box.x + C.TMS_NAV_OFFSET_X, box.y + C.TMS_NAV_OFFSET_Y, C.TMS_NAV_SPACER
end

---@param gymMode boolean|nil if true, single-column Gym TM layout
function LogOverlayLayout.tmsGridMetrics(gymMode)
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	local x, colSpacer, rowSpacer
	if gymMode then
		x = box.x + C.TMS_GYM_GRID_OFFSET_X
		colSpacer = C.TMS_GYM_COL_SPACER
		rowSpacer = C.TMS_GYM_ROW_SPACER
	else
		x = box.x + C.TMS_GRID_OFFSET_X
		colSpacer = C.TMS_COL_SPACER
		rowSpacer = C.TMS_ROW_SPACER
	end
	local y = box.y + C.TMS_GRID_OFFSET_Y
	return x, y, colSpacer, rowSpacer, box.x + box.w, box.y + box.h
end

function LogOverlayLayout.routeDetailsTitleBox()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	return {
		box.x + C.ROUTE_DETAILS_TITLE_OFFSET_X,
		box.y + C.ROUTE_DETAILS_TITLE_OFFSET_Y,
		120,
		12,
	}
end

---@return number navX, number encLabelY, number navHeaderY, number sideNavW
function LogOverlayLayout.routeDetailsSideNav()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	local sideW = C.ROUTE_DETAILS_SIDE_NAV_WIDTH
	local navX = box.x + box.w - sideW + 3
	return navX, box.y + C.ROUTE_DETAILS_ENC_LABEL_OFFSET_Y, C.ROUTE_DETAILS_NAV_HEADER_Y, sideW
end

---@param forTrainers boolean
function LogOverlayLayout.routeDetailsGridMetrics(forTrainers)
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	local sideW = C.ROUTE_DETAILS_SIDE_NAV_WIDTH
	local x, y
	if forTrainers then
		x = box.x + C.ROUTE_DETAILS_TRAINER_GRID_OFFSET_X
		y = box.y + C.ROUTE_DETAILS_TRAINER_GRID_OFFSET_Y
	else
		x = box.x + C.ROUTE_DETAILS_POKE_GRID_OFFSET_X
		y = box.y + C.ROUTE_DETAILS_POKE_GRID_OFFSET_Y
	end
	return x, y, C.ROUTE_DETAILS_COL_SPACER, C.ROUTE_DETAILS_ROW_SPACER, box.x + box.w - sideW, box.y + box.h
end

function LogOverlayLayout.trainerDetailsPartyMetrics()
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	return {
		partyListX = box.x + C.TRAINER_DETAILS_PARTY_LIST_OFFSET_X,
		partyListStartY = box.y + C.TRAINER_DETAILS_PARTY_LIST_OFFSET_Y,
		movesX = box.x + C.TRAINER_DETAILS_MOVES_OFFSET_X,
		movesY = box.y + C.TRAINER_DETAILS_MOVES_OFFSET_Y,
		badgeX = box.x + C.TRAINER_DETAILS_BADGE_OFFSET_X,
		badgeY = box.y + C.TRAINER_DETAILS_BADGE_OFFSET_Y,
		portraitX = box.x,
		portraitY = box.y + C.TRAINER_DETAILS_PORTRAIT_OFFSET_Y,
		nameX = box.x + 2,
		classY = box.y + 1,
		nameY = box.y + 10,
	}
end

---Rewrites LogTabMisc.Buttons hitboxes from TabBox (call after syncLayout / initialize).
function LogOverlayLayout.applyMiscButtonBoxes()
	if LogTabMisc == nil or LogTabMisc.Buttons == nil then
		return
	end
	local C = LogOverlayLayout.Constants
	local box = tabBox()
	local B = LogTabMisc.Buttons
	local checkX = box.x + C.MISC_CHECK_OFFSET_X
	local checkY = box.y + C.MISC_CHECK_START_Y
	local row = C.MISC_CHECK_ROW

	local function setCheck(btn, rowIndex)
		if btn == nil then return end
		local y = checkY + (rowIndex - 1) * row
		btn.box = { checkX, y, 8, 8 }
		btn.clickableArea = { checkX, y, 90, 10 }
	end

	setCheck(B.UnlearnableTMsSettingButton, 1)
	setCheck(B.PreEvoSettingButton, 2)
	setCheck(B.CustomTrainerNames, 3)

	if B.ShareRandomizer then
		B.ShareRandomizer.box = {
			Constants.SCREEN.WIDTH - box.x - C.MISC_SHARE_WIDTH,
			box.y + C.MISC_SHARE_OFFSET_Y,
			C.MISC_SHARE_WIDTH,
			11,
		}
	end

	local labelX = box.x + C.MISC_LABEL_OFFSET_X
	local labelY = box.y + C.MISC_LABEL_START_Y
	local labelRow = C.MISC_LABEL_ROW
	local labelW = C.MISC_LABEL_WIDTH
	local labels = { B.PokemonGame, B.RandomizerVersion, B.RandomSeed, B.SettingsString }
	for i, btn in ipairs(labels) do
		if btn then
			btn.box = { labelX, labelY + (i - 1) * labelRow, labelW, 11 }
		end
	end
end
