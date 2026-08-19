-- Validates a real RBY ROM against the selected native profile.
-- Usage: lua tools/gen1_rom_file_integration.lua path/to/game.gb[c]
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")
local romPath = assert(arg[1], "ROM path required")
local file = assert(io.open(romPath, "rb"))
local rom = file:read("*a")
file:close()

dofile(repoRoot .. "ironmon_tracker/gen1/GameProfiles.lua")

local function byte(offset)
	return rom:byte(offset + 1) or 0
end
local function word(offset)
	return byte(offset) + byte(offset + 1) * 0x100
end
local function offset(address)
	return address % 0x1000000
end

local header = rom:sub(0x13D, 0x140)
local gameCode = byte(0x13C) * 0x1000000 + byte(0x13D) * 0x10000
	+ byte(0x13E) * 0x100 + byte(0x13F)
local profile = assert(Gen1GameProfiles.get(gameCode), "Unsupported ROM header: " .. header)

-- Every base-stat row starts with its National Dex id and contains five
-- non-zero stats. Red/Blue store Mew separately.
for dexId = 1, 151 do
	local address = profile.rom.baseStats + (dexId - 1) * 0x1C
	if dexId == 151 and profile.version ~= "Yellow" then address = profile.rom.mewBaseStats end
	local row = offset(address)
	assert(byte(row) == dexId, string.format("Invalid base-stat row %d at %06X", dexId, row))
	for stat = 1, 5 do assert(byte(row + stat) > 0, "Zero base stat for dex " .. dexId) end
end

-- RBY has exactly 165 six-byte move records. IDs and core fields must stay in
-- their legal byte ranges even after randomization.
for moveId = 1, 165 do
	local row = offset(profile.rom.moveData) + (moveId - 1) * 6
	assert(byte(row) == moveId, string.format("Invalid move row %d at %06X", moveId, row))
	assert(byte(row + 5) % 0x40 > 0, "Move has zero PP: " .. moveId)
end

local function bankTarget(tableAddress, pointer)
	local tableOffset = offset(tableAddress)
	local bank = math.floor(tableOffset / 0x4000)
	if pointer < 0x4000 then return pointer end
	return bank * 0x4000 + pointer - 0x4000
end

-- Check every real species' evolution/learnset pointer and every native
-- trainer-class pointer. This catches regional offset drift immediately.
Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
dofile(repoRoot .. "ironmon_tracker/data/PokemonData.lua")
dofile(repoRoot .. "ironmon_tracker/gen1/SpeciesMap.lua")
for dexId = 1, 151 do
	local internalId = assert(Gen1SpeciesMap.getInternalId(dexId))
	local pointer = word(offset(profile.rom.levelUpMoves) + (internalId - 1) * 2)
	local target = bankTarget(profile.rom.levelUpMoves, pointer)
	assert(pointer ~= 0 and target < #rom, "Invalid learnset pointer for dex " .. dexId)
end
for classId = 1, 47 do
	local pointer = word(offset(profile.rom.trainers) + (classId - 1) * 2)
	local target = bankTarget(profile.rom.trainers, pointer)
	assert(pointer ~= 0 and target < #rom, "Invalid trainer pointer for class " .. classId)
end

print(string.format("Gen 1 ROM integration passed: %s, 151 species, 165 moves, 47 trainer classes", profile.name))
