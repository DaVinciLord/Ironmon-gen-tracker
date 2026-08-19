MoveData = {}

MoveData.Values = {
	GuillotineId = 12,
	HornDrillId = 32,
	LowKickId = 67,
	FissureId = 90,

	-- Used by Battle Details (RBY status bits)
	PayDayId = 6,
	DisableId = 50,
	MistId = 54,
	LeechSeedId = 73,
	RageId = 99,
	MinimizeId = 107,
	DefenseCurlId = 111,
	LightScreenId = 113,
	ReflectId = 115,
	FocusEnergyId = 116,
	BideId = 117,
	TransformId = 144,
	SubstituteId = 164,
}

MoveData.Addresses = {
	offsetMovePower = 0x0,
	offsetMoveType = 0x8,
	offsetMoveAccuracy = 0x10,
	offsetMovePP = 0x18,
	offsetMoveFlagsCategory = 0x6,

	sizeofMovePower = 8,
	sizeofMoveType = 8,
	sizeofMoveAccuracy = 8,
	sizeofMovePP = 8,
	sizeofMoveFlagsCategory = 2,
}

MoveData.IsRand = {
	moveType = false,
	movePower = false,
	moveAccuracy = false,
	movePP = false,
	moveCategory = false,
	tms = false,
}

-- Move categories identify the type of attack a move is: physical, special, or status
MoveData.Categories = {
	NONE = "None",
	PHYSICAL = "Physical",
	SPECIAL = "Special",
	STATUS = "Status",
}

-- RBY has no Hidden Power.
MoveData.HiddenPowerTypeList = {}
MoveData.HIDDEN_POWER_NOT_SET = nil

-- Physical/special split follows type, as in generations 1-3
MoveData.TypeToCategory = {
	[PokemonData.Types.NORMAL]   = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.FIGHTING] = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.FLYING]   = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.POISON]   = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.GROUND]   = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.ROCK]     = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.BUG]      = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.GHOST]    = MoveData.Categories.PHYSICAL,
	[PokemonData.Types.FIRE]     = MoveData.Categories.SPECIAL,
	[PokemonData.Types.WATER]    = MoveData.Categories.SPECIAL,
	[PokemonData.Types.GRASS]    = MoveData.Categories.SPECIAL,
	[PokemonData.Types.ELECTRIC] = MoveData.Categories.SPECIAL,
	[PokemonData.Types.PSYCHIC]  = MoveData.Categories.SPECIAL,
	[PokemonData.Types.ICE]      = MoveData.Categories.SPECIAL,
	[PokemonData.Types.DRAGON]   = MoveData.Categories.SPECIAL,
	[PokemonData.Types.UNKNOWN]  = MoveData.Categories.NONE,
}

MoveData.TypeToEffectiveness = {
	normal = { rock = 0.5, ghost = 0 },
	fire = { fire = 0.5, water = 0.5, grass = 2, ice = 2, bug = 2, rock = 0.5, dragon = 0.5 },
	water = { fire = 2, water = 0.5, grass = 0.5, ground = 2, rock = 2, dragon = 0.5 },
	grass = { fire = 0.5, water = 2, grass = 0.5, poison = 0.5, ground = 2, flying = 0.5, bug = 0.5, rock = 2, dragon = 0.5 },
	electric = { water = 2, grass = 0.5, electric = 0.5, ground = 0, flying = 2, dragon = 0.5 },
	ice = { water = 0.5, grass = 2, ice = 0.5, ground = 2, flying = 2, dragon = 2 },
	fighting = { normal = 2, ice = 2, poison = 0.5, flying = 0.5, psychic = 0.5, bug = 0.5, rock = 2, ghost = 0 },
	poison = { grass = 2, poison = 0.5, bug = 2, ground = 0.5, rock = 0.5, ghost = 0.5 },
	ground = { fire = 2, grass = 0.5, electric = 2, poison = 2, flying = 0, bug = 0.5, rock = 2 },
	flying = { grass = 2, electric = 0.5, fighting = 2, bug = 2, rock = 0.5 },
	psychic = { fighting = 2, poison = 2, psychic = 0.5 },
	bug = { fire = 0.5, grass = 2, fighting = 0.5, poison = 2, flying = 0.5, psychic = 2, ghost = 0.5 },
	rock = { fire = 2, ice = 2, fighting = 0.5, ground = 0.5, flying = 2, bug = 2 },
	ghost = { normal = 0, psychic = 0, ghost = 2 }, -- RBY Ghost/Psychic bug
	dragon = { dragon = 2 },
}

-- RBY OHKO accuracy is speed-based (see move summaries), not level-based.
-- Low Kick is a fixed 50 power and is not weight-based.
MoveData.MoveValueAdjustmentFuncs = {}

-- Is true when a Status move fails/doesn't work against a checked move type
MoveData.StatusMovesWillFail = {
	["73"] = { [PokemonData.Types.GRASS] = true, }, -- Leech Seed
	["77"] = { [PokemonData.Types.POISON] = true, }, -- PoisonPowder
	["86"] = { [PokemonData.Types.GROUND] = true, }, -- Thunder Wave
	["92"] = { [PokemonData.Types.POISON] = true, }, -- Toxic
	["139"] = { [PokemonData.Types.POISON] = true, }, -- Poison Gas
}

MoveData.IsTypelessMove = {}

MoveData.IsOHKOMove = {
	[ "12"] = true, -- Guillotine
	[ "32"] = true, -- Horn Drill
	[ "90"] = true, -- Fissure
}

MoveData.IsRecoilMove = {
	[ "36"] = true, -- Take Down
	[ "38"] = true, -- Double-Edge
	[ "66"] = true, -- Submission
	["165"] = true, -- Struggle
}

MoveData.IsNoMissDamagingMove = {
	["129"] = true, -- Swift
}

function MoveData.initialize()
	MoveData.knownTotal = nil

	-- For easier category lookups
	MoveData.Categories[1] = MoveData.Categories.PHYSICAL
	MoveData.Categories[2] = MoveData.Categories.SPECIAL
	MoveData.Categories[3] = MoveData.Categories.STATUS

	Gen1DataAdapter.initializeMoveData()
end

function MoveData.updateResources()
	for id = 1, MoveData.getTotal(), 1 do
		local move = MoveData.Moves[id] or MoveData.BlankMove
		if Resources.Game.MoveNames[id] then
			move.name = Resources.Game.MoveNames[id]
		end
		local descTable = Resources.Game.MoveDescriptions[id] or {}
		if descTable and descTable.Description then
			move.summary = descTable.Description
		end
	end
end

--- Reads the Move's type, power, accuracy, and pp from the game memory.
---@param forced boolean? Optional, forces the data to be read in from the game
function MoveData.buildData(forced)
	Gen1DataAdapter.initializeMoveData()
end

function MoveData.readMoveInfoFromMemory(moveId)
	return Gen1DataAdapter.readMoveInfo(moveId)
end

function MoveData.checkIfDataIsRandomized()
	return MoveData.isMoveDataRandomized()
end

---Returns true if the move data for this game is randomized (not vanilla), based on game data memory checks
---@return boolean
function MoveData.isMoveDataRandomized()
	return MoveData.IsRand.moveType or MoveData.IsRand.movePower or MoveData.IsRand.moveAccuracy or MoveData.IsRand.movePP or MoveData.IsRand.moveCategory
end

---Returns true if the TMs data for this game is randomized (not vanilla), based on game data memory checks
---@return boolean
function MoveData.isTMDataRandomized()
	return MoveData.IsRand.tms
end

---Returns true if the moveId is a valid, existing id of a move in MoveData.Moves
---@param moveId number
---@return boolean
function MoveData.isValid(moveId)
	return moveId ~= nil and MoveData.Moves[moveId] ~= nil
end

---Gets the total count of known Moves for this game.
---@return number
function MoveData.getTotal()
	return #MoveData.Moves
end

--Returns the Move data if the ID is available in the base game, or if NatDex extension exists, try getting data from there
---@param moveId number
---@return table move If no move found, returns MoveData.BlankMove
function MoveData.getNatDexCompatible(moveId)
	return MoveData.Moves[moveId or false] or MoveData.BlankMove
end

---Returns true if the move is a One-Hit KO move (i.e. Sheer Cold)
---@param moveId number|string
---@return boolean
function MoveData.isOHKO(moveId)
	return MoveData.IsOHKOMove[tostring(moveId)] ~= nil
end

---Returns true if the move causes recoil damage (i.e. Take Down); does NOT include Struggle (id=165)
---@param moveId number|string
---@return boolean
function MoveData.isRecoil(moveId)
	return MoveData.IsRecoilMove[tostring(moveId)] ~= nil
end

---Returns true if the move is a No-Miss damaging move (i.e. Swift).
---@param moveId number|string
---@return boolean
function MoveData.isNoMissDamagingMove(moveId)
	return MoveData.IsNoMissDamagingMove[tostring(moveId)] ~= nil
end

---Returns the move category of the move, such as Physical, Special, or Status; returns None if move not found
---@param moveId number|string
---@param moveType? string Optional, if provided (and not phys/spec split) will use this type to determine the category
---@return string category
function MoveData.getCategory(moveId, moveType)
	local move = MoveData.Moves[tonumber(moveId or "") or -1] or MoveData.BlankMove
	moveType = moveType or move.type
	if MoveData.IsRand.moveCategory then
		return move.category or MoveData.Categories.NONE
	end
	return MoveData.TypeToCategory[moveType] or MoveData.Categories.NONE
end

---Calculate the type & power of Hidden Power using a Pokémon's individual values (hp, atk, def, spa, spd, spe)
---@param ivs table Must contain key/value pairs for: hp, atk, def, spa, spd, spe
---@return string moveType The type of the move, or PokemonData.Types.UNKNOWN if it can't be calculated
---@return integer movePower the power of the move, between 30 and 70 inclusive; or 0 if unknown
function MoveData.calcHiddenPowerTypeAndPower(ivs)
	local moveType, movePower = MoveData.HiddenPowerTypeList[1], 0 -- unknown
	if not ivs or not ivs.hp then
		return moveType, movePower
	end

	-- Formula: https://bulbapedia.bulbagarden.net/wiki/Hidden_Power_(move)/Calculation#Generation_III_onward
	-- Type Bits: If a number is odd, its least significant bit is 1; otherwise (if the number is even), it is 0.
	local tBits = {
		hp = ivs.hp % 2,
		atk = ivs.atk % 2,
		def = ivs.def % 2,
		spe = ivs.spe % 2,
		spa = ivs.spa % 2,
		spd = ivs.spd % 2,
	}
	-- Power Bits: If a variable has a remainder of 2 or 3 when divided by 4, this bit is 1; otherwise, the bit is 0.
	local pBits = {
		hp = math.floor((ivs.hp % 4) / 2),
		atk = math.floor((ivs.atk % 4) / 2),
		def = math.floor((ivs.def % 4) / 2),
		spe = math.floor((ivs.spe % 4) / 2),
		spa = math.floor((ivs.spa % 4) / 2),
		spd = math.floor((ivs.spd % 4) / 2),
	}
	-- Perform the cacluation
	local typeSum = tBits.hp + (2 * tBits.atk) + (4 * tBits.def) + (8 * tBits.spe) + (16 * tBits.spa) + (32 * tBits.spd)
	local typeIndex = math.floor(typeSum * 15 / 63) -- results in 0 through 15, inclusive
	moveType = MoveData.HiddenPowerTypeList[typeIndex + 2] or MoveData.HiddenPowerTypeList[1] -- 1st is "unknown", 2nd is "fighting"
	local moveSum = pBits.hp + (2 * pBits.atk) + (4 * pBits.def) + (8 * pBits.spe) + (16 * pBits.spa) + (32 * pBits.spd)
	movePower = math.floor(moveSum * 40 / 63) + 30 -- results in 30 through 70, inclusive

	return moveType, movePower
end

---Determines (guesses) at the expected numerical power of a given move. For example, average power for multi-hit moves, or max power for HP based moves.
---@param moveId number
---@return number
function MoveData.getExpectedPower(moveId)
	if not MoveData.isValid(moveId) then
		return 0
	end

	-- https://bulbapedia.bulbagarden.net/wiki/Multi-strike_move#Variable_number_of_strikes
	local multiHitMoves = {
		[3] = true, [4] = true, [31] = true, [42] = true, [131] = true, [140] = true, [154] = true,
	}
	-- https://bulbapedia.bulbagarden.net/wiki/Multi-strike_move#Fixed_number_of_multiple_strikes
	local doubleHitMoves = {
		[155] = true, [24] = true, [41] = true,
	}

	local power = tonumber(MoveData.Moves[moveId].power) or 0
	if doubleHitMoves[moveId] then
		return (power * 2)
	elseif multiHitMoves[moveId] then
		-- Average of 3 hits
		return (power * 3)
	end

	return power
end

---Adjusts the move table data based on any variable damage calculations, or other attributes; No return, as this edits the move table directly.
---@param move table
---@param sourcePokemon? table Optional, as not all move adjustment calculations require a source and/or a target
---@param targetPokemon? table Optional, as not all move adjustment calculations require a source and/or a target
function MoveData.adjustVariableMoveValues(move, sourcePokemon, targetPokemon)
	sourcePokemon = sourcePokemon or {}
	targetPokemon = targetPokemon or {}
	local adjustmentFunc = MoveData.MoveValueAdjustmentFuncs[tonumber(move.id or 0) or false]
	if type(adjustmentFunc) == "function" then
		adjustmentFunc(move, sourcePokemon, targetPokemon)
	end
end

MoveData.BlankMove = {
	id = "0",
	name = Constants.BLANKLINE,
	type = PokemonData.Types.UNKNOWN,
	power = "0",
	pp = "0",
	accuracy = "0",
	category = MoveData.Categories.NONE,
	iscontact = false,
	priority = "0",
	summary = "",
}

--[[
The various Pokémon moves (Gen 3)
Data pulled from Bulbapedia: https://bulbapedia.bulbagarden.net/wiki/List_of_moves (Note that categories differ from the source for Gen 3)
Format for an entry:
	id: string -> internal id of the move, represented as an integer in a string
	name: string -> the name of the move as it appears in game
	type: string -> the type of damage the move does, using the PokemonData.Types enum
	power: string -> the strength of the move specified in game as in integer, or Constants.BLANKLINE when not applicable
	pp: string -> the base amount of actions this move is capable of
	accuracy: string -> the percent accuracy of the move connecting, or Constants.BLANKLINE when not applicable
	category: integer -> the type of damage a move does: physical/special/status, using the MoveData.Categories enum
]]
MoveData.Moves = {
	{ -- Begin Gen 1 Moves
		id = "1",
		name = "Pound",
		type = PokemonData.Types.NORMAL,
		power = "40",
		pp = "35",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "2",
		name = "Karate Chop",
		type = PokemonData.Types.FIGHTING,
		power = "50",
		pp = "25",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "3",
		name = "DoubleSlap",
		type = PokemonData.Types.NORMAL,
		power = "15",
		pp = "10",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "4",
		name = "Comet Punch",
		type = PokemonData.Types.NORMAL,
		power = "18",
		pp = "15",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "5",
		name = "Mega Punch",
		type = PokemonData.Types.NORMAL,
		power = "80",
		pp = "20",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "6",
		name = "Pay Day",
		type = PokemonData.Types.NORMAL,
		power = "40",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "7",
		name = "Fire Punch",
		type = PokemonData.Types.FIRE,
		power = "75",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "8",
		name = "Ice Punch",
		type = PokemonData.Types.ICE,
		power = "75",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "9",
		name = "ThunderPunch",
		type = PokemonData.Types.ELECTRIC,
		power = "75",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "10",
		name = "Scratch",
		type = PokemonData.Types.NORMAL,
		power = "40",
		pp = "35",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "11",
		name = "ViceGrip",
		type = PokemonData.Types.NORMAL,
		power = "55",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "12",
		name = "Guillotine",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "5",
		accuracy = "30",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		variablepower = true,
	},
	{
		id = "13",
		name = "Razor Wind",
		type = PokemonData.Types.NORMAL,
		power = "80",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "14",
		name = "Swords Dance",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "15",
		name = "Cut",
		type = PokemonData.Types.NORMAL,
		power = "50",
		pp = "30",
		accuracy = "95",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "16",
		name = "Gust",
		type = PokemonData.Types.FLYING,
		power = "40",
		pp = "35",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "17",
		name = "Wing Attack",
		type = PokemonData.Types.FLYING,
		power = "60",
		pp = "35",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "18",
		name = "Whirlwind",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
		priority = "-- 6",
	},
	{
		id = "19",
		name = "Fly",
		type = PokemonData.Types.FLYING,
		power = "70",
		pp = "15",
		accuracy = "95",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "20",
		name = "Bind",
		type = PokemonData.Types.NORMAL,
		power = "15",
		pp = "20",
		accuracy = "75",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "21",
		name = "Slam",
		type = PokemonData.Types.NORMAL,
		power = "80",
		pp = "20",
		accuracy = "75",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "22",
		name = "Vine Whip",
		type = PokemonData.Types.GRASS,
		power = "35",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "23",
		name = "Stomp",
		type = PokemonData.Types.NORMAL,
		power = "65",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "24",
		name = "Double Kick",
		type = PokemonData.Types.FIGHTING,
		power = "30",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "25",
		name = "Mega Kick",
		type = PokemonData.Types.NORMAL,
		power = "120",
		pp = "5",
		accuracy = "75",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "26",
		name = "Jump Kick",
		type = PokemonData.Types.FIGHTING,
		power = "70",
		pp = "25",
		accuracy = "95",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "27",
		name = "Rolling Kick",
		type = PokemonData.Types.FIGHTING,
		power = "60",
		pp = "15",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "28",
		name = "Sand-Attack",
		type = PokemonData.Types.GROUND,
		power = "0",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "29",
		name = "Headbutt",
		type = PokemonData.Types.NORMAL,
		power = "70",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "30",
		name = "Horn Attack",
		type = PokemonData.Types.NORMAL,
		power = "65",
		pp = "25",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "31",
		name = "Fury Attack",
		type = PokemonData.Types.NORMAL,
		power = "15",
		pp = "20",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "32",
		name = "Horn Drill",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "5",
		accuracy = "30",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		variablepower = true,
	},
	{
		id = "33",
		name = "Tackle",
		type = PokemonData.Types.NORMAL,
		power = "35",
		pp = "35",
		accuracy = "95",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "34",
		name = "Body Slam",
		type = PokemonData.Types.NORMAL,
		power = "85",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "35",
		name = "Wrap",
		type = PokemonData.Types.NORMAL,
		power = "15",
		pp = "20",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "36",
		name = "Take Down",
		type = PokemonData.Types.NORMAL,
		power = "90",
		pp = "20",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "37",
		name = "Thrash",
		type = PokemonData.Types.NORMAL,
		power = "90",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "38",
		name = "Double-Edge",
		type = PokemonData.Types.NORMAL,
		power = "120",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "39",
		name = "Tail Whip",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "40",
		name = "Poison Sting",
		type = PokemonData.Types.POISON,
		power = "15",
		pp = "35",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "41",
		name = "Twineedle",
		type = PokemonData.Types.BUG,
		power = "25",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "42",
		name = "Pin Missile",
		type = PokemonData.Types.BUG,
		power = "14",
		pp = "20",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "43",
		name = "Leer",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "44",
		name = "Bite",
		type = PokemonData.Types.DARK,
		power = "60",
		pp = "25",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "45",
		name = "Growl",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "40",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "46",
		name = "Roar",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
		priority = "-- 6",
	},
	{
		id = "47",
		name = "Sing",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "15",
		accuracy = "55",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "48",
		name = "Supersonic",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "55",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "49",
		name = "SonicBoom",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
		variablepower = true,
	},
	{
		id = "50",
		name = "Disable",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "55",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "51",
		name = "Acid",
		type = PokemonData.Types.POISON,
		power = "40",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "52",
		name = "Ember",
		type = PokemonData.Types.FIRE,
		power = "40",
		pp = "25",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "53",
		name = "Flamethrower",
		type = PokemonData.Types.FIRE,
		power = "95",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "54",
		name = "Mist",
		type = PokemonData.Types.ICE,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "55",
		name = "Water Gun",
		type = PokemonData.Types.WATER,
		power = "40",
		pp = "25",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "56",
		name = "Hydro Pump",
		type = PokemonData.Types.WATER,
		power = "120",
		pp = "5",
		accuracy = "80",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "57",
		name = "Surf",
		type = PokemonData.Types.WATER,
		power = "95",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "58",
		name = "Ice Beam",
		type = PokemonData.Types.ICE,
		power = "95",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "59",
		name = "Blizzard",
		type = PokemonData.Types.ICE,
		power = "120",
		pp = "5",
		accuracy = "70",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "60",
		name = "Psybeam",
		type = PokemonData.Types.PSYCHIC,
		power = "65",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "61",
		name = "BubbleBeam",
		type = PokemonData.Types.WATER,
		power = "65",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "62",
		name = "Aurora Beam",
		type = PokemonData.Types.ICE,
		power = "65",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "63",
		name = "Hyper Beam",
		type = PokemonData.Types.NORMAL,
		power = "150",
		pp = "5",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "64",
		name = "Peck",
		type = PokemonData.Types.FLYING,
		power = "35",
		pp = "35",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "65",
		name = "Drill Peck",
		type = PokemonData.Types.FLYING,
		power = "80",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "66",
		name = "Submission",
		type = PokemonData.Types.FIGHTING,
		power = "80",
		pp = "25",
		accuracy = "80",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "67",
		name = "Low Kick",
		type = PokemonData.Types.FIGHTING,
		power = "WT",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		variablepower = true,
	},
	{
		id = "68",
		name = "Counter",
		type = PokemonData.Types.FIGHTING,
		power = "0",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		priority = "-- 5",
		variablepower = true,
	},
	{
		id = "69",
		name = "Seismic Toss",
		type = PokemonData.Types.FIGHTING,
		power = "0",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		variablepower = true,
	},
	{
		id = "70",
		name = "Strength",
		type = PokemonData.Types.NORMAL,
		power = "80",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "71",
		name = "Absorb",
		type = PokemonData.Types.GRASS,
		power = "20",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "72",
		name = "Mega Drain",
		type = PokemonData.Types.GRASS,
		power = "40",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "73",
		name = "Leech Seed",
		type = PokemonData.Types.GRASS,
		power = "0",
		pp = "10",
		accuracy = "90",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "74",
		name = "Growth",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "40",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "75",
		name = "Razor Leaf",
		type = PokemonData.Types.GRASS,
		power = "55",
		pp = "25",
		accuracy = "95",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "76",
		name = "SolarBeam",
		type = PokemonData.Types.GRASS,
		power = "120",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "77",
		name = "PoisonPowder",
		type = PokemonData.Types.POISON,
		power = "0",
		pp = "35",
		accuracy = "75",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "78",
		name = "Stun Spore",
		type = PokemonData.Types.GRASS,
		power = "0",
		pp = "30",
		accuracy = "75",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "79",
		name = "Sleep Powder",
		type = PokemonData.Types.GRASS,
		power = "0",
		pp = "15",
		accuracy = "75",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "80",
		name = "Petal Dance",
		type = PokemonData.Types.GRASS,
		power = "70",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "81",
		name = "String Shot",
		type = PokemonData.Types.BUG,
		power = "0",
		pp = "40",
		accuracy = "95",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "82",
		name = "Dragon Rage",
		type = PokemonData.Types.DRAGON,
		power = "0",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		variablepower = true,
	},
	{
		id = "83",
		name = "Fire Spin",
		type = PokemonData.Types.FIRE,
		power = "15",
		pp = "15",
		accuracy = "70",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "84",
		name = "ThunderShock",
		type = PokemonData.Types.ELECTRIC,
		power = "40",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "85",
		name = "Thunderbolt",
		type = PokemonData.Types.ELECTRIC,
		power = "95",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "86",
		name = "Thunder Wave",
		type = PokemonData.Types.ELECTRIC,
		power = "0",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "87",
		name = "Thunder",
		type = PokemonData.Types.ELECTRIC,
		power = "120",
		pp = "10",
		accuracy = "70",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "88",
		name = "Rock Throw",
		type = PokemonData.Types.ROCK,
		power = "50",
		pp = "15",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "89",
		name = "Earthquake",
		type = PokemonData.Types.GROUND,
		power = "100",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "90",
		name = "Fissure",
		type = PokemonData.Types.GROUND,
		power = "0",
		pp = "5",
		accuracy = "30",
		category = MoveData.Categories.PHYSICAL,
		variablepower = true,
	},
	{
		id = "91",
		name = "Dig",
		type = PokemonData.Types.GROUND,
		power = "60",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "92",
		name = "Toxic",
		type = PokemonData.Types.POISON,
		power = "0",
		pp = "10",
		accuracy = "85",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "93",
		name = "Confusion",
		type = PokemonData.Types.PSYCHIC,
		power = "50",
		pp = "25",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "94",
		name = "Psychic",
		type = PokemonData.Types.PSYCHIC,
		power = "90",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "95",
		name = "Hypnosis",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "20",
		accuracy = "60",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "96",
		name = "Meditate",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "40",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "97",
		name = "Agility",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "98",
		name = "Quick Attack",
		type = PokemonData.Types.NORMAL,
		power = "40",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		priority = "+ 1",
	},
	{
		id = "99",
		name = "Rage",
		type = PokemonData.Types.NORMAL,
		power = "20",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "100",
		name = "Teleport",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "20",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "101",
		name = "Night Shade",
		type = PokemonData.Types.GHOST,
		power = "0",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		variablepower = true,
	},
	{
		id = "102",
		name = "Mimic",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "103",
		name = "Screech",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "40",
		accuracy = "85",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "104",
		name = "Double Team",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "15",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "105",
		name = "Recover",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "106",
		name = "Harden",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "107",
		name = "Minimize",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "108",
		name = "SmokeScreen",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "109",
		name = "Confuse Ray",
		type = PokemonData.Types.GHOST,
		power = "0",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "110",
		name = "Withdraw",
		type = PokemonData.Types.WATER,
		power = "0",
		pp = "40",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "111",
		name = "Defense Curl",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "40",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "112",
		name = "Barrier",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "113",
		name = "Light Screen",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "114",
		name = "Haze",
		type = PokemonData.Types.ICE,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "115",
		name = "Reflect",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "20",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "116",
		name = "Focus Energy",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "117",
		name = "Bide",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		variablepower = true,
	},
	{
		id = "118",
		name = "Metronome",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "119",
		name = "Mirror Move",
		type = PokemonData.Types.FLYING,
		power = "0",
		pp = "20",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "120",
		name = "Selfdestruct",
		type = PokemonData.Types.NORMAL,
		power = "200",
		pp = "5",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "121",
		name = "Egg Bomb",
		type = PokemonData.Types.NORMAL,
		power = "100",
		pp = "10",
		accuracy = "75",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "122",
		name = "Lick",
		type = PokemonData.Types.GHOST,
		power = "20",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "123",
		name = "Smog",
		type = PokemonData.Types.POISON,
		power = "20",
		pp = "20",
		accuracy = "70",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "124",
		name = "Sludge",
		type = PokemonData.Types.POISON,
		power = "65",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "125",
		name = "Bone Club",
		type = PokemonData.Types.GROUND,
		power = "65",
		pp = "20",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "126",
		name = "Fire Blast",
		type = PokemonData.Types.FIRE,
		power = "120",
		pp = "5",
		accuracy = "85",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "127",
		name = "Waterfall",
		type = PokemonData.Types.WATER,
		power = "80",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "128",
		name = "Clamp",
		type = PokemonData.Types.WATER,
		power = "35",
		pp = "10",
		accuracy = "75",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "129",
		name = "Swift",
		type = PokemonData.Types.NORMAL,
		power = "60",
		pp = "20",
		accuracy = "0",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "130",
		name = "Skull Bash",
		type = PokemonData.Types.NORMAL,
		power = "100",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "131",
		name = "Spike Cannon",
		type = PokemonData.Types.NORMAL,
		power = "20",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "132",
		name = "Constrict",
		type = PokemonData.Types.NORMAL,
		power = "10",
		pp = "35",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "133",
		name = "Amnesia",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "20",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "134",
		name = "Kinesis",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "15",
		accuracy = "80",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "135",
		name = "Softboiled",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "136",
		name = "Hi Jump Kick",
		type = PokemonData.Types.FIGHTING,
		power = "85",
		pp = "20",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "137",
		name = "Glare",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "75",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "138",
		name = "Dream Eater",
		type = PokemonData.Types.PSYCHIC,
		power = "100",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "139",
		name = "Poison Gas",
		type = PokemonData.Types.POISON,
		power = "0",
		pp = "40",
		accuracy = "55",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "140",
		name = "Barrage",
		type = PokemonData.Types.NORMAL,
		power = "15",
		pp = "20",
		accuracy = "85",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "141",
		name = "Leech Life",
		type = PokemonData.Types.BUG,
		power = "20",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "142",
		name = "Lovely Kiss",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "75",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "143",
		name = "Sky Attack",
		type = PokemonData.Types.FLYING,
		power = "140",
		pp = "5",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "144",
		name = "Transform",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "145",
		name = "Bubble",
		type = PokemonData.Types.WATER,
		power = "20",
		pp = "30",
		accuracy = "100",
		category = MoveData.Categories.SPECIAL,
	},
	{
		id = "146",
		name = "Dizzy Punch",
		type = PokemonData.Types.NORMAL,
		power = "70",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "147",
		name = "Spore",
		type = PokemonData.Types.GRASS,
		power = "0",
		pp = "15",
		accuracy = "100",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "148",
		name = "Flash",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "20",
		accuracy = "70",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "149",
		name = "Psywave",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "15",
		accuracy = "80",
		category = MoveData.Categories.SPECIAL,
		variablepower = true,
	},
	{
		id = "150",
		name = "Splash",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "40",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "151",
		name = "Acid Armor",
		type = PokemonData.Types.POISON,
		power = "0",
		pp = "40",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "152",
		name = "Crabhammer",
		type = PokemonData.Types.WATER,
		power = "90",
		pp = "10",
		accuracy = "85",
		category = MoveData.Categories.SPECIAL,
		iscontact = true,
	},
	{
		id = "153",
		name = "Explosion",
		type = PokemonData.Types.NORMAL,
		power = "250",
		pp = "5",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "154",
		name = "Fury Swipes",
		type = PokemonData.Types.NORMAL,
		power = "18",
		pp = "15",
		accuracy = "80",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "155",
		name = "Bonemerang",
		type = PokemonData.Types.GROUND,
		power = "50",
		pp = "10",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "156",
		name = "Rest",
		type = PokemonData.Types.PSYCHIC,
		power = "0",
		pp = "10",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "157",
		name = "Rock Slide",
		type = PokemonData.Types.ROCK,
		power = "75",
		pp = "10",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "158",
		name = "Hyper Fang",
		type = PokemonData.Types.NORMAL,
		power = "80",
		pp = "15",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "159",
		name = "Sharpen",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "160",
		name = "Conversion",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "30",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "161",
		name = "Tri Attack",
		type = PokemonData.Types.NORMAL,
		power = "80",
		pp = "10",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
	},
	{
		id = "162",
		name = "Super Fang",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "90",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
		variablepower = true,
	},
	{
		id = "163",
		name = "Slash",
		type = PokemonData.Types.NORMAL,
		power = "70",
		pp = "20",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
	{
		id = "164",
		name = "Substitute",
		type = PokemonData.Types.NORMAL,
		power = "0",
		pp = "10",
		accuracy = "0",
		category = MoveData.Categories.STATUS,
	},
	{
		id = "165",
		name = "Struggle",
		type = PokemonData.Types.NORMAL,
		power = "50",
		pp = "1",
		accuracy = "100",
		category = MoveData.Categories.PHYSICAL,
		iscontact = true,
	},
}
