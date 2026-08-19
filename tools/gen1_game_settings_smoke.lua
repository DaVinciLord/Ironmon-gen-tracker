-- Verifies that the Besteon startup configuration selects Gen 1 profiles and
-- refuses games outside the target generation.
-- Run from any directory with: lua tools/gen1_game_settings_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Constants = { HIDDEN_INFO = "?" }
FileManager = {}
Main = {
	DisplayError = function(message)
		Main.lastError = message
	end,
}
Utils = {
	reverseEndian32 = function(value)
		return value
	end,
}
Memory = {
	gameCode = 0,
	read32 = function(address)
		assert(address == 0x0800013C)
		return Memory.gameCode
	end,
}

dofile(repoRoot .. "ironmon_tracker/gen1/GameProfiles.lua")
dofile(repoRoot .. "ironmon_tracker/GameSettings.lua")

Memory.gameCode = Gen1GameProfiles.GameCodes.RED_US
assert(GameSettings.initialize())
assert(GameSettings.GEN == 1 and GameSettings.currentProfile.id == "red_us")
assert(GameSettings.partyMon1 == 0x0200116B)
assert(GameSettings.gamename == "Pokemon Red (US/EU)")

Memory.gameCode = Gen1GameProfiles.GameCodes.YELLOW_FR
assert(GameSettings.initialize())
assert(GameSettings.currentProfile.id == "yellow_fr" and GameSettings.isFrenchYellow)
assert(GameSettings.language == "French")
assert(GameSettings.partyMon1 == 0x0200116F)
assert(GameSettings.levelUpMoves == 0x0803B1DB)

Memory.gameCode = 0x42504545 -- Emerald
assert(not GameSettings.initialize())
assert(GameSettings.gamename == "Unsupported Game")
assert(Main.lastError:find("unsupported by the Gen 1 Ironmon Tracker", 1, true))

print("Gen 1 game settings smoke tests passed")
