-- Run from any directory with: lua tools/gen1_route_data_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Constants = { BLANKLINE = "-" }
Utils = { formatSpecialCharacters = function(s) return s end }
dofile(repoRoot .. "ironmon_tracker/data/RouteData.lua")
local populateAvailableRoutes = RouteData.populateAvailableRoutes
RouteData.populateAvailableRoutes = function(maxMapId)
	RouteData.lastPopulatedMap = maxMapId
	return populateAvailableRoutes(maxMapId)
end

RouteData.initialize()
assert(RouteData.Info[0x0C].name == "Route 1")
assert(RouteData.Info[0x0C][RouteData.EncounterArea.LAND] ~= nil)
assert(RouteData.Info[0x00][RouteData.EncounterArea.SURFING] ~= nil)
assert(RouteData.Info[0x00][RouteData.EncounterArea.OLDROD] ~= nil)
assert(RouteData.Info[0x28].name == "Oak's Lab")
assert(RouteData.Info[0x36].name == "Pewter Gym")
assert(RouteData.Info[0x0B].name == "Map 0x0B", "Unknown maps must not be mislabeled as another generation")
assert(RouteData.Locations.IsInLab[0x28] and RouteData.Locations.IsInHallOfFame[0x76])
assert(RouteData.Locations.DarkAreas[0x52] and RouteData.Locations.DarkAreas[0xE8])
assert(RouteData.Locations.IsInSafariZone[0xDC] and RouteData.Locations.CanObtainBadge[0x36])
assert(RouteData.CombinedAreas.MtMoon and #RouteData.CombinedAreas.MtMoon == 3)
assert(RouteData.lastPopulatedMap == 0xF8)
assert(RouteData.getEncounterAreaByTerrain(4) == RouteData.EncounterArea.SURFING)
assert(RouteData.getEncounterAreaByTerrain(0) == RouteData.EncounterArea.LAND)
local pivots = RouteData.getPivotOrSafariRouteIds(false)
assert(pivots[1] == 0x0C and pivots[4] == 0x33)

print("Gen 1 route data smoke tests passed")
