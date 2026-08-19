-- Run from any directory with: lua tools/gen1_rom_data_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
local bytes = {}
Memory = {
	readbyte = function(address) return bytes[address] or 0 end,
	readword = function(address) return (bytes[address] or 0) + (bytes[address + 1] or 0) * 0x100 end,
}
GameSettings = {
	GEN = 1,
	baseStats = 0x10000,
	mewBaseStats = 0x20000,
	moveData = 0x30000,
	levelUpMoves = 0x0803B05C,
	currentProfile = { version = "Red" },
}

local function put(address, ...)
	for index, value in ipairs({ ... }) do bytes[address + index - 1] = value end
end
-- Base stat record: dex id, HP, Atk, Def, Spe, Special, type 1, type 2.
put(GameSettings.baseStats, 1, 45, 49, 49, 45, 65, 0x16, 0x03)
put(GameSettings.mewBaseStats, 151, 100, 100, 100, 100, 100, 0x18, 0x18)
-- Move record: animation, effect, power, type, accuracy byte, PP.
put(GameSettings.moveData + (56 - 1) * 6, 56, 0, 120, 0x15, 204, 5) -- Hydro Pump
put(GameSettings.moveData + (59 - 1) * 6, 59, 0, 120, 0x19, 229, 5) -- Blizzard

dofile(repoRoot .. "ironmon_tracker/data/PokemonData.lua")
dofile(repoRoot .. "ironmon_tracker/data/MoveData.lua")
dofile(repoRoot .. "ironmon_tracker/gen1/SpeciesMap.lua")
dofile(repoRoot .. "ironmon_tracker/gen1/DataAdapter.lua")

PokemonData.initialize()
MoveData.initialize()
assert(PokemonData.Pokemon[1].bst == "253")
assert(PokemonData.Pokemon[1].baseStats.special == 65)
assert(PokemonData.Pokemon[1].types[1] == PokemonData.Types.GRASS)
assert(PokemonData.Pokemon[151].bst == "500", "Red/Blue Mew must use its separate base-stat record")
assert(not PokemonData.IsRand.types and not PokemonData.IsRand.stats)
assert(MoveData.Moves[56].power == "120" and MoveData.Moves[56].accuracy == "80")
assert(MoveData.Moves[59].type == PokemonData.Types.ICE and MoveData.Moves[59].accuracy == "90")
assert(not MoveData.IsRand.moveType and not MoveData.IsRand.movePower and not MoveData.IsRand.moveAccuracy)

bytes[GameSettings.moveData + (59 - 1) * 6 + 2] = 150
bytes[GameSettings.moveData + (59 - 1) * 6 + 3] = 0x14
MoveData.initialize()
assert(MoveData.IsRand.moveType and MoveData.IsRand.movePower)
assert(MoveData.Moves[59].power == "150" and MoveData.Moves[59].type == PokemonData.Types.FIRE)

print("Gen 1 ROM data smoke tests passed")
