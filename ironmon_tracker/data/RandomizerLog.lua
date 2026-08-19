-- A collection of tools for viewing a Randomized Pokémon game log
RandomizerLog = {
	-- Developer settings
	Settings = {
		UsePokemonNamesFromLog = true,
	},
}

RandomizerLog.Patterns = {
	RandomizerVersion = "Randomizer Version:%s*([^%s]+)%s*$", -- Note: log file line 1 does NOT start with "Rando..."
	RandomizerSeed = "^Random Seed:%s*(%d+)%s*$",
	RandomizerSettings = "^Settings String:%s*(.+)%s*$",
	RandomizerGame = "^Randomization of%s*(.+)%s+completed",
	-- PokemonName = "([%a%d%.]* ?[%a%d%.!'%-♀♂%?]+).-", -- Temporarily removed, using more loose match criteria
	-- MoveName = "([%u%d%.'%-%?]+)", -- might figure out later
	-- ItemName = "([%u%d%.'%-%?]+)", -- might figure out later
	getSectorHeaderPattern = function(sectorName)
		return "^%-?%-?" .. (sectorName or "") .. ":?%-?%-?$"
	end,
}

-- Each Sector has Pattern(s) to match on, and the Sector Start Header LineNumber
RandomizerLog.Sectors = {
	-- First three lines: Randomizer Version, Random Seed, Settings String

	Evolutions = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Randomized Evolutions"),
		-- Matches: pokemon, evos
		PokemonEvosPattern = "^(.-)%s*%->%s*(.*)",
	},
	BaseStatsItems = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Base Stats & Types"),
		-- RBY columns: id, pokemon, types, HP, Attack, Defense, Speed, Special.
		PokemonBSTPattern = "^%s*(%d+)|([^|]+)|([^|]+)|%s*(%d+)|%s*(%d+)|%s*(%d+)|%s*(%d+)|%s*(%d+)",
	},
	Moves = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Move Data"),
		-- Matches: moveId, movename, movetype, power, acc, pp
		MovePattern = "^%s*(%d*)|(.-)%s*|(.-)%s*|%s*(%d*)|%s*(%d*)|%s*(%d*)",
	},
	MoveSets = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pokemon Movesets"),
		-- Matches: pokemon
		NextMonPattern = "^%d+%s(.-)%s*%->",
		-- Matches: movename
		EvoMovePattern = "^Learned upon evolution:%s(.*)",
		-- Matches: level, movename
		MovePattern = "^Level%s(%d+)%s?%s?:%s(.*)",
	},
	TMMoves = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("TM Moves"),
		-- Matches: tmNumber, movename
		TMPattern = "^TM(%d+)%s(.*)",
	},
	-- TODO: If TMs aren't randomized, then we don't store the original TM data, we probably need to do that
	TMCompatibility = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("TM Compatibility"),
		-- Matches: pokemon
		NextMonPattern = "^%s*%d+%s*(.-)%s*|(.*)",
		-- Matches: tmNumber
		TMPattern = "TM(%d+)",
	},
	Trainers = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Trainers Pokemon"),
		-- Matches: trainer_num, trainername, party
		NextTrainerPattern = "^#(%d+)%s%(([^=>]+)%s*=?>?%s*(.*)%)[^%s]*%s%-%s(.*)",
		-- Matches a party Pokémon name and level.
		PartyPattern = "([^,]+)",
		-- Matches: pokemon and helditem[optional], level
		PartyPokemonPattern = "%s*(.-)%sLv(%d+)",
	},
	Routes = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Wild Pokemon"),
		-- Matches: route_set_num, name_encounter
		NextRoutePattern = "^Set %#(%d+)%s*%-%s*(.-)%s*%(.*%)",
		-- Matches: pokemon, level_min, level_max, bst_spread (max 12 total lines; the order determines encounter percentage)
		RoutePokemonPattern = "^(.-)%s*Lvs?%s?(%d+)%-?(%d*)%s*(.*)",
	},
	-- Currently unused
	PickupItems = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern("Pickup Items"),
		LevelPattern = "",
		PercentPattern = "",
		ItemsPattern = "",
	},
	GameInfo = {
		HeaderPattern = RandomizerLog.Patterns.getSectorHeaderPattern(string.rep("%-", 66)),
	},
}

-- https://github.com/pret/pokefirered/blob/master/src/data/wild_encounters.json
RandomizerLog.EncounterTypes = {
	-- These keys (not logkeys) should be identical to LogTabRouteDetails.Tabs keys
	Trainers = {
		-- Not used for wild encounters
		logKey = "Trainers",
		internalArea = RouteData.EncounterArea.TRAINER,
		index = 1,
	},
	GrassCave = {
		logKey = "Grass/Cave",
		internalArea = RouteData.EncounterArea.LAND,
		rates = { 0.20, 0.20, 0.10, 0.10, 0.10, 0.10, 0.05, 0.05, 0.04, 0.04, 0.01, 0.01, },
		index = 2,
	},
	Surfing = {
		logKey = "Surfing",
		internalArea = RouteData.EncounterArea.SURFING,
		rates = { 0.60, 0.30, 0.05, 0.04, 0.01, },
		index = 3,
	},
	RockSmash = {
		logKey = "Rock Smash",
		internalArea = RouteData.EncounterArea.ROCKSMASH,
		rates = { 0.60, 0.30, 0.05, 0.04, 0.01, },
		index = 4,
	},
	OldRod = {
		logKey = "Fishing",
		internalArea = RouteData.EncounterArea.OLDROD,
		rates = { 0.70, 0.30, },
		index = 5,
	},
	GoodRod = {
		logKey = "Fishing",
		internalArea = RouteData.EncounterArea.GOODROD,
		rates = { 0.60, 0.20, 0.20, },
		index = 6,
	},
	SuperRod = {
		logKey = "Fishing",
		internalArea = RouteData.EncounterArea.SUPERROD,
		rates = { 0.40, 0.40, 0.15, 0.04, 0.01, },
		index = 7,
	},
}

-- A table of parsed data from the log file: Settings, Pokemon, TMs, Trainers, PickupItems
RandomizerLog.Data = {}

function RandomizerLog.initialize()
	-- Holds the path of the previously loaded log file. This is used to check if a new file needs to be parsed
	RandomizerLog.loadedLogPath = nil

	RandomizerLog.initBlankData()
end

-- Parses the log file at 'filepath' into the data object RandomizerLog.Data
function RandomizerLog.parseLog(filepath)
	for _, sector in pairs(RandomizerLog.Sectors) do sector.LineNumber = nil end
	RandomizerLog.currentNidoranIsF = true
	Utils.tempDisableBizhawkSound()
	local logLines = FileManager.readLinesFromFile(filepath)
	if #logLines == 0 then
		Utils.tempEnableBizhawkSound()
		return false
	end

	RandomizerLog.initBlankData()
	RandomizerLog.locateSectorLineStarts(logLines)

	RandomizerLog.setupMappings()
	RandomizerLog.parseRandomizerSettings(logLines)
	RandomizerLog.parseBaseStatsItems(logLines) -- required to parse first
	RandomizerLog.parseEvolutions(logLines)
	RandomizerLog.parseMoves(logLines)
	RandomizerLog.parseMoveSets(logLines)
	RandomizerLog.parseTMMoves(logLines)
	RandomizerLog.parseTMCompatibility(logLines)
	RandomizerLog.parseTrainers(logLines)
	RandomizerLog.parseRoutes(logLines)
	RandomizerLog.parsePickupItems(logLines)
	RandomizerLog.parseRandomizerGame(logLines)
	RandomizerLog.removeMappings()

	Utils.tempEnableBizhawkSound()
	return true
end

-- Returns sanitized input from the log file to be compatible with the Tracker. Trims spacing.
function RandomizerLog.formatInput(str)
	if str == nil then return nil end
	str = str:match("^%s*(.-)%s*$") or str -- remove leading/trailing spaces

	str = str:gsub("♀", " F")
	str = str:gsub("♂", " M")
	str = str:gsub("%?", "")
	str = str:gsub("’", "'")
	str = str:gsub("%[PK%]%[MN%]", "PKMN")

	str = Utils.formatSpecialCharacters(str)
	str = Utils.toLowerUTF8(str)
	return str
end

RandomizerLog.currentNidoranIsF = true

-- In some cases, the ♀/♂ in nidoran's names are stripped out. This is only way to figure out which is which
function RandomizerLog.alternateNidorans(name)
	if Utils.isNilOrEmpty(name) or Utils.toLowerUTF8(name) ~= "nidoran" then return name end

	local correctName
	if RandomizerLog.currentNidoranIsF then
		correctName = name .. " f"
	else
		correctName = name .. " m"
	end
	RandomizerLog.currentNidoranIsF = not RandomizerLog.currentNidoranIsF
	return correctName
end

-- Clears out the parsed data and initializes it for each valid PokemonId
function RandomizerLog.initBlankData()
	RandomizerLog.Data = {
		Settings = {},
		Pokemon = {},
		Moves = {},
		TMs = {},
		Trainers = {},
		Routes = {},
		PickupItems = {}, -- Currently unused
	}

	for id = 1, PokemonData.getTotal(), 1 do
		if id <= 251 or id >= 277 then -- celebi / treecko
			RandomizerLog.Data.Pokemon[id] = {
				Types = {},
			}
		end
	end
end

-- Locates the starting line number of each sector
function RandomizerLog.locateSectorLineStarts(logLines)
	if logLines == nil or #logLines == 0 then
		return
	end

	for i, line in ipairs(logLines) do
		-- If the sector hasn't been found yet, and its this line
		for _, sector in pairs(RandomizerLog.Sectors) do
			if sector.LineNumber == nil and string.find(line, sector.HeaderPattern) ~= nil then
				sector.LineNumber = i + 1 -- +1 to skip the header itself
				break -- and continue looking for other sectors
			end
		end
	end
end

function RandomizerLog.parseRandomizerSettings(logLines)
	if #logLines < 3 then return end
	local version = string.match(logLines[1], RandomizerLog.Patterns.RandomizerVersion)
	local randomSeed = string.match(logLines[2], RandomizerLog.Patterns.RandomizerSeed)
	local settingsString = string.match(logLines[3], RandomizerLog.Patterns.RandomizerSettings)
	RandomizerLog.Data.Settings.Version = version
	RandomizerLog.Data.Settings.RandomSeed = randomSeed
	RandomizerLog.Data.Settings.SettingsString = settingsString
end

-- This sector is near the end of the file
function RandomizerLog.parseRandomizerGame(logLines)
	if RandomizerLog.Sectors.GameInfo.LineNumber == nil then
		return
	end

	local game = string.match(logLines[RandomizerLog.Sectors.GameInfo.LineNumber] or "", RandomizerLog.Patterns.RandomizerGame)
	RandomizerLog.Data.Settings.Game = game
end

function RandomizerLog.parseEvolutions(logLines)
	if RandomizerLog.Sectors.Evolutions.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Evolutions.LineNumber
	while index <= #logLines do
		local pokemon, evos = string.match(logLines[index] or "", RandomizerLog.Sectors.Evolutions.PokemonEvosPattern)
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or evos == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil then
			return
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		RandomizerLog.Data.Pokemon[pokemonId].Evolutions = {}

		-- Replace any "and" to make parsing lowercase-named log files easier.
		evos = evos:gsub(" and ", ", ")
		for _, evo in pairs(Utils.split(evos, ",", true)) do
			local evoToAdd = RandomizerLog.formatInput(evo)
			evoToAdd = RandomizerLog.alternateNidorans(evoToAdd)
			local evoPokemonId = RandomizerLog.PokemonNameToIdMap[evoToAdd]
			if evoPokemonId ~= nil then
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].Evolutions, evoPokemonId)
				-- Add pre-evolutions to the evolved Pokemon
				if RandomizerLog.Data.Pokemon[evoPokemonId].PreEvolutions == nil then
					RandomizerLog.Data.Pokemon[evoPokemonId].PreEvolutions = {}
				end
				table.insert(RandomizerLog.Data.Pokemon[evoPokemonId].PreEvolutions, pokemonId)
			end
		end

		index = index + 1
	end
end

function RandomizerLog.parseBaseStatsItems(logLines)
	if RandomizerLog.Sectors.BaseStatsItems.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.BaseStatsItems.LineNumber + 1 -- remove the first line to skip the table header
	while index <= #logLines do
		local id, pokemon, types, hp, atk, def, spe, special = string.match(logLines[index] or "", RandomizerLog.Sectors.BaseStatsItems.PokemonBSTPattern)
		id = tonumber(tostring(id)) or 0
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or special == nil then
			return
		end

		local pokemonId = PokemonData.dexMapNationalToInternal(id)
		local pokemonData = RandomizerLog.Data.Pokemon[pokemonId]
		if pokemonData ~= nil then
			-- Setup future lookups to handle custom names
			RandomizerLog.PokemonNameToIdMap[pokemon] = pokemonId

			pokemonData.Name = Utils.firstToUpper(pokemon)

			types = RandomizerLog.formatInput(types) or ""
			local type1, type2 = string.match(types, "([^/]+)/?(.*)")
			pokemonData.Types = {
				PokemonData.Types[string.upper(type1 or "")] or PokemonData.Types.EMPTY,
				PokemonData.Types[string.upper(type2 or "")] or PokemonData.Types.EMPTY,
			}

			pokemonData.BaseStats = {
				hp = tonumber(hp) or 0,
				atk = tonumber(atk) or 0,
				def = tonumber(def) or 0,
				spe = tonumber(spe) or 0,
				special = tonumber(special) or 0,
			}
		end
		index = index + 1
	end
end

function RandomizerLog.parseMoves(logLines)
	if RandomizerLog.Sectors.Moves.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Moves.LineNumber + 1 -- remove the first line to skip the table header
	while index <= #logLines do
		local moveId, movename, movetype, power, acc, pp = string.match(logLines[index] or "", RandomizerLog.Sectors.Moves.MovePattern)
		moveId = tonumber(RandomizerLog.formatInput(moveId) or "") -- nil if not a number
		power = tonumber(RandomizerLog.formatInput(power) or "") -- nil if not a number
		acc = tonumber(RandomizerLog.formatInput(acc) or "") -- nil if not a number
		pp = tonumber(RandomizerLog.formatInput(pp) or "") -- nil if not a number

		-- If nothing matches, end of sector
		if moveId == nil or RandomizerLog.formatInput(movename) == nil or movetype == nil then
			return
		end

		RandomizerLog.Data.Moves[moveId] = {
			moveId = moveId,
			name = movename, -- For custom move names
			type = PokemonData.Types[Utils.toUpperUTF8(movetype or "")] or PokemonData.Types.EMPTY,
			power = power,
			acc = acc,
			pp = pp,
		}

		index = index + 1
	end
end

function RandomizerLog.parseMoveSets(logLines)
	if RandomizerLog.Sectors.MoveSets.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.MoveSets.LineNumber
	while index <= #logLines do
		local pokemon = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.NextMonPattern)
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- Search for the next Pokémon's name, or the end of sector
		-- I might fix this whole mess later when I'm awake
		while pokemon == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil do
			if string.find(logLines[index] or "", "^%-%-") ~= nil or index + 1 > #logLines then
				return
			end
			index = index + 1
			pokemon = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.NextMonPattern)
			pokemon = RandomizerLog.formatInput(pokemon)
			pokemon = RandomizerLog.alternateNidorans(pokemon)
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		local pokemonData = RandomizerLog.Data.Pokemon[pokemonId]
		if pokemonData ~= nil then
			pokemonData.MoveSet = {}
			-- RBY logs contain five base-stat lines between the species header and
			-- its first learned move.
			index = index + 6

			-- Check first if the first move is a special "Learned upon evolution" move
			local level = "0"
			local movename = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.EvoMovePattern)
			if movename == nil then
				level, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.MovePattern)
			end
			-- Search for each listed level-up move
			while level ~= nil and movename ~= nil do
				local nextMove = {
					level = tonumber(RandomizerLog.formatInput(level)) or 0,
					moveId = RandomizerLog.MoveNameToIdMap[RandomizerLog.formatInput(movename)] or 0,
					name = movename, -- For custom move names
				}
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].MoveSet, nextMove)

				index = index + 1
				if index > #logLines then
					return
				end
				level, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.MoveSets.MovePattern)
			end
		else
			index = index + 1
		end
	end
end

function RandomizerLog.parseTMMoves(logLines)
	if RandomizerLog.Sectors.TMMoves.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.TMMoves.LineNumber
	while index <= #logLines do
		local tmNumber, movename = string.match(logLines[index] or "", RandomizerLog.Sectors.TMMoves.TMPattern)
		tmNumber = tonumber(RandomizerLog.formatInput(tmNumber) or "") -- nil if not a number

		-- If nothing matches, end of sector
		if tmNumber == nil or RandomizerLog.formatInput(movename) == nil then
			return
		end

		RandomizerLog.Data.TMs[tmNumber] = {
			moveId = RandomizerLog.MoveNameToIdMap[RandomizerLog.formatInput(movename)] or 0,
			name = movename, -- For custom move names
		}

		index = index + 1
	end
end

function RandomizerLog.parseTMCompatibility(logLines)
	if RandomizerLog.Sectors.TMCompatibility.LineNumber == nil then
		return
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.TMCompatibility.LineNumber
	while index <= #logLines do
		local pokemon, tms = string.match(logLines[index] or "", RandomizerLog.Sectors.TMCompatibility.NextMonPattern)
		pokemon = RandomizerLog.formatInput(pokemon)
		pokemon = RandomizerLog.alternateNidorans(pokemon)

		-- If nothing matches, end of sector
		if pokemon == nil or tms == nil or RandomizerLog.PokemonNameToIdMap[pokemon] == nil then
			return
		end

		local pokemonId = RandomizerLog.PokemonNameToIdMap[pokemon]
		RandomizerLog.Data.Pokemon[pokemonId].TMMoves = {}

		for tmNumberStr in string.gmatch(tms, RandomizerLog.Sectors.TMCompatibility.TMPattern) do
			local tmNumber = tonumber(RandomizerLog.formatInput(tmNumberStr) or "") -- nil if not a number
			if tmNumber ~= nil and RandomizerLog.Data.TMs[tmNumber] ~= nil then
				table.insert(RandomizerLog.Data.Pokemon[pokemonId].TMMoves, tmNumber)
			end
		end
		index = index + 1
	end
end

function RandomizerLog.parseTrainers(logLines)
	if RandomizerLog.Sectors.Trainers.LineNumber == nil then
		return
	end

	local trainersToExclude = TrainerData.getExcludedTrainers()

	-- Parse the sector
	local index = RandomizerLog.Sectors.Trainers.LineNumber
	while index <= #logLines do
		local trainer_num, trainer_fullname, customname_full, party = string.match(logLines[index] or "", RandomizerLog.Sectors.Trainers.NextTrainerPattern)
		trainer_num = tonumber(RandomizerLog.formatInput(trainer_num) or "") -- nil if not a number
		trainer_fullname = RandomizerLog.formatInput(trainer_fullname)
		customname_full = RandomizerLog.formatInput(customname_full)

		-- If nothing matches, end of sector
		if trainer_num == nil or trainer_fullname == nil or party == nil then
			return
		end
		trainer_num = (TrainerData.GlobalLogIdToTrainerId or {})[trainer_num]
		if trainer_num == nil then return end

		local trainerClass, trainerName = RandomizerLog.splitTrainerClassAndName(trainer_fullname)
		local customClass, customName = RandomizerLog.splitTrainerClassAndName(customname_full)
		RandomizerLog.Data.Trainers[trainer_num] = {
			name = trainerName,
			class = trainerClass,
			fullname = trainer_fullname,
			customClass = customClass,
			customName = customName,
			customFullname = customname_full,
			minlevel = nil,
			maxlevel = nil,
			avgTrainerLv = nil, -- average of all party pokemon levels
			party = {},
		}
		local trainer = RandomizerLog.Data.Trainers[trainer_num]

		for partypokemon in string.gmatch(party, RandomizerLog.Sectors.Trainers.PartyPattern) do
			local pokemonAndItem, level = string.match(partypokemon, RandomizerLog.Sectors.Trainers.PartyPokemonPattern)
			local splitTable = Utils.split(pokemonAndItem, "@", true)
			local pokemon = RandomizerLog.formatInput(splitTable[1] or "")
			pokemon = RandomizerLog.alternateNidorans(pokemon)
			local helditem = RandomizerLog.formatInput(splitTable[2] or "")
			level = tonumber(RandomizerLog.formatInput(level) or "") or 0 -- nil if not a number

			if Utils.isNilOrEmpty(helditem) then
				helditem = nil -- don't waste storage if empty
			end

			if pokemon ~= nil and RandomizerLog.PokemonNameToIdMap[pokemon] ~= nil then
				local partyPokemon = {
					pokemonID = RandomizerLog.PokemonNameToIdMap[pokemon],
					helditem = helditem,
					level = level,
					moveIds = {}, -- Holds the 4 moves this Pokemon has at this current level, needed for searching
				}
				if level < (trainer.minlevel or 999) then
					trainer.minlevel = level
				end
				if level > (trainer.maxlevel or 0) then
					trainer.maxlevel = level
				end
				trainer.avgTrainerLv = (trainer.avgTrainerLv or 0) + level

				local pokemonLog = RandomizerLog.Data.Pokemon[partyPokemon.pokemonID] or {}
				local pokemonMoves = pokemonLog.MoveSet or {}

				-- Pokemon forget moves in order from 1st learned to last, so figure out current moveset by working backwards
				for j = #pokemonMoves, 1, -1 do
					if pokemonMoves[j].level <= partyPokemon.level then
						-- Insert at the front (i=1) to add them in "reverse" or bottom-up
						table.insert(partyPokemon.moveIds, 1, pokemonMoves[j].moveId)

						if #partyPokemon.moveIds >= 4 then
							break
						end
					end
				end

				table.insert(trainer.party, partyPokemon)
			end
		end
		if #trainer.party > 0 then
			trainer.avgTrainerLv = trainer.avgTrainerLv / #trainer.party
		end
		if trainersToExclude[trainer_num] or not TrainerData.shouldUseTrainer(trainer_num) then
			RandomizerLog.Data.Trainers[trainer_num] = nil
		end
		index = index + 1
	end
end

function RandomizerLog.parseRoutes(logLines)
	if RandomizerLog.Sectors.Routes.LineNumber == nil then
		return
	end

	RandomizerLog.prepareRoutes(logLines)

	local trainersToExclude = TrainerData.getExcludedTrainers()

	-- First add in routes that have trainers from Tracker data. The Log only has route info for wild encounters
	for mapId, routeInternal in pairs(RouteData.Info or {}) do
		local routeName = (RouteData.Info[mapId] or {}).name
		RandomizerLog.Data.Routes[mapId] = {
			name = routeName or "Unknown Area",
			numTrainers = 0,
			minTrainerLv = nil,
			maxTrainerLv = nil,
			avgTrainerLv = nil,
			numWilds = 0,
			minWildLv = nil,
			maxWildLv = nil,
			EncountersAreas = {},
		}
		local route = RandomizerLog.Data.Routes[mapId]
		if routeInternal.trainers ~= nil then
			route.EncountersAreas.Trainers = {
				logKey = RandomizerLog.EncounterTypes.Trainers.logKey,
				trainers = {},
			}
			-- Determine average level of the trainers in this area
			if #routeInternal.trainers > 0 then
				local numAdded, avgLevel = 0, 0
				for _, trainerId in ipairs(routeInternal.trainers) do
					-- Don't add in extra rivals if we know to remove them
					if not trainersToExclude[trainerId] and TrainerData.shouldUseTrainer(trainerId) then
						local trainerData = RandomizerLog.Data.Trainers[trainerId] or {}
						numAdded = numAdded + 1
						if (trainerData.minlevel or 999) < (route.minTrainerLv or 999) then
							route.minTrainerLv = trainerData.minlevel
						end
						if (trainerData.maxlevel or -1) > (route.maxTrainerLv or 0) then
							route.maxTrainerLv = trainerData.maxlevel
						end
						avgLevel = avgLevel + (trainerData.avgTrainerLv or 0)
						table.insert(route.EncountersAreas.Trainers.trainers, trainerId)
					end
				end
				if numAdded > 0 and avgLevel > 0 then
					route.numTrainers = numAdded
					route.avgTrainerLv = avgLevel / route.numTrainers
				end
			end
		end
	end

	-- The log combines the 3 different fishing rod encounters into a single encounter table
	local fishingEncs = {
		logKey = RandomizerLog.EncounterTypes.OldRod.logKey,
		rates = {},
	}
	for _, rate in ipairs(RandomizerLog.EncounterTypes.OldRod.rates) do
		table.insert(fishingEncs.rates, rate)
	end
	for _, rate in ipairs(RandomizerLog.EncounterTypes.GoodRod.rates) do
		table.insert(fishingEncs.rates, rate)
	end
	for _, rate in ipairs(RandomizerLog.EncounterTypes.SuperRod.rates) do
		table.insert(fishingEncs.rates, rate)
	end

	-- Parse the sector
	local index = RandomizerLog.Sectors.Routes.LineNumber
	while index <= #logLines do
		local route_set_num, name_encounter = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.NextRoutePattern)
		route_set_num = tonumber(RandomizerLog.formatInput(route_set_num) or "") -- nil if not a number
		name_encounter = RandomizerLog.formatInput(name_encounter)

		-- Search for the next Route, or the end of sector
		while route_set_num == nil or name_encounter == nil do
			if string.find(logLines[index] or "", "^%-%-") ~= nil or index + 1 > #logLines then
				RandomizerLog.finalizeRoutes()
				return
			end
			index = index + 1
			route_set_num, name_encounter = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.NextRoutePattern)
			route_set_num = tonumber(RandomizerLog.formatInput(route_set_num) or "") -- nil if not a number
			name_encounter = RandomizerLog.formatInput(name_encounter)
		end

		local routeName, encounterTypeKey, isFishingRoute
		for key, encTable in pairs(RandomizerLog.EncounterTypes) do
			-- Only wild encounter data in this section of the log
			if encTable ~= RandomizerLog.EncounterTypes.Trainers then
				local logKey = encTable.logKey or "NO LOG KEY USED"
				local encIndex = string.find(name_encounter, logKey:lower(), 1, true)
				if encIndex ~= nil then
					routeName = name_encounter:sub(1, encIndex - 2) -- Remove trailing space
					encounterTypeKey = key
					isFishingRoute = (logKey == "Fishing")
					break
				end
			end
		end

		local mapId = RandomizerLog.RouteSetNumToIdMap[route_set_num or 0] or 0
		if mapId ~= 0 and encounterTypeKey ~= nil then
			index = index + 1

			if RandomizerLog.Data.Routes[mapId] == nil then
				-- Create the route information table
				RandomizerLog.Data.Routes[mapId] = {
					name = routeName or "Unknown Area",
					numTrainers = 0,
					minTrainerLv = nil,
					maxTrainerLv = nil,
					avgTrainerLv = nil,
					numWilds = 0,
					minWildLv = nil,
					maxWildLv = nil,
					EncountersAreas = {},
				}
			end
			local route = RandomizerLog.Data.Routes[mapId]

			-- Condense route data for multiple encounter areas and trainer sets
			if isFishingRoute then
				route.EncountersAreas.OldRod = { setNumber = route_set_num, key = "OldRod", pokemon = {}, }
				route.EncountersAreas.GoodRod = { setNumber = route_set_num, key = "GoodRod", pokemon = {}, }
				route.EncountersAreas.SuperRod = { setNumber = route_set_num, key = "SuperRod", pokemon = {}, }
			else
				route.EncountersAreas[encounterTypeKey] = {
					setNumber = route_set_num,
					key = encounterTypeKey,
					pokemon = {},
				}
			end

			-- Max 12 total wild encounters, the order determines encounter percentage
			local encounterIndex = 1
			local encounterArea = route.EncountersAreas[encounterTypeKey]
			local encounterRates = RandomizerLog.EncounterTypes[encounterTypeKey].rates or {}

			if isFishingRoute then
				encounterArea = route.EncountersAreas.OldRod
				encounterRates = fishingEncs.rates
			end

			-- Search for each listed wild encounter
			local pokemon, level_min, level_max, bst_spread = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.RoutePokemonPattern)
			while pokemon ~= nil and level_min ~= nil do
				pokemon = RandomizerLog.formatInput(pokemon)
				local pokemonID = RandomizerLog.PokemonNameToIdMap[pokemon]
				if pokemonID ~= nil then
					if isFishingRoute then
						if encounterIndex <= 2 then
							encounterArea = route.EncountersAreas.OldRod
						elseif encounterIndex >= 3 and encounterIndex <= 5 then
							encounterArea = route.EncountersAreas.GoodRod
						else
							encounterArea = route.EncountersAreas.SuperRod
						end
					end

					-- Condense encounter data for multiple listings of the same Pokemon (combine levels & rates)
					if encounterArea.pokemon[pokemonID] == nil then
						encounterArea.pokemon[pokemonID] = {}
					end

					local enc = encounterArea.pokemon[pokemonID]
					local minLv = tonumber(RandomizerLog.formatInput(level_min)) or 0
					local maxLv = tonumber(RandomizerLog.formatInput(level_max)) or minLv
					enc.index = enc.index or encounterIndex
					enc.levelMin = math.min(enc.levelMin or 100, minLv)
					enc.levelMax = math.max(enc.levelMax or 0, maxLv)
					enc.rate = (enc.rate or 0) + (encounterRates[encounterIndex] or 0)
				end

				index = index + 1
				encounterIndex = encounterIndex + 1
				if index > #logLines then
					break
				end
				pokemon, level_min, level_max, bst_spread = string.match(logLines[index] or "", RandomizerLog.Sectors.Routes.RoutePokemonPattern)
			end


			-- If the levels for the route's wild encounters haven't been noted yet, do that
			-- Typically grass/cave encounters are parsed first from the log
			if route.minWildLv == nil or route.maxWildLv == nil then
				for _, p in pairs(encounterArea.pokemon or {}) do
					-- Count the # of unique pokemon in this area
					route.numWilds = route.numWilds + 1
					if (p.levelMin or 999) < (route.minWildLv or 999) then
						route.minWildLv = p.levelMin
					end
					if (p.levelMax or -1) > (route.maxWildLv or 0) then
						route.maxWildLv = p.levelMax
					end
				end
			end

			if index > #logLines then
				break
			end
		else
			index = index + 1
		end
	end
	RandomizerLog.finalizeRoutes()
end

-- Currently unused
function RandomizerLog.parsePickupItems(logLines)
	-- Utils.printDebug("#%s: %s >%s< %s", trainer_num, pokemon or "N/A", helditem or "N/A", level or 0)
end

function RandomizerLog.areLanguagesMismatched()
	return GameSettings.language:upper() ~= Resources.currentLanguage.Key:upper()
end

-- Returns the Pokemon name, either from the log itself (for custom names) or from internal Tracker data
function RandomizerLog.getPokemonName(pokemonID)
	if not PokemonData.isValid(pokemonID) then
		return Constants.BLANKLINE
	end

	local pokemonInternalName = PokemonData.Pokemon[pokemonID].name or Constants.BLANKLINE
	local pokemonLogName = RandomizerLog.Data.Pokemon[pokemonID].Name or pokemonInternalName

	-- When languages don't match, there's no way to tell if the name in the log is a custom name or not, assume it's not
	if RandomizerLog.areLanguagesMismatched() then
		return pokemonInternalName
	end

	-- By default, display the literal name as it appears in the log
	if RandomizerLog.Settings.UsePokemonNamesFromLog then
		return pokemonLogName
	else
		return pokemonInternalName
	end
end

-- Returns class, name of the trainer; split from 'fullname'
function RandomizerLog.splitTrainerClassAndName(fullname)
	fullname = fullname or ""
	local pattern = "(.-)%s*(%S+)$"
	if fullname:find("&", 1, true) then -- i.e. (Young Couple) (Gia & Jes)
		pattern = "(.-)%s*(%S+%s*&%s*%S+)$"
	elseif fullname:find("Lt. ", 1, true) then -- i.e. (Leader) (Lt. Surge)
		pattern = "(.-)%s*(%S+%s%S+)$"
	end
	local class, name = fullname:match(pattern)
	if name == nil then
		name = class
		class = nil
	end
	return class or "", name or ""
end

function RandomizerLog.setupMappings()
	local allMovesSource = MoveData.Moves

	-- If the game's language and tracker's display language don't match, load relevant Resources using the game language
	if RandomizerLog.areLanguagesMismatched() then
		local languageToLoad = Resources.Languages[GameSettings.language:upper()] or Resources.Default.Language
		local languageGameData = RandomizerLog.loadLanguageMappings(languageToLoad)

		if languageGameData.Game.MoveNames then
			allMovesSource = {}
			for id, name in ipairs(languageGameData.Game.MoveNames) do
				table.insert(allMovesSource, { id = id, name = name, })
			end
		end

	end

	-- Pokémon names -> IDs
	RandomizerLog.PokemonNameToIdMap = {} -- setup later while parsing the first important log sector

	-- Move names -> IDs
	RandomizerLog.MoveNameToIdMap = {}
	for _, moveInfo in ipairs(allMovesSource) do
		if moveInfo.id ~= nil and not Utils.isNilOrEmpty(moveInfo.name) then
			local formattedName = RandomizerLog.formatInput(moveInfo.name) or ""
			RandomizerLog.MoveNameToIdMap[formattedName] = tonumber(moveInfo.id) or -1
		end
	end

	RandomizerLog.RouteSetNumToIdMap = RandomizerLog.RouteSetToMap
end

function RandomizerLog.removeMappings()
	RandomizerLog.PokemonNameToIdMap = nil
	RandomizerLog.MoveNameToIdMap = nil
	RandomizerLog.RouteSetNumToIdMap = nil
	collectgarbage()
end

function RandomizerLog.loadLanguageMappings(language)
	local gamedata = {}

	-- Sub function used by other resource load functions
	local function dataLoadHelper(asset, data)
		if gamedata[asset] == nil then
			gamedata[asset] = {}
		end
		local assetTable = gamedata[asset]
		for key, val in pairs(data) do
			assetTable[key] = val
		end
	end

	local langFolder = FileManager.prependDir(FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Languages .. FileManager.slash)
	local langFilePath = langFolder .. language.FileName
	if FileManager.fileExists(langFilePath) then
		 -- Temp store the old callback function while reading in some Game Resources
		local originalScreenCallback = ScreenResources
		local originalGameCallback = GameResources
		ScreenResources = function(data) end -- Do nothing, only need Game data
		GameResources = function(data) dataLoadHelper("Game", data) end
		-- Load language resources into gamedata
		dofile(langFilePath)
		Resources.sanitizeTable(gamedata)
		ScreenResources = originalScreenCallback
		GameResources = originalGameCallback
	end

	return gamedata
end

RandomizerLog.RouteSetToMap = {
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

function RandomizerLog.prepareRoutes(logLines)
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
	local floorOrder = {
		"GROTTE INCONNUE", "UNKNOWN DUNGEON", "CERULEAN CAVE",
		"MONT SELENITE", "MT MOON", "ROUTE VICTOIRE", "VICTORY ROAD",
		"TOUR POKEMON", "POKEMON TOWER", "ILES ECUME", "SEAFOAM ISLANDS",
		"PARC SAFARI", "SAFARI ZONE", "POKEMON MANSION", "MANOIR", "ROCK TUNNEL", "GROTTE",
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
		for _, label in ipairs(floorOrder) do
			local maps = floorMaps[label]
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
end

function RandomizerLog.finalizeRoutes()
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
