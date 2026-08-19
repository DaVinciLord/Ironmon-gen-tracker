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
	"ironmon_tracker/Program.lua",
	"ironmon_tracker/Battle.lua",
	"ironmon_tracker/Input.lua",
	"ironmon_tracker/Tracker.lua",
	"ironmon_tracker/TrackerAPI.lua",
	"ironmon_tracker/screens/TrackerScreen.lua",
	"ironmon_tracker/screens/SetupScreen.lua",
	"ironmon_tracker/screens/ExtrasScreen.lua",
	"ironmon_tracker/screens/QuickloadScreen.lua",
	"ironmon_tracker/screens/GameOverScreen.lua",
	"ironmon_tracker/network/EventHandler.lua",
}) do
	local content = read(path)
	assert(not content:find("GachaMonData", 1, true), path .. " still calls GachaMonData")
	assert(not content:find("GachaMonOverlay", 1, true), path .. " still calls GachaMonOverlay")
	assert(not content:find("GachaMonFileManager", 1, true), path .. " still calls GachaMonFileManager")
	assert(not content:find("AnimationManager", 1, true), path .. " still calls AnimationManager")
end

print("Gen 1 removed subsystem smoke tests passed")
