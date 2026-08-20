-- Layout engine adapted from NDS-Ironmon-Tracker UIBaseClasses/Layout.lua
-- Places child controls in a horizontal, vertical, or grid flow.

Layout = {}

Layout.ALIGNMENT = {
	HORIZONTAL = 0,
	VERTICAL = 1,
	GRID = 2,
	NONE = 3,
}

---Creates a layout that positions sibling controls inside a frame.
---@param initialAlignment number|nil Layout.ALIGNMENT.*
---@param initialSpacing number|nil pixels between items
---@param initialPadding table|nil { x, y }
---@param initialMaxItemsPerRow number|nil required for GRID
---@return table layout
function Layout.create(initialAlignment, initialSpacing, initialPadding, initialMaxItemsPerRow)
	local self = {}
	local frame = nil
	local alignment = initialAlignment or Layout.ALIGNMENT.VERTICAL
	local spacing = initialSpacing or 0
	local maxItemsPerRow = initialMaxItemsPerRow or 0
	local padding = initialPadding or { x = 0, y = 0 }
	if padding.x == nil then padding.x = 0 end
	if padding.y == nil then padding.y = 0 end
	local items = {}

	function self.setItems(newItems)
		items = newItems or {}
	end

	function self.setFrame(newFrame)
		frame = newFrame
	end

	function self.setAlignment(newAlignment)
		alignment = newAlignment
	end

	function self.setSpacing(newSpacing)
		spacing = newSpacing or 0
	end

	function self.setPadding(newPadding)
		padding = {
			x = (newPadding and newPadding.x) or 0,
			y = (newPadding and newPadding.y) or 0,
		}
	end

	function self.changeItemPositions()
		if frame == nil then return end
		local currentRowItems = 0
		local startPosition = frame.getPosition()
		local currentPosition = {
			x = startPosition.x + padding.x,
			y = startPosition.y + padding.y,
		}
		local startX = currentPosition.x

		for _, item in ipairs(items) do
			local visible = true
			if item.isVisible then
				visible = item.isVisible()
			end
			if visible then
				currentRowItems = currentRowItems + 1
				item.move(currentPosition)
				local size = item.getSize()
				if alignment == Layout.ALIGNMENT.HORIZONTAL then
					currentPosition = {
						x = currentPosition.x + size.width + spacing,
						y = currentPosition.y,
					}
				elseif alignment == Layout.ALIGNMENT.VERTICAL then
					currentPosition = {
						x = currentPosition.x,
						y = currentPosition.y + size.height + spacing,
					}
				elseif alignment == Layout.ALIGNMENT.GRID then
					if currentRowItems >= maxItemsPerRow and maxItemsPerRow > 0 then
						currentRowItems = 0
						currentPosition = {
							x = startX,
							y = currentPosition.y + size.height + spacing,
						}
					else
						currentPosition = {
							x = currentPosition.x + size.width + spacing,
							y = currentPosition.y,
						}
					end
				end
			end
		end
	end

	return self
end
