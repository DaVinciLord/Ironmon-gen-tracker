Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
local bytes = {}
Memory = {
	readbyte = function(address) return bytes[address] or 0 end,
	readword = function(address) return (bytes[address] or 0) + (bytes[address + 1] or 0) * 0x100 end,
}
GameSettings = {
	GEN = 1, baseStats = 0x10000, mewBaseStats = 0x20000, moveData = 0x30000,
	levelUpMoves = 0x0803B05C, currentProfile = { version = "Red" },
}

local function put(address, ...)
	for index, value in ipairs({ ... }) do bytes[address + index - 1] = value end
end

dofile("ironmon_tracker/data/PokemonData.lua")
dofile("ironmon_tracker/data/MoveData.lua")
dofile("ironmon_tracker/gen1/SpeciesMap.lua")
dofile("ironmon_tracker/gen1/DataAdapter.lua")
Gen1SpeciesMap.rebuildDexMap()

local bulbasaurInternal = assert(Gen1SpeciesMap.getInternalId(1))
assert(bulbasaurInternal == 0x99)
local pointerEntry = GameSettings.levelUpMoves + (bulbasaurInternal - 1) * 2
put(pointerEntry, 0x00, 0x72)
local learnsetAddress = 0x0803B200 -- bank $0E, pointer $7200
put(learnsetAddress,
	1, 16, 0x09, -- level evolution to Ivysaur
	0, -- end evolutions
	7, 73, 13, 22, 0) -- Leech Seed, Vine Whip

local evolutions, moves = Gen1DataAdapter.readEvolutionsAndMoves(1)
assert(#evolutions == 1 and evolutions[1].level == 16 and evolutions[1].species == 2)
assert(#moves == 2 and moves[1].level == 7 and moves[1].id == 73 and moves[2].id == 22)
local publicMoves = PokemonData.readLevelUpMoves(1)
assert(#publicMoves == 2 and publicMoves[2].level == 13)

print("Gen 1 learnset smoke tests passed")
