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
end

return YellowFRSupport
