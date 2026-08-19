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

local function id(classId, trainerNumber)
	return Gen1TrainerData.makeId(classId, trainerNumber)
end

-- Badge bit → gym leader. Soul/Marsh/Volcano/Earth follow Kanto badge order.
Gen1TrainerData.GymLeaders = {
	[0] = id(34, 1), -- Brock
	[1] = id(35, 1), -- Misty
	[2] = id(36, 1), -- Lt. Surge
	[3] = id(37, 1), -- Erika
	[4] = id(38, 1), -- Koga
	[5] = id(40, 1), -- Sabrina
	[6] = id(39, 1), -- Blaine
	[7] = id(29, 3), -- Giovanni (Viridian Gym)
}

-- Gym leaders, rivals, Giovanni, and the Elite Four have unique class/party
-- IDs. Other trainers are attached to the map where they are fought.
Gen1TrainerData.TrainersByMap = {
	[0x21] = { id(25, 1), id(25, 2), id(25, 3) }, -- Route 22 rivals
	[0x36] = { id(34, 1) }, -- Pewter Gym
	[0x41] = { id(35, 1) }, -- Cerulean Gym
	[0x5C] = { id(36, 1) }, -- Vermilion Gym
	[0x86] = { id(37, 1) }, -- Celadon Gym
	[0x9D] = { id(38, 1) }, -- Fuchsia Gym
	[0xB2] = { id(40, 1) }, -- Saffron Gym
	[0xA6] = { id(39, 1) }, -- Cinnabar Gym
	[0x2D] = { id(29, 3) }, -- Viridian Gym (Giovanni)
	[0xCA] = { id(29, 1) }, -- Rocket Hideout Giovanni
	[0xEB] = { id(29, 2) }, -- Silph Co. Giovanni
	[0xF5] = { id(44, 1) },
	[0xF6] = { id(33, 1) },
	[0xF7] = { id(46, 1) },
	[0x71] = { id(47, 1) },
	[0x78] = { id(43, 1), id(43, 2), id(43, 3) },
}

function Gen1TrainerData.applyRouteTrainers()
	if not RouteData or not RouteData.Info then return end
	for mapId, trainers in pairs(Gen1TrainerData.TrainersByMap) do
		local route = RouteData.Info[mapId]
		if route then
			route.trainers = {}
			for _, trainerId in ipairs(trainers) do
				table.insert(route.trainers, trainerId)
			end
		end
	end
end

function Gen1TrainerData.rememberTrainerOnMap(mapId, trainerId)
	if not trainerId or trainerId == 0 then return end
	if not RouteData or not RouteData.Info then return end
	local route = RouteData.Info[mapId or false]
	if not route then return end
	route.trainers = route.trainers or {}
	for _, existing in ipairs(route.trainers) do
		if existing == trainerId then return end
	end
	table.insert(route.trainers, trainerId)
end

function Gen1TrainerData.markDefeated(trainerId)
	if not trainerId or trainerId == 0 then return end
	if not Tracker or not Tracker.Data then return end
	Tracker.Data.defeatedTrainers = Tracker.Data.defeatedTrainers or {}
	Tracker.Data.defeatedTrainers[trainerId] = true
	Gen1TrainerData.rememberTrainerOnMap(Program.GameData.mapId, trainerId)
end

function Gen1TrainerData.hasDefeatedTrainer(trainerId)
	if not TrainerData.Trainers[trainerId or false] then return false end
	if Program.isValidMapLocation and not Program.isValidMapLocation() then return false end
	if Tracker and Tracker.Data and Tracker.Data.defeatedTrainers and Tracker.Data.defeatedTrainers[trainerId] then
		return true
	end
	local badges = (GameSettings.badges and Memory.readbyte(GameSettings.badges)) or 0
	for bit, leaderId in pairs(Gen1TrainerData.GymLeaders) do
		if leaderId == trainerId then
			local mask = 2 ^ bit
			if math.floor(badges / mask) % 2 == 1 then return true end
		end
	end
	return false
end

function Gen1TrainerData.countDefeated()
	local count = 0
	local seen = {}
	for trainerId, defeated in pairs(Tracker.Data.defeatedTrainers or {}) do
		if defeated and TrainerData.Trainers[trainerId or false] then
			seen[trainerId] = true
			count = count + 1
		end
	end
	local badges = Memory.readbyte(GameSettings.badges) or 0
	for bit, leaderId in pairs(Gen1TrainerData.GymLeaders) do
		local mask = 2 ^ bit
		if math.floor(badges / mask) % 2 == 1 and not seen[leaderId] and TrainerData.Trainers[leaderId] then
			count = count + 1
		end
	end
	return count
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
		trainerId = trainerId, defeated = Gen1TrainerData.hasDefeatedTrainer(trainerId),
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
	Gen1TrainerData.applyRouteTrainers()
end

function Gen1TrainerData.apply()
	-- TrackerAPI.getOpponentTrainerId now calls Gen1TrainerData.getCurrentTrainerId natively.
end

-- Program is loaded after data modules, so runtime overrides are connected by
-- Gen1Runtime once the inherited Program table exists.
function Gen1TrainerData.getDefeatedTrainersByLocation(mapId)
	local route = RouteData.Info[mapId or false]
	if not route then return {}, 0 end
	local defeatedTrainers = {}
	local totalTrainers = 0
	for _, trainerId in ipairs(route.trainers or {}) do
		if TrainerData.Trainers[trainerId or false] then
			totalTrainers = totalTrainers + 1
			if Gen1TrainerData.hasDefeatedTrainer(trainerId) then
				table.insert(defeatedTrainers, trainerId)
			end
		end
	end
	return defeatedTrainers, totalTrainers
end

function Gen1TrainerData.getDefeatedTrainersByCombinedArea(mapIdList)
	if type(mapIdList) ~= "table" then return {}, 0 end
	local totalTrainers = 0
	local defeatedTrainers = {}
	for _, mapId in ipairs(mapIdList) do
		local defeatedList, total = Gen1TrainerData.getDefeatedTrainersByLocation(mapId)
		totalTrainers = totalTrainers + total
		for _, trainerId in ipairs(defeatedList) do
			table.insert(defeatedTrainers, trainerId)
		end
	end
	return defeatedTrainers, totalTrainers
end

function Gen1TrainerData.applyRuntime()
	-- Program.lua already delegates to this module.
end

Gen1TrainerData.apply()

return Gen1TrainerData
