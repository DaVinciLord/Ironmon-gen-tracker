PokemonData = {}

PokemonData.Values = {
	QuestionMarkId = 252, -- The ID of the image file that shows a question mark for unknown pokemon (like scouting route pivots)
	EggId = 412,
	GhostId = 413, -- Pokémon Tower's Silph Scope Ghost
	DefaultBaseFriendship = 70,
	FriendshipRequiredToEvo = 220,
	ExpYieldBulbasaur = 64,
	ExpYieldLapras = 219,
	ExpYieldShuckle = 80,
}

-- https://github.com/pret/pokefirered/blob/0c17a3b041a56f176f23145e4a4c0ae758f8d720/include/pokemon.h#L208-L236
PokemonData.Addresses = {
	offsetBaseStats = 0x0,
	offsetTypes = 0x6,
	offsetCatchRate = 0x8,
	offsetExpYield = 0x9,
	offsetGenderRatio = 0x10,
	offsetBaseFriendship = 0x12,
	offsetLevelUpMoveId = 0x0,
	offsetLevelUpMoveLv = 0x9,

	sizeofExpYield = 1, -- Number of bytes for the experience yield section
	sizeofLevelUpLearnset = 4,
	sizeofLevelUpMove = 2,
	sizeofLevelUpMoveId = 9,
	sizeofLevelUpMoveLv = 7,

	endFlagLevelUp = 0xFFFF
}

PokemonData.IsRand = {
	types = false,
	stats = false,
	moveLearnSet = false,
	friendshipBase = false,
	expYield = false
}

-- Enumerated constants that defines the various types a Pokémon and its Moves are
PokemonData.Types = {
	NORMAL = "normal",
	FIGHTING = "fighting",
	FLYING = "flying",
	POISON = "poison",
	GROUND = "ground",
	ROCK = "rock",
	BUG = "bug",
	GHOST = "ghost",
	STEEL = "steel",
	FIRE = "fire",
	WATER = "water",
	GRASS = "grass",
	ELECTRIC = "electric",
	PSYCHIC = "psychic",
	ICE = "ice",
	DRAGON = "dragon",
	DARK = "dark",
	FAIRY = "fairy", -- Adding in just for Nat. Dex. rom hack support convenience
	UNKNOWN = "unknown", -- For the move "Curse" in Gen 2-4
	EMPTY = "", -- No second type for this Pokémon or an empty field
}

-- Enumerated constants that defines various evolution possibilities
-- This enum does NOT include levels for evolution, only stones, friendship, no evolution, etc.
PokemonData.Evolutions = {
	-- This Pokémon does not evolve.
	NONE = {
		abbreviation = Constants.BLANKLINE,
		short = { Constants.BLANKLINE, },
		detailed = { Constants.BLANKLINE, },
	},
	-- Unused directly, necessary as an info index
	LEVEL = {
		abbreviation = "LEVEL",
		short = { "Lv.%s", }, -- requires level parameter
		detailed = { "Level %s", }, -- requires level value
	},
	-- High friendship
	FRIEND = {
		abbreviation = "FRIEND",
		short = { "Friend", },
		detailed = { "%s Friendship", }, -- requires friendship value
	},
	-- High friendship, Pokémon has enough friendship to evolve
	FRIEND_READY = {
		abbreviation = "READY",
	},
	-- Various evolution stone items
	EEVEE_STONES = {
		abbreviation = "STONE",
		short = { "Thunder", "Water", "Fire", "Sun", "Moon", },
		detailed = { "5 Diff. Stones", },
		evoItemIds = { 93, 94, 95, 96, 97 },
	},
	-- Thunderstone item
	THUNDER = {
		abbreviation = "THUNDER",
		short = { "Thunder", },
		detailed = { "Thunderstone", },
		evoItemIds = { 96 },
	},
	-- Fire stone item
	FIRE = {
		abbreviation = "FIRE",
		short = { "Fire", },
		detailed = { "Fire Stone", },
		evoItemIds = { 95 },
	},
	-- Water stone item
	WATER = {
		abbreviation = "WATER",
		short = { "Water", },
		detailed = { "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Moon stone item
	MOON = {
		abbreviation = "MOON",
		short = { "Moon", },
		detailed = { "Moon Stone", },
		evoItemIds = { 94 },
	},
	-- Leaf stone item
	LEAF = {
		abbreviation = "LEAF",
		short = { "Leaf", },
		detailed = { "Leaf Stone", },
		evoItemIds = { 98 },
	},
	-- Sun stone item
	SUN = {
		abbreviation = "SUN",
		short = { "Sun", },
		detailed = { "Sun Stone", },
		evoItemIds = { 93 },
	},
	-- Leaf or Sun stone items
	LEAF_SUN = {
		abbreviation = "LF/SN",
		short = { "Leaf", "Sun", },
		detailed = { "Leaf Stone", "Sun Stone", },
		evoItemIds = { 93, 98, },
	},
	-- Water stone item or at level 30
	WATER30 = {
		abbreviation = "30/WTR",
		short = { "Lv.30", "Water", },
		detailed = { "Level 30", "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Water stone item or at level 37
	WATER37 = {
		abbreviation = "37/WTR",
		short = { "Lv.37", "Water", },
		detailed = { "Level 37", "Water Stone", },
		evoItemIds = { 97 },
	},
	-- Water stone item or at level 37 (reverse order)
	WATER37_REV = {
		abbreviation = "WTR/37",
		short = { "Water", "Lv.37", },
		detailed = { "Water Stone", "Level 37", },
		evoItemIds = { 97 },
	},
}

function PokemonData.initialize()
	PokemonData.knownTotal = nil
	Gen1DataAdapter.initializePokemonData()
end

function PokemonData.updateResources()
	for id = 1, PokemonData.getTotal(), 1 do
		local pokemon = PokemonData.Pokemon[id] or PokemonData.BlankPokemon
		if Resources.Game.PokemonNames[id] then
			pokemon.name = Resources.Game.PokemonNames[id]
		end
	end

	-- Manually add in each evolution translation, as each has different formatting
	local PE = PokemonData.Evolutions
	local RPED = Resources.PokemonEvolutionDetails
	-- PE.LEVEL.abbreviation = RPED.LEVEL.abbreviation -- Doesn't need translation; not displayed
	PE.LEVEL.short = { RPED.LEVEL.short .. "%s" }
	PE.LEVEL.detailed = { RPED.LEVEL.detailed .. " %s" }
	PE.FRIEND.abbreviation = RPED.FRIEND.abbreviation
	PE.FRIEND.short = { RPED.FRIEND.short }
	PE.FRIEND.detailed = { "%s " .. RPED.FRIEND.detailed }
	PE.FRIEND_READY.abbreviation = RPED.FRIEND_READY.abbreviation
	PE.EEVEE_STONES.abbreviation = RPED.EEVEE_STONES.abbreviation
	PE.EEVEE_STONES.short = { RPED.THUNDER.short, RPED.WATER.short, RPED.FIRE.short, RPED.SUN.short, RPED.MOON.short, }
	PE.EEVEE_STONES.detailed = { RPED.EEVEE_STONES.detailed, }
	PE.THUNDER.abbreviation = RPED.THUNDER.abbreviation
	PE.THUNDER.short = { RPED.THUNDER.short }
	PE.THUNDER.detailed = { RPED.THUNDER.detailed }
	PE.FIRE.abbreviation = RPED.FIRE.abbreviation
	PE.FIRE.short = { RPED.FIRE.short }
	PE.FIRE.detailed = { RPED.FIRE.detailed }
	PE.WATER.abbreviation = RPED.WATER.abbreviation
	PE.WATER.short = { RPED.WATER.short }
	PE.WATER.detailed = { RPED.WATER.detailed }
	PE.MOON.abbreviation = RPED.MOON.abbreviation
	PE.MOON.short = { RPED.MOON.short }
	PE.MOON.detailed = { RPED.MOON.detailed }
	PE.LEAF.abbreviation = RPED.LEAF.abbreviation
	PE.LEAF.short = { RPED.LEAF.short }
	PE.LEAF.detailed = { RPED.LEAF.detailed }
	PE.SUN.abbreviation = RPED.SUN.abbreviation
	PE.SUN.short = { RPED.SUN.short }
	PE.SUN.detailed = { RPED.SUN.detailed }
	PE.LEAF_SUN.abbreviation = RPED.LEAF_SUN.abbreviation
	PE.LEAF_SUN.short = { RPED.LEAF.short, RPED.SUN.short, }
	PE.LEAF_SUN.detailed = { RPED.LEAF.detailed, RPED.SUN.detailed, }
	PE.WATER30.abbreviation = RPED.WATER30.abbreviation
	PE.WATER30.short = { RPED.LEVEL.short .. "30", RPED.WATER.short, }
	PE.WATER30.detailed = { RPED.LEVEL.detailed .. " 30", RPED.WATER.detailed, }
	PE.WATER37.abbreviation = RPED.WATER37.abbreviation
	PE.WATER37.short = { RPED.LEVEL.short .. "37", RPED.WATER.short, }
	PE.WATER37.detailed = { RPED.LEVEL.detailed .. " 37", RPED.WATER.detailed, }
	PE.WATER37_REV.abbreviation = RPED.WATER37_REV.abbreviation
	PE.WATER37_REV.short = { RPED.WATER.short, RPED.LEVEL.short .. "37", }
	PE.WATER37_REV.detailed = { RPED.WATER.detailed, RPED.LEVEL.detailed .. " 37", }
end

function PokemonData.buildData(forced)
	Gen1DataAdapter.initializePokemonData()
end

--- Compare data from game memory with original game data to determine what's been randomized
function PokemonData.checkIfDataIsRandomized()
	-- Randomization flags are set by Gen1DataAdapter.initializePokemonData().
end

---Returns true if the Pokémon data in this game is randomized (not vanilla), based on game data memory checks
---@return boolean
function PokemonData.isGameDataRandomized()
	return PokemonData.IsRand.types or PokemonData.IsRand.stats
		or PokemonData.IsRand.moveLearnSet or PokemonData.IsRand.friendshipBase or PokemonData.IsRand.expYield
end

---Returns true if info unknown to the player (random or otherwise) is allowed to be revealed.
---@return boolean
function PokemonData.canShowUnknownTypes()
	if Options["Open Book Play Mode"] then
		return true
	end
	return not PokemonData.IsRand.types and Options["Show data for vanilla game"]
end

---Returns true if info unknown to the player (random or otherwise) is allowed to be revealed.
---@return boolean
function PokemonData.canShowUnknownStats()
	if Options["Open Book Play Mode"] then
		return true
	end
	return not PokemonData.IsRand.stats and Options["Show data for vanilla game"]
end

---Returns true if info unknown to the player (random or otherwise) is allowed to be revealed.
---@return boolean
function PokemonData.canShowUnknownMoveLearnSets()
	if Options["Open Book Play Mode"] then
		return true
	end
	return not PokemonData.IsRand.moveLearnSet and Options["Show data for vanilla game"]
end

function PokemonData.getTypeResource(typename)
	typename = typename or "unknown"
	return Resources.Game.PokemonTypes[typename] or Resources.Game.PokemonTypes.unknown
end

---Returns true if the pokemonId is a valid, existing id of a pokemon in PokemonData.Pokemon
---@param pokemonID number
---@return boolean
function PokemonData.isValid(pokemonID)
	return pokemonID ~= nil and PokemonData.Pokemon[pokemonID] ~= nil
end

---Returns true if the pokemonId is a valid id of a pokemon that can be drawn, usually from an image file
---@param pokemonID number
---@return boolean
function PokemonData.isImageIDValid(pokemonID)
	-- 0 is a valid placeholder id
	return PokemonData.isValid(pokemonID) or pokemonID == PokemonData.Values.EggId or pokemonID == PokemonData.Values.GhostId or pokemonID == 0
end

---Gets the total count of known Pokémon for this game.
---@return number
function PokemonData.getTotal()
	return #PokemonData.Pokemon
end

---Returns the Pokemon data if the ID is available in the base game, or if NatDex extension exists, try getting data from there
---@param pokemonID number
---@return table pokemon If no mon found, returns PokemonData.BlankPokemon
function PokemonData.getNatDexCompatible(pokemonID)
	return PokemonData.Pokemon[pokemonID or false] or PokemonData.BlankPokemon
end

function PokemonData.dexMapInternalToNational(pokemonID)
	return pokemonID
end

function PokemonData.dexMapNationalToInternal(pokemonID)
	return pokemonID
end

function PokemonData.getIdFromName(pokemonName)
	for id = 1, PokemonData.getTotal(), 1 do
		local pokemon = PokemonData.Pokemon[id] or PokemonData.BlankPokemon
		if pokemon.name == pokemonName then
			return id
		end
	end

	return nil
end

function PokemonData.namesToList()
	local pokemonNames = {}
	for id = 1, PokemonData.getTotal(), 1 do
		local pokemon = PokemonData.Pokemon[id] or PokemonData.BlankPokemon
		if id < 252 or id > 276 then -- Skip fake Pokemon
			table.insert(pokemonNames, pokemon.name)
		end
	end
	return pokemonNames
end

-- Returns a table that contains the type weaknesses, resistances, and immunities for a Pokémon, listed as type-strings
function PokemonData.getEffectiveness(pokemonID)
	local effectiveness = {
		[0] = {},
		[0.25] = {},
		[0.5] = {},
		[1] = {},
		[2] = {},
		[4] = {},
	}

	if not PokemonData.isValid(pokemonID) then
		return effectiveness
	end

	local pokemon = PokemonData.Pokemon[pokemonID]

	for moveType, typeMultiplier in pairs(MoveData.TypeToEffectiveness) do
		local total = 1
		if pokemon.types and typeMultiplier[pokemon.types[1]] ~= nil then
			total = total * typeMultiplier[pokemon.types[1]]
		end
		if pokemon.types and pokemon.types[2] ~= pokemon.types[1] and typeMultiplier[pokemon.types[2]] ~= nil then
			total = total * typeMultiplier[pokemon.types[2]]
		end
		if effectiveness[total] ~= nil then
			table.insert(effectiveness[total], moveType)
		end
	end

	return effectiveness
end

---Returns whole number between 0 and 100 representing the percent likelihood to catch a pokemon
---@param pokemonID number
---@param hpMax number
---@param hpCurrent number
---@param level number? Optional, the Pokémon level, used only for Nest Ball; defaults to 5
---@param status number? Optional, defaults to "None"
---@param ball number? Optional, defaults to Poké Ball (item id = 4)
---@param terrain number? Optional, defaults to 0 (no terrain); use 3 for UNDERWATER
---@param battleTurn number? Optional, defaults to 0; first turn of a battle
---@return number
function PokemonData.calcCatchRate(pokemonID, hpMax, hpCurrent, level, status, ball, terrain, battleTurn)
	return Gen1DataAdapter.calcCatchRate(pokemonID, hpMax, hpCurrent, level, status, ball)
end

---Reads from the game data all of the level-up moves learned by a Pokémon species
---@param pokemonID number
---@return table<number, table<string, number>> learnedMoves A list moves, each entry as a table: { id = number, level = number }
function PokemonData.readLevelUpMoves(pokemonID)
	if not PokemonData.isValid(pokemonID) then
		return {}
	end
	local _, moves = Gen1DataAdapter.readEvolutionsAndMoves(pokemonID)
	return moves or {}
end

PokemonData.TypeIndexMap = {
	[0x00] = PokemonData.Types.NORMAL,
	[0x01] = PokemonData.Types.FIGHTING,
	[0x02] = PokemonData.Types.FLYING,
	[0x03] = PokemonData.Types.POISON,
	[0x04] = PokemonData.Types.GROUND,
	[0x05] = PokemonData.Types.ROCK,
	[0x06] = PokemonData.Types.BUG,
	[0x07] = PokemonData.Types.GHOST,
	[0x08] = PokemonData.Types.STEEL,
	[0x09] = PokemonData.Types.UNKNOWN, -- MYSTERY
	[0x0A] = PokemonData.Types.FIRE,
	[0x0B] = PokemonData.Types.WATER,
	[0x0C] = PokemonData.Types.GRASS,
	[0x0D] = PokemonData.Types.ELECTRIC,
	[0x0E] = PokemonData.Types.PSYCHIC,
	[0x0F] = PokemonData.Types.ICE,
	[0x10] = PokemonData.Types.DRAGON,
	[0x11] = PokemonData.Types.DARK,
	[0x12] = PokemonData.Types.FAIRY,
}
PokemonData.TypeNameToIndexMap = {
	[PokemonData.Types.NORMAL] = 0x00,
	[PokemonData.Types.FIGHTING] = 0x01,
	[PokemonData.Types.FLYING] = 0x02,
	[PokemonData.Types.POISON] = 0x03,
	[PokemonData.Types.GROUND] = 0x04,
	[PokemonData.Types.ROCK] = 0x05,
	[PokemonData.Types.BUG] = 0x06,
	[PokemonData.Types.GHOST] = 0x07,
	[PokemonData.Types.STEEL] = 0x08,
	[PokemonData.Types.UNKNOWN] = 0x09, -- MYSTERY
	[PokemonData.Types.FIRE] = 0x0A,
	[PokemonData.Types.WATER] = 0x0B,
	[PokemonData.Types.GRASS] = 0x0C,
	[PokemonData.Types.ELECTRIC] = 0x0D,
	[PokemonData.Types.PSYCHIC] = 0x0E,
	[PokemonData.Types.ICE] = 0x0F,
	[PokemonData.Types.DRAGON] = 0x10,
	[PokemonData.Types.DARK] = 0x11,
	[PokemonData.Types.FAIRY] = 0x12,
}

PokemonData.BlankPokemon = {
	pokemonID = 0,
	name = Constants.BLANKLINE,
	types = { PokemonData.Types.UNKNOWN, PokemonData.Types.EMPTY },
	evolution = PokemonData.Evolutions.NONE,
	bst = Constants.BLANKLINE,
	expYield = 0,
	movelvls = { {}, {} },
	weight = 0.0,
	friendshipBase = 0,
}

--[[
Data for each Pokémon (Gen 3) - Sourced from Bulbapedia
Format for an entry:
	pokemonID: integer -> The gen 3 pokedex id number for this Pokémon; automatically populated
	name: string -> Name of the Pokémon as it appears in game
	types: {string, string} -> Each Pokémon can have one or two types, using the PokemonData.Types enum to alias the strings; automatically populated from game memory
	evolution: string -> Displays the level, item, or other requirement a Pokémon needs to evolve
	bst: integer -> A sum of the base stats of the Pokémon
	expYield: integer -> Base experience yield of the Pokémon; automatically populated from game memory
	movelvls: {{integer list}, {integer list}} -> A pair of tables (1:RSE/2:FRLG) declaring the levels at which a Pokémon learns new moves or an empty list means it learns nothing
	weight: number -> pokemon's weight in kg (mainly used for Low Kick calculations)
]]
PokemonData.Pokemon = {
	{
		name = "Bulbasaur",
		evolution = "16",
		bst = 318,
		movelvls = { { 4, 7, 10, 15, 15, 20, 25, 32, 39, 46 }, { 4, 7, 10, 15, 15, 20, 25, 32, 39, 46 } },
		weight = 6.9
	},
	{
		name = "Ivysaur",
		evolution = "32",
		bst = 405,
		movelvls = { { 4, 7, 10, 15, 15, 22, 29, 38, 47, 56 }, { 4, 7, 10, 15, 15, 22, 29, 38, 47, 56 } },
		weight = 13.0
	},
	{
		name = "Venusaur",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 4, 7, 10, 15, 15, 22, 29, 41, 53, 65 }, { 4, 7, 10, 15, 15, 22, 29, 41, 53, 65 } },
		weight = 100.0
	},
	{
		name = "Charmander",
		evolution = "16",
		bst = 309,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 8.5
	},
	{
		name = "Charmeleon",
		evolution = "36",
		bst = 405,
		movelvls = { { 7, 13, 20, 27, 34, 41, 48, 55 }, { 7, 13, 20, 27, 34, 41, 48, 55 } },
		weight = 19.0
	},
	{
		name = "Charizard",
		evolution = PokemonData.Evolutions.NONE,
		bst = 534,
		movelvls = { { 7, 13, 20, 27, 34, 36, 44, 54, 64 }, { 7, 13, 20, 27, 34, 36, 44, 54, 64 } },
		weight = 90.5
	},
	{
		name = "Squirtle",
		evolution = "16",
		bst = 314,
		movelvls = { { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 }, { 4, 7, 10, 13, 18, 23, 28, 33, 40, 47 } },
		weight = 9.0
	},
	{
		name = "Wartortle",
		evolution = "36",
		bst = 405,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 37, 45, 53 }, { 4, 7, 10, 13, 19, 25, 31, 37, 45, 53 } },
		weight = 22.5
	},
	{
		name = "Blastoise",
		evolution = PokemonData.Evolutions.NONE,
		bst = 530,
		movelvls = { { 4, 7, 10, 13, 19, 25, 31, 42, 55, 68 }, { 4, 7, 10, 13, 19, 25, 31, 42, 55, 68 } },
		weight = 85.5
	},
	{
		name = "Caterpie",
		evolution = "7",
		bst = 195,
		movelvls = { {}, {} },
		weight = 2.9
	},
	{
		name = "Metapod",
		evolution = "10",
		bst = 205,
		movelvls = { { 7 }, { 7 } },
		weight = 9.9
	},
	{
		name = "Butterfree",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 }, { 10, 13, 14, 15, 18, 23, 28, 34, 40, 47 } },
		weight = 32.0
	},
	{
		name = "Weedle",
		evolution = "7",
		bst = 195,
		movelvls = { {}, {} },
		weight = 3.2
	},
	{
		name = "Kakuna",
		evolution = "10",
		bst = 205,
		movelvls = { { 7 }, { 7 } },
		weight = 10.0
	},
	{
		name = "Beedrill",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 10, 15, 20, 25, 30, 35, 40, 45 }, { 10, 15, 20, 25, 30, 35, 40, 45 } },
		weight = 29.5
	},
	{
		name = "Pidgey",
		evolution = "18",
		bst = 251,
		movelvls = { { 5, 9, 13, 19, 25, 31, 39, 47 }, { 5, 9, 13, 19, 25, 31, 39, 47 } },
		weight = 1.8
	},
	{
		name = "Pidgeotto",
		evolution = "36",
		bst = 349,
		movelvls = { { 5, 9, 13, 20, 27, 34, 43, 52 }, { 5, 9, 13, 20, 27, 34, 43, 52 } },
		weight = 30.0
	},
	{
		name = "Pidgeot",
		evolution = PokemonData.Evolutions.NONE,
		bst = 469,
		movelvls = { { 5, 9, 13, 20, 27, 34, 48, 62 }, { 5, 9, 13, 20, 27, 34, 48, 62 } },
		weight = 39.5
	},
	{
		name = "Rattata",
		evolution = "20",
		bst = 253,
		movelvls = { { 7, 13, 20, 27, 34, 41 }, { 7, 13, 20, 27, 34, 41 } },
		weight = 3.5
	},
	{
		name = "Raticate",
		evolution = PokemonData.Evolutions.NONE,
		bst = 413,
		movelvls = { { 7, 13, 20, 30, 40, 50 }, { 7, 13, 20, 30, 40, 50 } },
		weight = 18.5
	},
	{
		name = "Spearow",
		evolution = "20",
		bst = 262,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.0
	},
	{
		name = "Fearow",
		evolution = PokemonData.Evolutions.NONE,
		bst = 442,
		movelvls = { { 7, 13, 26, 32, 40, 47 }, { 7, 13, 26, 32, 40, 47 } },
		weight = 38.0
	},
	{
		name = "Ekans",
		evolution = "22",
		bst = 288,
		movelvls = { { 8, 13, 20, 25, 32, 37, 37, 37, 44 }, { 8, 13, 20, 25, 32, 37, 37, 37, 44 } },
		weight = 6.9
	},
	{
		name = "Arbok",
		evolution = PokemonData.Evolutions.NONE,
		bst = 438,
		movelvls = { { 8, 13, 20, 28, 38, 46, 46, 46, 56 }, { 8, 13, 20, 28, 38, 46, 46, 46, 56 } },
		weight = 65.0
	},
	{
		name = "Pikachu",
		evolution = PokemonData.Evolutions.THUNDER,
		bst = 300,
		movelvls = { { 6, 8, 11, 15, 20, 26, 33, 41, 50 }, { 6, 8, 11, 15, 20, 26, 33, 41, 50 } },
		weight = 6.0
	},
	{
		name = "Raichu",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { {}, {} },
		weight = 30.0
	},
	{
		name = "Sandshrew",
		evolution = "22",
		bst = 300,
		movelvls = { { 6, 11, 17, 23, 30, 37, 45, 53 }, { 6, 11, 17, 23, 30, 37, 45, 53 } },
		weight = 12.0
	},
	{
		name = "Sandslash",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 6, 11, 17, 24, 33, 42, 52, 62 }, { 6, 11, 17, 24, 33, 42, 52, 62 } },
		weight = 29.5
	},
	{
		name = "Nidoran F",
		evolution = "16",
		bst = 275,
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 7.0
	},
	{
		name = "Nidorina",
		evolution = PokemonData.Evolutions.MOON,
		bst = 365,
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 20.0
	},
	{
		name = "Nidoqueen",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 23 }, { 22, 43 } },
		weight = 60.0
	},
	{
		name = "Nidoran M",
		evolution = "16",
		bst = 273,
		movelvls = { { 8, 12, 17, 20, 23, 30, 38, 47 }, { 8, 12, 17, 20, 23, 30, 38, 47 } },
		weight = 9.0
	},
	{
		name = "Nidorino",
		evolution = PokemonData.Evolutions.MOON,
		bst = 365,
		movelvls = { { 8, 12, 18, 22, 26, 34, 43, 53 }, { 8, 12, 18, 22, 26, 34, 43, 53 } },
		weight = 19.5
	},
	{
		name = "Nidoking",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 23 }, { 22, 43 } },
		weight = 62.0
	},
	{
		name = "Clefairy",
		evolution = PokemonData.Evolutions.MOON,
		bst = 323,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 7.5,
		friendshipBase = 140
	},
	{
		name = "Clefable",
		evolution = PokemonData.Evolutions.NONE,
		bst = 473,
		movelvls = { {}, {} },
		weight = 40.0,
		friendshipBase = 140
	},
	{
		name = "Vulpix",
		evolution = PokemonData.Evolutions.FIRE,
		bst = 299,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41 } },
		weight = 9.9
	},
	{
		name = "Ninetales",
		evolution = PokemonData.Evolutions.NONE,
		bst = 505,
		movelvls = { { 45 }, { 45 } },
		weight = 19.9
	},
	{
		name = "Jigglypuff",
		evolution = PokemonData.Evolutions.MOON,
		bst = 270,
		movelvls = { { 4, 9, 14, 19, 24, 29, 34, 39, 44, 49 }, { 4, 9, 14, 19, 24, 29, 34, 39, 44, 49 } },
		weight = 5.5
	},
	{
		name = "Wigglytuff",
		evolution = PokemonData.Evolutions.NONE,
		bst = 425,
		movelvls = { {}, {} },
		weight = 12.0
	},
	{
		name = "Zubat",
		evolution = "22",
		bst = 245,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 7.5
	},
	{
		name = "Golbat",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 455,
		movelvls = { { 6, 11, 16, 21, 28, 35, 42, 49, 56 }, { 6, 11, 16, 21, 28, 35, 42, 49, 56 } },
		weight = 55.0
	},
	{
		name = "Oddish",
		evolution = "21",
		bst = 320,
		movelvls = { { 7, 14, 16, 18, 23, 32, 39 }, { 7, 14, 16, 18, 23, 32, 39 } },
		weight = 5.4
	},
	{
		name = "Gloom",
		evolution = PokemonData.Evolutions.LEAF_SUN,
		bst = 395,
		movelvls = { { 7, 14, 16, 18, 24, 35, 44 }, { 7, 14, 16, 18, 24, 35, 44 } },
		weight = 8.6
	},
	{
		name = "Vileplume",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 44 }, { 44 } },
		weight = 18.6
	},
	{
		name = "Paras",
		evolution = "24",
		bst = 285,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 5.4
	},
	{
		name = "Parasect",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51, 59 }, { 7, 13, 19, 27, 35, 43, 51, 59 } },
		weight = 29.5
	},
	{
		name = "Venonat",
		evolution = "31",
		bst = 305,
		movelvls = { { 9, 17, 20, 25, 28, 33, 36, 41 }, { 9, 17, 20, 25, 28, 33, 36, 41 } },
		weight = 30.0
	},
	{
		name = "Venomoth",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 9, 17, 20, 25, 28, 31, 36, 42, 52 }, { 9, 17, 20, 25, 28, 31, 36, 42, 52 } },
		weight = 12.5
	},
	{
		name = "Diglett",
		evolution = "26",
		bst = 265,
		movelvls = { { 5, 9, 17, 25, 33, 41, 49 }, { 5, 9, 17, 21, 25, 33, 41, 49 } },
		weight = 0.8
	},
	{
		name = "Dugtrio",
		evolution = PokemonData.Evolutions.NONE,
		bst = 405,
		movelvls = { { 5, 9, 17, 25, 26, 38, 51, 64 }, { 5, 9, 17, 21, 25, 26, 38, 51, 64 } },
		weight = 33.3
	},
	{
		name = "Meowth",
		evolution = "28",
		bst = 290,
		movelvls = { { 11, 20, 28, 35, 41, 46, 50 }, { 10, 18, 25, 31, 36, 40, 43, 45 } },
		weight = 4.2
	},
	{
		name = "Persian",
		evolution = PokemonData.Evolutions.NONE,
		bst = 440,
		movelvls = { { 11, 20, 29, 38, 46, 53, 59 }, { 10, 18, 25, 34, 42, 49, 55, 61 } },
		weight = 32.0
	},
	{
		name = "Psyduck",
		evolution = "33",
		bst = 320,
		movelvls = { { 5, 10, 16, 23, 31, 40, 50 }, { 5, 10, 16, 23, 31, 40, 50 } },
		weight = 19.6
	},
	{
		name = "Golduck",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 5, 10, 16, 23, 31, 44, 58 }, { 5, 10, 16, 23, 31, 44, 58 } },
		weight = 76.6
	},
	{
		name = "Mankey",
		evolution = "28",
		bst = 305,
		movelvls = { { 9, 15, 21, 27, 33, 39, 45, 51 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 28.0
	},
	{
		name = "Primeape",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 9, 15, 21, 27, 28, 36, 45, 54, 63 }, { 6, 11, 16, 21, 26, 28, 35, 44, 53, 62 } },
		weight = 32.0
	},
	{
		name = "Growlithe",
		evolution = PokemonData.Evolutions.FIRE,
		bst = 350,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 19.0
	},
	{
		name = "Arcanine",
		evolution = PokemonData.Evolutions.NONE,
		bst = 555,
		movelvls = { { 49 }, { 49 } },
		weight = 155.0
	},
	{
		name = "Poliwag",
		evolution = "25",
		bst = 300,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 12.4
	},
	{
		name = "Poliwhirl",
		evolution = PokemonData.Evolutions.WATER37_REV, -- Level 37 replaces trade evolution for Politoed
		bst = 385,
		movelvls = { { 7, 13, 19, 27, 35, 43, 51 }, { 7, 13, 19, 27, 35, 43, 51 } },
		weight = 20.0
	},
	{
		name = "Poliwrath",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 35, 51 }, { 35, 51 } },
		weight = 54.0
	},
	{
		name = "Abra",
		evolution = "16",
		bst = 310,
		movelvls = { {}, {} },
		weight = 19.5
	},
	{
		name = "Kadabra",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 400,
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 56.5
	},
	{
		name = "Alakazam",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 16, 18, 21, 23, 25, 30, 33, 36, 43 }, { 16, 18, 21, 23, 25, 30, 33, 36, 43 } },
		weight = 48.0
	},
	{
		name = "Machop",
		evolution = "28",
		bst = 305,
		movelvls = { { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 }, { 7, 13, 19, 22, 25, 31, 37, 40, 43, 49 } },
		weight = 19.5
	},
	{
		name = "Machoke",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 405,
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 70.5
	},
	{
		name = "Machamp",
		evolution = PokemonData.Evolutions.NONE,
		bst = 505,
		movelvls = { { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 }, { 7, 13, 19, 22, 25, 33, 41, 46, 51, 59 } },
		weight = 130.0
	},
	{
		name = "Bellsprout",
		evolution = "21",
		bst = 300,
		movelvls = { { 6, 11, 15, 17, 19, 23, 30, 37, 45 }, { 6, 11, 15, 17, 19, 23, 30, 37, 45 } },
		weight = 4.0
	},
	{
		name = "Weepinbell",
		evolution = PokemonData.Evolutions.LEAF,
		bst = 390,
		movelvls = { { 6, 11, 15, 17, 19, 24, 33, 42, 54 }, { 6, 11, 15, 17, 19, 24, 33, 42, 54 } },
		weight = 6.4
	},
	{
		name = "Victreebel",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { {}, {} },
		weight = 15.5
	},
	{
		name = "Tentacool",
		evolution = "30",
		bst = 335,
		movelvls = { { 6, 12, 19, 25, 30, 36, 43, 49 }, { 6, 12, 19, 25, 30, 36, 43, 49 } },
		weight = 45.5
	},
	{
		name = "Tentacruel",
		evolution = PokemonData.Evolutions.NONE,
		bst = 515,
		movelvls = { { 6, 12, 19, 25, 30, 38, 47, 55 }, { 6, 12, 19, 25, 30, 38, 47, 55 } },
		weight = 55.0
	},
	{
		name = "Geodude",
		evolution = "25",
		bst = 300,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 20.0
	},
	{
		name = "Graveler",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 390,
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 105.0
	},
	{
		name = "Golem",
		evolution = PokemonData.Evolutions.NONE,
		bst = 485,
		movelvls = { { 6, 11, 16, 21, 29, 37, 45, 53, 62 }, { 6, 11, 16, 21, 29, 37, 45, 53, 62 } },
		weight = 300.0
	},
	{
		name = "Ponyta",
		evolution = "40",
		bst = 410,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 45, 53 }, { 5, 9, 14, 19, 25, 31, 38, 45, 53 } },
		weight = 30.0
	},
	{
		name = "Rapidash",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 5, 9, 14, 19, 25, 31, 38, 40, 50, 63 }, { 5, 9, 14, 19, 25, 31, 38, 40, 50, 63 } },
		weight = 95.0
	},
	{
		name = "Slowpoke",
		evolution = PokemonData.Evolutions.WATER37, -- Water stone replaces trade evolution to Slowking
		bst = 315,
		movelvls = { { 6, 15, 20, 29, 34, 43, 48 }, { 6, 13, 17, 24, 29, 36, 40, 47 } },
		weight = 36.0
	},
	{
		name = "Slowbro",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 6, 15, 20, 29, 34, 37, 46, 54 }, { 6, 13, 17, 24, 29, 36, 37, 44, 55 } },
		weight = 78.5
	},
	{
		name = "Magnemite",
		evolution = "30",
		bst = 325,
		movelvls = { { 6, 11, 16, 21, 26, 32, 38, 44, 50 }, { 6, 11, 16, 21, 26, 32, 38, 44, 50 } },
		weight = 6.0
	},
	{
		name = "Magneton",
		evolution = PokemonData.Evolutions.NONE,
		bst = 465,
		movelvls = { { 6, 11, 16, 21, 26, 35, 44, 53, 62 }, { 6, 11, 16, 21, 26, 35, 44, 53, 62 } },
		weight = 60.0
	},
	{
		name = "Farfetch'd",
		evolution = PokemonData.Evolutions.NONE,
		bst = 352,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 15.0
	},
	{
		name = "Doduo",
		evolution = "31",
		bst = 310,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45 }, { 9, 13, 21, 25, 33, 37, 45 } },
		weight = 39.2
	},
	{
		name = "Dodrio",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 9, 13, 21, 25, 38, 47, 60 }, { 9, 13, 21, 25, 38, 47, 60 } },
		weight = 85.2
	},
	{
		name = "Seel",
		evolution = "34",
		bst = 325,
		movelvls = { { 9, 17, 21, 29, 37, 41, 49 }, { 9, 17, 21, 29, 37, 41, 49 } },
		weight = 90.0
	},
	{
		name = "Dewgong",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { { 9, 17, 21, 29, 34, 42, 51, 64 }, { 9, 17, 21, 29, 34, 42, 51, 64 } },
		weight = 120.0
	},
	{
		name = "Grimer",
		evolution = "38",
		bst = 325,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 30.0
	},
	{
		name = "Muk", -- PUMP SLOP
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 4, 8, 13, 19, 26, 34, 47, 61 }, { 4, 8, 13, 19, 26, 34, 47, 61 } },
		weight = 30.0
	},
	{
		name = "Shellder",
		evolution = PokemonData.Evolutions.WATER,
		bst = 305,
		movelvls = { { 9, 17, 25, 33, 41, 49 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 4.0
	},
	{
		name = "Cloyster",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 33, 41 }, { 36, 43 } },
		weight = 132.5
	},
	{
		name = "Gastly",
		evolution = "25",
		bst = 310,
		movelvls = { { 8, 13, 16, 21, 28, 33, 36 }, { 8, 13, 16, 21, 28, 33, 36, 41, 48 } },
		weight = 0.1
	},
	{
		name = "Haunter",
		evolution = "37", -- Level 37 replaces trade evolution
		bst = 405,
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 0.1
	},
	{
		name = "Gengar",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 8, 13, 16, 21, 25, 31, 39, 48 }, { 8, 13, 16, 21, 25, 31, 39, 45, 53, 64 } },
		weight = 40.5
	},
	{
		name = "Onix",
		evolution = "30", -- Level 30 replaces trade evolution
		bst = 385,
		movelvls = { { 9, 13, 21, 25, 33, 37, 45, 49, 57 }, { 8, 12, 19, 23, 30, 34, 41, 45, 52, 56 } },
		weight = 210.0
	},
	{
		name = "Drowzee",
		evolution = "26",
		bst = 328,
		movelvls = { { 10, 18, 25, 31, 36, 40, 43, 45 }, { 7, 11, 17, 21, 27, 31, 37, 41, 47 } },
		weight = 32.4
	},
	{
		name = "Hypno",
		evolution = PokemonData.Evolutions.NONE,
		bst = 483,
		movelvls = { { 10, 18, 25, 33, 40, 49, 55, 60 }, { 7, 11, 17, 21, 29, 35, 43, 49, 57 } },
		weight = 75.6
	},
	{
		name = "Krabby",
		evolution = "28",
		bst = 325,
		movelvls = { { 5, 12, 16, 23, 27, 34, 41, 45 }, { 5, 12, 16, 23, 27, 34, 38, 45, 49 } },
		weight = 6.5
	},
	{
		name = "Kingler",
		evolution = PokemonData.Evolutions.NONE,
		bst = 475,
		movelvls = { { 5, 12, 16, 23, 27, 38, 49, 57 }, { 5, 12, 16, 23, 27, 38, 42, 57, 65 } },
		weight = 60.0
	},
	{
		name = "Voltorb",
		evolution = "30",
		bst = 330,
		movelvls = { { 8, 15, 21, 27, 32, 37, 42, 46, 49 }, { 8, 15, 21, 27, 32, 37, 42, 46, 49 } },
		weight = 10.4
	},
	{
		name = "Electrode",
		evolution = PokemonData.Evolutions.NONE,
		bst = 480,
		movelvls = { { 8, 15, 21, 27, 34, 41, 48, 54, 59 }, { 8, 15, 21, 27, 34, 41, 48, 54, 59 } },
		weight = 66.6
	},
	{
		name = "Exeggcute",
		evolution = PokemonData.Evolutions.LEAF,
		bst = 325,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43 }, { 7, 13, 19, 25, 31, 37, 43 } },
		weight = 2.5
	},
	{
		name = "Exeggutor",
		evolution = PokemonData.Evolutions.NONE,
		bst = 520,
		movelvls = { { 19, 31 }, { 19, 31 } },
		weight = 120.0
	},
	{
		name = "Cubone",
		evolution = "28",
		bst = 320,
		movelvls = { { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45 } },
		weight = 6.5
	},
	{
		name = "Marowak",
		evolution = PokemonData.Evolutions.NONE,
		bst = 425,
		movelvls = { { 5, 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 }, { 5, 9, 13, 17, 21, 25, 32, 39, 46, 53, 61 } },
		weight = 45.0
	},
	{
		name = "Hitmonlee",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 }, { 6, 11, 16, 20, 21, 26, 31, 36, 41, 46, 51 } },
		weight = 49.8
	},
	{
		name = "Hitmonchan",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 }, { 7, 13, 20, 26, 26, 26, 32, 38, 44, 50 } },
		weight = 50.2
	},
	{
		name = "Lickitung",
		evolution = PokemonData.Evolutions.NONE,
		bst = 385,
		movelvls = { { 7, 12, 18, 23, 29, 34, 40, 45, 51 }, { 7, 12, 18, 23, 29, 34, 40, 45, 51 } },
		weight = 65.5
	},
	{
		name = "Koffing",
		evolution = "35",
		bst = 340,
		movelvls = { { 9, 17, 21, 25, 33, 41, 45, 49 }, { 9, 17, 21, 25, 33, 41, 45, 49 } },
		weight = 1.0
	},
	{
		name = "Weezing",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 9, 17, 21, 25, 33, 44, 51, 58 }, { 9, 17, 21, 25, 33, 44, 51, 58 } },
		weight = 9.5
	},
	{
		name = "Rhyhorn",
		evolution = "42",
		bst = 345,
		movelvls = { { 10, 15, 24, 29, 38, 43, 52, 57 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 115.0
	},
	{
		name = "Rhydon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 485,
		movelvls = { { 10, 15, 24, 29, 38, 46, 58, 66 }, { 10, 15, 24, 29, 38, 46, 58, 66 } },
		weight = 120.0
	},
	{
		name = "Chansey",
		evolution = PokemonData.Evolutions.FRIEND,
		bst = 450,
		movelvls = { { 5, 9, 13, 17, 23, 29, 35, 41, 49, 57 }, { 5, 9, 13, 17, 23, 29, 35, 41, 49, 57 } },
		weight = 34.6,
		friendshipBase = 140
	},
	{
		name = "Tangela",
		evolution = PokemonData.Evolutions.NONE,
		bst = 435,
		movelvls = { { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46 }, { 4, 10, 13, 19, 22, 28, 31, 37, 40, 46 } },
		weight = 35.0
	},
	{
		name = "Kangaskhan",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 80.0
	},
	{
		name = "Horsea",
		evolution = "32",
		bst = 295,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 8.0
	},
	{
		name = "Seadra",
		evolution = "40", -- Level 40 replaces trade evolution
		bst = 440,
		movelvls = { { 8, 15, 22, 29, 40, 51, 62 }, { 8, 15, 22, 29, 40, 51, 62 } },
		weight = 25.0
	},
	{
		name = "Goldeen",
		evolution = "33",
		bst = 320,
		movelvls = { { 10, 15, 24, 29, 38, 43, 52 }, { 10, 15, 24, 29, 38, 43, 52, 57 } },
		weight = 15.0
	},
	{
		name = "Seaking",
		evolution = PokemonData.Evolutions.NONE,
		bst = 450,
		movelvls = { { 10, 15, 24, 29, 41, 49, 61 }, { 10, 15, 24, 29, 41, 49, 61, 69 } },
		weight = 39.0
	},
	{
		name = "Staryu",
		evolution = PokemonData.Evolutions.WATER,
		bst = 340,
		movelvls = { { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 }, { 6, 10, 15, 19, 24, 28, 33, 37, 42, 46 } },
		weight = 34.5
	},
	{
		name = "Starmie",
		evolution = PokemonData.Evolutions.NONE,
		bst = 520,
		movelvls = { { 33 }, { 33 } },
		weight = 80.0
	},
	{
		name = "Mr. Mime",
		evolution = PokemonData.Evolutions.NONE,
		bst = 460,
		movelvls = { { 5, 9, 13, 17, 21, 21, 25, 29, 33, 37, 41, 45, 49, 53 }, { 5, 8, 12, 15, 19, 19, 22, 26, 29, 33, 36, 40, 43, 47, 50 } },
		weight = 54.5
	},
	{
		name = "Scyther",
		evolution = "30", -- Level 30 replaces trade evolution
		bst = 500,
		movelvls = { { 6, 11, 16, 21, 26, 31, 36, 41, 46 }, { 6, 11, 16, 21, 26, 31, 36, 41, 46 } },
		weight = 56.0
	},
	{
		name = "Jynx",
		evolution = PokemonData.Evolutions.NONE,
		bst = 455,
		movelvls = { { 9, 13, 21, 25, 35, 41, 51, 57, 67 }, { 9, 13, 21, 25, 35, 41, 51, 57, 67 } },
		weight = 40.6
	},
	{
		name = "Electabuzz",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 9, 17, 25, 36, 47, 58 }, { 9, 17, 25, 36, 47, 58 } },
		weight = 30.0
	},
	{
		name = "Magmar", -- MAMGAR
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 7, 13, 19, 25, 33, 41, 49, 57 }, { 7, 13, 19, 25, 33, 41, 49, 57 } },
		weight = 44.5
	},
	{
		name = "Pinsir",
		evolution = PokemonData.Evolutions.NONE,
		bst = 500,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49 }, { 7, 13, 19, 25, 31, 37, 43, 49 } },
		weight = 55.0
	},
	{
		name = "Tauros",
		evolution = PokemonData.Evolutions.NONE,
		bst = 490,
		movelvls = { { 4, 8, 13, 19, 26, 34, 43, 53 }, { 4, 8, 13, 19, 26, 34, 43, 53 } },
		weight = 88.4
	},
	{
		name = "Magikarp",
		evolution = "20",
		bst = 200,
		movelvls = { { 15, 30 }, { 15, 30 } },
		weight = 10.0
	},
	{
		name = "Gyarados",
		evolution = PokemonData.Evolutions.NONE,
		bst = 540,
		movelvls = { { 20, 25, 30, 35, 40, 45, 50, 55 }, { 20, 25, 30, 35, 40, 45, 50, 55 } },
		weight = 235.0
	},
	{
		name = "Lapras",
		evolution = PokemonData.Evolutions.NONE,
		bst = 535,
		movelvls = { { 7, 13, 19, 25, 31, 37, 43, 49, 55 }, { 7, 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 220.0
	},
	{
		name = "Ditto",
		evolution = PokemonData.Evolutions.NONE,
		bst = 288,
		movelvls = { {}, {} },
		weight = 4.0
	},
	{
		name = "Eevee",
		evolution = PokemonData.Evolutions.EEVEE_STONES,
		bst = 325,
		movelvls = { { 8, 16, 23, 30, 36, 42 }, { 8, 16, 23, 30, 36, 42 } },
		weight = 6.5
	},
	{
		name = "Vaporeon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 29.0
	},
	{
		name = "Jolteon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 24.5
	},
	{
		name = "Flareon",
		evolution = PokemonData.Evolutions.NONE,
		bst = 525,
		movelvls = { { 8, 16, 23, 30, 36, 42, 47, 52 }, { 8, 16, 23, 30, 36, 42, 47, 52 } },
		weight = 25.0
	},
	{
		name = "Porygon",
		evolution = "30", -- Level 30 replaces trade evolution
		bst = 395,
		movelvls = { { 9, 12, 20, 24, 32, 36, 44, 48 }, { 9, 12, 20, 24, 32, 36, 44, 48 } },
		weight = 36.5
	},
	{
		name = "Omanyte",
		evolution = "40",
		bst = 355,
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 7.5
	},
	{
		name = "Omastar", -- LORD HELIX
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 35.0
	},
	{
		name = "Kabuto",
		evolution = "40",
		bst = 355,
		movelvls = { { 13, 19, 25, 31, 37, 43, 49, 55 }, { 13, 19, 25, 31, 37, 43, 49, 55 } },
		weight = 11.5
	},
	{
		name = "Kabutops",
		evolution = PokemonData.Evolutions.NONE,
		bst = 495,
		movelvls = { { 13, 19, 25, 31, 37, 40, 46, 55, 65 }, { 13, 19, 25, 31, 37, 40, 46, 55, 65 } },
		weight = 40.5
	},
	{
		name = "Aerodactyl",
		evolution = PokemonData.Evolutions.NONE,
		bst = 515,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50 }, { 8, 15, 22, 29, 36, 43, 50 } },
		weight = 59.0
	},
	{
		name = "Snorlax",
		evolution = PokemonData.Evolutions.NONE,
		bst = 540,
		movelvls = { { 6, 10, 15, 19, 24, 28, 28, 33, 37, 42, 46, 51 }, { 5, 9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49, 53 } },
		weight = 460.0
	},
	{
		name = "Articuno",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 55.4,
		friendshipBase = 35
	},
	{
		name = "Zapdos",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 52.6,
		friendshipBase = 35
	},
	{
		name = "Moltres",
		evolution = PokemonData.Evolutions.NONE,
		bst = 580,
		movelvls = { { 13, 25, 37, 49, 61, 73, 85 }, { 13, 25, 37, 49, 61, 73, 85 } },
		weight = 60.0,
		friendshipBase = 35
	},
	{
		name = "Dratini",
		evolution = "30",
		bst = 300,
		movelvls = { { 8, 15, 22, 29, 36, 43, 50, 57 }, { 8, 15, 22, 29, 36, 43, 50, 57 } },
		weight = 3.3,
		friendshipBase = 35
	},
	{
		name = "Dragonair",
		evolution = "55",
		bst = 420,
		movelvls = { { 8, 15, 22, 29, 38, 47, 56, 65 }, { 8, 15, 22, 29, 38, 47, 56, 65 } },
		weight = 16.5,
		friendshipBase = 35
	},
	{
		name = "Dragonite",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 8, 15, 22, 29, 38, 47, 55, 61, 75 }, { 8, 15, 22, 29, 38, 47, 55, 61, 75 } },
		weight = 210.0,
		friendshipBase = 35
	},
	{
		name = "Mewtwo",
		evolution = PokemonData.Evolutions.NONE,
		bst = 680,
		movelvls = { { 11, 22, 33, 44, 55, 66, 77, 88, 99 }, { 11, 22, 33, 44, 55, 66, 77, 88, 99 } },
		weight = 122.0,
		friendshipBase = 0
	},
	{
		name = "Mew",
		evolution = PokemonData.Evolutions.NONE,
		bst = 600,
		movelvls = { { 10, 20, 30, 40, 50 }, { 10, 20, 30, 40, 50 } },
		weight = 4.0,
		friendshipBase = 100
	},
}
