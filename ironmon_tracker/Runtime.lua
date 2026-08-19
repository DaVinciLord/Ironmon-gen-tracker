-- Connects the native RBY readers to Besteon's current runtime state while the
-- remaining GBA-specific subsystems are removed in later slices.
Gen1Runtime = {}

local function asTrackerPokemon(data, isEnemy)
	if not data then return nil end
	data.nickname = Gen1SpeciesMap.getName(data.internalSpecies) or ""
	data.trainerID = isEnemy and -1 or data.trainerID
	-- The working Yellow FR tracker stored the species byte as personality so
	-- Tracker.getPokemon would not treat a real party member as an empty GBA slot.
	data.personality = data.internalSpecies or data.pokemonID or 1
	data.currentExp = 0
	data.totalExp = 100
	if not isEnemy and data.experience and data.level and data.level < 100 then
		local internal = PokemonData.Pokemon[data.pokemonID] or {}
		local atLevel = Gen1DataAdapter.expForLevel(internal.growthRate, data.level)
		local atNextLevel = Gen1DataAdapter.expForLevel(internal.growthRate, data.level + 1)
		data.currentExp = math.max(0, math.min(data.experience - atLevel, atNextLevel - atLevel))
		data.totalExp = math.max(1, atNextLevel - atLevel)
	end
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
	local count = Memory.readbyte(GameSettings.partyCount) or 0
	if count < 1 or count > 6 then
		count = 6
	end
	for slot = 1, 6 do
		Program.GameData.PlayerTeam[slot] = nil
		if slot <= count then
			local address = GameSettings.partyMon1 + (slot - 1) * Gen1PokemonReader.PartyStructSize
			local internalId = Memory.readbyte(address) or 0
			if internalId ~= 0 then
				local pokemon = Gen1Runtime.readPartyPokemon(address)
				if Program.validPokemonData(pokemon) then
					Program.GameData.PlayerTeam[slot] = pokemon
				end
			end
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
	-- Pallet Town is map 0. The working Yellow FR tracker treated any assigned
	-- mapId as in-game, including 0, and did not wait on partyCount.
	return Program.GameData.mapId ~= nil
end

function Gen1Runtime.readBadgeBits()
	if not Gen1Runtime.isValidMapLocation() then return 0 end
	return Memory.readbyte(GameSettings.badges) or 0
end

function Gen1Runtime.getPokemonTypes(isOwn)
	local address = (isOwn and GameSettings.battleMon or GameSettings.enemyMon) + 5
	local first = Gen1DataAdapter.TypeIndexMap[Memory.readbyte(address)] or PokemonData.Types.UNKNOWN
	local second = Gen1DataAdapter.TypeIndexMap[Memory.readbyte(address + 1)] or PokemonData.Types.UNKNOWN
	if second == first then second = PokemonData.Types.EMPTY end
	return { first, second }
end

function Gen1Runtime.getMoveIdFromTMHMNumber(number, isHM)
	if type(number) ~= "number" or number < 1 or number > (isHM and 5 or 50) then return 0 end
	return Memory.readbyte(GameSettings.tmMoves + number - 1 + (isHM and 50 or 0)) or 0
end

function Gen1Runtime.getTMsHMsBagItems()
	local tms, hms = {}, {}
	for itemId, quantity in pairs((Program.GameData.Items or {}).Other or {}) do
		if MiscData.TMs[itemId] then table.insert(tms, { id = itemId, quantity = quantity }) end
		if MiscData.HMs[itemId] then table.insert(hms, { id = itemId, quantity = quantity }) end
	end
	table.sort(tms, function(a, b) return a.id < b.id end)
	table.sort(hms, function(a, b) return a.id < b.id end)
	return tms, hms
end

function Gen1Runtime.getExtras() return { lefts = {}, rights = {}, bumps = {} } end
function Gen1Runtime.getLearnedMoveInfoTable()
	local empty = { pokemonID = nil, level = nil, moveId = nil }
	local moveId = GameSettings.moveNum and Memory.readbyte(GameSettings.moveNum) or 0
	local slot = (GameSettings.whichPokemon and Memory.readbyte(GameSettings.whichPokemon) or 0) + 1
	if moveId < 1 or moveId > 165 or slot < 1 or slot > 6 then
		Gen1Runtime.rememberPartyLevels()
		return empty
	end
	local pokemon = Tracker.getPokemon(slot, true)
	local previousLevel = (Gen1Runtime.lastPartyLevels or {})[slot]
		or ((Program.GameData.PlayerTeam or {})[slot] or {}).level
	Gen1Runtime.rememberPartyLevels()
	if not pokemon or not previousLevel or (pokemon.level or 0) <= previousLevel then
		return empty
	end
	return { pokemonID = pokemon.pokemonID, level = pokemon.level, moveId = moveId }
end

function Gen1Runtime.rememberPartyLevels()
	Gen1Runtime.lastPartyLevels = Gen1Runtime.lastPartyLevels or {}
	for slot = 1, 6 do
		local pokemon = Tracker.getPokemon and Tracker.getPokemon(slot, true)
			or (Program.GameData.PlayerTeam or {})[slot]
		if pokemon and pokemon.level then
			Gen1Runtime.lastPartyLevels[slot] = pokemon.level
		end
	end
end

local function emptyItems()
	return { healingTotal = 0, healingPercentage = 0, healingValue = 0,
		PokeBalls = {}, HPHeals = {}, PPHeals = {}, StatusHeals = {}, EvoStones = {}, Other = {} }
end

function Gen1Runtime.updateBagItems()
	local items = emptyItems()
	local count = math.min(Memory.readbyte(GameSettings.bagCount) or 0, 20)
	for slot = 0, count - 1 do
		local itemId = Memory.readbyte(GameSettings.bagItems + slot * 2)
		local quantity = Memory.readbyte(GameSettings.bagItems + slot * 2 + 1)
		if itemId and itemId ~= 0 and itemId ~= 0xFF and quantity > 0 then
			if MiscData.PokeBalls[itemId] then items.PokeBalls[itemId] = quantity end
			if MiscData.HealingItems[itemId] then items.HPHeals[itemId] = quantity end
			if MiscData.PPItems[itemId] then items.PPHeals[itemId] = quantity end
			if MiscData.StatusItems[itemId] then items.StatusHeals[itemId] = quantity end
			if MiscData.EvolutionStones[itemId] then items.EvoStones[itemId] = quantity end
			if not (items.PokeBalls[itemId] or items.HPHeals[itemId] or items.PPHeals[itemId]
				or items.StatusHeals[itemId] or items.EvoStones[itemId]) then items.Other[itemId] = quantity end
		end
	end
	Program.GameData.Items = items
	Program.recalcLeadPokemonHealingInfo()
end

function Gen1Runtime.updateRepelSteps()
	local remaining = GameSettings.repelSteps and Memory.readbyte(GameSettings.repelSteps) or 0
	if remaining > 0 then
		Program.ActiveRepel.inUse = true
		if remaining ~= Program.ActiveRepel.stepCount then
			Program.ActiveRepel.stepCount = remaining
			if remaining > Program.ActiveRepel.duration then
				if remaining <= 200 then
					Program.ActiveRepel.duration = 200
				elseif remaining <= 250 then
					Program.ActiveRepel.duration = 250
				end
			end
		end
	else
		Program.ActiveRepel.inUse = false
		Program.ActiveRepel.stepCount = 0
		Program.ActiveRepel.duration = 100
	end
end

function Gen1Runtime.isInSafariZone()
	local mapId = Program.GameData.mapId
	if RouteData.Locations and RouteData.Locations.IsInSafariZone and RouteData.Locations.IsInSafariZone[mapId] then
		return true
	end
	return (GameSettings.safariBalls and Memory.readbyte(GameSettings.safariBalls) or 0) > 0
end

function Gen1Runtime.isInEvolutionScene()
	return (GameSettings.evolutionOccurred and Memory.readbyte(GameSettings.evolutionOccurred) or 0) ~= 0
end

function Gen1Runtime.isInStartMenu()
	if (GameSettings.battleState and Memory.readbyte(GameSettings.battleState) or 0) ~= 0 then return false end
	return (GameSettings.joyIgnore and Memory.readbyte(GameSettings.joyIgnore) or 0) ~= 0
end

function Gen1Runtime.getPlayerTilePosition()
	return {
		x = GameSettings.playerX and Memory.readbyte(GameSettings.playerX) or 0,
		y = GameSettings.playerY and Memory.readbyte(GameSettings.playerY) or 0,
	}
end

function Gen1Runtime.getStarterChoice()
	return GameSettings.playerStarter and Memory.readbyte(GameSettings.playerStarter) or 0
end

function Gen1Runtime.readFlashLevel()
	local palOffset = GameSettings.mapPalOffset and Memory.readbyte(GameSettings.mapPalOffset) or 0
	if palOffset == 6 then return 8 end
	return 0
end

function Gen1Runtime.updateCatchingTutorial()
	local battleType = GameSettings.battleType and Memory.readbyte(GameSettings.battleType) or 0
	Program.inCatchingTutorial = battleType == 1
	if Program.inCatchingTutorial then
		Battle.recentBattleWasTutorial = true
	else
		Program.hasCompletedTutorial = true
	end
end

function Gen1Runtime.updatePCHeals()
	if Battle.inActiveBattle and Battle.inActiveBattle() then return end
	if not (RouteData.Locations and RouteData.Locations.CanPCHeal[Program.GameData.mapId]) then return end
	local allFull, anyDamaged = true, false
	for slot = 1, 6 do
		local pokemon = Program.GameData.PlayerTeam[slot]
		if pokemon then
			if (pokemon.curHP or 0) < (pokemon.stats and pokemon.stats.hp or pokemon.curHP or 0) then
				allFull = false
				anyDamaged = true
			end
		end
	end
	if anyDamaged then
		Gen1Runtime.partyWasDamagedAtCenter = true
	elseif allFull and Gen1Runtime.partyWasDamagedAtCenter then
		Gen1Runtime.partyWasDamagedAtCenter = false
		if Options["Track PC Heals"] and TrackerScreen.Buttons.PCHealAutoTracking and TrackerScreen.Buttons.PCHealAutoTracking.toggleState then
			if Options["PC heals count downward"] then
				Tracker.Data.centerHeals = math.max(0, (Tracker.Data.centerHeals or 0) - 1)
			else
				Tracker.Data.centerHeals = math.min(99, (Tracker.Data.centerHeals or 0) + 1)
			end
		end
	end
end

function Gen1Runtime.changeGameSettingForLR()
	-- Game Boy has no L/R button-mode override.
end

function Gen1Runtime.checkForStarterSelection()
	if not GameSettings.usesStarterChoice() then
		Program.isViewingStarter = false
		return
	end
	if not RouteData.Locations or not RouteData.Locations.IsInLab[Program.GameData.mapId] then
		Program.isViewingStarter = false
		return
	end
	if (Memory.readbyte(GameSettings.partyCount) or 0) > 0 then
		if Program.isViewingStarter then
			Program.isViewingStarter = false
			if Program.changeScreenView then Program.changeScreenView(TrackerScreen) end
		end
	end
end

function Gen1Runtime.snapshotRodItem()
	local item = GameSettings.curItem and Memory.readbyte(GameSettings.curItem) or 0
	if item == 76 or item == 77 or item == 78 then
		Gen1Runtime.lastRodItem = item
	end
end

function Gen1Runtime.update()
	local forced = Program.updateRequired
	if Program.Frames.highAccuracyUpdate == 0 or forced then
		Gen1Runtime.updateMapLocation()
		Gen1Runtime.snapshotRodItem()
		if Program.GameTimer and not Program.GameTimer.hasStarted and Gen1Runtime.isValidMapLocation() then
			Program.GameTimer:start()
		end
		if Program.GameTimer then Program.GameTimer:update() end
	end

	if not Gen1Runtime.isValidMapLocation() then return end
	if Program.Frames.lowAccuracyUpdate == 0 or forced then
		Gen1Runtime.updateCatchingTutorial()
		if not Program.inCatchingTutorial and not Gen1Runtime.isInEvolutionScene() then
			Gen1Runtime.updatePokemonTeams()
			if TeamViewArea and TeamViewArea.buildOutPartyScreen then TeamViewArea.buildOutPartyScreen() end
			if Program.currentScreen == StartupScreen then Program.currentScreen = TrackerScreen end
			if Options["Show starter ball info"] then Gen1Runtime.checkForStarterSelection() end
			local learnedInfoTable = Gen1Runtime.getLearnedMoveInfoTable()
			if learnedInfoTable.pokemonID ~= nil then
				Tracker.TrackMove(learnedInfoTable.pokemonID, learnedInfoTable.moveId, learnedInfoTable.level)
			end
			if Options["Display repel usage"] and not (Battle.inActiveBattle and Battle.inActiveBattle()) then
				Program.inStartMenu = Gen1Runtime.isInStartMenu()
				if not Program.inStartMenu then Gen1Runtime.updateRepelSteps() end
			end
		end
	end
	if Program.Frames.three_sec_update == 0 or forced then
		Gen1Runtime.updateBagItems()
		Gen1Runtime.updatePCHeals()
		if Program.updateBadgesObtained then Program.updateBadgesObtained() end
	end
	if Program.Frames.saveData == 0 then Tracker.AutoSave.saveToFile() end
	if Program.Frames.lowAccuracyUpdate == 0 or forced then CustomCode.afterProgramDataUpdate() end
end

function Gen1Runtime.apply()
	-- Program.lua already delegates to this module. Kept as a no-op so older
	-- smoke tests that call apply() still load.
end

function Gen1Runtime.initialize()
	Program.Addresses.sizeofPokemonStruct = Gen1PokemonReader.PartyStructSize
end

return Gen1Runtime
