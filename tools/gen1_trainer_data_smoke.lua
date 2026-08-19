local bytes = {}
local pointerTable = 0x08039DD1
local classAddress = 0x08039E2F
bytes[pointerTable] = 0x2F
bytes[pointerTable + 1] = 0x5E

-- Youngster #1: all at level 11. Youngster #2: individual levels.
for offset, value in ipairs({ 11, 1, 2, 0, 0xFF, 5, 3, 8, 4, 0 }) do
	bytes[classAddress + offset - 1] = value
end

GameSettings = {
	currentProfile = { version = "Yellow" },
	trainers = pointerTable,
	battleState = 0x200,
	trainerClass = 0x201,
	trainerNumber = 0x202,
}
Memory = {
	readbyte = function(address) return bytes[address] or 0 end,
	readword = function(address)
		return (bytes[address] or 0) + (bytes[address + 1] or 0) * 0x100
	end,
}
local unknownClass = { filename = "unknown" }
TrainerData = {
	Classes = setmetatable({ Unknown = unknownClass }, { __index = function() return unknownClass end }),
	IsRand = {},
}
Program = {
	GameTrainer = {
		new = function(_, value) return value end,
	},
}
TrackerAPI = {}
SpeciesMap = { getDexId = function(id) return id + 1000 end }

dofile("ironmon_tracker/data/TrainerData.lua")
TrackerAPI.getOpponentTrainerId = TrainerData.getCurrentTrainerId
Program.readTrainerGameData = TrainerData.readTrainer
TrainerData.initialize()

assert(#TrainerData.OrderedIds == 396, "Yellow must expose every native trainer party")
assert(TrainerData.getClassAddress(1) == classAddress)
local normal = TrainerData.readParty(1, 1)
assert(#normal == 2 and normal[1].level == 11 and normal[1].pokemonID == 1001)
local special = TrainerData.readParty(1, 2)
assert(#special == 2 and special[1].level == 5 and special[2].level == 8)

bytes[GameSettings.battleState] = 2
bytes[GameSettings.trainerClass] = 1
bytes[GameSettings.trainerNumber] = 2
local trainerId = TrackerAPI.getOpponentTrainerId()
assert(trainerId == TrainerData.makeId(1, 2))
local trainer = Program.readTrainerGameData(trainerId)
assert(trainer.partySize == 2 and trainer.trainerClass == "Youngster" and trainer.trainerName == "#2")
bytes[GameSettings.battleState] = 1
assert(TrackerAPI.getOpponentTrainerId() == 0)

assert(#TrainerData.GymTMs == 8, "Kanto gyms each award one TM")
assert(TrainerData.GymTMs[1].number == 34 and TrainerData.GymTMs[1].leader == "Brock")
assert(TrainerData.GymTMs[5].number == 6 and TrainerData.GymTMs[8].number == 27)

print("Gen 1 trainer data smoke tests passed")
