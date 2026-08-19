-- Reproduces BizHawk/NLua: dofile("ironmon_tracker/") when a Gen 1 version
-- has no GBA trainer-route data file. On Linux, io.open of a directory can
-- succeed, then dofile throws "cannot read ironmon_tracker/: est un dossier".
-- Run from any directory with: lua tools/gen1_lua_data_load_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")
if repoRoot == "" then repoRoot = "./" end
if not repoRoot:match("[/\\]$") then repoRoot = repoRoot .. "/" end

Main = { DisplayError = function() end }
dofile(repoRoot .. "ironmon_tracker/FileManager.lua")
FileManager.dir = repoRoot

local trackerFolder = FileManager.Folders.TrackerCode .. FileManager.slash
assert(FileManager.getPathIfExists(trackerFolder) == nil,
	"getPathIfExists must reject the tracker folder as a file")

local ok, result = pcall(FileManager.loadLuaData, "Yellow", "TrainerRoutes")
assert(ok, "loadLuaData(Yellow) must not throw: " .. tostring(result))
assert(result == nil, "Gen 1 Yellow has no GBA trainer-route Lua data")

ok, result = pcall(FileManager.loadLuaData, "Red", "TrainerRoutes")
assert(ok, "loadLuaData(Red) must not throw: " .. tostring(result))
assert(result == nil)

ok, result = pcall(FileManager.loadLuaData, "Blue", "TrainerRoutes")
assert(ok, "loadLuaData(Blue) must not throw: " .. tostring(result))
assert(result == nil)

GameSettings = { versioncolor = "Yellow" }
dofile(repoRoot .. "ironmon_tracker/data/TrainerMapData.lua")
Main.IsOnBizhawk = function() return true end
ok, result = pcall(TrainerMapData.buildData)
assert(ok, "TrainerMapData.buildData must not throw on Gen 1: " .. tostring(result))
assert(type(TrainerMapData.Routes) == "table")
assert(next(TrainerMapData.Routes) == nil, "Gen 1 trainer map routes stay empty")

print("Gen 1 lua data load smoke tests passed")
