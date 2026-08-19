-- Native single-battle state for RBY. No battler arrays, double-battle slots,
-- abilities, BattleScripts, or GBA turn structures are involved.
Gen1BattleRuntime = {}

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
	return {
		atk = Memory.readbyte(startAddress),
		def = Memory.readbyte(startAddress + 1),
		spe = Memory.readbyte(startAddress + 2),
		special = Memory.readbyte(startAddress + 3),
		acc = Memory.readbyte(startAddress + 4),
		eva = Memory.readbyte(startAddress + 5),
	}
end

function Gen1BattleRuntime.inActiveBattle()
	return Battle.inBattleScreen and Battle.dataReady
end

function Gen1BattleRuntime.begin(state, enemy)
	Battle.inBattleScreen = true
	Battle.dataReady = true
	Battle.isWildEncounter = state == 1
	Battle.numBattlers = 2
	Battle.partySize = math.min(Memory.readbyte(GameSettings.partyCount) or 0, 6)
	Battle.isViewingOwn = not Options["Auto swap to enemy"]
	Battle.isViewingLeft = true
	Battle.lastEnemyMoveId = 0
	Battle.enemyMoveAtBattleStart = Memory.readbyte(GameSettings.enemyMove) or 0
	Battle.enemyMoveReadArmed = Battle.enemyMoveAtBattleStart == 0
	Battle.lastEnemySignature = nil
	Battle.pendingTrainerFrames = 0
	Battle.Combatants.LeftOwn = 1
	Battle.Combatants.LeftOther = 1
	Tracker.resetBattleNotes()
	Input.StatHighlighter:resetSelectedStat()
	Battle.trySwapScreenBackToMain()
	Gen1BattleRuntime.observeEnemy(enemy)
	CustomCode.afterBattleBegins()
end

function Gen1BattleRuntime.finish()
	if not Battle.inBattleScreen then return end
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
	Battle.trySwapScreenBackToMain()
	Program.Frames.saveData = 70
	CustomCode.afterBattleEnds()
end

function Gen1BattleRuntime.observeEnemy(enemy)
	local currentSignature = signature(enemy)
	if not currentSignature or currentSignature == Battle.lastEnemySignature then return end
	Battle.lastEnemySignature = currentSignature
	Battle.lastEnemyMoveId = 0
	Battle.enemyMoveAtBattleStart = Memory.readbyte(GameSettings.enemyMove) or 0
	Battle.enemyMoveReadArmed = Battle.enemyMoveAtBattleStart == 0
	Tracker.TrackEncounter(enemy.pokemonID, Battle.isWildEncounter)
	if Battle.isWildEncounter and type(Tracker.TrackRouteEncounter) == "function" and RouteData.EncounterArea then
		Tracker.TrackRouteEncounter(Program.GameData.mapId, RouteData.EncounterArea.LAND, enemy.pokemonID)
	end
end

function Gen1BattleRuntime.updateBattleStatus()
	local state = Memory.readbyte(GameSettings.battleState) or 0
	local enemy = Tracker.getPokemon(1, false)
	if Gen1BattleRuntime.inActiveBattle() then
		if state == 0 or not enemy then
			Gen1BattleRuntime.finish()
		else
			Gen1BattleRuntime.observeEnemy(enemy)
		end
		return
	end

	if state == 1 and enemy then
		Gen1BattleRuntime.begin(state, enemy)
	elseif state == 2 and enemy then
		-- Trainer intros can briefly retain the previous opponent. Require a
		-- changed signature, with a bounded fallback for identical opponents.
		local enemySignature = signature(enemy)
		if enemySignature ~= Battle.lastCompletedEnemySignature then
			Gen1BattleRuntime.begin(state, enemy)
		else
			Battle.pendingTrainerFrames = (Battle.pendingTrainerFrames or 0) + 10
			if Battle.pendingTrainerFrames >= 300 then Gen1BattleRuntime.begin(state, enemy) end
		end
	elseif state == 0 then
		Battle.pendingTrainerFrames = 0
		Battle.lastCompletedEnemySignature = signature(enemy) or Battle.lastCompletedEnemySignature
	end
end

function Gen1BattleRuntime.processEnemyMove()
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

function Gen1BattleRuntime.updateStatStages()
	local own = Tracker.getPokemon(1, true)
	if own then own.statStages = readStages(GameSettings.playerStatStages) end
	local enemy = Tracker.getPokemon(1, false)
	if enemy then enemy.statStages = readStages(GameSettings.playerStatStages + 0x14) end
end

function Gen1BattleRuntime.update()
	if not Program.isValidMapLocation() then return end
	if Program.Frames.highAccuracyUpdate == 0 or Program.updateRequired then
		Gen1BattleRuntime.updateBattleStatus()
	end
	if not Gen1BattleRuntime.inActiveBattle() then return end
	if Program.Frames.highAccuracyUpdate == 0 or Program.updateRequired then
		Gen1BattleRuntime.processEnemyMove()
	end
	if Program.Frames.lowAccuracyUpdate == 0 or Program.updateRequired then
		Gen1BattleRuntime.updateStatStages()
		CustomCode.afterBattleDataUpdate()
	end
end

function Gen1BattleRuntime.getViewedPokemon(isOwn)
	local viewOwn = isOwn or not Gen1BattleRuntime.inActiveBattle() or Battle.isViewingOwn
	return Tracker.getPokemon(1, viewOwn)
end

function Gen1BattleRuntime.togglePokemonViewed()
	if not Gen1BattleRuntime.inActiveBattle() then return end
	Battle.isViewingOwn = not Battle.isViewingOwn
	Program.redraw(true)
end

function Gen1BattleRuntime.apply()
	Battle.inActiveBattle = Gen1BattleRuntime.inActiveBattle
	Battle.update = Gen1BattleRuntime.update
	Battle.updateBattleStatus = Gen1BattleRuntime.updateBattleStatus
	Battle.updateHighAccuracy = Gen1BattleRuntime.processEnemyMove
	Battle.updateLowAccuracy = Gen1BattleRuntime.updateStatStages
	Battle.getViewedPokemon = Gen1BattleRuntime.getViewedPokemon
	Battle.togglePokemonViewed = Gen1BattleRuntime.togglePokemonViewed
	Battle.beginNewBattle = function()
		local state = Memory.readbyte(GameSettings.battleState) or 0
		Gen1BattleRuntime.begin(state, Tracker.getPokemon(1, false))
	end
	Battle.endCurrentBattle = Gen1BattleRuntime.finish
end

function Gen1BattleRuntime.initialize() Gen1BattleRuntime.apply() end
Gen1BattleRuntime.apply()

return Gen1BattleRuntime
