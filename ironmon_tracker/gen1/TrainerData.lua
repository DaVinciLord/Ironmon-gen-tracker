-- Native RBY trainer classes and parties. TrainerDataPointers contains one
-- little-endian bank pointer per class; each class then stores its numbered
-- parties as zero-terminated records.
Gen1TrainerData = {}

Gen1TrainerData.ClassNames = {
	"Youngster", "Bug Catcher", "Lass", "Sailor", "Jr. Trainer M", "Jr. Trainer F",
	"Pokemaniac", "Super Nerd", "Hiker", "Biker", "Burglar", "Engineer",
	"Unused Juggler", "Fisher", "Swimmer", "Cue Ball", "Gambler", "Beauty",
	"Psychic", "Rocker", "Juggler", "Tamer", "Bird Keeper", "Blackbelt",
	"Rival", "Prof. Oak", "Chief", "Scientist", "Giovanni", "Rocket",
	"Cooltrainer M", "Cooltrainer F", "Bruno", "Brock", "Misty", "Lt. Surge",
	"Erika", "Koga", "Blaine", "Sabrina", "Gentleman", "Rival", "Rival",
	"Lorelei", "Channeler", "Agatha", "Lance",
}

-- UPR ZX 4.6.1 gen1_offsets.ini. Randomization changes the party records,
-- not the number of trainer parties in each class.
Gen1TrainerData.RedBlueClassCounts = {
	13, 14, 18, 8, 9, 24, 7, 12, 14, 15, 9, 3, 0, 11, 15, 9, 7, 15, 4, 2, 8, 6,
	17, 9, 9, 3, 0, 13, 3, 41, 10, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5, 12, 3, 1, 24, 1, 1,
}
Gen1TrainerData.YellowClassCounts = {
	14, 15, 19, 8, 10, 25, 7, 12, 14, 15, 9, 3, 0, 11, 15, 9, 7, 15, 4, 2, 8, 6,
	17, 9, 3, 3, 0, 13, 3, 49, 10, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5, 10, 3, 1, 24, 1, 1,
}

local classKeys = {
	"Youngster", "BugCatcher", "Lass", "Sailor", "Camper", "Picnicker",
	"PokeManiac", "SuperNerd", "Hiker", "Biker", "Burglar", "Engineer",
	"Juggler", "Fisherman", "SwimmerM", "CueBall", "Gamer", "Beauty",
	"Psychic", "Rocker", "Juggler", "Tamer", "BirdKeeper", "BlackBelt",
	"RivalFRLGA", "Unknown", "Unknown", "Scientist", "GymLeader8", "TeamRocketGrunt",
	"CoolTrainer", "CoolTrainer", "EliteFour2", "GymLeader1", "GymLeader2", "GymLeader3",
	"GymLeader4", "GymLeader5", "GymLeader7", "GymLeader6", "Gentleman", "RivalFRLGB",
	"EliteChampion", "EliteFour1", "Channeler", "EliteFour3", "EliteFour4",
}

function Gen1TrainerData.makeId(classId, trainerNumber)
	return classId * 0x100 + trainerNumber
end

function Gen1TrainerData.splitId(trainerId)
	return math.floor((trainerId or 0) / 0x100), (trainerId or 0) % 0x100
end

local function classCounts()
	if GameSettings.currentProfile and GameSettings.currentProfile.version == "Yellow" then
		return Gen1TrainerData.YellowClassCounts
	end
	return Gen1TrainerData.RedBlueClassCounts
end

local function classObject(classId)
	return TrainerData.Classes[classKeys[classId] or "Unknown"] or TrainerData.Classes.Unknown
end

local function bankPointerToAddress(pointer)
	local tableOffset = (GameSettings.trainers or 0) % 0x1000000
	local bank = math.floor(tableOffset / 0x4000)
	if pointer < 0x4000 then return 0x08000000 + pointer end
	return 0x08000000 + bank * 0x4000 + pointer - 0x4000
end

function Gen1TrainerData.getClassAddress(classId)
	if classId < 1 or classId > #Gen1TrainerData.ClassNames then return nil end
	local pointer = Memory.readword(GameSettings.trainers + (classId - 1) * 2)
	if not pointer or pointer == 0 then return nil end
	return bankPointerToAddress(pointer)
end

local function skipRecord(address)
	for offset = 0, 63 do
		if Memory.readbyte(address + offset) == 0 then return address + offset + 1 end
	end
	return nil
end

function Gen1TrainerData.getPartyAddress(classId, trainerNumber)
	local address = Gen1TrainerData.getClassAddress(classId)
	if not address or trainerNumber < 1 or trainerNumber > (classCounts()[classId] or 0) then return nil end
	for _ = 2, trainerNumber do
		address = skipRecord(address)
		if not address then return nil end
	end
	return address
end

function Gen1TrainerData.readParty(classId, trainerNumber)
	local address = Gen1TrainerData.getPartyAddress(classId, trainerNumber)
	if not address then return {} end
	local party = {}
	local first = Memory.readbyte(address)
	address = address + 1
	if first == 0xFF then
		for _ = 1, 6 do
			local level = Memory.readbyte(address)
			if level == 0 then break end
			local internalSpecies = Memory.readbyte(address + 1)
			table.insert(party, {
				pokemonID = Gen1SpeciesMap.getDexId(internalSpecies) or 0,
				internalSpecies = internalSpecies,
				level = level, ivs = 9, heldItem = 0, moves = {},
			})
			address = address + 2
		end
	else
		for _ = 1, 6 do
			local internalSpecies = Memory.readbyte(address)
			if internalSpecies == 0 then break end
			table.insert(party, {
				pokemonID = Gen1SpeciesMap.getDexId(internalSpecies) or 0,
				internalSpecies = internalSpecies,
				level = first, ivs = 9, heldItem = 0, moves = {},
			})
			address = address + 1
		end
	end
	return party
end

function Gen1TrainerData.getCurrentTrainerId()
	if (Memory.readbyte(GameSettings.battleState) or 0) ~= 2 then return 0 end
	local classId = Memory.readbyte(GameSettings.trainerClass) or 0
	local trainerNumber = Memory.readbyte(GameSettings.trainerNumber) or 0
	if classId < 1 or classId > #Gen1TrainerData.ClassNames or trainerNumber < 1 then return 0 end
	return Gen1TrainerData.makeId(classId, trainerNumber)
end

function Gen1TrainerData.readTrainer(trainerId)
	local classId, trainerNumber = Gen1TrainerData.splitId(trainerId)
	if not TrainerData.Trainers[trainerId] then return nil end
	local party = Gen1TrainerData.readParty(classId, trainerNumber)
	return Program.GameTrainer:new({
		trainerId = trainerId, defeated = false,
		trainerClass = Gen1TrainerData.ClassNames[classId],
		trainerName = string.format("#%d", trainerNumber),
		partySize = #party, party = party, partyFlags = 0, items = {},
		doubleBattle = false, aiFlags = 0, gender = 0,
	})
end

function Gen1TrainerData.initialize()
	TrainerData.Trainers, TrainerData.OrderedIds = {}, {}
	Gen1TrainerData.GlobalLogIdToTrainerId = {}
	TrainerData.GymTMs, TrainerData.CommonTrainers, TrainerData.FinalTrainer = {}, {}, {}
	for key in pairs(TrainerData.IsRand or {}) do TrainerData.IsRand[key] = false end

	local globalLogId = 0
	for classId, count in ipairs(classCounts()) do
		for trainerNumber = 1, count do
			globalLogId = globalLogId + 1
			local trainerId = Gen1TrainerData.makeId(classId, trainerNumber)
			Gen1TrainerData.GlobalLogIdToTrainerId[globalLogId] = trainerId
			TrainerData.Trainers[trainerId] = {
				name = Gen1TrainerData.ClassNames[classId], class = classObject(classId),
				classId = classId, trainerNumber = trainerNumber,
			}
			table.insert(TrainerData.OrderedIds, trainerId)
		end
	end
	for trainerNumber = 1, (classCounts()[43] or 0) do
		TrainerData.FinalTrainer[Gen1TrainerData.makeId(43, trainerNumber)] = true
	end

	-- The first Youngster is identical in clean Red, Blue, and Yellow. This
	-- mirrors upstream's small vanilla probe without assuming that a modified
	-- ROM necessarily randomized every other data category.
	local probe = Gen1TrainerData.readParty(1, 1)
	TrainerData.IsRand.teamSize = #probe ~= 2
	TrainerData.IsRand.teamLevels = not probe[1] or probe[1].level ~= 11
	TrainerData.IsRand.teamPokemon = not probe[1] or not probe[2]
		or probe[1].internalSpecies ~= 0xA5 or probe[2].internalSpecies ~= 0x6C
end

function Gen1TrainerData.apply()
	TrainerData.initialize = Gen1TrainerData.initialize
	TrainerData.isRival = function(trainerId)
		local classId = Gen1TrainerData.splitId(trainerId)
		return classId == 25 or classId == 42 or classId == 43
	end
	TrainerData.isGiovanni = function(trainerId)
		local classId = Gen1TrainerData.splitId(trainerId or Gen1TrainerData.getCurrentTrainerId())
		return classId == 29
	end
	TrainerData.shouldUseTrainer = function(trainerId) return TrainerData.Trainers[trainerId or false] ~= nil end
	TrainerData.getExcludedTrainers = function() return {} end
	TrackerAPI.getOpponentTrainerId = Gen1TrainerData.getCurrentTrainerId
end

-- Program is loaded after data modules, so runtime overrides are connected by
-- Gen1Runtime once the inherited Program table exists.
function Gen1TrainerData.applyRuntime()
	Program.readTrainerGameData = Gen1TrainerData.readTrainer
	Program.hasDefeatedTrainer = function() return false end
end

Gen1TrainerData.apply()

return Gen1TrainerData
