-- Run from any directory with: lua tools/gen1_game_profiles_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

dofile(repoRoot .. "ironmon_tracker/gen1/GameProfiles.lua")

local codes = Gen1GameProfiles.GameCodes
local red = assert(Gen1GameProfiles.get(codes.RED_US))
local blue = assert(Gen1GameProfiles.get(codes.BLUE_US))
local yellow = assert(Gen1GameProfiles.get(codes.YELLOW_US))
local yellowFr = assert(Gen1GameProfiles.get(codes.YELLOW_FR))

assert(red.generation == 1 and blue.generation == 1 and yellow.generation == 1 and yellowFr.generation == 1)
assert(red.version == "Red" and blue.version == "Blue")
assert(yellow.language == "English" and yellowFr.language == "French")
assert(Gen1GameProfiles.get(codes.RED_KAIZO) == red)
assert(Gen1GameProfiles.get(codes.YELLOW_KAIZO) == yellow)
assert(not Gen1GameProfiles.isSupported(0x414C0042), "Crystal must not be accepted by the Gen 1-only tracker")
assert(not Gen1GameProfiles.isSupported(0x42504545), "Emerald must not be accepted by the Gen 1-only tracker")

assert(red.wram.partyCount == 0x02001163 and red.wram.partySpecies == 0x02001164)
assert(red.wram.playerSelectedMove == 0x02000CDC and red.wram.battleState == 0x02001057)
assert(red.wram.trainerClass == 0x02001031 and red.wram.trainerNumber == 0x0200105D)
assert(red.rom.levelUpMoves == 0x0803B05C and red.rom.trainers == 0x08039D3B)
assert(yellow.wram.partyCount == 0x02001162 and yellow.wram.partySpecies == 0x02001163)
assert(yellow.wram.playerSelectedMove == 0x02000CDC and yellow.wram.battleState == 0x02001056)
assert(yellow.wram.trainerClass == 0x02001030 and yellow.wram.trainerNumber == 0x0200105C)

assert(yellowFr.wram.partyMon1 == 0x0200116F)
assert(yellowFr.wram.partyCount == 0x02001167)
assert(yellowFr.wram.enemyMon == 0x02000FE9)
assert(yellowFr.wram.battleState == 0x0200105B)
assert(yellowFr.wram.currentMap == 0x02001362)
assert(yellowFr.wram.trainerClass == 0x02001035 and yellowFr.wram.trainerNumber == 0x02001061)
assert(yellowFr.rom.levelUpMoves == yellow.rom.levelUpMoves + 3)
assert(yellowFr.rom.trainers == yellow.rom.trainers + 3)

print("Gen 1 game profile smoke tests passed")
