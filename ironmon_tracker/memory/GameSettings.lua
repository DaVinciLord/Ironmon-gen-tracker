-- Active ROM identity and native RBY addresses. GameProfiles is the sole
-- source of supported games; no GBA address registry is loaded at runtime.
GameSettings = { generation = 1, GEN = 1 }

function GameSettings.initialize()
	local gameCode = Utils.reverseEndian32(Memory.read32(GameProfiles.HeaderAddress) or 0)
	local profile = GameProfiles.get(gameCode)
	if not profile then
		GameSettings.gamename = "Unsupported Game"
		Main.DisplayError("This game is unsupported by the Gen 1 Ironmon Tracker.\n\nSupported games: Pokemon Red, Blue, and Yellow (US/EU), plus Pokemon Yellow (France).")
		return false
	end

	GameSettings.currentProfile = profile
	GameSettings.gamecode = gameCode
	GameSettings.game = profile.version == "Yellow" and 2 or 1
	GameSettings.gamename = profile.name
	GameSettings.versiongroup = GameSettings.game
	GameSettings.versioncolor = profile.version
	GameSettings.language = profile.language
	GameSettings.fullVersionName = profile.name
	GameSettings.generation = 1
	GameSettings.GEN = 1
	GameSettings.isYellow = profile.version == "Yellow"
	GameSettings.isFrenchYellow = profile.id == "yellow_fr"
	GameSettings.badgePrefix = "FRLG"
	GameSettings.badgeXOffsets = { 0, 0, 0, 0, 0, 0, 0, 0 }
	GameSettings.wram, GameSettings.rom = profile.wram, profile.rom
	for name, address in pairs(profile.wram) do GameSettings[name] = address end
	for name, address in pairs(profile.rom) do GameSettings[name] = address end
	return true
end

---Red/Blue let the player pick one of three starters. Yellow always gives
---Pikachu, so starter-ball and favorite-starter UI is unused.
function GameSettings.usesStarterChoice()
	return GameSettings.isYellow ~= true
end

---Legacy extension entry point. Address profiles cannot replace the native RBY
---registry, so unsupported GBA-style game settings are deliberately rejected.
function GameSettings.importAddressesFromJson() return false end

local function decodeNumber(value)
	if type(value) ~= "string" then return value end
	value = Utils.replaceText(value, "0x", "")
	return tonumber(value, 16) or tonumber(value)
end

---Applies optional numeric overrides to the remaining Gen 1 data objects.
function GameSettings.importTrackerOverridesFromJson(filepath)
	filepath = filepath or FileManager.prependDir(FileManager.Files.ADDRESS_OVERRIDES)
	if not FileManager.fileExists(filepath) then return false end
	local data = FileManager.decodeJsonFile(filepath)
	if not data then return false end
	local globals = { Program = Program, BattleDetailsScreen = BattleDetailsScreen,
		PokemonData = PokemonData, MoveData = MoveData }
	xpcall(function()
		for globalKey, globalInfo in pairs(data) do
			local object = globals[globalKey]
			if object then
				for key, raw in pairs(globalInfo.Addresses or {}) do
					local value = decodeNumber(raw)
					if type(value) == "number" then object[key] = value end
				end
				for key, raw in pairs(globalInfo.Values or {}) do
					local value = decodeNumber(raw)
					if type(value) == "number" then object[key] = value end
				end
			end
		end
	end, FileManager.logError)
	return true
end

function GameSettings.getRomName()
	if Main.IsOnBizhawk() then return gameinfo.getromname() or "" end
	return ""
end

function GameSettings.getRomHash()
	if Main.IsOnBizhawk() then return gameinfo.getromhash() or "" end
	return ""
end

function GameSettings.getTrackerAutoSaveName()
	local ending = FileManager.PostFixes.AUTOSAVE .. FileManager.Extensions.TRACKED_DATA
	return (GameSettings.gamename or "Pokemon RBY"):gsub("%s%(.*%)", " ") .. ending
end

return GameSettings
