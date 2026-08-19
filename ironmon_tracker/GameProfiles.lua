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
	trainerClass = 0x02001031,
	currentOpponent = 0x02001059,
	trainerNumber = 0x0200105D,
	battleResult = 0x02000CF9, -- wBattleResult / CCF9
	curItem = 0x02000F91, -- wCurItem / CF91
	whichPokemon = 0x02000F92, -- wWhichPokemon / CF92
	moveNum = 0x020010E0, -- wMoveNum / D0E0
	repelSteps = 0x020010DB, -- wRepelRemainingSteps / D0DB
	evolutionOccurred = 0x0200111D, -- wEvolutionOccurred / D11D
	playerY = 0x02001361, -- wYCoord / D361
	playerX = 0x02001362, -- wXCoord / D362
	mapPalOffset = 0x0200135D, -- wMapPalOffset / D35D
	walkBikeSurf = 0x02001700, -- wWalkBikeSurfState / D700
	safariSteps = 0x0200170D, -- wSafariSteps / D70D
	playerStarter = 0x02001717, -- wPlayerStarter / D717
	safariBalls = 0x02001A47, -- wNumSafariBalls / DA47
	joyIgnore = 0x02000D38, -- joypad lock / CD38
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
	trainerClass = 0x02001030,
	currentOpponent = 0x02001058,
	trainerNumber = 0x0200105C,
	battleResult = 0x02000CF9,
	curItem = 0x02000F90,
	whichPokemon = 0x02000F91,
	moveNum = 0x020010DF,
	repelSteps = 0x020010DA,
	evolutionOccurred = 0x0200111C,
	playerY = 0x02001360,
	playerX = 0x02001361,
	mapPalOffset = 0x0200135C,
	walkBikeSurf = 0x020016FF,
	safariSteps = 0x0200170C,
	playerStarter = 0x02001716,
	safariBalls = 0x02001A46,
	joyIgnore = 0x02000D38,
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
	trainerClass = 0x02001035, -- wTrainerClass / D035
	currentOpponent = 0x0200105D, -- wCurOpponent / D05D
	trainerNumber = 0x02001061, -- wTrainerNo / D061
	battleResult = 0x02000CF9, -- wBattleResult stays with the unmoved CCxx block
	curItem = 0x02000F95, -- wCurItem / CF95
	whichPokemon = 0x02000F96, -- wWhichPokemon / CF96
	moveNum = 0x020010E4, -- wMoveNum / D0E4
	repelSteps = 0x020010DF, -- wRepelRemainingSteps / D0DF
	evolutionOccurred = 0x02001121, -- wEvolutionOccurred / D121
	playerY = 0x02001365, -- wYCoord / D365
	playerX = 0x02001366, -- wXCoord / D366
	mapPalOffset = 0x02001361, -- wMapPalOffset / D361
	walkBikeSurf = 0x02001704, -- wWalkBikeSurfState / D704
	safariSteps = 0x02001711, -- wSafariSteps / D711
	playerStarter = 0x0200171B, -- wPlayerStarter / D71B
	safariBalls = 0x02001A4B, -- wNumSafariBalls / DA4B
	joyIgnore = 0x02000D38, -- joypad lock / CD38
}

local function copyTable(source)
	local copy = {}
	for key, value in pairs(source) do
		copy[key] = value
	end
	return copy
end

-- pret pokered: wPlayerBattleStatus1 is 11 bytes after wIsInBattle; Pay Day and
-- disabled-move IDs live in the CCxx block after wPlayerSelectedMove.
local function attachBattleDetailAddresses(wram)
	wram.playerBattleStatus1 = wram.battleState + 0x0B
	wram.enemyBattleStatus1 = wram.battleState + 0x10
	wram.playerDisabledMove = wram.battleState + 0x16
	wram.enemyDisabledMove = wram.battleState + 0x1B
	wram.paydayMoney = wram.playerSelectedMove + 9
	wram.playerDisabledMoveNumber = wram.playerSelectedMove + 18
	wram.enemyDisabledMoveNumber = wram.playerSelectedMove + 19
	return wram
end

attachBattleDetailAddresses(RED_BLUE_WRAM)
attachBattleDetailAddresses(YELLOW_US_WRAM)
attachBattleDetailAddresses(YELLOW_FR_WRAM)

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
redBlueRom.levelUpMoves = 0x0803B05C -- EvosMovesPointerTable
redBlueRom.trainers = 0x08039D3B -- TrainerDataPointers
redBlueRom.tmMoves = 0x08013773

local yellowUsRom = copyTable(COMMON_ROM)
yellowUsRom.levelUpMoves = 0x0803B1E5 -- EvosMovesPointerTable
yellowUsRom.trainers = 0x08039DD1 -- TrainerDataPointers
yellowUsRom.tmMoves = 0x0801232D

local yellowFrRom = copyTable(COMMON_ROM)
yellowFrRom.levelUpMoves = 0x0803B1E8 -- EvosMovesPointerTable (+3 from Yellow US)
yellowFrRom.trainers = 0x08039DD4 -- TrainerDataPointers (+3 from Yellow US)
yellowFrRom.tmMoves = 0x0801233C

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
