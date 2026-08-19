-- Narrows Besteon's shared datasets to the data that exists in Red/Blue/Yellow
-- and applies the original Generation 1 battle rules.
Gen1DataAdapter = {}

Gen1DataAdapter.PokemonCount = 151
Gen1DataAdapter.MoveCount = 165

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
