-- Currently, this is only used for connecting to trainer data parsed from a randomizer log file
TrainerData = {}

TrainerData.IsRand = {
	-- trainerName = false,
	teamPokemon = false,
	teamLevels = false,
	teamSize = false,
}

-- These are populated later after the game being played is determined
TrainerData.Trainers = {}
TrainerData.OrderedIds = {}
TrainerData.GymTMs = {}
TrainerData.CommonTrainers = {} -- Commonly known trainers, used for !trainer command lookups
TrainerData.FinalTrainer = {} -- The final trainer to defeat to win Ironmon

TrainerData.TrainerGroups = {
	All = "All",
	Rival = "Rival",
	Gym = "Gym",
	Elite4 = "Elite 4",
	Boss = "Boss",
	Other = "Other",
}

-- A table of information for each different trainer class
-- 'filename' is the image stem under images/trainers and images/trainerPortraits
TrainerData.Classes = {
	GymLeader1 = 	{ filename = "gymleader-1", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader2 = 	{ filename = "gymleader-2", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader3 = 	{ filename = "gymleader-3", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader4 = 	{ filename = "gymleader-4", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader5 = 	{ filename = "gymleader-5", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader6 = 	{ filename = "gymleader-6", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader7 = 	{ filename = "gymleader-7", 	group = TrainerData.TrainerGroups.Gym, },
	GymLeader8 = 	{ filename = "gymleader-8", 	group = TrainerData.TrainerGroups.Gym, },
	EliteFour1 = 	{ filename = "elitefour-1", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteFour2 = 	{ filename = "elitefour-2", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteFour3 = 	{ filename = "elitefour-3", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteFour4 = 	{ filename = "elitefour-4", 	group = TrainerData.TrainerGroups.Elite4, },
	EliteChampion = { filename = "elitefour-champ", group = TrainerData.TrainerGroups.Elite4, },
	RivalFRLGA = 	{ filename = "rival-a", 		group = TrainerData.TrainerGroups.Rival, },
	RivalFRLGB = 	{ filename = "rival-b", 		group = TrainerData.TrainerGroups.Rival, },
	RivalFRLGC = 	{ filename = "rival-c", 		group = TrainerData.TrainerGroups.Rival, },

	Beauty = 		{ filename = "beauty", },
	Biker = 		{ filename = "biker", },
	BirdKeeper = 	{ filename = "bird-keeper", },
	BlackBelt = 	{ filename = "blackbelt", },
	BugCatcher = 	{ filename = "bug-catcher", },
	Burglar = 		{ filename = "burglar", },
	Camper = 		{ filename = "camper", },
	Channeler = 	{ filename = "channeler", },
	CoolTrainer = 	{ filename = "cooltrainer", },
	CueBall = 		{ filename = "cue-ball", },
	Engineer = 		{ filename = "engineer", },
	Fisherman = 	{ filename = "fisherman", },
	Gamer = 		{ filename = "gamer", },
	Gentleman = 	{ filename = "gentleman", },
	Hiker = 		{ filename = "hiker", },
	Juggler = 		{ filename = "juggler", },
	Lass = 			{ filename = "lass", },
	Picnicker = 	{ filename = "picnicker", },
	PokeManiac = 	{ filename = "pokemaniac", },
	Psychic = 		{ filename = "psychic", },
	Rocker = 		{ filename = "rocker", },
	Sailor = 		{ filename = "sailor", },
	Scientist = 	{ filename = "scientist", },
	SuperNerd = 	{ filename = "super-nerd", },
	SwimmerM = 		{ filename = "swimmer-m", },
	Tamer = 		{ filename = "tamer", },
	TeamRocketGrunt = { filename = "team-rocket-grunt", },
	Youngster = 	{ filename = "youngster", },
	Unknown = 		{ filename = "unknown", },
}

TrainerData.BlankTrainer = {
	class = TrainerData.Classes.Unknown,
	group = TrainerData.TrainerGroups.Other,
}



---Returns true if the Pokémon data in this game is randomized (not vanilla), based on game data memory checks

--- Compare data from game memory with original game data to determine what's been randomized
function TrainerData.checkIfDataIsRandomized()
	-- Randomization flags are set by TrainerData.initialize().
	return
end

---Returns true if the Pokémon data in this game is randomized (not vanilla), based on game data memory checks
---@return boolean
function TrainerData.isTeamDataRandomized()
	return TrainerData.IsRand.teamPokemon or TrainerData.IsRand.teamLevels or TrainerData.IsRand.teamSize
end

---Returns true if info unknown to the player (random or otherwise) is allowed to be revealed.
---@return boolean
function TrainerData.canShowUnknownTrainerTeams()
	if Options["Open Book Play Mode"] then
		return true
	end
	return not TrainerData.IsRand.teamPokemon and Options["Show data for vanilla game"]
end

function TrainerData.getTrainerInfo(trainerId)
	return TrainerData.Trainers[trainerId or false] or TrainerData.BlankTrainer
end

-- Determines if the trainer's display name should use its in-game name (i.e. Terry) or class name (i.e. Rival)
function TrainerData.shouldUseClassName(trainerId)
	return TrainerData.isRival(trainerId)
end
function TrainerData.isRival(trainerId)
	local classId = TrainerData.splitId(trainerId)
	return classId == 25 or classId == 42 or classId == 43
end
function TrainerData.shouldUseTrainer(trainerId)
	return TrainerData.Trainers[trainerId or false] ~= nil
end
function TrainerData.getExcludedTrainers()
	return {}
end
function TrainerData.isGiovanni(trainerId)
	local classId = TrainerData.splitId(trainerId or TrainerData.getCurrentTrainerId())
	return classId == 29
end
function TrainerData.getCommonTrainers(gamenumber)
	return {}
end

local function getClassFilename(trainerClass)
	trainerClass = trainerClass or TrainerData.Classes.Unknown
	return trainerClass.filename or TrainerData.Classes.Unknown.filename
end

function TrainerData.getFullImage(trainerClass)
	return FileManager.buildImagePath(FileManager.Folders.Trainers, getClassFilename(trainerClass), FileManager.Extensions.TRAINER)
end

function TrainerData.getPortraitIcon(trainerClass)
	return FileManager.buildImagePath(FileManager.Folders.TrainersPortraits, getClassFilename(trainerClass), FileManager.Extensions.TRAINER)
end

-- Helper function to convert Class->{TrainerId(List)} to TrainerId->{Class,Group}
local function mapClassesToTrainers(classMap, trainerList)
	for class, trainers in pairs(classMap) do
		for _, item in pairs(trainers) do
			-- Could be a list of raw ids, or a range ids as pair (fromID, toID)
			if type(item) == "number" then
				trainerList[item] = {
					class = class,
					group = class.group
				}
			elseif type(item) == "table" and #item == 2 then
				-- Add each number sequentially from the first value to the second value
				for i = item[1], item[2], 1 do
					trainerList[i] = {
						class = class,
						group = class.group
					}
				end
			end
		end
	end
end

-- For each trainer, add info on what route they can be found on
local function mapRoutesToTrainers()
	for routeId, route in pairs(RouteData.Info or {}) do
		if route.trainers and #route.trainers > 0 then
			for _, trainerId in ipairs(route.trainers or {}) do
				local trainer = TrainerData.Trainers[trainerId]
				if trainer then
					trainer.routeId = routeId
				end
			end
		end
	end
end

-- Native RBY trainer classes and parties. TrainerDataPointers contains one
-- little-endian bank pointer per class; each class then stores its numbered
-- parties as zero-terminated records.
TrainerData.ClassNames = {
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
TrainerData.RedBlueClassCounts = {
	13, 14, 18, 8, 9, 24, 7, 12, 14, 15, 9, 3, 0, 11, 15, 9, 7, 15, 4, 2, 8, 6,
	17, 9, 9, 3, 0, 13, 3, 41, 10, 8, 1, 1, 1, 1, 1, 1, 1, 1, 5, 12, 3, 1, 24, 1, 1,
}
TrainerData.YellowClassCounts = {
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

function TrainerData.makeId(classId, trainerNumber)
	return classId * 0x100 + trainerNumber
end

local function id(classId, trainerNumber)
	return TrainerData.makeId(classId, trainerNumber)
end

-- Badge bit → gym leader. Soul/Marsh/Volcano/Earth follow Kanto badge order.
TrainerData.GymLeaders = {
	[0] = id(34, 1), -- Brock
	[1] = id(35, 1), -- Misty
	[2] = id(36, 1), -- Lt. Surge
	[3] = id(37, 1), -- Erika
	[4] = id(38, 1), -- Koga
	[5] = id(40, 1), -- Sabrina
	[6] = id(39, 1), -- Blaine
	[7] = id(29, 3), -- Giovanni (Viridian Gym)
}

-- TM item each Kanto gym awards (RBY/Yellow). UPR randomizes the move on the
-- TM, not which TM number the gym gives.
TrainerData.RbyGymTMs = {
	{ number = 34, leader = "Brock" },
	{ number = 11, leader = "Misty" },
	{ number = 24, leader = "Lt. Surge" },
	{ number = 21, leader = "Erika" },
	{ number = 6, leader = "Koga" },
	{ number = 46, leader = "Sabrina" },
	{ number = 38, leader = "Blaine" },
	{ number = 27, leader = "Giovanni" },
}

-- Gym leaders, rivals, Giovanni, and the Elite Four have unique class/party
-- IDs. Other trainers are attached to the map where they are fought.
TrainerData.TrainersByMap = {
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

function TrainerData.applyRouteTrainers()
	if not RouteData or not RouteData.Info then return end
	for mapId, trainers in pairs(TrainerData.TrainersByMap) do
		local route = RouteData.Info[mapId]
		if route then
			route.trainers = {}
			for _, trainerId in ipairs(trainers) do
				table.insert(route.trainers, trainerId)
			end
		end
	end
end

function TrainerData.rememberTrainerOnMap(mapId, trainerId)
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

function TrainerData.markDefeated(trainerId)
	if not trainerId or trainerId == 0 then return end
	if not Tracker or not Tracker.Data then return end
	Tracker.Data.defeatedTrainers = Tracker.Data.defeatedTrainers or {}
	Tracker.Data.defeatedTrainers[trainerId] = true
	TrainerData.rememberTrainerOnMap(Program.GameData.mapId, trainerId)
end

function TrainerData.hasDefeatedTrainer(trainerId)
	if not TrainerData.Trainers[trainerId or false] then return false end
	if Program.isValidMapLocation and not Program.isValidMapLocation() then return false end
	if Tracker and Tracker.Data and Tracker.Data.defeatedTrainers and Tracker.Data.defeatedTrainers[trainerId] then
		return true
	end
	local badges = (GameSettings.badges and Memory.readbyte(GameSettings.badges)) or 0
	for bit, leaderId in pairs(TrainerData.GymLeaders) do
		if leaderId == trainerId then
			local mask = 2 ^ bit
			if math.floor(badges / mask) % 2 == 1 then return true end
		end
	end
	return false
end

function TrainerData.countDefeated()
	local count = 0
	local seen = {}
	for trainerId, defeated in pairs(Tracker.Data.defeatedTrainers or {}) do
		if defeated and TrainerData.Trainers[trainerId or false] then
			seen[trainerId] = true
			count = count + 1
		end
	end
	local badges = Memory.readbyte(GameSettings.badges) or 0
	for bit, leaderId in pairs(TrainerData.GymLeaders) do
		local mask = 2 ^ bit
		if math.floor(badges / mask) % 2 == 1 and not seen[leaderId] and TrainerData.Trainers[leaderId] then
			count = count + 1
		end
	end
	return count
end

function TrainerData.splitId(trainerId)
	return math.floor((trainerId or 0) / 0x100), (trainerId or 0) % 0x100
end

local function classCounts()
	if GameSettings.currentProfile and GameSettings.currentProfile.version == "Yellow" then
		return TrainerData.YellowClassCounts
	end
	return TrainerData.RedBlueClassCounts
end

local function classObject(classId)
	return TrainerData.Classes[classKeys[classId] or "Unknown"] or TrainerData.Classes.Unknown
end

local function trainerGroup(classId, trainerNumber)
	-- Giovanni's class covers Rocket Hideout, Silph, and Viridian Gym.
	-- Only the gym fight belongs with the Gym filter.
	if classId == 29 and trainerNumber ~= 3 then
		return TrainerData.TrainerGroups.Boss
	end
	local class = classObject(classId)
	return class.group or TrainerData.TrainerGroups.Other
end

local function bankPointerToAddress(pointer)
	local tableOffset = (GameSettings.trainers or 0) % 0x1000000
	local bank = math.floor(tableOffset / 0x4000)
	if pointer < 0x4000 then return 0x08000000 + pointer end
	return 0x08000000 + bank * 0x4000 + pointer - 0x4000
end

function TrainerData.getClassAddress(classId)
	if classId < 1 or classId > #TrainerData.ClassNames then return nil end
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

function TrainerData.getPartyAddress(classId, trainerNumber)
	local address = TrainerData.getClassAddress(classId)
	if not address or trainerNumber < 1 or trainerNumber > (classCounts()[classId] or 0) then return nil end
	for _ = 2, trainerNumber do
		address = skipRecord(address)
		if not address then return nil end
	end
	return address
end

function TrainerData.readParty(classId, trainerNumber)
	local address = TrainerData.getPartyAddress(classId, trainerNumber)
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
				pokemonID = SpeciesMap.getDexId(internalSpecies) or 0,
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
				pokemonID = SpeciesMap.getDexId(internalSpecies) or 0,
				internalSpecies = internalSpecies,
				level = first, ivs = 9, heldItem = 0, moves = {},
			})
			address = address + 1
		end
	end
	return party
end

function TrainerData.getCurrentTrainerId()
	if (Memory.readbyte(GameSettings.battleState) or 0) ~= 2 then return 0 end
	local classId = Memory.readbyte(GameSettings.trainerClass) or 0
	local trainerNumber = Memory.readbyte(GameSettings.trainerNumber) or 0
	if classId < 1 or classId > #TrainerData.ClassNames or trainerNumber < 1 then return 0 end
	return TrainerData.makeId(classId, trainerNumber)
end

function TrainerData.readTrainer(trainerId)
	local classId, trainerNumber = TrainerData.splitId(trainerId)
	if not TrainerData.Trainers[trainerId] then return nil end
	local party = TrainerData.readParty(classId, trainerNumber)
	return Program.GameTrainer:new({
		trainerId = trainerId, defeated = TrainerData.hasDefeatedTrainer(trainerId),
		trainerClass = TrainerData.ClassNames[classId],
		trainerName = string.format("#%d", trainerNumber),
		partySize = #party, party = party, partyFlags = 0, items = {},
		doubleBattle = false, aiFlags = 0, gender = 0,
	})
end

function TrainerData.initialize()
	TrainerData.Trainers, TrainerData.OrderedIds = {}, {}
	TrainerData.GlobalLogIdToTrainerId = {}
	TrainerData.GymTMs, TrainerData.CommonTrainers, TrainerData.FinalTrainer = {}, {}, {}
	for _, gymTM in ipairs(TrainerData.RbyGymTMs) do
		table.insert(TrainerData.GymTMs, {
			number = gymTM.number,
			leader = gymTM.leader,
		})
	end
	for key in pairs(TrainerData.IsRand or {}) do TrainerData.IsRand[key] = false end

	local globalLogId = 0
	for classId, count in ipairs(classCounts()) do
		for trainerNumber = 1, count do
			globalLogId = globalLogId + 1
			local trainerId = TrainerData.makeId(classId, trainerNumber)
			TrainerData.GlobalLogIdToTrainerId[globalLogId] = trainerId
			TrainerData.Trainers[trainerId] = {
				name = TrainerData.ClassNames[classId], class = classObject(classId),
				group = trainerGroup(classId, trainerNumber),
				classId = classId, trainerNumber = trainerNumber,
			}
			table.insert(TrainerData.OrderedIds, trainerId)
		end
	end
	for trainerNumber = 1, (classCounts()[43] or 0) do
		TrainerData.FinalTrainer[TrainerData.makeId(43, trainerNumber)] = true
	end

	-- The first Youngster is identical in clean Red, Blue, and Yellow. This
	-- mirrors upstream's small vanilla probe without assuming that a modified
	-- ROM necessarily randomized every other data category.
	local probe = TrainerData.readParty(1, 1)
	TrainerData.IsRand.teamSize = #probe ~= 2
	TrainerData.IsRand.teamLevels = not probe[1] or probe[1].level ~= 11
	TrainerData.IsRand.teamPokemon = not probe[1] or not probe[2]
		or probe[1].internalSpecies ~= 0xA5 or probe[2].internalSpecies ~= 0x6C
	TrainerData.applyRouteTrainers()
end

function TrainerData.getDefeatedTrainersByLocation(mapId)
	local route = RouteData.Info[mapId or false]
	if not route then return {}, 0 end
	local defeatedTrainers = {}
	local totalTrainers = 0
	for _, trainerId in ipairs(route.trainers or {}) do
		if TrainerData.Trainers[trainerId or false] then
			totalTrainers = totalTrainers + 1
			if TrainerData.hasDefeatedTrainer(trainerId) then
				table.insert(defeatedTrainers, trainerId)
			end
		end
	end
	return defeatedTrainers, totalTrainers
end

function TrainerData.getDefeatedTrainersByCombinedArea(mapIdList)
	if type(mapIdList) ~= "table" then return {}, 0 end
	local totalTrainers = 0
	local defeatedTrainers = {}
	for _, mapId in ipairs(mapIdList) do
		local defeatedList, total = TrainerData.getDefeatedTrainersByLocation(mapId)
		totalTrainers = totalTrainers + total
		for _, trainerId in ipairs(defeatedList) do
			table.insert(defeatedTrainers, trainerId)
		end
	end
	return defeatedTrainers, totalTrainers
end



function TrainerData.buildData()
	TrainerData.initialize()
end
