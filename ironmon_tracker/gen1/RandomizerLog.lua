-- Keeps Besteon's log UI while constraining UPR parsing to RBY data shapes.
Gen1RandomizerLog = {}

local originalParseLog = RandomizerLog.parseLog
local originalParseRoutes = RandomizerLog.parseRoutes

Gen1RandomizerLog.RouteSetToMap = {
	[1]=0x0C,[2]=0x0D,[3]=0x0E,[4]=0x0F,[5]=0x10,[6]=0x11,[7]=0x11,
	[8]=0x12,[9]=0x13,[10]=0x14,[11]=0x15,[12]=0x16,[13]=0x17,[14]=0x17,
	[15]=0x18,[16]=0x18,[17]=0x19,[18]=0x1A,[19]=0x1B,[20]=0x1C,[21]=0x1D,
	[22]=0x1E,[23]=0x1F,[24]=0x20,[25]=0x20,[26]=0x21,[27]=0x22,[28]=0x23,[29]=0x24,
	[30]=0x33,[31]=0x3B,[32]=0x3C,[33]=0x3D,[34]=0x52,[35]=0x53,[36]=0x6C,
	[37]=0x90,[38]=0x91,[39]=0x92,[40]=0x93,[41]=0x94,
	[42]=0x9F,[43]=0xA0,[44]=0xA1,[45]=0xA1,[46]=0xA2,[47]=0xA2,[48]=0xA5,[49]=0xC0,
	[50]=0xC2,[51]=0xC5,[52]=0xC6,[53]=0xD6,[54]=0xD7,[55]=0xD8,
	[56]=0xD9,[57]=0xDA,[58]=0xDB,[59]=0xDC,[60]=0xE2,[61]=0xE3,[62]=0xE4,[63]=0xE8,
	-- Old/Good Rod tables are global in RBY. They are copied to every
	-- Super-Rod location after parsing.
	[64]=0x100,[65]=0x100,
	[66]=0x100,[67]=0x01,[68]=0x03,[69]=0x05,[70]=0x06,[71]=0x07,[72]=0x08,
	[73]=0x0F,[74]=0x11,[75]=0x23,[76]=0x24,[77]=0x15,[78]=0x16,[79]=0x17,
	[80]=0x18,[81]=0x1C,[82]=0x1D,[83]=0x1E,[84]=0x1F,[85]=0x20,[86]=0x21,
	[87]=0x22,[88]=0x05,[89]=0xDC,
}

function Gen1RandomizerLog.setupMappings()
	local allMovesSource = MoveData.Moves
	if RandomizerLog.areLanguagesMismatched() then
		local languageToLoad = Resources.Languages[GameSettings.language:upper()] or Resources.Default.Language
		local languageGameData = RandomizerLog.loadLanguageMappings(languageToLoad)
		if languageGameData.Game.MoveNames then
			allMovesSource = {}
			for id, name in ipairs(languageGameData.Game.MoveNames) do
				table.insert(allMovesSource, { id = id, name = name })
			end
		end
	end

	RandomizerLog.PokemonNameToIdMap = {}
	RandomizerLog.MoveNameToIdMap = {}
	for _, moveInfo in ipairs(allMovesSource) do
		if moveInfo.id ~= nil and not Utils.isNilOrEmpty(moveInfo.name) then
			local formattedName = RandomizerLog.formatInput(moveInfo.name) or ""
			RandomizerLog.MoveNameToIdMap[formattedName] = tonumber(moveInfo.id) or -1
		end
	end

	-- Kept empty until the inherited parser no longer references the mapping at
	-- all. RBY has no abilities.
	RandomizerLog.AbilityNameToIdMap = {}
	-- Native RBY encounter-set mapping is intentionally separate from the
	-- inherited Hoenn/Kanto remakes tables.
	RandomizerLog.RouteSetNumToIdMap = Gen1RandomizerLog.RouteSetToMap
end

function Gen1RandomizerLog.parseRoutes(logLines)
	local namedMaps = {
		["PALLET TOWN"]=0x100,["BOURG PALETTE"]=0x100,
		["VIRIDIAN CITY"]=0x01,["JADIELLE"]=0x01,["CERULEAN CITY"]=0x03,["AZURIA"]=0x03,
		["VERMILION CITY"]=0x05,["CARMIN SUR MER"]=0x05,["CELADON CITY"]=0x06,["CELADOPOLE"]=0x06,
		["FUCHSIA CITY"]=0x07,["PARMANIE"]=0x07,["CINNABAR ISLAND"]=0x08,["CRAMOIS'ILE"]=0x08,
		["VIRIDIAN FOREST"]=0x33,["FORET DE JADE"]=0x33,["POWER PLANT"]=0x53,["CENTRALE"]=0x53,
		["DIGLETT'S CAVE"]=0xC5,["DIGLETTS CAVE"]=0xC5,["CAVE TAUPIQUEUR"]=0xC5,
	}
	local floorMaps = {
		["MT MOON"]={0x3B,0x3C,0x3D},["MONT SELENITE"]={0x3B,0x3C,0x3D},
		["ROCK TUNNEL"]={[2]=0x52,[3]=0xE8},["GROTTE"]={[2]=0x52,[3]=0xE8},
		["VICTORY ROAD"]={0x6C,0xC2,0xC6},["ROUTE VICTOIRE"]={0x6C,0xC2,0xC6},
		["POKEMON TOWER"]={[3]=0x90,[4]=0x91,[5]=0x92,[6]=0x93,[7]=0x94},
		["TOUR POKEMON"]={[3]=0x90,[4]=0x91,[5]=0x92,[6]=0x93,[7]=0x94},
		["SEAFOAM ISLANDS"]={0x9F,0xA0,0xA1,0xA2,0xC0},["ILES ECUME"]={0x9F,0xA0,0xA1,0xA2,0xC0},
		["POKEMON MANSION"]={0xA5,0xD6,0xD7,0xD8},["MANOIR"]={0xA5,0xD6,0xD7,0xD8},
		["SAFARI ZONE"]={[2]=0xD9,[3]=0xDA,[4]=0xDB,[5]=0xDC},
		["PARC SAFARI"]={[2]=0xD9,[3]=0xDA,[4]=0xDB,[5]=0xDC},
		["CERULEAN CAVE"]={0xE2,0xE3,0xE4},["UNKNOWN DUNGEON"]={0xE2,0xE3,0xE4},
		["GROTTE INCONNUE"]={0xE2,0xE3,0xE4},
	}
	local function cleanName(value)
		value = (value or ""):upper():gsub("%[.-%]", "POKE"):gsub("[ÉÈÊ]", "E")
		return value:gsub("[^%w%s'%(%)%-]", ""):gsub("%s+", " "):match("^%s*(.-)%s*$")
	end
	local function resolveMap(name)
		local clean = cleanName(name)
		if clean:find("OLD ROD FISHING", 1, true) or clean:find("GOOD ROD FISHING", 1, true) then
			return 0x100
		end
		local routeNum = tonumber(clean:match("ROUTE%s+(%d+)") or clean:match("CHENAL%s+(%d+)"))
		if routeNum and routeNum >= 1 and routeNum <= 25 then return 0x0B + routeNum end
		for label, mapId in pairs(namedMaps) do
			if clean:find(label, 1, true) then return mapId end
		end
		local floor = tonumber(clean:match("%((%d+)%)")) or tonumber(clean:match("(%d+)[Ff]"))
		for label, maps in pairs(floorMaps) do
			if clean:find(label, 1, true) then return maps[floor or 1] end
		end
	end
	for _, line in ipairs(logLines) do
		local setNumber, encounterName = line:match(RandomizerLog.Sectors.Routes.NextRoutePattern)
		setNumber = tonumber(setNumber)
		if setNumber then
			local mapId = resolveMap(encounterName)
			if mapId then RandomizerLog.RouteSetNumToIdMap[setNumber] = mapId end
		end
	end

	RandomizerLog.EncounterTypes.GrassCave.logKey = "Grass/Cave"
	RandomizerLog.EncounterTypes.GrassCave.rates = { 0.20, 0.20, 0.15, 0.10, 0.10, 0.10, 0.05, 0.05, 0.04, 0.01 }
	RandomizerLog.EncounterTypes.Surfing.logKey = "Surfing"
	RandomizerLog.EncounterTypes.Surfing.rates = RandomizerLog.EncounterTypes.GrassCave.rates
	RandomizerLog.EncounterTypes.OldRod.logKey = "Old Rod Fishing"
	RandomizerLog.EncounterTypes.OldRod.rates = { 1.0 }
	RandomizerLog.EncounterTypes.GoodRod.logKey = "Good Rod Fishing"
	RandomizerLog.EncounterTypes.GoodRod.rates = { 0.5, 0.5 }
	RandomizerLog.EncounterTypes.SuperRod.logKey = "Super Rod Fishing"
	RandomizerLog.EncounterTypes.SuperRod.rates = { 0.25, 0.25, 0.25, 0.25 }

	originalParseRoutes(logLines)

	local pallet = RandomizerLog.Data.Routes[0x100] or RandomizerLog.Data.Routes[0x00] or {}
	if RandomizerLog.Data.Routes[0x100] then
		pallet.name = (RouteData.Info[0x00] or {}).name or pallet.name
		RandomizerLog.Data.Routes[0x00] = pallet
		RandomizerLog.Data.Routes[0x100] = nil
	end
	local globalOldRod = (pallet.EncountersAreas or {}).OldRod
	local globalGoodRod = (pallet.EncountersAreas or {}).GoodRod
	for _, route in pairs(RandomizerLog.Data.Routes or {}) do
		if route.EncountersAreas and route.EncountersAreas.SuperRod then
			route.EncountersAreas.OldRod = globalOldRod
			route.EncountersAreas.GoodRod = globalGoodRod
		end
	end
end

function Gen1RandomizerLog.parseLog(filepath)
	for _, sector in pairs(RandomizerLog.Sectors) do sector.LineNumber = nil end
	RandomizerLog.currentNidoranIsF = true
	return originalParseLog(filepath)
end

function Gen1RandomizerLog.apply()
	RandomizerLog.setupMappings = Gen1RandomizerLog.setupMappings
	RandomizerLog.parseLog = Gen1RandomizerLog.parseLog
	RandomizerLog.parseRoutes = Gen1RandomizerLog.parseRoutes
end

Gen1RandomizerLog.apply()

return Gen1RandomizerLog
