-- Native RBY map ids. Unknown interiors retain an explicit hexadecimal label
-- instead of being misidentified as a Hoenn/FRLG map.
Gen1RouteData = {}

Gen1RouteData.OldRodItem = 76
Gen1RouteData.GoodRodItem = 77
Gen1RouteData.SuperRodItem = 78

Gen1RouteData.MapNames = {
	[0x00]="Pallet Town", [0x01]="Viridian City", [0x02]="Pewter City", [0x03]="Cerulean City",
	[0x04]="Lavender Town", [0x05]="Vermilion City", [0x06]="Celadon City", [0x07]="Fuchsia City",
	[0x08]="Cinnabar Island", [0x09]="Indigo Plateau", [0x0A]="Saffron City",
	[0x0C]="Route 1", [0x0D]="Route 2", [0x0E]="Route 3", [0x0F]="Route 4",
	[0x10]="Route 5", [0x11]="Route 6", [0x12]="Route 7", [0x13]="Route 8",
	[0x14]="Route 9", [0x15]="Route 10", [0x16]="Route 11", [0x17]="Route 12",
	[0x18]="Route 13", [0x19]="Route 14", [0x1A]="Route 15", [0x1B]="Route 16",
	[0x1C]="Route 17", [0x1D]="Route 18", [0x1E]="Route 19", [0x1F]="Route 20",
	[0x20]="Route 21", [0x21]="Route 22", [0x22]="Route 23", [0x23]="Route 24", [0x24]="Route 25",
	[0x28]="Oak's Lab", [0x29]="Viridian Pokemon Center", [0x2D]="Viridian Gym",
	[0x33]="Viridian Forest", [0x36]="Pewter Gym", [0x3A]="Pewter Pokemon Center",
	[0x3B]="Mt. Moon 1F", [0x3C]="Mt. Moon B1F", [0x3D]="Mt. Moon B2F",
	[0x40]="Cerulean Pokemon Center", [0x41]="Cerulean Gym",
	[0x52]="Rock Tunnel 1F", [0x53]="Power Plant",
	[0x59]="Vermilion Pokemon Center", [0x5C]="Vermilion Gym",
	[0x5F]="S.S. Anne 1F", [0x60]="S.S. Anne 2F", [0x61]="S.S. Anne 3F",
	[0x62]="S.S. Anne B1F", [0x63]="S.S. Anne Bow", [0x64]="S.S. Anne Kitchen",
	[0x65]="S.S. Anne Captain's Room", [0x66]="S.S. Anne 1F Rooms", [0x67]="S.S. Anne 2F Rooms",
	[0x68]="S.S. Anne B1F Rooms", [0x6C]="Victory Road 1F", [0x71]="Lance's Room",
	[0x76]="Hall of Fame", [0x78]="Champion's Room",
	[0x85]="Celadon Pokemon Center", [0x86]="Celadon Gym",
	[0x8D]="Lavender Pokemon Center",
	[0x8E]="Pokemon Tower 1F", [0x8F]="Pokemon Tower 2F", [0x90]="Pokemon Tower 3F",
	[0x91]="Pokemon Tower 4F", [0x92]="Pokemon Tower 5F", [0x93]="Pokemon Tower 6F",
	[0x94]="Pokemon Tower 7F", [0x9A]="Fuchsia Pokemon Center", [0x9D]="Fuchsia Gym",
	[0x9F]="Seafoam Islands B1F", [0xA0]="Seafoam Islands B2F", [0xA1]="Seafoam Islands B3F",
	[0xA2]="Seafoam Islands B4F", [0xA5]="Pokemon Mansion 1F", [0xA6]="Cinnabar Gym",
	[0xAB]="Cinnabar Pokemon Center", [0xAE]="Indigo Plateau Lobby",
	[0xB1]="Fighting Dojo", [0xB2]="Saffron Gym", [0xB5]="Silph Co. 1F",
	[0xB6]="Saffron Pokemon Center", [0xC0]="Seafoam Islands 1F",
	[0xC2]="Victory Road 2F", [0xC5]="Diglett's Cave", [0xC6]="Victory Road 3F",
	[0xC7]="Rocket Hideout B1F", [0xC8]="Rocket Hideout B2F", [0xC9]="Rocket Hideout B3F",
	[0xCA]="Rocket Hideout B4F", [0xCF]="Silph Co. 2F", [0xD0]="Silph Co. 3F",
	[0xD1]="Silph Co. 4F", [0xD2]="Silph Co. 5F", [0xD3]="Silph Co. 6F",
	[0xD4]="Silph Co. 7F", [0xD5]="Silph Co. 8F",
	[0xD6]="Pokemon Mansion 2F", [0xD7]="Pokemon Mansion 3F",
	[0xD8]="Pokemon Mansion B1F", [0xD9]="Safari Zone East", [0xDA]="Safari Zone North",
	[0xDB]="Safari Zone West", [0xDC]="Safari Zone Center", [0xE2]="Cerulean Cave 2F",
	[0xE3]="Cerulean Cave B1F", [0xE4]="Cerulean Cave 1F", [0xE8]="Rock Tunnel B1F",
	[0xE9]="Silph Co. 9F", [0xEA]="Silph Co. 10F", [0xEB]="Silph Co. 11F",
	[0xF5]="Lorelei's Room", [0xF6]="Bruno's Room", [0xF7]="Agatha's Room",
}

Gen1RouteData.WildMaps = {
	[0x0C]=true,[0x0D]=true,[0x0E]=true,[0x0F]=true,[0x10]=true,[0x11]=true,[0x12]=true,
	[0x13]=true,[0x14]=true,[0x15]=true,[0x16]=true,[0x17]=true,[0x18]=true,[0x19]=true,
	[0x1A]=true,[0x1B]=true,[0x1C]=true,[0x1D]=true,[0x1E]=true,[0x1F]=true,[0x20]=true,
	[0x21]=true,[0x22]=true,[0x23]=true,[0x24]=true,[0x33]=true,[0x3B]=true,[0x3C]=true,
	[0x3D]=true,[0x52]=true,[0x53]=true,[0x6C]=true,[0x8F]=true,[0x90]=true,[0x91]=true,
	[0x92]=true,[0x93]=true,[0x94]=true,[0x9F]=true,[0xA0]=true,[0xA1]=true,[0xA2]=true,
	[0xA5]=true,[0xC0]=true,[0xC2]=true,[0xC5]=true,[0xC6]=true,[0xC7]=true,[0xC8]=true,
	[0xC9]=true,[0xCA]=true,[0xD6]=true,[0xD7]=true,[0xD8]=true,[0xD9]=true,[0xDA]=true,
	[0xDB]=true,[0xDC]=true,[0xE2]=true,[0xE3]=true,[0xE4]=true,[0xE8]=true,
}

-- Maps with a water encounter table. Grass/cave and surfing must stay distinct.
Gen1RouteData.SurfMaps = {
	[0x00]=true,[0x03]=true,[0x05]=true,[0x06]=true,[0x07]=true,[0x08]=true,
	[0x0F]=true,[0x11]=true,[0x15]=true,[0x16]=true,[0x17]=true,[0x18]=true,
	[0x1C]=true,[0x1D]=true,[0x1E]=true,[0x1F]=true,[0x20]=true,[0x21]=true,
	[0x22]=true,[0x23]=true,[0x24]=true,[0x9F]=true,[0xA0]=true,[0xA1]=true,
	[0xA2]=true,[0xC0]=true,[0xDC]=true,[0xD9]=true,[0xDA]=true,[0xDB]=true,
}

-- Super Rod locations. Old/Good Rod are global in RBY and are copied onto
-- every Super Rod map so scouting never lands on the synthetic 0x100 id.
Gen1RouteData.FishingMaps = {
	[0x00]=true,[0x01]=true,[0x03]=true,[0x05]=true,[0x06]=true,[0x07]=true,[0x08]=true,
	[0x0F]=true,[0x11]=true,[0x15]=true,[0x16]=true,[0x17]=true,[0x18]=true,
	[0x1C]=true,[0x1D]=true,[0x1E]=true,[0x1F]=true,[0x20]=true,[0x21]=true,
	[0x22]=true,[0x23]=true,[0x24]=true,[0xDC]=true,
}

local function readByte(address)
	if not address or not Memory or not Memory.readbyte then return 0 end
	return Memory.readbyte(address) or 0
end

function Gen1RouteData.initialize()
	RouteData.Info = {}
	RouteData.AvailableRoutes = {}
	RouteData.Locations = {
		CanPCHeal = {}, CanObtainBadge = {}, IsInLab = { [0x28] = true },
		IsInHallOfFame = { [0x76] = true }, IsInSafariZone = {}, EarlyGameCity = {}, DarkAreas = {},
	}
	RouteData.CombinedAreas = {
		MtMoon = { 0x3B, 0x3C, 0x3D },
		RockTunnel = { 0x52, 0xE8 },
		PokemonTower = { 0x8E, 0x8F, 0x90, 0x91, 0x92, 0x93, 0x94 },
		SafariZone = { 0xD9, 0xDA, 0xDB, 0xDC },
		SeafoamIslands = { 0xC0, 0x9F, 0xA0, 0xA1, 0xA2 },
		VictoryRoad = { 0x6C, 0xC2, 0xC6 },
		CeruleanCave = { 0xE4, 0xE2, 0xE3 },
		PokemonMansion = { 0xA5, 0xD6, 0xD7, 0xD8 },
		SSAnne = { 0x5F, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68 },
		RocketHideout = { 0xC7, 0xC8, 0xC9, 0xCA },
		SilphCo = { 0xB5, 0xCF, 0xD0, 0xD1, 0xD2, 0xD3, 0xD4, 0xD5, 0xE9, 0xEA, 0xEB },
		EliteFour = { 0xF5, 0xF6, 0xF7, 0x71, 0x78 },
	}
	for mapId = 0, 0xF8 do
		local route = { id = mapId, name = Gen1RouteData.MapNames[mapId] or string.format("Map 0x%02X", mapId) }
		if Gen1RouteData.WildMaps[mapId] and RouteData.EncounterArea.LAND then
			route[RouteData.EncounterArea.LAND] = {}
		end
		if Gen1RouteData.SurfMaps[mapId] and RouteData.EncounterArea.SURFING then
			route[RouteData.EncounterArea.SURFING] = {}
		end
		if Gen1RouteData.FishingMaps[mapId] then
			if RouteData.EncounterArea.OLDROD then route[RouteData.EncounterArea.OLDROD] = {} end
			if RouteData.EncounterArea.GOODROD then route[RouteData.EncounterArea.GOODROD] = {} end
			if RouteData.EncounterArea.SUPERROD then route[RouteData.EncounterArea.SUPERROD] = {} end
		end
		RouteData.Info[mapId] = route
	end
	for _, mapId in ipairs({ 0x29, 0x3A, 0x40, 0x59, 0x85, 0x8D, 0x9A, 0xAB, 0xAE, 0xB6 }) do
		RouteData.Locations.CanPCHeal[mapId] = true
	end
	for _, mapId in ipairs({ 0x36, 0x41, 0x5C, 0x86, 0x9D, 0xB2, 0xA6, 0x2D }) do
		RouteData.Locations.CanObtainBadge[mapId] = true
	end
	for _, mapId in ipairs({ 0xD9, 0xDA, 0xDB, 0xDC }) do
		RouteData.Locations.IsInSafariZone[mapId] = true
	end
	RouteData.Locations.DarkAreas[0x52] = true
	RouteData.Locations.DarkAreas[0xE8] = true
	RouteData.Locations.EarlyGameCity[0x00] = true
	RouteData.Locations.EarlyGameCity[0x01] = true
	for _, maps in pairs(RouteData.CombinedAreas) do
		for _, mapId in ipairs(maps) do
			if RouteData.Info[mapId] then RouteData.Info[mapId].area = maps end
		end
	end
	if Gen1TrainerData and Gen1TrainerData.applyRouteTrainers then
		Gen1TrainerData.applyRouteTrainers()
	end
	RouteData.populateAvailableRoutes(0xF8)
end

function Gen1RouteData.getEncounterAreaByTerrain(terrainId)
	if terrainId == 4 or terrainId == 5 then return RouteData.EncounterArea.SURFING end
	return RouteData.EncounterArea.LAND
end

function Gen1RouteData.getCurrentEncounterArea()
	local item = readByte(GameSettings.curItem)
	if item ~= Gen1RouteData.OldRodItem and item ~= Gen1RouteData.GoodRodItem and item ~= Gen1RouteData.SuperRodItem then
		item = (Gen1Runtime and Gen1Runtime.lastRodItem) or 0
	end
	if item == Gen1RouteData.OldRodItem then return RouteData.EncounterArea.OLDROD end
	if item == Gen1RouteData.GoodRodItem then return RouteData.EncounterArea.GOODROD end
	if item == Gen1RouteData.SuperRodItem then return RouteData.EncounterArea.SUPERROD end
	if readByte(GameSettings.walkBikeSurf) == 2 then return RouteData.EncounterArea.SURFING end
	return RouteData.EncounterArea.LAND
end

function Gen1RouteData.consumeEncounterArea()
	local area = Gen1RouteData.getCurrentEncounterArea()
	if Gen1Runtime then Gen1Runtime.lastRodItem = nil end
	return area
end

function Gen1RouteData.getPivotOrSafariRouteIds(useSafari)
	if useSafari then return { 0xD9, 0xDA, 0xDB, 0xDC } end
	return { 0x0C, 0x0D, 0x21, 0x33 }
end

RouteData.initialize = Gen1RouteData.initialize
RouteData.getEncounterAreaByTerrain = Gen1RouteData.getEncounterAreaByTerrain
RouteData.getPivotOrSafariRouteIds = Gen1RouteData.getPivotOrSafariRouteIds
RouteData.consumeEncounterArea = Gen1RouteData.consumeEncounterArea
RouteData.getCurrentEncounterArea = Gen1RouteData.getCurrentEncounterArea

return Gen1RouteData
