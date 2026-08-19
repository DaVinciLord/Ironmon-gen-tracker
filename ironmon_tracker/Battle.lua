-- Shared battle state for the native RBY runtime. The actual memory polling is
-- installed by gen1/BattleRuntime.lua after the inherited modules are loaded.
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

setmetatable(Battle, { __index = function(_, key)
	if key == "inBattle" then return Battle.inActiveBattle() end
end })

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

function Battle.inActiveBattle() return Battle.inBattleScreen and Battle.dataReady end

-- Replaced by Gen1BattleRuntime.apply(); retained for deterministic module loads.
function Battle.update() end
function Battle.updateBattleStatus() end
function Battle.updateHighAccuracy() end
function Battle.updateLowAccuracy() end

function Battle.getViewedIndex() return Battle.isViewingOwn and 0 or 1 end

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
	-- Historical DataHelper contract; RBY only has one target per side.
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

return Battle
