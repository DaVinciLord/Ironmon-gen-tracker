local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*a")
	file:close()
	return content
end

local manifest = read("ironmon_tracker/FileManager.lua")
for _, moduleName in ipairs({ "AbilityData", "GachaMonData", "GachaMonFileManager", "GachaMonOverlay", "AnimationManager", "MGBA", "MGBADisplay" }) do
	assert(not manifest:find('name%s*=%s*"' .. moduleName .. '"'), moduleName .. " must not be loaded")
end

for _, path in ipairs({
	"ironmon_tracker/Main.lua",
	"ironmon_tracker/core/Program.lua",
	"ironmon_tracker/core/Battle.lua",
	"ironmon_tracker/core/Input.lua",
	"ironmon_tracker/core/Tracker.lua",
	"ironmon_tracker/core/TrackerAPI.lua",
	"ironmon_tracker/ui/screens/combat/TrackerScreen.lua",
	"ironmon_tracker/ui/screens/setup/SetupScreen.lua",
	"ironmon_tracker/ui/screens/setup/ExtrasScreen.lua",
	"ironmon_tracker/ui/screens/setup/QuickloadScreen.lua",
	"ironmon_tracker/ui/screens/tools/GameOverScreen.lua",
	"ironmon_tracker/network/EventHandler.lua",
}) do
	local content = read(path)
	assert(not content:find("GachaMonData", 1, true), path .. " still calls GachaMonData")
	assert(not content:find("GachaMonOverlay", 1, true), path .. " still calls GachaMonOverlay")
	assert(not content:find("GachaMonFileManager", 1, true), path .. " still calls GachaMonFileManager")
	assert(not content:find("AnimationManager", 1, true), path .. " still calls AnimationManager")
end

local gameOptions = read("ironmon_tracker/ui/screens/setup/GameOptionsScreen.lua")
assert(not gameOptions:find('"Determine friendship readiness"', 1, true), "friendship option must not be shown")
local extras = read("ironmon_tracker/ui/screens/setup/ExtrasScreen.lua")
assert(not extras:find('"Display gender"', 1, true), "gender option must not be shown")

local trainerData = read("ironmon_tracker/data/TrainerData.lua")
assert(not trainerData:find('"frlg-"', 1, true), "trainer sprites must not use the frlg- prefix")
assert(not trainerData:find("Wally", 1, true), "Hoenn-only trainer classes must be removed")
assert(not trainerData:find("TeamAquaGrunt", 1, true), "Team Aqua must not remain as a trainer class")
assert(not trainerData:find("hasPostfix", 1, true), "RSE/FRLG sprite postfixes must not remain")

local logOverlay = read("ironmon_tracker/ui/screens/log/LogOverlay.lua")
assert(logOverlay:find("boy-frlg", 1, true), "log overlay must use FRLG player heads")
assert(not logOverlay:find("boy-rs", 1, true), "log overlay must not index RSE player heads")

local trackerScreen = read("ironmon_tracker/ui/screens/combat/TrackerScreen.lua")
assert(trackerScreen:find("usesStarterChoice", 1, true), "Yellow must hide starter favorites and ball picker")
local streamer = read("ironmon_tracker/ui/screens/stream/StreamerScreen.lua")
assert(streamer:find("usesStarterChoice", 1, true), "Yellow must hide favorite-starter picker")

print("Gen 1 removed subsystem smoke tests passed")
