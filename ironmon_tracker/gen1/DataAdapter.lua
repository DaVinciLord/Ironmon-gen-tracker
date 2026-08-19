-- Narrows Besteon's shared datasets to the data that exists in Red/Blue/Yellow
-- and applies the original Generation 1 battle rules.
Gen1DataAdapter = {}

Gen1DataAdapter.PokemonCount = 151
Gen1DataAdapter.MoveCount = 165

Gen1DataAdapter.TypeIndexMap = {
	[0x00] = PokemonData.Types.NORMAL,
	[0x01] = PokemonData.Types.FIGHTING,
	[0x02] = PokemonData.Types.FLYING,
	[0x03] = PokemonData.Types.POISON,
	[0x04] = PokemonData.Types.GROUND,
	[0x05] = PokemonData.Types.ROCK,
	[0x07] = PokemonData.Types.BUG,
	[0x08] = PokemonData.Types.GHOST,
	[0x14] = PokemonData.Types.FIRE,
	[0x15] = PokemonData.Types.WATER,
	[0x16] = PokemonData.Types.GRASS,
	[0x17] = PokemonData.Types.ELECTRIC,
	[0x18] = PokemonData.Types.PSYCHIC,
	[0x19] = PokemonData.Types.ICE,
	[0x1A] = PokemonData.Types.DRAGON,
}

local function truncate(array, lastIndex)
	for index = #array, lastIndex + 1, -1 do
		array[index] = nil
	end
end

local function applyMoveOverride(moveId, fields)
	local move = MoveData.Moves[moveId]
	if not move then return end
	for field, value in pairs(fields) do
		move[field] = value
	end
	if move.power ~= "0" and move.power ~= Constants.BLANKLINE then
		move.category = MoveData.TypeToCategory[move.type]
	end
end

local function baseStatsAddress(pokemonId)
	if pokemonId == 151 and GameSettings.currentProfile.version ~= "Yellow" then
		return GameSettings.mewBaseStats
	end
	return GameSettings.baseStats + (pokemonId - 1) * 0x1C
end

function Gen1DataAdapter.readPokemonInfo(pokemonId)
	local address = baseStatsAddress(pokemonId)
	local stats = {
		hp = Memory.readbyte(address + 1),
		atk = Memory.readbyte(address + 2),
		def = Memory.readbyte(address + 3),
		spe = Memory.readbyte(address + 4),
		special = Memory.readbyte(address + 5),
	}
	return {
		stats = stats,
		types = {
			Gen1DataAdapter.TypeIndexMap[Memory.readbyte(address + 6)] or PokemonData.Types.UNKNOWN,
			Gen1DataAdapter.TypeIndexMap[Memory.readbyte(address + 7)] or PokemonData.Types.UNKNOWN,
		},
	}
end

function Gen1DataAdapter.initializePokemonData()
	local bulbasaur = Gen1DataAdapter.readPokemonInfo(1)
	PokemonData.IsRand.types = bulbasaur.types[1] ~= PokemonData.Types.GRASS or bulbasaur.types[2] ~= PokemonData.Types.POISON
	PokemonData.IsRand.stats = bulbasaur.stats.hp ~= 45 or bulbasaur.stats.atk ~= 49 or bulbasaur.stats.def ~= 49
	PokemonData.IsRand.abilities = false
	PokemonData.IsRand.friendshipBase = false
	PokemonData.IsRand.expYield = false

	for pokemonId = 1, Gen1DataAdapter.PokemonCount do
		local pokemon = PokemonData.Pokemon[pokemonId]
		local info = Gen1DataAdapter.readPokemonInfo(pokemonId)
		pokemon.pokemonID = pokemonId
		pokemon.types = info.types
		pokemon.baseStats = info.stats
		pokemon.bst = tostring(info.stats.hp + info.stats.atk + info.stats.def + info.stats.spe + info.stats.special)
	end
	PokemonData.knownTotal = Gen1DataAdapter.PokemonCount
end

function Gen1DataAdapter.readMoveInfo(moveId)
	local address = GameSettings.moveData + (moveId - 1) * 6
	local power = Memory.readbyte(address + 2)
	local typeName = Gen1DataAdapter.TypeIndexMap[Memory.readbyte(address + 3)] or PokemonData.Types.UNKNOWN
	local accuracyByte = Memory.readbyte(address + 4)
	return {
		power = tostring(power),
		type = typeName,
		accuracy = tostring(math.ceil(accuracyByte * 100 / 255)),
		pp = tostring(Memory.readbyte(address + 5) % 0x40),
	}
end

function Gen1DataAdapter.initializeMoveData()
	local blizzard = Gen1DataAdapter.readMoveInfo(59)
	local hydroPump = Gen1DataAdapter.readMoveInfo(56)
	MoveData.IsRand.moveType = blizzard.type ~= PokemonData.Types.ICE or hydroPump.type ~= PokemonData.Types.WATER
	MoveData.IsRand.movePower = blizzard.power ~= "120" or hydroPump.power ~= "120"
	MoveData.IsRand.moveAccuracy = blizzard.accuracy ~= "90" or hydroPump.accuracy ~= "80"
	MoveData.IsRand.movePP = blizzard.pp ~= "5" or hydroPump.pp ~= "5"
	MoveData.IsRand.moveCategory = false

	for moveId = 1, Gen1DataAdapter.MoveCount do
		local move = MoveData.Moves[moveId]
		local info = Gen1DataAdapter.readMoveInfo(moveId)
		move.type = info.type
		move.accuracy = info.accuracy
		move.pp = info.pp
		if not move.variablepower and info.power ~= "1" then move.power = info.power end
		if move.power ~= "0" and move.category ~= MoveData.Categories.STATUS then
			move.category = MoveData.TypeToCategory[move.type]
		end
	end
	MoveData.knownTotal = Gen1DataAdapter.MoveCount
	Gen1DataAdapter.applyMoveSummaries()
end

function Gen1DataAdapter.apply()
	truncate(PokemonData.Pokemon, Gen1DataAdapter.PokemonCount)
	truncate(MoveData.Moves, Gen1DataAdapter.MoveCount)

	-- RBY has no Hidden Power and only exposes its fifteen native types.
	MoveData.HiddenPowerTypeList = {}
	MoveData.HIDDEN_POWER_NOT_SET = nil
	MoveData.MoveValueAdjustmentFuncs[MoveData.Values.LowKickId] = nil

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
	PokemonData.TypeIndexMap = Gen1DataAdapter.TypeIndexMap
	PokemonData.initialize = Gen1DataAdapter.initializePokemonData
	MoveData.initialize = Gen1DataAdapter.initializeMoveData

	-- The upstream list stores later-generation values. These are every move
	-- field changed between RBY and GSC that affects the tracker's display.
	local overrides = {
		[2] = { type = PokemonData.Types.NORMAL }, -- Karate Chop
		[16] = { type = PokemonData.Types.NORMAL }, -- Gust
		[17] = { power = "35" }, -- Wing Attack
		[18] = { accuracy = "85", priority = "0" }, -- Whirlwind
		[28] = { type = PokemonData.Types.NORMAL }, -- Sand-Attack
		[38] = { power = "100" }, -- Double-Edge
		[44] = { type = PokemonData.Types.NORMAL }, -- Bite
		[46] = { priority = "0" }, -- Roar
		[59] = { accuracy = "90" }, -- Blizzard
		[67] = { power = "50" }, -- Low Kick has no weight-based power in RBY
		[88] = { accuracy = "65" }, -- Rock Throw
		[91] = { power = "100" }, -- Dig
		[117] = { accuracy = "0" }, -- Bide bypasses accuracy checks
		[120] = { power = "130" }, -- Selfdestruct
		[153] = { power = "170" }, -- Explosion
		[165] = { pp = "10" }, -- Struggle's internal PP
	}
	for moveId, fields in pairs(overrides) do
		applyMoveOverride(moveId, fields)
	end

	Gen1DataAdapter.applyMoveSummaries()
end

function Gen1DataAdapter.applyMoveSummaries()
	local trapping = "Traps the target for 2-5 turns and prevents it from attacking."
	local ohko = "Knocks out the target. Fails if the target is faster than the user."
	for _, moveId in ipairs({ 12, 32, 90 }) do MoveData.Moves[moveId].summary = ohko end
	for _, moveId in ipairs({ 20, 35, 83, 128 }) do MoveData.Moves[moveId].summary = trapping end
	MoveData.Moves[44].summary = "10% chance to make the target flinch."
	MoveData.Moves[51].summary = "33.2% chance to lower the target's Defense by 1."
	MoveData.Moves[61].summary = "33.2% chance to lower the target's Speed by 1."
	MoveData.Moves[62].summary = "33.2% chance to lower the target's Attack by 1."
	MoveData.Moves[63].summary = "Recharges next turn unless it misses, breaks a substitute, or knocks out the target."
	MoveData.Moves[116].summary = "Due to a Gen 1 bug, quarters the user's critical-hit rate instead of raising it."
	MoveData.Moves[132].summary = "33.2% chance to lower the target's Speed by 1."
	MoveData.Moves[145].summary = "33.2% chance to lower the target's Speed by 1."
	MoveData.Moves[146].summary = "No additional effect."
	MoveData.Moves[165].summary = "User loses 1/2 of the damage dealt; no recoil when breaking a substitute."
end

function Gen1DataAdapter.initialize()
	-- Applied while loading modules so PokemonData/MoveData initialize with the
	-- correct table bounds and never read Gen 2+ records from the ROM.
end

function Gen1DataAdapter.updateResources()
	-- Besteon loads localized Gen 3 descriptions first. Reapply only the moves
	-- whose mechanics differ in RBY after every language/resource refresh.
	Gen1DataAdapter.applyMoveSummaries()
end

Gen1DataAdapter.apply()

return Gen1DataAdapter
