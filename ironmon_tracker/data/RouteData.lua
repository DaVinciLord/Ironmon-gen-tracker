RouteData = {}

-- key: mapId (mapLayoutId)
-- value: name = ('string'),
--        encounterArea = ('table')
RouteData.Info = {}

-- All route map icons are currently 20x20 pixels
RouteData.Icons = {
	BuildingDoorLarge = { filename = "building-door-large", },
	BuildingDoorSmall = { filename = "building-door-small", },
	CaveEntrance = { filename = "cave-entrance", },
	CityMap = { filename = "city-map", },
	EliteFourStatue = { filename = "elitefour-statue", },
	ForestTree = { filename = "forest-tree", },
	GymBuilding = { filename = "gym-building", },
	MountainTop = { filename = "mountain-top", },
	OceanWaves = { filename = "ocean-waves", },
	RouteSign = { filename = "route-sign", },
	RouteSignWooden = { filename = "route-sign-wooden", },
}
for _, icon in pairs(RouteData.Icons) do
	icon.getIconPath = function(self) return FileManager.buildImagePath("maps", self.filename, ".png") end
end

RouteData.AvailableRoutes = {}

RouteData.EncounterArea = {
	LAND = "Walking", -- Max 12 possible
	SURFING = "Surfing", -- Max 5 possible
	UNDERWATER = "Underwater", -- Max 5 possible(?)
	STATIC = "Static",
	ROCKSMASH = "RockSmash", -- Max 5 possible
	SUPERROD = "Super Rod", -- Max 10 possible between all rods
	GOODROD = "Good Rod",
	OLDROD = "Old Rod",
	TRAINER = "Trainer", -- Eventually want to show trainer info/teams per area
}

RouteData.OrderedEncounters = {
	RouteData.EncounterArea.LAND,
	RouteData.EncounterArea.SURFING,
	RouteData.EncounterArea.UNDERWATER,
	RouteData.EncounterArea.STATIC,
	RouteData.EncounterArea.ROCKSMASH,
	RouteData.EncounterArea.SUPERROD,
	RouteData.EncounterArea.GOODROD,
	RouteData.EncounterArea.OLDROD,
	RouteData.EncounterArea.TRAINER,
}

-- [Deprecated] Use PokemonData.dexMapNationalToInternal(id) instead.
RouteData.NatDexToIndex = {}

-- Maps the rodId from 'gSpecialVar_ItemId' to encounterArea
RouteData.Rods = {
	[76] = RouteData.EncounterArea.OLDROD,
	[77] = RouteData.EncounterArea.GOODROD,
	[78] = RouteData.EncounterArea.SUPERROD,
}

-- Allows the Tracker to verify if data can be updated based on the location of the player
RouteData.Locations = {
	CanPCHeal = {},
	CanObtainBadge = {},
	IsInLab = {},
	IsInHallOfFame = {},
	IsInSafariZone = {},
	EarlyGameCity = {},
	DarkAreas = {},
}
-- Maps a mapId to all its connected other mapIds that make up a complete dungeon (e.g. Pokemon Tower 1F-7F)
RouteData.CombinedAreas = {}

function RouteData.initialize()
	Gen1RouteData.initialize()
end

function RouteData.populateAvailableRoutes(maxMapId)
	maxMapId = maxMapId or 0
	RouteData.AvailableRoutes = {}

	if maxMapId < 0 then return end

	-- Iterate based on mapId order so the list is somewhat organized
	for mapId=0, maxMapId, 1 do
		local route = RouteData.Info[mapId]
		if route ~= nil and route.name ~= nil then
			for _, encounterArea in ipairs(RouteData.OrderedEncounters) do
				if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
					table.insert(RouteData.AvailableRoutes, Utils.formatSpecialCharacters(route.name))
					break
				end
			end
		end
	end
end

function RouteData.hasRoute(mapId)
	return mapId ~= nil and RouteData.Info[mapId] ~= nil and RouteData.Info[mapId] ~= {}
end

function RouteData.hasRouteEncounterArea(mapId, encounterArea)
	if encounterArea == nil or not RouteData.hasRoute(mapId) then return false end

	return RouteData.Info[mapId][encounterArea] ~= nil and RouteData.Info[mapId][encounterArea] ~= {}
end

---@param mapId? number Optional, defaults to current location
---@return boolean
function RouteData.hasRouteTrainers(mapId)
	local route = RouteData.Info[mapId or TrackerAPI.getMapId()]
	return route and route.trainers and #route.trainers > 0
end

function RouteData.countPokemonInArea(mapId, encounterArea)
	local areaInfo = RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	return #areaInfo
end

function RouteData.isFishingEncounter(encounterArea)
	return encounterArea == RouteData.EncounterArea.OLDROD or encounterArea == RouteData.EncounterArea.GOODROD or encounterArea == RouteData.EncounterArea.SUPERROD
end

---Returns true if the player has visibility in the current area, notably useful for checking dark caves.
---@param mapId? number The mapId to check for; default = current location
---@return boolean
function RouteData.canSeeDarkArea(mapId)
	mapId = mapId or TrackerAPI.getMapId()

	-- Can always see if not in an area/zone that's dark
	if not RouteData.Locations.DarkAreas[mapId] then
		return true
	end

	-- 0 = fully bright, 1 = flash active (RSE), 8 = fully dark
	local flashLevel = Program.readFlashLevel()
	return flashLevel <= 1
end

---Returns an ordered list of routes used for early game pivoting; or safari zones routes if `useSafari` is true
---@param useSafari? boolean Optional, if true will return safari zone routes instead of early game pivots
---@return table routeIds
function RouteData.getPivotOrSafariRouteIds(useSafari)
	return Gen1RouteData.getPivotOrSafariRouteIds(useSafari)
end

function RouteData.getEncounterAreaByTerrain(terrainId, battleFlags)
	return Gen1RouteData.getEncounterAreaByTerrain(terrainId)
end

---Returns true if this route has any encounter data (trainers or wild)
---@param mapId number
---@return boolean
function RouteData.hasAnyEncounters(mapId)
	if not RouteData.hasRoute(mapId) then
		return false
	end
	local route = RouteData.Info[mapId] or {}
	if route.trainers ~= nil then
		return true
	end
	for _, encounterArea in pairs(RouteData.EncounterArea or {}) do
		if route[encounterArea] ~= nil then
			return true
		end
	end
	return false
end

function RouteData.getNextAvailableEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return nil end

	local startingIndex = 0
	for index, area in ipairs(RouteData.OrderedEncounters) do
		if encounterArea == area then
			startingIndex = index
			break
		end
	end

	local numEncounters = #RouteData.OrderedEncounters
	local nextIndex = (startingIndex % numEncounters) + 1
	local maxIterations = numEncounters + 1
	while startingIndex ~= nextIndex and maxIterations >= 0 do
		encounterArea = RouteData.OrderedEncounters[nextIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		nextIndex = (nextIndex % numEncounters) + 1
		maxIterations = maxIterations - 1
	end

	return encounterArea
end

function RouteData.getPreviousAvailableEncounterArea(mapId, encounterArea)
	if not RouteData.hasRoute(mapId) then return nil end

	local startingIndex = 0
	for index, area in ipairs(RouteData.OrderedEncounters) do
		if encounterArea == area then
			startingIndex = index
			break
		end
	end

	local numEncounters = #RouteData.OrderedEncounters
	-- This fancy formula is due to indices starting at 1, thanks lua
	local previousIndex = ((startingIndex - 2 + numEncounters) % numEncounters) + 1
	while startingIndex ~= previousIndex do
		encounterArea = RouteData.OrderedEncounters[previousIndex]
		if RouteData.hasRouteEncounterArea(mapId, encounterArea) then
			break
		end
		previousIndex = ((previousIndex - 2 + numEncounters) % numEncounters) + 1
	end

	return encounterArea
end

-- Returns a table of all pokemon info in an area, where pokemonID is the key, and encounter rate/levels are the values
function RouteData.getEncounterAreaPokemon(mapId, encounterArea)
	if not RouteData.hasRouteEncounterArea(mapId, encounterArea) then return {} end

	local pIndex = RouteData.getIndexForGameVersion()
	local areaInfo = {}
	-- Eventually fix this by more clearly separating a route's name from its encounters. eg. (encounters.wild)
	---@diagnostic disable-next-line: param-type-mismatch
	for _, encounter in pairs(RouteData.Info[mapId][encounterArea]) do
		local info = {
			pokemonID = 0,
			rate = 0,
			minLv = 0,
			maxLv = 0,
		}
		for key, _ in pairs(info) do
			local encVal = encounter[key] or 0
			if type(encVal) == "number" then
				info[key] = encVal
			else -- encVal = {val, val, val}
				info[key] = encVal[pIndex]
			end
		end
		-- the pokedex #s stored in route encounter data are national pokedex #s
		info.pokemonID = PokemonData.dexMapNationalToInternal(info.pokemonID)

		-- Some version have fewer Pokemon than others; if so, the ID will be -1
		if PokemonData.isValid(info.pokemonID) then
			table.insert(areaInfo, {
				pokemonID = info.pokemonID,
				rate = info.rate,
				minLv = info.minLv,
				maxLv = info.maxLv,
			})
		end
	end
	return areaInfo
end

-- Different game versions have different Pokemon appear in an encounterArea: pokemonID = {ID, ID, ID}
function RouteData.getIndexForGameVersion()
	return 1
end

-- Builds out RouteData.CombinedAreas by grouping multi-floor buildings and caves together for easy look-ups
function RouteData.combineRouteAreas()
	-- Remove any existing mappings, if they exist
	for _, mapIdList in pairs(RouteData.CombinedAreas) do
		local maxIterations = 9999
		while #mapIdList > 0 and maxIterations > 0 do
			table.remove(mapIdList)
			maxIterations = maxIterations - 1
		end
	end
	-- Add in mappings
	for mapId, route in pairs(RouteData.Info) do
		-- The 'area' is the RouteData.CombinedAreas
		if type(route.area) == "table" then
			table.insert(route.area, mapId)
		end
	end
	-- After all mappings have been added, sort them
	for _, mapIdList in pairs(RouteData.CombinedAreas) do
		table.sort(mapIdList, function(a,b) return a < b end)
	end
end

RouteData.BlankRoute = {
	id = 0,
	name = Constants.BLANKLINE,
}

---Returns the name of a route or it's combined area
---@param mapId number
---@param simplifiedName? boolean Optional, if true will simplify the name by removing any parentheses; default false
---@return string
function RouteData.getRouteOrAreaName(mapId, simplifiedName)
	if not RouteData.hasRoute(mapId) then
		return "Unknown Area"
	end
	local route = RouteData.Info[mapId]
	local routeName = route.area and route.area.name or route.name
	if simplifiedName then
		routeName = Utils.replaceText(routeName, "%(.*%)", "")
	end
	return routeName
end

-- https://github.com/pret/pokefirered/blob/918ed2d31eeeb036230d0912cc2527b83788bc85/include/constants/layouts.h
-- https://www.serebii.net/pokearth/kanto/3rd/route1.shtml
