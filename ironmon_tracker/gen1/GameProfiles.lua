-- Native Generation 1 game identities and memory layouts.
--
-- Addresses in `wram` use BizHawk's System Bus mapping (0x02000000 +
-- Game Boy WRAM offset). ROM offsets use the equivalent 0x08000000 mapping.
-- Keeping these values in one Gen 1-only registry prevents GBA address names
-- and version conditionals from leaking into the runtime.
Gen1GameProfiles = {}

Gen1GameProfiles.HeaderAddress = 0x0800013C

Gen1GameProfiles.GameCodes = {
	RED_US = 0x52454400, -- "RED\0"
	BLUE_US = 0x424C5545, -- "BLUE"
	YELLOW_US = 0x59454C4C, -- "YELL"
	YELLOW_FR = 0x59454C41, -- "YELA" from POKEMON YELAPSF
	RED_KAIZO = 0x41495A00, -- historical randomized Red header alias
	YELLOW_KAIZO = 0x4C574B41, -- historical randomized Yellow header alias
}

local COMMON_ROM = {
	moveData = 0x08038000,
	baseStats = 0x080383DE,
	mewBaseStats = 0x0800425B,
}

local RED_BLUE_WRAM = {
	partyMon1 = 0x0200116B,
	partyCount = 0x02001163,
	partySpecies = 0x02001164,
	enemyMon = 0x02000FE5,
	enemyMove = 0x02000FCC,
	enemyType1 = 0x02000FEA,
	playerSelectedMove = 0x02000CDC,
	enemySelectedMove = 0x02000CDD,
	playerStatStages = 0x02000D1A,
	playerMove = 0x02000FD2,
	battleMon = 0x02001014,
	battleState = 0x02001057,
	battleType = 0x0200105A,
	currentMap = 0x0200135E,
	badges = 0x02001356,
	bagCount = 0x0200131D,
	bagItems = 0x0200131E,
}

local YELLOW_US_WRAM = {
	partyMon1 = 0x0200116A,
	partyCount = 0x02001162,
	partySpecies = 0x02001163,
	enemyMon = 0x02000FE4,
	enemyMove = 0x02000FCB,
	enemyType1 = 0x02000FE9,
	playerSelectedMove = 0x02000CDC,
	enemySelectedMove = 0x02000CDD,
	playerStatStages = 0x02000D1A,
	playerMove = 0x02000FD1,
	battleMon = 0x02001013,
	battleState = 0x02001056,
	battleType = 0x02001059,
	currentMap = 0x0200135D,
	badges = 0x02001355,
	bagCount = 0x0200131C,
	bagItems = 0x0200131D,
}

-- Runtime-confirmed on French Yellow in BizHawk. Do not replace these with a
-- blanket regional delta: several battle fields intentionally do not move.
local YELLOW_FR_WRAM = {
	partyMon1 = 0x0200116F, -- wPartyMon1 / D16F
	partyCount = 0x02001167, -- wPartyCount / D167
	partySpecies = 0x02001168, -- wPartySpecies / D168
	enemyMon = 0x02000FE9, -- wEnemyMon / CFE9
	enemyMove = 0x02000FD0, -- wEnemyMoveNum / CFD0
	enemyType1 = 0x02000FEE, -- wEnemyMonType1 / CFEE
	playerSelectedMove = 0x02000CDC, -- wPlayerSelectedMove / CCDC
	enemySelectedMove = 0x02000CDD, -- wEnemySelectedMove / CCDD
	playerStatStages = 0x02000D1A, -- wPlayerMonStatMods / CD1A
	playerMove = 0x02000FD6, -- wPlayerMoveNum / CFD6
	battleMon = 0x02001018, -- wBattleMon / D018
	battleState = 0x0200105B, -- wIsInBattle / D05B
	battleType = 0x0200105E, -- wBattleType / D05E
	currentMap = 0x02001362, -- wCurMap / D362
	badges = 0x0200135A, -- wObtainedBadges / D35A
	bagCount = 0x02001321, -- wNumBagItems / D321
	bagItems = 0x02001322, -- wBagItems / D322
}

local function copyTable(source)
	local copy = {}
	for key, value in pairs(source) do
		copy[key] = value
	end
	return copy
end

local function makeProfile(id, name, version, language, wram, rom)
	return {
		id = id,
		name = name,
		generation = 1,
		version = version,
		language = language,
		wram = copyTable(wram),
		rom = copyTable(rom),
	}
end

local redBlueRom = copyTable(COMMON_ROM)
redBlueRom.levelUpMoves = 0x0803B1D8
redBlueRom.trainers = 0x08039D99

local yellowUsRom = copyTable(COMMON_ROM)
yellowUsRom.levelUpMoves = 0x0803B1D8 -- table begins at 0x3B1E5 (+0x0D)
yellowUsRom.trainers = 0x08039D99 -- table begins at 0x39DD1 (+0x38)

local yellowFrRom = copyTable(COMMON_ROM)
yellowFrRom.levelUpMoves = 0x0803B1DB -- table begins at 0x3B1E8 (+0x0D)
yellowFrRom.trainers = 0x08039D9C -- table begins at 0x39DD4 (+0x38)

Gen1GameProfiles.Profiles = {
	red_us = makeProfile("red_us", "Pokemon Red (US/EU)", "Red", "English", RED_BLUE_WRAM, redBlueRom),
	blue_us = makeProfile("blue_us", "Pokemon Blue (US/EU)", "Blue", "English", RED_BLUE_WRAM, redBlueRom),
	yellow_us = makeProfile("yellow_us", "Pokemon Yellow (US/EU)", "Yellow", "English", YELLOW_US_WRAM, yellowUsRom),
	yellow_fr = makeProfile("yellow_fr", "Pokemon Yellow (France)", "Yellow", "French", YELLOW_FR_WRAM, yellowFrRom),
}

Gen1GameProfiles.ByGameCode = {
	[Gen1GameProfiles.GameCodes.RED_US] = Gen1GameProfiles.Profiles.red_us,
	[Gen1GameProfiles.GameCodes.RED_KAIZO] = Gen1GameProfiles.Profiles.red_us,
	[Gen1GameProfiles.GameCodes.BLUE_US] = Gen1GameProfiles.Profiles.blue_us,
	[Gen1GameProfiles.GameCodes.YELLOW_US] = Gen1GameProfiles.Profiles.yellow_us,
	[Gen1GameProfiles.GameCodes.YELLOW_KAIZO] = Gen1GameProfiles.Profiles.yellow_us,
	[Gen1GameProfiles.GameCodes.YELLOW_FR] = Gen1GameProfiles.Profiles.yellow_fr,
}

function Gen1GameProfiles.get(gameCode)
	return Gen1GameProfiles.ByGameCode[gameCode]
end

function Gen1GameProfiles.isSupported(gameCode)
	return Gen1GameProfiles.get(gameCode) ~= nil
end

return Gen1GameProfiles
