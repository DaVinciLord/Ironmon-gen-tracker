-- RBY singles battle state. Same public API as Besteon (inActiveBattle,
-- update, getViewedPokemon, togglePokemonViewed, …) with Gen 1 memory.
Battle = {
	inBattleScreen = false, dataReady = false, isWildEncounter = false, isGhost = false,
	lastPokemonSeen = 0, opposingTrainerId = 0, isViewingOwn = true, isViewingLeft = true,
	numBattlers = 0, partySize = 6, recentBattleWasTutorial = false, turnCount = -1,
	damageReceived = 0, lastEnemyMoveId = 0, enemyHasAttacked = false,
	enemyMoveAtBattleStart = 0, enemyMoveReadArmed = false,
	lastEnemySignature = nil, lastCompletedEnemySignature = nil, pendingTrainerFrames = 0,
	CurrentRoute = { encounterArea = RouteData.EncounterArea.LAND, hasInfo = false },
	Combatants = { LeftOwn = 1, LeftOther = 1, RightOwn = 1, RightOther = 1 },
}

Battle.IndexMap = {
	[0] = "LeftOwn",
	[1] = "LeftOther",
	[2] = "RightOwn",
	[3] = "RightOther",
}

setmetatable(Battle, { __index = function(_, key)
	if key == "inBattle" then return Battle.inActiveBattle() end
end })

local function signature(pokemon)
	if not pokemon then return nil end
	local stats = pokemon.stats or {}
	return table.concat({ pokemon.pokemonID or 0, pokemon.level or 0, pokemon.curHP or 0,
		stats.hp or 0, stats.atk or 0, stats.def or 0, stats.spe or 0, stats.special or 0 }, ":")
end

local function moveBelongsToPokemon(pokemon, moveId)
	if not pokemon or not moveId or moveId == 0 then return false end
	for _, move in ipairs(pokemon.moves or {}) do
		if move.id == moveId then return true end
	end
	return false
end

local function readStages(startAddress)
	-- RBY stores stat modifiers with 7 as neutral. Besteon UI uses 6 as neutral.
	local function normalized(offset)
		return math.max(0, (Memory.readbyte(startAddress + offset) or 7) - 1)
	end
	return {
		atk = normalized(0),
		def = normalized(1),
		spe = normalized(2),
		special = normalized(3),
		acc = normalized(4),
		eva = normalized(5),
	}
end

function Battle.initialize()
	Battle.inBattleScreen, Battle.dataReady, Battle.isWildEncounter = false, false, false
	Battle.isGhost, Battle.lastPokemonSeen, Battle.opposingTrainerId = false, 0, 0
	Battle.isViewingOwn, Battle.isViewingLeft, Battle.numBattlers = true, true, 0
	Battle.partySize, Battle.turnCount, Battle.damageReceived = 6, -1, 0
	Battle.lastEnemyMoveId, Battle.enemyHasAttacked = 0, false
	Battle.enemyMoveAtBattleStart, Battle.enemyMoveReadArmed = 0, false
	Battle.lastEnemySignature, Battle.lastCompletedEnemySignature = nil, nil
	Battle.pendingTrainerFrames, Battle.CurrentRoute.hasInfo = 0, false
	Battle.Combatants = { LeftOwn = 1, LeftOther = 1, RightOwn = 1, RightOther = 1 }
end

function Battle.inActiveBattle()
	return Battle.inBattleScreen and Battle.dataReady
end

function Battle.getViewedIndex()
	return Battle.isViewingOwn and 0 or 1
end

function Battle.getViewedPokemon(isOwn)
	local viewOwn = isOwn or not Battle.inActiveBattle() or Battle.isViewingOwn
	return Tracker.getPokemon(1, viewOwn)
end

function Battle.togglePokemonViewed()
	if not Battle.inActiveBattle() then return end
	Battle.isViewingOwn = not Battle.isViewingOwn
	Program.redraw(true)
end

function Battle.getDoublesCursorTargetInfo()
	local targetOwn = not Battle.isViewingOwn and Battle.inActiveBattle()
	return { slot = 1, target = targetOwn and 0 or 1, isLeft = true, isOwner = targetOwn }
end

function Battle.trySwapScreenBackToMain()
	local allowed = {
		[InfoScreen] = true, [TrainerInfoScreen] = true, [TrainersOnRouteScreen] = true,
		[RandomEvosScreen] = true, [MoveHistoryScreen] = true, [CatchRatesScreen] = true,
		[TypeDefensesScreen] = true, [CoverageCalcScreen] = true,
		[HealsInBagScreen] = true, [BattleDetailsScreen] = true,
	}
	if Program.currentScreen == InfoScreen then InfoScreen.clearScreenData() end
	if allowed[Program.currentScreen or false] then Program.currentScreen = TrackerScreen end
end

function Battle.resetBattle()
	local oldSaveDataFrames = Program.Frames.saveData
	Battle.endCurrentBattle()
	Battle.beginNewBattle()
	Program.Frames.saveData = oldSaveDataFrames
end

function Battle.wonFinalBattle(lastBattleStatus, lastTrainerId)
	lastTrainerId = lastTrainerId or Battle.opposingTrainerId
	return (lastBattleStatus == nil or lastBattleStatus == 1)
		and TrainerData.FinalTrainer[lastTrainerId or 0] == true
end

function Battle.beginNewBattle()
	local state = Memory.readbyte(GameSettings.battleState) or 0
	Battle.begin(state, Tracker.getPokemon(1, false))
end

function Battle.begin(state, enemy)
	Battle.inBattleScreen = true
	Battle.dataReady = true
	Battle.isWildEncounter = state == 1
	Battle.opposingTrainerId = state == 2 and TrainerData and TrainerData.getCurrentTrainerId() or 0
	Battle.numBattlers = 2
	Battle.partySize = math.min(Memory.readbyte(GameSettings.partyCount) or 0, 6)
	Battle.isViewingOwn = not Options["Auto swap to enemy"]
	Battle.isViewingLeft = true
	Battle.lastEnemyMoveId = 0
	if state == 1 then
		Battle.CurrentRoute = Battle.CurrentRoute or {}
		Battle.CurrentRoute.encounterArea = (RouteData and RouteData.consumeEncounterArea and RouteData.consumeEncounterArea())
			or (RouteData.EncounterArea and RouteData.EncounterArea.LAND)
	end
	local battleType = GameSettings.battleType and Memory.readbyte(GameSettings.battleType) or 0
	Battle.recentBattleWasTutorial = battleType == 1
	if state == 2 and TrainerData and TrainerData.rememberTrainerOnMap then
		TrainerData.rememberTrainerOnMap(Program.GameData.mapId, Battle.opposingTrainerId)
	end
	Battle.enemyMoveAtBattleStart = Memory.readbyte(GameSettings.enemyMove) or 0
	Battle.enemyMoveReadArmed = Battle.enemyMoveAtBattleStart == 0
	Battle.lastEnemySignature = nil
	Battle.pendingTrainerFrames = 0
	Battle.Combatants.LeftOwn = 1
	Battle.Combatants.LeftOther = 1
	Tracker.resetBattleNotes()
	Input.StatHighlighter:resetSelectedStat()
	Battle.trySwapScreenBackToMain()
	if GameOverScreen and GameOverScreen.createTempSaveState then GameOverScreen.createTempSaveState() end
	Battle.observeEnemy(enemy)
	if BattleDetailsScreen then BattleDetailsScreen.clearBuiltData() end
	CustomCode.afterBattleBegins()
end

function Battle.endCurrentBattle()
	if not Battle.inBattleScreen then return end
	local lastTrainerId = Battle.opposingTrainerId
	if lastTrainerId and lastTrainerId ~= 0 and TrainerData and TrainerData.markDefeated then
		local result = GameSettings.battleResult and Memory.readbyte(GameSettings.battleResult) or 1
		local lead = Tracker.getPokemon(1, true)
		local leadAlive = lead and (lead.curHP or 0) > 0
		if result == 0 and leadAlive then
			TrainerData.markDefeated(lastTrainerId)
		end
	end
	Battle.lastCompletedEnemySignature = signature(Tracker.getPokemon(1, false)) or Battle.lastEnemySignature
	Tracker.recordLastLevelsSeen()
	Battle.inBattleScreen = false
	Battle.dataReady = false
	Battle.isWildEncounter = false
	Battle.numBattlers = 0
	Battle.isViewingOwn = true
	Battle.isViewingLeft = true
	Battle.lastEnemyMoveId = 0
	Battle.lastEnemySignature = nil
	Battle.pendingTrainerFrames = 0
	for slot = 1, 6 do
		local pokemon = Tracker.getPokemon(slot, true)
		if pokemon then
			pokemon.statStages = { atk = 6, def = 6, spe = 6, special = 6, acc = 6, eva = 6 }
		end
	end
	Tracker.resetBattleNotes()
	if BattleDetailsScreen then BattleDetailsScreen.clearBuiltData() end
	Battle.trySwapScreenBackToMain()
	Program.Frames.saveData = 70
	CustomCode.afterBattleEnds()
	if GameOverScreen and GameOverScreen.openIfEnded then GameOverScreen.openIfEnded(lastTrainerId) end
end

function Battle.observeEnemy(enemy)
	local currentSignature = signature(enemy)
	if not currentSignature or currentSignature == Battle.lastEnemySignature then return end
	Battle.lastEnemySignature = currentSignature
	Battle.lastEnemyMoveId = 0
	Battle.enemyMoveAtBattleStart = Memory.readbyte(GameSettings.enemyMove) or 0
	Battle.enemyMoveReadArmed = Battle.enemyMoveAtBattleStart == 0
	Tracker.TrackEncounter(enemy.pokemonID, Battle.isWildEncounter)
	if Battle.isWildEncounter and type(Tracker.TrackRouteEncounter) == "function" and RouteData.EncounterArea then
		local area = (Battle.CurrentRoute and Battle.CurrentRoute.encounterArea)
			or (RouteData and RouteData.getCurrentEncounterArea and RouteData.getCurrentEncounterArea())
			or RouteData.EncounterArea.LAND
		Tracker.TrackRouteEncounter(Program.GameData.mapId, area, enemy.pokemonID)
	end
end

function Battle.updateBattleStatus()
	local state = Memory.readbyte(GameSettings.battleState) or 0
	local enemy = Tracker.getPokemon(1, false)
	if Battle.inActiveBattle() then
		if state == 0 or not enemy then
			Battle.endCurrentBattle()
		else
			Battle.observeEnemy(enemy)
		end
		return
	end

	if state == 1 and enemy then
		Battle.begin(state, enemy)
	elseif state == 2 and enemy then
		local enemySignature = signature(enemy)
		if enemySignature ~= Battle.lastCompletedEnemySignature then
			Battle.begin(state, enemy)
		else
			Battle.pendingTrainerFrames = (Battle.pendingTrainerFrames or 0) + 10
			if Battle.pendingTrainerFrames >= 300 then Battle.begin(state, enemy) end
		end
	elseif state == 0 then
		Battle.pendingTrainerFrames = 0
		Battle.lastCompletedEnemySignature = signature(enemy) or Battle.lastCompletedEnemySignature
	end
end

function Battle.updateHighAccuracy()
	local enemyMove = Memory.readbyte(GameSettings.enemyMove) or 0
	if not Battle.enemyMoveReadArmed then
		if enemyMove == 0 or enemyMove ~= Battle.enemyMoveAtBattleStart then
			Battle.enemyMoveReadArmed = true
		end
	end
	if not Battle.enemyMoveReadArmed or enemyMove == 0 then return end
	local enemy = Tracker.getPokemon(1, false)
	if enemy and enemyMove ~= Battle.lastEnemyMoveId and moveBelongsToPokemon(enemy, enemyMove) then
		Battle.lastEnemyMoveId = enemyMove
		Tracker.TrackMove(enemy.pokemonID, enemyMove, enemy.level)
	end
end

function Battle.updateLowAccuracy()
	local own = Tracker.getPokemon(1, true)
	if own then own.statStages = readStages(GameSettings.playerStatStages) end
	local enemy = Tracker.getPokemon(1, false)
	if enemy then enemy.statStages = readStages(GameSettings.playerStatStages + 0x14) end
end

function Battle.update()
	if not Program.isValidMapLocation() then return end
	if Program.Frames.highAccuracyUpdate == 0 or Program.updateRequired then
		Battle.updateBattleStatus()
	end
	if not Battle.inActiveBattle() then return end
	if Program.Frames.highAccuracyUpdate == 0 or Program.updateRequired then
		Battle.updateHighAccuracy()
	end
	if Program.Frames.lowAccuracyUpdate == 0 or Program.updateRequired then
		Battle.updateLowAccuracy()
		if BattleDetailsScreen then BattleDetailsScreen.updateData() end
		CustomCode.afterBattleDataUpdate()
	end
end

return Battle
