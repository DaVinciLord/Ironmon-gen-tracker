-- Keeps Besteon's log UI while constraining UPR parsing to RBY data shapes.
Gen1RandomizerLog = {}

local originalSetupMappings = RandomizerLog.setupMappings
local originalParseLog = RandomizerLog.parseLog

function Gen1RandomizerLog.setupMappings()
	originalSetupMappings()
	-- The inherited selector treats game=1/2 as Hoenn versions. Native RBY
	-- encounter-set mapping is intentionally separate from those tables.
	RandomizerLog.RouteSetNumToIdMap = {}
end

function Gen1RandomizerLog.parseLog(filepath)
	for _, sector in pairs(RandomizerLog.Sectors) do sector.LineNumber = nil end
	RandomizerLog.currentNidoranIsF = true
	return originalParseLog(filepath)
end

function Gen1RandomizerLog.apply()
	RandomizerLog.setupMappings = Gen1RandomizerLog.setupMappings
	RandomizerLog.parseLog = Gen1RandomizerLog.parseLog
	-- Never interpret an RBY encounter set through a Ruby/Emerald route table.
	RandomizerLog.parseRoutes = function() end
end

Gen1RandomizerLog.apply()

return Gen1RandomizerLog
