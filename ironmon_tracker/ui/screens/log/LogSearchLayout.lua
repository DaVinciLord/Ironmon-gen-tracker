-- Geometry for the right-gap log search panel (sort/filter + keyboard).
-- Mirrors TrackerScreenLayout: bottom keyboard respects DOWN_GAP via getTrackerHeight().

LogSearchLayout = {}

LogSearchLayout.Constants = {
	HEADER_OFFSET_Y = 10, -- room for "SEARCH THE LOG" above the top box
	KEYBOARD_HEIGHT = 60,
	DROPDOWN_OFFSET_X = 40,
	DROPDOWN_WIDTH = 90,
	DROPDOWN_HEIGHT = 13,
	PADDING = 2,
}

local boxes = nil

local function trackerHeight()
	if Drawing and Drawing.getTrackerHeight then
		return Drawing.getTrackerHeight()
	end
	return Constants.SCREEN.HEIGHT + (Constants.SCREEN.DOWN_GAP or 0)
end

---Rebuilds top content box + keyboard band in the tracker right gap.
function LogSearchLayout.rebuild()
	local C = LogSearchLayout.Constants
	local m = Constants.SCREEN.MARGIN
	local originX = Constants.SCREEN.WIDTH + m
	local panelW = Constants.SCREEN.RIGHT_GAP - (2 * m)
	local trackerH = trackerHeight()
	local keyboardH = C.KEYBOARD_HEIGHT
	local keyboardY = trackerH - m - keyboardH
	local topY = m + C.HEADER_OFFSET_Y
	-- Top box fills from under the header down to the keyboard (shared edge).
	local topH = math.max(40, keyboardY - topY)

	boxes = {
		margin = m,
		padding = C.PADDING,
		originX = originX,
		headerY = m - 2,
		topBox = {
			x = originX,
			y = topY,
			w = panelW,
			h = topH,
		},
		keyboard = {
			x = originX,
			y = keyboardY,
			w = panelW,
			h = keyboardH,
			paddingX = 2,
			paddingY = 2,
			paddingBoard = 4,
		},
		sortDropdown = {
			x = originX + C.DROPDOWN_OFFSET_X,
			y = topY + C.PADDING + 1,
			w = C.DROPDOWN_WIDTH,
			h = C.DROPDOWN_HEIGHT,
		},
	}
end

function LogSearchLayout.get()
	if boxes == nil then
		LogSearchLayout.rebuild()
	end
	return boxes
end

---@return table topBox { x, y, width, height } legacy field names for LogSearchScreen
function LogSearchLayout.topBox()
	local b = LogSearchLayout.get().topBox
	return { x = b.x, y = b.y, width = b.w, height = b.h }
end

---@return table botBox keyboard band with padding fields
function LogSearchLayout.keyboardBox()
	local k = LogSearchLayout.get().keyboard
	return {
		x = k.x,
		y = k.y,
		width = k.w,
		height = k.h,
		paddingX = k.paddingX,
		paddingY = k.paddingY,
		paddingBoard = k.paddingBoard,
	}
end

---@return table dropdownBox sort-by dropdown rect
function LogSearchLayout.sortDropdownBox()
	local d = LogSearchLayout.get().sortDropdown
	return { x = d.x, y = d.y, width = d.w, height = d.h }
end

---Filter dropdown sits above the search text field (caller passes that Y).
---@param searchFieldY number
---@return table dropdownBox
function LogSearchLayout.filterDropdownBox(searchFieldY)
	local C = LogSearchLayout.Constants
	local layout = LogSearchLayout.get()
	local y = searchFieldY - Constants.SCREEN.LINESPACING - C.PADDING * 2 - 1
	return {
		x = layout.originX + C.DROPDOWN_OFFSET_X,
		y = y,
		width = C.DROPDOWN_WIDTH,
		height = C.DROPDOWN_HEIGHT,
	}
end
