-- Run from any directory with: lua tools/gen1_species_map_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
dofile(repoRoot .. "ironmon_tracker/data/PokemonData.lua")
dofile(repoRoot .. "ironmon_tracker/gen1/SpeciesMap.lua")

Gen1SpeciesMap.initialize()
assert(Gen1SpeciesMap.getDexId(0x99) == 1, "Bulbasaur internal id must map to Pokédex 1")
assert(Gen1SpeciesMap.getDexId(0x54) == 25, "Pikachu internal id must map to Pokédex 25")
assert(Gen1SpeciesMap.getDexId(0x03) == 32, "Nidoran M internal id must map to Pokédex 32")
assert(Gen1SpeciesMap.getDexId(0x0F) == 29, "Nidoran F internal id must map to Pokédex 29")
assert(Gen1SpeciesMap.getDexId(0x15) == 151, "Mew internal id must map to Pokédex 151")
assert(Gen1SpeciesMap.getDexId(0x1F) == nil, "MissingNo. must never become a tracked Pokémon")

print("Gen 1 species map smoke tests passed")
