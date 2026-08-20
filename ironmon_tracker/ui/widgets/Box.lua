-- Box adapted from NDS-Ironmon-Tracker UIBaseClasses/Box.lua
-- Geometry + optional draw via Theme.COLORS (Besteon color keys).

Box = {}

local function resolveThemeColor(colorKey)
	if colorKey == nil or Theme == nil or Theme.COLORS == nil then
		return 0x00000000
	end
	return Theme.COLORS[colorKey] or 0x00000000
end

---Creates a positioned rectangle. Color keys use Besteon Theme names
---(e.g. "Upper box background", "Upper box border").
---@param initialPosition table { x, y }
---@param initialSize table|nil { width, height }
---@param borderColorKey string|nil Theme.COLORS key for border
---@param fillColorKey string|nil Theme.COLORS key for fill
---@param shouldShadow boolean|nil
---@param initialZIndex number|nil
---@return table box
function Box.create(initialPosition, initialSize, borderColorKey, fillColorKey, shouldShadow, initialZIndex)
	local self = {}
	local relativePosition = {
		x = (initialPosition and initialPosition.x) or 0,
		y = (initialPosition and initialPosition.y) or 0,
	}
	local position = { x = relativePosition.x, y = relativePosition.y }
	local size = initialSize and {
		width = initialSize.width or 0,
		height = initialSize.height or 0,
	} or { width = 0, height = 0 }
	local shadowed = shouldShadow == true
	local backgroundColorKey = borderColorKey
	local backgroundFillColorKey = fillColorKey
	local ZIndex = initialZIndex or 0

	function self.move(newPosition)
		position.x = newPosition.x
		position.y = newPosition.y
		relativePosition.x = newPosition.x
		relativePosition.y = newPosition.y
	end

	function self.getZIndex()
		return ZIndex
	end

	function self.calculateActualPosition(parentPosition)
		position = {
			x = parentPosition.x + relativePosition.x,
			y = parentPosition.y + relativePosition.y,
		}
	end

	function self.shift(xAmount, yAmount)
		relativePosition = {
			x = relativePosition.x + xAmount,
			y = relativePosition.y + yAmount,
		}
	end

	function self.getPosition()
		return { x = position.x, y = position.y }
	end

	function self.getSize()
		return { width = size.width, height = size.height }
	end

	function self.resize(newSize)
		size.width = newSize.width
		size.height = newSize.height
	end

	function self.setBackgroundColorKey(newColorKey)
		backgroundColorKey = newColorKey
	end

	function self.setBackgroundFillColorKey(newBackgroundFillColorKey)
		backgroundFillColorKey = newBackgroundFillColorKey
	end

	function self.getBackgroundFillColorKey()
		return backgroundFillColorKey
	end

	function self.show()
		if size.width == 0 and size.height == 0 then
			return
		end
		local border = resolveThemeColor(backgroundColorKey)
		local fill = resolveThemeColor(backgroundFillColorKey)
		if shadowed and Utils and Utils.calcShadowColor and fill ~= 0x00000000 then
			local shadow = Utils.calcShadowColor(fill)
			gui.drawRectangle(position.x + 1, position.y + 1, size.width, size.height, 0x00000000, shadow)
		end
		gui.drawRectangle(position.x, position.y, size.width, size.height, border, fill)
	end

	return self
end
