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
-- 'filename' is used with prefixes and postfixes to determine which image to show, depending on the game being played
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
}

function TrainerData.initialize()
	Gen1TrainerData.initialize()
end

function TrainerData.buildData()
	Gen1TrainerData.initialize()
end

---Returns true if the Pokémon data in this game is randomized (not vanilla), based on game data memory checks

--- Compare data from game memory with original game data to determine what's been randomized
function TrainerData.checkIfDataIsRandomized()
	-- Randomization flags are set by Gen1TrainerData.initialize().
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
	local classId = Gen1TrainerData.splitId(trainerId)
	return classId == 25 or classId == 42 or classId == 43
end
function TrainerData.shouldUseTrainer(trainerId)
	return TrainerData.Trainers[trainerId or false] ~= nil
end
function TrainerData.getExcludedTrainers()
	return {}
end
function TrainerData.isGiovanni(trainerId)
	local classId = Gen1TrainerData.splitId(trainerId or Gen1TrainerData.getCurrentTrainerId())
	return classId == 29
end
function TrainerData.getCommonTrainers(gamenumber)
	return {}
end

local function getClassFilename(trainerClass)
	trainerClass = trainerClass or TrainerData.Classes.Unknown
	local classFilename = trainerClass.filename or TrainerData.Classes.Unknown.filename
	return "frlg-" .. classFilename
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
