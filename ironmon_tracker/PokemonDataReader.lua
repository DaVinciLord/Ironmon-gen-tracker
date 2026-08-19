-- Reader for the two native RBY Pokémon structures: the 44-byte party record
-- and the compact active-battle record. Multi-byte values in these structures
-- are big-endian even though the emulator's generic word helper is not.
Gen1PokemonReader = {}

Gen1PokemonReader.PartyStructSize = 44

Gen1PokemonReader.Status = {
	NONE = 0,
	SLEEP = 1,
	POISON = 2,
	BURN = 3,
	FREEZE = 4,
	PARALYSIS = 5,
}

local function read8(address)
	return Memory.readbyte(address)
end

local function readBE16(address)
	return read8(address) * 0x100 + read8(address + 1)
end

local function readBE24(address)
	return read8(address) * 0x10000 + read8(address + 1) * 0x100 + read8(address + 2)
end

local function decodeStatus(raw)
	local sleepTurns = raw % 8
	if sleepTurns > 0 then return Gen1PokemonReader.Status.SLEEP, sleepTurns end
	if math.floor(raw / 0x08) % 2 == 1 then return Gen1PokemonReader.Status.POISON, 0 end
	if math.floor(raw / 0x10) % 2 == 1 then return Gen1PokemonReader.Status.BURN, 0 end
	if math.floor(raw / 0x20) % 2 == 1 then return Gen1PokemonReader.Status.FREEZE, 0 end
	if math.floor(raw / 0x40) % 2 == 1 then return Gen1PokemonReader.Status.PARALYSIS, 0 end
	return Gen1PokemonReader.Status.NONE, 0
end

local function readDVs(address)
	local attackDefense = read8(address)
	local speedSpecial = read8(address + 1)
	local attack = math.floor(attackDefense / 0x10)
	local defense = attackDefense % 0x10
	local speed = math.floor(speedSpecial / 0x10)
	local special = speedSpecial % 0x10
	local hp = (attack % 2) * 8 + (defense % 2) * 4 + (speed % 2) * 2 + (special % 2)
	return { hp = hp, atk = attack, def = defense, spe = speed, special = special }
end

local function readStatExperience(address)
	return {
		hp = readBE16(address),
		atk = readBE16(address + 2),
		def = readBE16(address + 4),
		spe = readBE16(address + 6),
		special = readBE16(address + 8),
	}
end

local function readMoves(moveAddress, ppAddress)
	local moves = {}
	for slot = 0, 3 do
		moves[slot + 1] = {
			id = read8(moveAddress + slot),
			level = 1,
			pp = read8(ppAddress + slot) % 0x40,
		}
	end
	return moves
end

local function resolveSpecies(internalId, resolver)
	if type(resolver) == "function" then
		return resolver(internalId) or 0
	end
	return internalId
end

function Gen1PokemonReader.readPartyPokemon(startAddress, speciesResolver)
	local internalId = read8(startAddress)
	local status, sleepTurns = decodeStatus(read8(startAddress + 4))
	local special = readBE16(startAddress + 42)
	return {
		trackerKey = internalId,
		internalSpecies = internalId,
		pokemonID = resolveSpecies(internalId, speciesResolver),
		trainerID = readBE16(startAddress + 12),
		experience = readBE24(startAddress + 14),
		level = read8(startAddress + 33),
		status = status,
		sleep_turns = sleepTurns,
		curHP = readBE16(startAddress + 1),
		dvs = readDVs(startAddress + 27),
		statExp = readStatExperience(startAddress + 17),
		stats = {
			hp = readBE16(startAddress + 34),
			atk = readBE16(startAddress + 36),
			def = readBE16(startAddress + 38),
			spe = readBE16(startAddress + 40),
			special = special,
		},
		statStages = { atk = 6, def = 6, spe = 6, special = 6, acc = 6, eva = 6 },
		moves = readMoves(startAddress + 8, startAddress + 29),
	}
end

function Gen1PokemonReader.readBattlePokemon(startAddress, speciesResolver)
	local internalId = read8(startAddress)
	local status, sleepTurns = decodeStatus(read8(startAddress + 4))
	local special = readBE16(startAddress + 23)
	return {
		trackerKey = internalId,
		internalSpecies = internalId,
		pokemonID = resolveSpecies(internalId, speciesResolver),
		level = read8(startAddress + 14),
		status = status,
		sleep_turns = sleepTurns,
		curHP = readBE16(startAddress + 1),
		dvs = readDVs(startAddress + 12),
		stats = {
			hp = readBE16(startAddress + 15),
			atk = readBE16(startAddress + 17),
			def = readBE16(startAddress + 19),
			spe = readBE16(startAddress + 21),
			special = special,
		},
		statStages = { atk = 6, def = 6, spe = 6, special = 6, acc = 6, eva = 6 },
		moves = readMoves(startAddress + 8, startAddress + 25),
	}
end

return Gen1PokemonReader
