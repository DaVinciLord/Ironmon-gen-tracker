-- Run from any directory with: lua tools/gen1_data_adapter_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Constants = {
	BLANKLINE = "--",
	HIDDEN_INFO = "?",
	Words = { POKEMON = "Pokemon" },
}
GameSettings = { GEN = 1 }

dofile(repoRoot .. "ironmon_tracker/data/PokemonData.lua")
dofile(repoRoot .. "ironmon_tracker/data/MoveData.lua")
dofile(repoRoot .. "ironmon_tracker/gen1/DataAdapter.lua")

assert(#PokemonData.Pokemon == 151, "Gen 1 dataset must stop at Mew")
assert(PokemonData.Pokemon[151].name == "Mew")
assert(PokemonData.Pokemon[152] == nil, "Chikorita must not exist in the Gen 1 runtime dataset")
assert(#MoveData.Moves == 165, "Gen 1 move dataset must stop at Struggle")
assert(MoveData.Moves[165].name == "Struggle")
assert(MoveData.Moves[166] == nil, "Sketch must not exist in the Gen 1 runtime dataset")
assert(#MoveData.HiddenPowerTypeList == 0, "Hidden Power does not exist in Gen 1")

local chart = MoveData.TypeToEffectiveness
assert(chart.ghost.psychic == 0, "RBY Ghost attacks must reproduce the Psychic immunity bug")
assert(chart.ice.fire == nil, "RBY Ice attacks must be neutral against Fire")
assert(chart.poison.bug == 2 and chart.bug.poison == 2, "RBY Bug and Poison must be super-effective against each other")
assert(chart.dark == nil and chart.steel == nil and chart.fairy == nil)

assert(MoveData.Moves[17].power == "35")
assert(MoveData.Moves[59].accuracy == "90")
assert(MoveData.Moves[67].power == "50")
assert(MoveData.Moves[88].accuracy == "65")
assert(MoveData.Moves[91].power == "100")
assert(MoveData.Moves[120].power == "130" and MoveData.Moves[153].power == "170")
assert(MoveData.Moves[16].type == PokemonData.Types.NORMAL)
assert(MoveData.Moves[44].type == PokemonData.Types.NORMAL)
assert(MoveData.Moves[117].accuracy == "0")
assert(MoveData.Moves[165].pp == "10")
assert(MoveData.Moves[116].summary:find("Gen 1 bug", 1, true))
assert(MoveData.Moves[20].summary:find("prevents it from attacking", 1, true))
assert(MoveData.Moves[12].summary:find("faster", 1, true))
assert(MoveData.MoveValueAdjustmentFuncs[MoveData.Values.LowKickId] == nil)

print("Gen 1 data adapter smoke tests passed")
