YellowFRSupport = {}

local FRENCH_YELLOW_GAMECODE = 0x59454C41 -- "YELA" from POKEMON YELAPSF

function YellowFRSupport.apply()
	if YellowFRSupport.applied then return end
	YellowFRSupport.applied = true

	local originalSetGameInfo = GameSettings.setGameInfo
	GameSettings.setGameInfo = function(gamecode)
		if gamecode == FRENCH_YELLOW_GAMECODE then
			GameSettings.game = 2
			GameSettings.gamename = "Pokemon Yellow(F)"
			GameSettings.versiongroup = 2
			GameSettings.versioncolor = "Yellow"
			-- Keep tracker-side data/UI in English for now. The ROM itself remains French.
			GameSettings.language = "English"
			GameSettings.badgePrefix = "FRLG"
			GameSettings.badgeXOffsets = { 1, 1, 0, 0, 1, 1, 1, 1 }
			GameSettings.GEN = nil
			GameSettings.isFrenchYellow = true
			return
		end

		GameSettings.isFrenchYellow = false
		originalSetGameInfo(gamecode)
	end

	local originalSetWramAddresses = GameSettings.setWramAddresses
	GameSettings.setWramAddresses = function()
		originalSetWramAddresses()

		if GameSettings.isFrenchYellow then
			-- French Yellow WRAM map.
			--
			-- Runtime-confirmed on a clean French Yellow dump in BizHawk:
			--   wPartyMon1    = D16F
			--   wPartyCount   = D167
			--   wEnemyMon     = CFE9
			--   wEnemyMoveNum = CFD0
			--   wEnemyMonType = CFEE
			--   wIsInBattle   = D05B (0=none, 1=wild, 2=trainer)
			--
			-- The remaining entries below are derived from the French Red
			-- disassembly (einstein95/pokered-fr), adjusted by the exact
			-- Yellow-vs-Red delta from pret's English symbol maps. This method
			-- reproduces every runtime-confirmed French Yellow address above.
			GameSettings.pstats = 0x0200116F -- wPartyMon1 (confirmed)
			GameSettings.estats = 0x02000FE9 -- wEnemyMon (confirmed)
			GameSettings.eMove = 0x02000FD0 -- wEnemyMoveNum (confirmed)
			GameSettings.eType = 0x02000FEE -- wEnemyMonType1 (confirmed by probe v4)
			GameSettings.StatChange = 0x02000D1A -- wPlayerMonStatMods (same in US/FR, Red/Yellow)

			-- The legacy tracker uses this field as if it were a battler-party-index
			-- array. In Gen 1 it actually points at wPartyCount. Preserve that
			-- existing behavior for now while correcting the French address.
			GameSettings.gBattlerPartyIndexes = 0x02001167 -- wPartyCount

			-- Despite its legacy GBA-style name, this is wIsInBattle in Gen 1.
			GameSettings.gBattleTypeFlags = 0x0200105B -- confirmed: 0=none, 1=wild, 2=trainer
			GameSettings.gMapHeader = 0x02001362 -- wCurMap (validated by probe v4)
			GameSettings.gPlayerPartyCount = 0x02001167 -- wPartyCount (confirmed)

			GameSettings.badgeOffset = 0x0200135A -- wObtainedBadges (validated by probe v4)
			GameSettings.bagPocket_Items_Size = 0x02001321 -- wNumBagItems (validated by probe v4)
			GameSettings.bagPocket_Items_offset = 0x02001322 -- wBagItems (validated by probe v4)
			GameSettings.bagPocket_Berries_offset = 0x02001322 -- Gen 1 has one item bag list

			-- Keep the historical gTurn value for now. It maps to
			-- wAILayer2Encouragement, not a true turn counter; replacing this
			-- heuristic is tracked as a separate stabilization task.
			GameSettings.gTurn = 0x02000CD5
		end
	end

	local originalSetRomAddresses = GameSettings.setRomAddresses
	GameSettings.setRomAddresses = function(gameIndex, versionIndex)
		originalSetRomAddresses(gameIndex, versionIndex)

		if GameSettings.isFrenchYellow then
			-- UPR ZX gen1_offsets.ini documents Yellow (F) as +3 bytes for
			-- both the level-up moveset area and trainer data compared with Yellow (U).
			-- The tracker intentionally points 0x0D before MovesetsDataOffset
			-- and 0x38 before TrainerDataTableOffset, so retain those relatives.
			GameSettings.gEvo_move = 0x0803B1DB
			GameSettings.trainnerpoke = 0x08039D9C
		end
	end

	-- The upstream Gen 1 implementation currently stubs encounter counters to 0,
	-- so Battle.isWildEncounter never becomes true. Yellow exposes the distinction
	-- directly through wIsInBattle: 1=wild, 2=trainer. Use that authoritative
	-- value for the French Yellow compatibility path and leave other games alone.
	local originalUpdateBattleEncounterType = Program.updateBattleEncounterType
	Program.updateBattleEncounterType = function()
		if GameSettings.isFrenchYellow and GameSettings.gBattleTypeFlags ~= nil then
			local battleState = Memory.readbyte(GameSettings.gBattleTypeFlags)
			if battleState == 1 then
				Battle.isWildEncounter = true
			elseif battleState == 2 then
				Battle.isWildEncounter = false
			end
			return
		end

		originalUpdateBattleEncounterType()
	end
end

return YellowFRSupport
