-- Frame adapted from NDS-Ironmon-Tracker UIBaseClasses/Frame.lua
-- Container that owns child controls and optionally a Layout.

Frame = {}

---@param initialBox table from Box.create
---@param initialLayout table|nil from Layout.create
---@param initialFrame table|nil parent frame
---@param initialVisibility boolean|function|nil
---@return table frame
function Frame.create(initialBox, initialLayout, initialFrame, initialVisibility)
	local self = {}
	local layout = initialLayout
	local box = initialBox
	local parentFrame = initialFrame
	local visible = initialVisibility
	if visible == nil then
		visible = true
	end
	local controls = {}

	function self.recalculateChildPositions()
		if layout ~= nil then
			layout.setFrame(self)
			layout.setItems(controls)
			layout.changeItemPositions()
		else
			local parentPos = self.getPosition()
			for _, control in ipairs(controls) do
				if control.calculateActualPosition then
					control.calculateActualPosition(parentPos)
				end
			end
		end
		for _, control in ipairs(controls) do
			if control.recalculateChildPositions then
				control.recalculateChildPositions()
			end
		end
	end

	function self.calculateActualPosition(position)
		box.calculateActualPosition(position)
	end

	function self.setBackgroundColorKey(newColorKey)
		box.setBackgroundColorKey(newColorKey)
	end

	function self.setBackgroundFillColorKey(newColorKey)
		box.setBackgroundFillColorKey(newColorKey)
	end

	function self.changeParentFrame(newFrame, newIndex)
		if parentFrame ~= nil then
			parentFrame.removeControl(self)
		end
		parentFrame = newFrame
		parentFrame.addControl(self, newIndex)
	end

	function self.addControl(control, newIndex)
		if newIndex ~= nil then
			table.insert(controls, newIndex, control)
		else
			table.insert(controls, control)
		end
	end

	function self.removeControl(control)
		for i, c in ipairs(controls) do
			if c == control then
				table.remove(controls, i)
				return
			end
		end
	end

	function self.clearAllChildren()
		for _, control in ipairs(controls) do
			if control.clearAllChildren then
				control.clearAllChildren()
			end
		end
		controls = {}
	end

	function self.resize(newSize)
		box.resize(newSize)
	end

	function self.getPosition()
		return box.getPosition()
	end

	function self.getSize()
		return box.getSize()
	end

	function self.setVisibility(newVisibility)
		visible = newVisibility
	end

	function self.isVisible()
		if type(visible) == "function" then
			return visible()
		end
		return visible
	end

	function self.move(newPosition)
		box.move(newPosition)
	end

	function self.shift(xAmount, yAmount)
		box.shift(xAmount, yAmount)
	end

	function self.setLayoutAlignment(newAlignment)
		if layout then layout.setAlignment(newAlignment) end
	end

	function self.setLayoutSpacing(newSpacing)
		if layout then layout.setSpacing(newSpacing) end
	end

	function self.setLayoutPadding(newPadding)
		if layout then layout.setPadding(newPadding) end
	end

	function self.getZIndex()
		return box.getZIndex()
	end

	function self.show()
		if not self.isVisible() then
			return
		end
		box.show()
		self.recalculateChildPositions()
		local toDraw = {}
		for _, control in ipairs(controls) do
			table.insert(toDraw, control)
		end
		table.sort(toDraw, function(a, b)
			local zA = a.getZIndex and a.getZIndex() or 0
			local zB = b.getZIndex and b.getZIndex() or 0
			return zA < zB
		end)
		for _, control in ipairs(toDraw) do
			control.show()
		end
	end

	if parentFrame ~= nil then
		parentFrame.addControl(self)
	end

	return self
end
