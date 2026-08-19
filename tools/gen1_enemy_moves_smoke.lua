-- Besteon shows enemy RAM moves iff canShowUnknownMoveLearnSets():
-- Open Book, or (learnsets not randomized AND "Show data for vanilla game").
-- Gen 1 must detect RBY learnset randomization; it must not invent a new gate.
local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*a")
	file:close()
	return content
end

Constants = { BLANKLINE = "--", HIDDEN_INFO = "?", Words = { POKEMON = "Pokemon" } }
Options = { ["Open Book Play Mode"] = false, ["Show data for vanilla game"] = true }
dofile("ironmon_tracker/data/PokemonData.lua")

PokemonData.IsRand.moveLearnSet = false
assert(PokemonData.canShowUnknownMoveLearnSets(), "vanilla + show vanilla data reveals enemy moves")

PokemonData.IsRand.moveLearnSet = true
assert(not PokemonData.canShowUnknownMoveLearnSets(), "randomized learnsets hide enemy RAM moves")

Options["Open Book Play Mode"] = true
assert(PokemonData.canShowUnknownMoveLearnSets(), "Open Book still reveals enemy moves")

local dataHelper = read("ironmon_tracker/data/DataHelper.lua")
assert(dataHelper:find("canShowUnknownMoveLearnSets", 1, true), "DataHelper must keep the Besteon canShowMoves gate")
assert(not dataHelper:find("canShowEnemyBattleMoves", 1, true), "do not invent a separate enemy-move gate")
local input = read("ironmon_tracker/Input.lua")
assert(input:find("canShowUnknownMoveLearnSets", 1, true))
assert(not input:find("canShowEnemyBattleMoves", 1, true))

print("Gen 1 enemy moves smoke tests passed")
