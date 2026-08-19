-- Run from any directory with: lua tools/gen1_catch_rate_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
Memory = { readbyte = function() return 0 end, readword = function() return 0 end }
GameSettings = { currentProfile = { version = "Yellow" } }
MiscData = { StatusType = { None = 0, Sleep = 1, Poison = 2, Burn = 3, Freeze = 4, Paralyze = 5, Toxic = 6 } }
dofile(repoRoot .. "ironmon_tracker/data/PokemonData.lua")
dofile(repoRoot .. "ironmon_tracker/data/MoveData.lua")
dofile(repoRoot .. "ironmon_tracker/data/SpeciesMap.lua")
dofile(repoRoot .. "ironmon_tracker/data/DataAdapter.lua")

PokemonData.Pokemon[1].catchRate = 45
assert(PokemonData.calcCatchRate(1, 100, 100, 5, MiscData.StatusType.None, 4) == 6)
assert(PokemonData.calcCatchRate(1, 100, 1, 5, MiscData.StatusType.None, 4) == 17)
assert(PokemonData.calcCatchRate(1, 100, 100, 5, MiscData.StatusType.Sleep, 4) == 15)
assert(PokemonData.calcCatchRate(1, 100, 100, 5, MiscData.StatusType.None, 3) == 11)
assert(PokemonData.calcCatchRate(1, 100, 100, 5, MiscData.StatusType.None, 2) == 10)
assert(PokemonData.calcCatchRate(1, 100, 100, 5, MiscData.StatusType.None, 1) == 100)
assert(PokemonData.calcCatchRate(0, 100, 100, 5, 0, 4) == 0)

print("Gen 1 catch-rate smoke tests passed")
