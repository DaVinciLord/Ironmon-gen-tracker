-- Run from any directory with: lua tools/gen1_species_map_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
dofile(repoRoot .. "ironmon_tracker/data/PokemonData.lua")
dofile(repoRoot .. "ironmon_tracker/data/SpeciesMap.lua")

SpeciesMap.initialize()
assert(SpeciesMap.getDexId(0x99) == 1, "Bulbasaur internal id must map to Pokédex 1")
assert(SpeciesMap.getDexId(0x54) == 25, "Pikachu internal id must map to Pokédex 25")
assert(SpeciesMap.getDexId(0x03) == 32, "Nidoran M internal id must map to Pokédex 32")
assert(SpeciesMap.getDexId(0x0F) == 29, "Nidoran F internal id must map to Pokédex 29")
assert(SpeciesMap.getDexId(0x78) == 87, "Dewgong internal id must map to Pokédex 87")
assert(SpeciesMap.getDexId(0x2B) == 106, "Hitmonlee internal id must map to Pokédex 106")
assert(SpeciesMap.getDexId(0x15) == 151, "Mew internal id must map to Pokédex 151")
assert(SpeciesMap.getDexId(0x1F) == nil, "MissingNo. must never become a tracked Pokémon")

-- Resources.updateResources replaces PokemonData names with the UI language
-- before SpeciesMap.initialize / DataAdapter.initializePokemonData rebuild
-- the dex map. French Yellow would otherwise map every species to pokemonID 0.
PokemonData.Pokemon[87].name = "Lamantine"
PokemonData.Pokemon[106].name = "Kicklee"
PokemonData.Pokemon[1].name = "Bulbizarre"
SpeciesMap.rebuildDexMap()
assert(SpeciesMap.getDexId(0x78) == 87, "Dewgong must still map after French names replace PokemonData")
assert(SpeciesMap.getDexId(0x2B) == 106, "Hitmonlee must still map after French names replace PokemonData")
assert(SpeciesMap.getDexId(0x99) == 1, "Bulbasaur must still map after French names replace PokemonData")

print("Gen 1 species map smoke tests passed")
