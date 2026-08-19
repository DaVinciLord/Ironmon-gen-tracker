-- Run from any directory with: lua tools/gen1_pokemon_reader_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

local bytes = {}
Memory = { readbyte = function(address) return bytes[address] or 0 end }
dofile(repoRoot .. "ironmon_tracker/PokemonDataReader.lua")

local function put(address, ...)
	for index, value in ipairs({ ... }) do bytes[address + index - 1] = value end
end

local base = 0x1000
put(base + 0, 0x54) -- Pikachu internal id in RBY
put(base + 1, 0x00, 0x23) -- 35 current HP
put(base + 4, 0x43) -- asleep for 3 turns (sleep bits take precedence)
put(base + 8, 84, 98, 86, 129) -- Thunder Shock, Quick Attack, Thunder Wave, Swift
put(base + 12, 0x12, 0x34)
put(base + 14, 0x01, 0x02, 0x03)
put(base + 17, 0x00, 1, 0x00, 2, 0x00, 3, 0x00, 4, 0x00, 5)
put(base + 27, 0xA5, 0xC7) -- Atk 10, Def 5, Spe 12, Special 7; HP DV 4
put(base + 29, 30, 0x41, 20, 10) -- PP Ups are masked out
put(base + 33, 25)
put(base + 34, 0x00, 60, 0x00, 40, 0x00, 30, 0x00, 55, 0x00, 50)

local party = Gen1PokemonReader.readPartyPokemon(base, function(internalId)
	assert(internalId == 0x54)
	return 25
end)
assert(party.pokemonID == 25 and party.internalSpecies == 0x54)
assert(party.curHP == 35 and party.stats.hp == 60 and party.stats.special == 50)
assert(party.stats.spa == nil and party.stats.spd == nil, "RBY must expose one Special stat")
assert(party.trainerID == 0x1234 and party.experience == 0x010203)
assert(party.status == Gen1PokemonReader.Status.SLEEP and party.sleep_turns == 3)
assert(party.dvs.hp == 5 and party.dvs.atk == 10 and party.dvs.special == 7)
assert(party.statExp.special == 5)
assert(party.moves[2].id == 98 and party.moves[2].pp == 1)

bytes = {}
put(base + 0, 0x54)
put(base + 1, 0x00, 42)
put(base + 4, 0x10) -- burn
put(base + 8, 84, 98, 86, 129)
put(base + 12, 0xF1, 0x2E)
put(base + 14, 30)
put(base + 15, 0x00, 70, 0x00, 45, 0x00, 35, 0x00, 60, 0x00, 55)
put(base + 25, 30, 20, 10, 5)
local enemy = Gen1PokemonReader.readBattlePokemon(base, function() return 25 end)
assert(enemy.level == 30 and enemy.status == Gen1PokemonReader.Status.BURN)
assert(enemy.stats.hp == 70 and enemy.stats.special == 55)
assert(enemy.dvs.atk == 15 and enemy.dvs.def == 1 and enemy.dvs.spe == 2 and enemy.dvs.special == 14)

print("Gen 1 Pokemon reader smoke tests passed")
