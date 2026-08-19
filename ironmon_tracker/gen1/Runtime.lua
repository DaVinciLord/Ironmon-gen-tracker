-- Connects the native RBY readers to Besteon's current runtime state while the
-- remaining GBA-specific subsystems are removed in later slices.
Gen1Runtime = {}

local function asTrackerPokemon(data, isEnemy)
	if not data then return nil end
	data.nickname = Gen1SpeciesMap.getName(data.internalSpecies) or ""
	data.trainerID = isEnemy and -1 or data.trainerID
	data.currentExp = 0
	data.totalExp = 0
	data.heldItem = nil
	data.friendship = nil
	data.isEgg = 0
	return Program.DefaultPokemon:new(data)
end

function Gen1Runtime.readPartyPokemon(startAddress)
	return asTrackerPokemon(Gen1PokemonReader.readPartyPokemon(startAddress, Gen1SpeciesMap.getDexId), false)
end

function Gen1Runtime.readEnemyPokemon(startAddress)
	return asTrackerPokemon(Gen1PokemonReader.readBattlePokemon(startAddress, Gen1SpeciesMap.getDexId), true)
end

function Gen1Runtime.updatePokemonTeams()
	local count = math.min(Memory.readbyte(GameSettings.partyCount) or 0, 6)
	for slot = 1, 6 do
		if slot <= count then
			local address = GameSettings.partyMon1 + (slot - 1) * Gen1PokemonReader.PartyStructSize
			local pokemon = Gen1Runtime.readPartyPokemon(address)
			if Program.validPokemonData(pokemon) then
				Program.GameData.PlayerTeam[slot] = pokemon
			else
				Program.GameData.PlayerTeam[slot] = nil
			end
		else
			Program.GameData.PlayerTeam[slot] = nil
		end
	end

	local battleState = Memory.readbyte(GameSettings.battleState) or 0
	if battleState == 1 or battleState == 2 then
		local enemy = Gen1Runtime.readEnemyPokemon(GameSettings.enemyMon)
		Program.GameData.EnemyTeam[1] = Program.validPokemonData(enemy) and enemy or nil
	else
		Program.GameData.EnemyTeam[1] = nil
	end
	for slot = 2, 6 do Program.GameData.EnemyTeam[slot] = nil end
end

function Gen1Runtime.updateMapLocation()
	Program.GameData.mapId = Memory.readbyte(GameSettings.currentMap)
end

function Gen1Runtime.isValidMapLocation()
	local partyCount = Memory.readbyte(GameSettings.partyCount) or 0
	return Program.GameData.mapId ~= nil and partyCount > 0 and partyCount <= 6
end

function Gen1Runtime.readBadgeBits()
	if not Gen1Runtime.isValidMapLocation() then return 0 end
	return Memory.readbyte(GameSettings.badges) or 0
end

function Gen1Runtime.update()
	local forced = Program.updateRequired
	if Program.Frames.highAccuracyUpdate == 0 or forced then
		Gen1Runtime.updateMapLocation()
		if not Program.GameTimer.hasStarted and Gen1Runtime.isValidMapLocation() then
			Program.GameTimer:start()
		end
		Program.GameTimer:update()
	end

	if not Gen1Runtime.isValidMapLocation() then return end
	if Program.Frames.lowAccuracyUpdate == 0 or forced then
		Gen1Runtime.updatePokemonTeams()
		TeamViewArea.buildOutPartyScreen()
		if Program.currentScreen == StartupScreen then Program.currentScreen = TrackerScreen end
	end
	if Program.Frames.three_sec_update == 0 or forced then
		Program.updateBadgesObtained()
	end
	if Program.Frames.saveData == 0 then Tracker.AutoSave.saveToFile() end
	if Program.Frames.lowAccuracyUpdate == 0 or forced then CustomCode.afterProgramDataUpdate() end
end

function Gen1Runtime.apply()
	Program.Addresses.sizeofPokemonStruct = Gen1PokemonReader.PartyStructSize
	Program.updatePokemonTeams = Gen1Runtime.updatePokemonTeams
	Program.readNewPokemon = Gen1Runtime.readPartyPokemon
	Program.updateMapLocation = Gen1Runtime.updateMapLocation
	Program.isValidMapLocation = Gen1Runtime.isValidMapLocation
	Program.readBadgeBits = Gen1Runtime.readBadgeBits
	Program.update = Gen1Runtime.update
end

function Gen1Runtime.initialize()
	Gen1Runtime.apply()
end

Gen1Runtime.apply()

return Gen1Runtime
