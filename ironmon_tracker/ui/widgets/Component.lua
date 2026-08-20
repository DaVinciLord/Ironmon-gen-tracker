-- Component adapted from NDS-Ironmon-Tracker UIBaseClasses/Component.lua
-- Thin wrapper that binds a Box to a parent Frame.

Component = {}

---@param initialFrame table|nil parent frame
---@param initialBox table box from Box.create
---@return table component
function Component.create(initialFrame, initialBox)
	local self = {}
	local frame = initialFrame
	local box = initialBox

	function self.calculateActualPosition(position)
		box.calculateActualPosition(position)
	end

	function self.show()
		box.show()
	end

	function self.getSize()
		return box.getSize()
	end

	function self.getFrame()
		return frame
	end

	function self.getPosition()
		return box.getPosition()
	end

	function self.getZIndex()
		return box.getZIndex()
	end

	function self.setBackgroundColorKey(newColorKey)
		box.setBackgroundColorKey(newColorKey)
	end

	function self.setBackgroundFillColorKey(newColorKey)
		box.setBackgroundFillColorKey(newColorKey)
	end

	function self.getBackgroundFillColorKey()
		return box.getBackgroundFillColorKey()
	end

	function self.resize(newSize)
		box.resize(newSize)
	end

	function self.move(newPosition)
		box.move(newPosition)
	end

	function self.shift(xAmount, yAmount)
		box.shift(xAmount, yAmount)
	end

	if frame ~= nil and frame.addControl then
		frame.addControl(self)
	end

	return self
end
