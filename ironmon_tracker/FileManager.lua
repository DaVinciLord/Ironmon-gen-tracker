FileManager = {}

-- Define file separator. Windows is \ and Linux is /
FileManager.slash = package.config:sub(1,1) or "\\"

-- File/Folder names cannot use the characters included in this pattern. These include < > : " / \ | ? *
FileManager.INVALID_FILE_PATTERN = '[%<%>%:%"%/%\\%|%?%*]'

FileManager.Folders = {
	TrackerCode = "ironmon_tracker",
	Custom = "extensions",
	Quickload = "quickload",
	TrackerNotes = "tracker_notes", -- gets created in `FileManager.setupFolders()`
	SavedGames = "saved_games", -- needs to be created first to be used
	BackupSaves = "backup_saves", -- needs to be created first to be used
	DataCode = "data",
	MemoryCode = "memory",
	CoreCode = "core",
	ConstantsCode = "constants",
	UtilsCode = "utils",
	DrawingCode = "drawing",
	LibCode = "lib",
	Network = "network",
	UiCode = "ui",
	WidgetsCode = "ui" .. FileManager.slash .. "widgets",
	ScreensCode = "ui" .. FileManager.slash .. "screens",
	Languages = "Languages",
	RandomizerSettings = "RandomizerSettings",
	GameAddresses = "GameAddresses",
	Images = "images",
	Trainers = "trainers",
	TrainersPortraits = "trainerPortraits",
	Badges = "badges",
	Icons = "icons",
	AnimatedPokemon = "pokemonAnimated",
}

FileManager.Files = {
	SETTINGS = "Settings.ini",
	THEME_PRESETS = "ThemePresets.txt",
	RANDOMIZER_ERROR_LOG = "RandomizerErrorLog.txt",
	TRACKER_CORE = "Ironmon-Tracker.lua",
	UPDATE_OR_INSTALL = "UpdateOrInstall.lua",
	REQUESTS_DATA = "Requests.json", -- Located in the `network` folder
	STREAMERBOT_CODE = FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.Network .. FileManager.slash .. "StreamerbotCodeImport.txt",
	JSON_LIBRARY = FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.LibCode .. FileManager.slash .. "Json.lua",
	OSEXECUTE_OUTPUT = FileManager.Folders.TrackerCode .. FileManager.slash .. "osexecute-output.txt",
	ERROR_LOG = FileManager.Folders.TrackerCode .. FileManager.slash .. "errorlog.txt",
	CRASH_REPORT = FileManager.Folders.TrackerCode .. FileManager.slash .. "crashreport.txt",
	KNOWN_WORKING_DIR = FileManager.Folders.TrackerCode .. FileManager.slash .. "knownworkingdir.txt",
	NEWRUN_PROFILES = FileManager.Folders.TrackerCode .. FileManager.slash .. "NewRunProfiles.json",
	ADDRESS_OVERRIDES = FileManager.Folders.TrackerCode .. FileManager.slash .. FileManager.Folders.GameAddresses .. FileManager.slash .. "TrackerOverrides.json",
	LanguageCode = {
		SpainData = "SpainData.lua",
		ItalyData = "ItalyData.lua",
		FranceData = "FranceData.lua",
		GermanyData = "GermanyData.lua",
		JapanData = "JapanData.lua",
	},
	Other = {
		REPEL = "repelUsage.png",
		ANIMATED_POKEMON = "AnimatedPokemon.gif",
	}
}

FileManager.PreFixes = {}

FileManager.PostFixes = {
	ATTEMPTS_FILE = "Attempts",
	AUTORANDOMIZED = "AutoRandomized",
	PREVIOUSATTEMPT = "PreviousAttempt",
	AUTOSAVE = "AutoSave",
	BACKUPSAVE = "BackupSave",
}

FileManager.Extensions = {
	GB_ROM = ".gb",
	GBC_ROM = ".gbc",
	DEFAULT_ROM = ".gbc",
	RANDOMIZER_LOGFILE = ".log",
	TRACKED_DATA = ".tdat",
	ATTEMPTS = ".txt",
	ANIMATED_POKEMON = ".gif",
	TRAINER = ".png",
	BADGE = ".png",
	BIZHAWK_SAVESTATE = ".State",
	MGBA_SAVESTATE = ".ss0", -- ".ss0" through ".ss9" are okay to use
	LUA_CODE = ".lua",
	TAR_GZ = ".tar.gz",
	PNG = ".png",
}

FileManager.RomExtensions = { "gbc", "gb" }
FileManager.RomExtensionSet = { gb = true, gbc = true }

-- Relative path under ironmon_tracker/ for a screen file: ui/screens/<group>/<file>
function FileManager.screenFile(group, filename)
	return FileManager.Folders.ScreensCode
		.. FileManager.slash .. group
		.. FileManager.slash .. filename
end

function FileManager.widgetFile(filename)
	return FileManager.Folders.WidgetsCode .. FileManager.slash .. filename
end

function FileManager.isRomExtension(extension)
	return FileManager.RomExtensionSet[(extension or ""):lower()] == true
end

function FileManager.findRomPath(pathWithoutExtension)
	for _, extension in ipairs(FileManager.RomExtensions) do
		local candidatePath = pathWithoutExtension .. "." .. extension
		if FileManager.fileExists(candidatePath) then return candidatePath, "." .. extension end
	end
	return nil, nil
end

FileManager.Urls = {
	VERSION = "https://api.github.com/repos/besteon/Ironmon-Tracker/releases/latest",
	DOWNLOAD = "https://github.com/besteon/Ironmon-Tracker/releases/latest",
	WIKI = "https://github.com/besteon/Ironmon-Tracker/wiki",
	DISCUSSIONS = "https://github.com/besteon/Ironmon-Tracker/discussions/389", -- Discussion: "Help us translate the Ironmon Tracker"
	NEW_RUNS = "https://github.com/besteon/Ironmon-Tracker/wiki/New-Runs-Setup",
	EXTENSIONS = "https://github.com/besteon/Ironmon-Tracker/wiki/Tracker-Add-ons#custom-code-extensions",
	STREAM_CONNECT = "https://github.com/besteon/Ironmon-Tracker/wiki/Stream-Connect-Guide",
}

-- All Lua code files used by the Tracker, loaded and initialized in the order listed
FileManager.LuaCode = {
	-- First set of core files
	{ name = "Inifile", filepath = FileManager.Folders.LibCode .. FileManager.slash .. "Inifile.lua", },
	{ name = "Resources", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "Resources.lua", },
	{ name = "Constants", filepath = FileManager.Folders.ConstantsCode .. FileManager.slash .. "Constants.lua", },
	{ name = "TrackerAPI", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "TrackerAPI.lua", },
	{ name = "Utils", filepath = FileManager.Folders.UtilsCode .. FileManager.slash .. "Utils.lua", },
	{ name = "Memory", filepath = FileManager.Folders.MemoryCode .. FileManager.slash .. "Memory.lua", },
	{ name = "GameProfiles", filepath = FileManager.Folders.MemoryCode .. FileManager.slash .. "GameProfiles.lua", },
	{ name = "PokemonDataReader", filepath = FileManager.Folders.MemoryCode .. FileManager.slash .. "PokemonDataReader.lua", },
	{ name = "GameSettings", filepath = FileManager.Folders.MemoryCode .. FileManager.slash .. "GameSettings.lua", },
	{ name = "StructEncoder", filepath = FileManager.Folders.LibCode .. FileManager.slash .. "StructEncoder.lua", },
	-- Data files
	{ name = "PokemonData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "PokemonData.lua", },
	{ name = "SpeciesMap", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "SpeciesMap.lua", },
	{ name = "PokemonRevoData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "PokemonRevoData.lua", },
	{ name = "MoveData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "MoveData.lua", },
	{ name = "DataAdapter", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "DataAdapter.lua", },
	{ name = "MiscData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "MiscData.lua", },
	{ name = "RouteData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "RouteData.lua", },
	{ name = "DataHelper", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "DataHelper.lua", },
	{ name = "EventData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "EventData.lua", },
	{ name = "RandomizerLog", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "RandomizerLog.lua", },
	{ name = "TrainerData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "TrainerData.lua", },
	{ name = "TrainerMapData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "TrainerMapData.lua", },
	{ name = "SpriteData", filepath = FileManager.Folders.DataCode .. FileManager.slash .. "SpriteData.lua", },
	-- Second set of core files
	{ name = "Options", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "Options.lua", },
	{ name = "Drawing", filepath = FileManager.Folders.DrawingCode .. FileManager.slash .. "Drawing.lua", },
	{ name = "ExternalUI", filepath = FileManager.Folders.DrawingCode .. FileManager.slash .. "ExternalUI.lua", },
	{ name = "Theme", filepath = FileManager.Folders.DrawingCode .. FileManager.slash .. "Theme.lua", },
	{ name = "ColorPicker", filepath = FileManager.Folders.DrawingCode .. FileManager.slash .. "ColorPicker.lua", },
	{ name = "Program", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "Program.lua", },
	{ name = "Input", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "Input.lua", },
	{ name = "Battle", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "Battle.lua", },
	{ name = "Pickle", filepath = FileManager.Folders.LibCode .. FileManager.slash .. "Pickle.lua", },
	{ name = "Tracker", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "Tracker.lua", },
	-- Network files
	{ name = "Network", filepath = FileManager.Folders.Network .. FileManager.slash .. "Network.lua", },
	{ name = "EventHandler", filepath = FileManager.Folders.Network .. FileManager.slash .. "EventHandler.lua", },
	{ name = "RequestHandler", filepath = FileManager.Folders.Network .. FileManager.slash .. "RequestHandler.lua", },
	-- UI widgets (layout kit; screens still draw with Besteon APIs)
	{ name = "Layout", filepath = FileManager.widgetFile("Layout.lua"), },
	{ name = "Box", filepath = FileManager.widgetFile("Box.lua"), },
	{ name = "Component", filepath = FileManager.widgetFile("Component.lua"), },
	{ name = "Frame", filepath = FileManager.widgetFile("Frame.lua"), },
	-- Screen files (ui/screens/<role>/)
	{ name = "TrackerScreenLayout", filepath = FileManager.screenFile("combat", "TrackerScreenLayout.lua"), },
	{ name = "TrackerScreen", filepath = FileManager.screenFile("combat", "TrackerScreen.lua"), },
	{ name = "InfoScreen", filepath = FileManager.screenFile("combat", "InfoScreen.lua"), },
	{ name = "TrainerInfoScreen", filepath = FileManager.screenFile("combat", "TrainerInfoScreen.lua"), },
	{ name = "TrainersOnRouteScreen", filepath = FileManager.screenFile("combat", "TrainersOnRouteScreen.lua"), },
	{ name = "NavigationMenu", filepath = FileManager.screenFile("setup", "NavigationMenu.lua"), },
	{ name = "StartupScreen", filepath = FileManager.screenFile("setup", "StartupScreen.lua"), },
	{ name = "UpdateScreen", filepath = FileManager.screenFile("setup", "UpdateScreen.lua"), },
	{ name = "SetupScreen", filepath = FileManager.screenFile("setup", "SetupScreen.lua"), },
	{ name = "ExtrasScreen", filepath = FileManager.screenFile("setup", "ExtrasScreen.lua"), },
	{ name = "QuickloadScreen", filepath = FileManager.screenFile("setup", "QuickloadScreen.lua"), },
	{ name = "GameOptionsScreen", filepath = FileManager.screenFile("setup", "GameOptionsScreen.lua"), },
	{ name = "NotebookIndexScreen", filepath = FileManager.screenFile("notebook", "NotebookIndexScreen.lua"), },
	{ name = "NotebookPokemonSeen", filepath = FileManager.screenFile("notebook", "NotebookPokemonSeen.lua"), },
	{ name = "NotebookPokemonNoteView", filepath = FileManager.screenFile("notebook", "NotebookPokemonNoteView.lua"), },
	{ name = "NotebookTrainersByArea", filepath = FileManager.screenFile("notebook", "NotebookTrainersByArea.lua"), },
	{ name = "TrackedDataScreen", filepath = FileManager.screenFile("notebook", "TrackedDataScreen.lua"), },
	{ name = "LanguageScreen", filepath = FileManager.screenFile("setup", "LanguageScreen.lua"), },
	{ name = "StatsScreen", filepath = FileManager.screenFile("notebook", "StatsScreen.lua"), },
	{ name = "RandomEvosScreen", filepath = FileManager.screenFile("combat", "RandomEvosScreen.lua"), },
	{ name = "MoveHistoryScreen", filepath = FileManager.screenFile("notebook", "MoveHistoryScreen.lua"), },
	{ name = "CatchRatesScreen", filepath = FileManager.screenFile("tools", "CatchRatesScreen.lua"), },
	{ name = "TypeDefensesScreen", filepath = FileManager.screenFile("combat", "TypeDefensesScreen.lua"), },
	{ name = "HealsInBagScreen", filepath = FileManager.screenFile("tools", "HealsInBagScreen.lua"), },
	{ name = "BattleDetailsScreen", filepath = FileManager.screenFile("combat", "BattleDetailsScreen.lua"), },
	{ name = "GameOverScreen", filepath = FileManager.screenFile("tools", "GameOverScreen.lua"), },
	{ name = "StatMarkingScoreSheet", filepath = FileManager.screenFile("combat", "StatMarkingScoreSheet.lua"), },
	{ name = "StreamerScreen", filepath = FileManager.screenFile("stream", "StreamerScreen.lua"), },
	{ name = "TimeMachineScreen", filepath = FileManager.screenFile("tools", "TimeMachineScreen.lua"), },
	{ name = "CustomExtensionsScreen", filepath = FileManager.screenFile("extensions", "CustomExtensionsScreen.lua"), },
	{ name = "SingleExtensionScreen", filepath = FileManager.screenFile("extensions", "SingleExtensionScreen.lua"), },
	{ name = "ViewLogWarningScreen", filepath = FileManager.screenFile("log", "ViewLogWarningScreen.lua"), },
	{ name = "CrashRecoveryScreen", filepath = FileManager.screenFile("tools", "CrashRecoveryScreen.lua"), },
	{ name = "CoverageCalcScreen", filepath = FileManager.screenFile("tools", "CoverageCalcScreen.lua"), },
	{ name = "LogOverlay", filepath = FileManager.screenFile("log", "LogOverlay.lua"), },
	{ name = "LogTabPokemon", filepath = FileManager.screenFile("log", "LogTabPokemon.lua"), },
	{ name = "LogTabPokemonDetails", filepath = FileManager.screenFile("log", "LogTabPokemonDetails.lua"), },
	{ name = "LogTabTrainers", filepath = FileManager.screenFile("log", "LogTabTrainers.lua"), },
	{ name = "LogTabTrainerDetails", filepath = FileManager.screenFile("log", "LogTabTrainerDetails.lua"), },
	{ name = "LogTabRoutes", filepath = FileManager.screenFile("log", "LogTabRoutes.lua"), },
	{ name = "LogTabRouteDetails", filepath = FileManager.screenFile("log", "LogTabRouteDetails.lua"), },
	{ name = "LogTabTMs", filepath = FileManager.screenFile("log", "LogTabTMs.lua"), },
	{ name = "LogTabMisc", filepath = FileManager.screenFile("log", "LogTabMisc.lua"), },
	{ name = "TeamViewArea", filepath = FileManager.screenFile("overlay", "TeamViewArea.lua"), },
	{ name = "LogSearchScreen", filepath = FileManager.screenFile("log", "LogSearchScreen.lua"), },
	{ name = "StreamConnectOverlay", filepath = FileManager.screenFile("stream", "StreamConnectOverlay.lua"), },
	-- Miscellaneous files
	{ name = "CustomCode", filepath = FileManager.Folders.CoreCode .. FileManager.slash .. "CustomCode.lua", },
}

-- Data files that can be loaded at runtime when needed (they aren't available until loaded)
-- The table key is the versioncolor, and the value is a table of data key labels and their filepaths
FileManager.LuaData = {
	All = {},
}

-- Some files are initialized early and don't need to be re-intialized again
FileManager.ExcludeFromInitialize = {
	["UpdateOrInstall"] = true,
	["Main"] = true,
	["FileManager"] = true,
	["Resources"] = true,
	["CustomCode"] = true,
	["GameSettings"] = true,
	["Memory"] = true,
}

function FileManager.setupFolders()
	local foldersToCheck = {
		FileManager.getTdatFolderPath(),
	}
	for _, folder in ipairs(foldersToCheck) do
		if not FileManager.folderExists(folder) then
			FileManager.createFolder(folder)
		end
	end
end

-- Returns true if a file exists at its absolute file path; false otherwise
function FileManager.fileExists(filepath)
	return FileManager.getPathIfExists(filepath) ~= nil
end

function FileManager.folderExists(folderpath)
	if folderpath == nil then return false end
	folderpath = FileManager.tryAppendSlash(folderpath)

	-- Hacky but simply way to check if a folder exists: try to rename it
	-- The "code" return value only exists in Lua 5.2+, but not required to use here
	local exists, err, code = os.rename(folderpath, folderpath)
	-- Code 13 = Permission denied, but it exists
	if exists or (not exists and code == 13) then
		return true
	end

	-- Otherwise check the absolute path of the file
	folderpath = FileManager.prependDir(folderpath)
	exists, err, code = os.rename(folderpath, folderpath)
	if exists or (not exists and code == 13) then
		return true
	end

	return false
end

-- Linux (and NLua/BizHawk) can io.open() a directory. That must not count as a file,
-- or later dofile() throws: "cannot read ironmon_tracker/: est un dossier".
local function canOpenAsFile(path)
	local openOk, file = pcall(io.open, path, "r")
	if not openOk or file == nil then
		return false
	end
	local readOk, _, readErr = pcall(function()
		return file:read(1)
	end)
	pcall(function() io.close(file) end)
	-- Directories: read returns nil + "Is a directory" / "est un dossier".
	-- Empty files: read returns nil with no error and are still valid files.
	return readOk and readErr == nil
end

-- Returns the path that allows opening a file at 'filepath', if one exists and it can be opened; otherwise, returns nil
---@return string|nil filepath
function FileManager.getPathIfExists(filepath)
	filepath = string.match(filepath or "", "^%s*(.-)%s*$") -- remove leading/trailing spaces

	-- Empty filepaths "" can be opened successfully on Linux, as directories are considered files
	if filepath == "" then return nil end
	local lastChar = filepath:sub(-1)
	if lastChar == "/" or lastChar == "\\" then return nil end

	if canOpenAsFile(filepath) then
		return filepath
	end

	-- Otherwise check the absolute path of the file
	filepath = FileManager.prependDir(filepath)
	if canOpenAsFile(filepath) then
		return filepath
	end

	return nil
end

---Returns the absolute file path using a local filename/path and the working directory of the Tracker
---@param filenameOrPath string
---@param includeTrailingSlash? boolean (Optional) If true, appends the system's path separator (slash)
---@return string
function FileManager.prependDir(filenameOrPath, includeTrailingSlash)
	local suffix = includeTrailingSlash and FileManager.slash or ""
	return FileManager.dir .. (filenameOrPath or "") .. suffix
end

-- An absolute path working directory is required for Bizhawk (Windows or Linux)
function FileManager.setupWorkingDirectory()
	FileManager.dir = ""
	local dir = tostring(IronmonTracker.workingDir or "")

	-- First check if the working directory has been looked up before
	local knownDirPath = FileManager.Files.KNOWN_WORKING_DIR
	local knownDirFile = io.open(knownDirPath, "r")
	-- If the file doesn't exist, try another path
	if knownDirFile == nil then
		knownDirPath = dir .. knownDirPath
		knownDirFile = io.open(knownDirPath, "r")
	end

	-- If the working directory is known (used in the past), then load that instead of running an os execute
	if knownDirFile ~= nil then
		dir = knownDirFile:read("*a") or ""
		knownDirFile:close()
		dir = tostring(dir:gsub("^%s*(.-)%s*$", "%1"))
		-- Then verify that this saved working directory is correct and usable (user might have moved files/folders)
		if not FileManager.fileExists(dir .. FileManager.Files.TRACKER_CORE) then
			dir = ""
		end
	end

	-- Properly format the path
	local function formatPath(filepath)
		filepath = FileManager.formatPathForOS(filepath)
		filepath = FileManager.tryAppendSlash(filepath)
		-- Linux Bizhawk 2.8 doesn't support popen or working dir absolute path
		if Main.emulator == Main.EMU.BIZHAWK28 and filepath == FileManager.slash then
			filepath = ""
		end
		return filepath
	end

	-- Otherwise, if no known working directory was found, look it up the hard way
	if knownDirFile == nil or dir == "" then
		-- For Bizhawk, use luaconsole script list as a quick backup solution
		if Main.IsOnBizhawk() then
			local pathCheckFile = io.open(dir .. FileManager.Files.TRACKER_CORE, "r")
			if pathCheckFile then
				pathCheckFile:close()
			else
				local luaconsole = client.gettool("luaconsole")
				local luaImp = luaconsole and luaconsole.get_LuaImp()
				local scriptList = luaImp and luaImp.ScriptList or { Count = 0 }
				for i = 0, scriptList.Count - 1, 1 do
					local scriptPath = scriptList[i].Path or scriptList[i].path or ""
					local index = scriptPath:find(FileManager.Files.TRACKER_CORE, 1, true)
					if index then
						dir = scriptPath:sub(1, index - 1)
						break
					end
				end
				dir = formatPath(dir)
			end
		end
		-- If still can't find the filepath, use a command to get it
		if dir == "" then
			-- Windows: "cd", Linux: "pwd"
			local getDirCommand = FileManager.slash == "\\" and "cd" or "pwd"
			-- Bizhawk handles current working directory differently, this is the only way to get it
			local success, fileLines = FileManager.tryOsExecute(getDirCommand)
			if success and #fileLines > 0 and Main.IsOnBizhawk() then
				dir = fileLines[1]
			end
			dir = formatPath(dir)
		end

		-- Save known working directory to file to load for future startups
		if dir ~= "" then
			knownDirFile = io.open(knownDirPath, "w")
			if knownDirFile then
				knownDirFile:write(dir)
				knownDirFile:flush()
				knownDirFile:close()
			end
		end
	end

	-- The current known working directory of the Tracker
	FileManager.dir = dir
	IronmonTracker.workingDir = dir
end

-- Attempts to execute the command, returning two results: success, outputTable
function FileManager.tryOsExecute(command, errorFile)
	local tempOutputFile = FileManager.prependDir(FileManager.Files.OSEXECUTE_OUTPUT)
	local commandWithOutput = string.format('%s >"%s"', command, tempOutputFile)
	if errorFile ~= nil then
		commandWithOutput = string.format('%s 2>"%s"', commandWithOutput, errorFile)
	end

	-- An attempted fix to allow non-english characters in paths; but this is only half of it, so it's incomplete.
	-- Leaving this here in case some more research is done to figure out how to work around this.
	-- local foreignCompatibleCommand = "@chcp 65001>nul && " .. commandWithOutput

	local result = os.execute(commandWithOutput)
	local success = (result == true or result == 0) -- 0 = success in some cases
	if not success then
		return success, {}
	end
	return success, FileManager.readLinesFromFile(tempOutputFile)
end

-- Attempts to load a file as Lua code. Returns true if successful; false otherwise.
function FileManager.loadLuaFile(filename, silenceErrors)
	-- First try and load the file from the folder that contains most/all the Tracker lua code
	local filepath = FileManager.getPathIfExists(FileManager.Folders.TrackerCode .. FileManager.slash .. filename)
	if filepath ~= nil then
		dofile(filepath)
		return true
	end

	-- Otherwise, check if the file exists on the root Tracker folder (UpdateOrInstall.lua lives here)
	filepath = FileManager.getPathIfExists(filename)
	if filepath ~= nil then
		dofile(filepath)
		return true
	end

	if not silenceErrors then
		print("Unable to load " .. filename .. "\nMake sure all of the downloaded Tracker's files are still together.")
		Main.DisplayError("Unable to load " .. filename .. "\n\nMake sure all of the downloaded Tracker's files are still together.")
	end

	return false
end

---Loads a known data file and returns the result.
---@param gameKey string Ruby, Sapphire, Emerald, FireRed, LeafGreen, or All
---@param dataKey string The key label for the data file to load
---@return any|nil
function FileManager.loadLuaData(gameKey, dataKey)
	local gameDataTable = FileManager.LuaData[gameKey or false] or {}
	local dataFilepath = gameDataTable[dataKey or false] or ""
	-- Gen 1 versioncolors (Red/Blue/Yellow) have no GBA trainer-route tables.
	-- An empty relative path would resolve to the `ironmon_tracker/` folder.
	if dataFilepath == "" then
		return nil
	end

	local filepath = FileManager.getPathIfExists(FileManager.Folders.TrackerCode .. FileManager.slash .. dataFilepath)
	if not filepath then
		return nil
	end

	return dofile(filepath)
end

---Executes 'functionName' for all loaded code files.
---@param functionName string The name of the function to execute
---@param excludeFileNames? table<string, boolean> (Optional) A set of file names to exclude from having the function executed
function FileManager.executeEachFile(functionName, excludeFileNames)
	excludeFileNames = excludeFileNames or {}
	local globalRef
	if Main.emulator == Main.EMU.BIZHAWK28 then
		globalRef = _G -- Lua 5.1 only
	else
		---@diagnostic disable-next-line: undefined-global
		globalRef = _ENV -- Lua 5.4
	end

	for _, luafile in ipairs(FileManager.LuaCode) do
		local luaFilename = luafile.name or ""
		if not excludeFileNames[luaFilename] then
			local luaObject = globalRef[luaFilename] or {}
			local luaFunction = luaObject[functionName]
			if type(luaFunction) == "function" then
				luaFunction()
			end
		end
	end
end

---Removes the system's path separator (slash) from the end of the path, or returns the path unchanged
---@param path string
---@return string
function FileManager.trimSlash(path)
	if (path or "") == "" or not path:find("[/\\]$") then
		return path
	end
	return path:sub(1, -2)
end

---Appends the system's path separator (slash) to the path if it's not already present
---@param path string
---@return string
function FileManager.tryAppendSlash(path)
	if (path or "") == "" or path:find("[/\\]$") then
		return path
	end
	return path .. FileManager.slash
end

-- Returns a properly formatted path that contains only the correct path-separators based on the OS
function FileManager.formatPathForOS(path)
	path = path or ""
	if FileManager.slash == "/" then
		path = path:gsub("\\", "/")
	else
		path = path:gsub("/", "\\")
	end
	return path
end

-- Returns true if it creates the folder, false if it already exists (I think)
function FileManager.createFolder(folderpath)
	if folderpath == nil then return end
	folderpath = FileManager.trimSlash(folderpath)
	local command
	if Main.OS == "Windows" then
		command = string.format('mkdir "%s"', folderpath)
	else
		command = string.format('mkdir -p "%s"', folderpath)
	end
	return FileManager.tryOsExecute(command)
end

-- Returns a list of file names found in a given folder
function FileManager.getFilesFromDirectory(folderpath)
	local files = {}

	-- Not supported on Linux Bizhawk 2.8, Lua 5.1
	if folderpath == nil or (Main.OS ~= "Windows" and Main.emulator == Main.EMU.BIZHAWK28) then
		return files
	end

	local scanDirCommand
	if Main.OS == "Windows" then
		scanDirCommand = string.format('dir "%s" /b', folderpath)
	else
		-- Note: "-A" removes "." and ".." from the listing
		scanDirCommand = string.format('ls -A "%s"', folderpath)
	end
	local success, fileLines = FileManager.tryOsExecute(scanDirCommand)
	if success then
		for _, filename in ipairs(fileLines) do
			table.insert(files, filename)
		end
	end

	return files
end

-- Erases the contents of the ERROR_LOG and adds a header for diagnostics
function FileManager.setupErrorLog()
	FileManager.ErrorsLogged = {}

	local file = io.open(FileManager.prependDir(FileManager.Files.ERROR_LOG), "w")
	if file ~= nil then
		-- Diagnostics information
		local version = string.format("Tracker Version: %s", Main.TrackerVersion or "N/A")
		local gamerom = string.format("Rom Name: %s", GameSettings.getRomName() or "N/A")
		local gamename = string.format("Game: %s", GameSettings.gamename or "N/A")
		local date = string.format("Date: %s", os.date())
		local divider = string.rep("-", 30)
		file:write(version .. "\n")
		file:write(gamerom .. "\n")
		file:write(gamename .. "\n")
		file:write(date .. "\n")
		file:write(divider .. "\n\n")

		file:flush()
		file:close()
	end
end

-- Logs a message to the ERROR_LOG file
function FileManager.logError(errorMessage)
	errorMessage = errorMessage or "(No error message.)"
	local fullErrorMsg = string.format("%s\n%s\n\n", errorMessage, debug.traceback() or "Stack Trace N/A")
	if not FileManager.ErrorsLogged[fullErrorMsg] then
		FileManager.ErrorsLogged[fullErrorMsg] = true

		-- Only print to user the first part of the error, that describes what went wrong; less overall clutter
		print(errorMessage)

		-- And print the full error and its stack trace in the log file
		local file = io.open(FileManager.prependDir(FileManager.Files.ERROR_LOG), "a")
		if file ~= nil then
			local currentTime = os.date("[%H:%M]")
			file:write(string.format("%s %s", currentTime, fullErrorMsg))
			file:flush()
			file:close()
		end
	end
end

---Checks if there is an override available and returns that path; or nil if no override exists
---@param key string A table key for Options.Overrides
---@return string|nil folderpath Path includes trailing slash
function FileManager.getPathOverride(key)
	local folderpath = Options.Overrides[key or false] or ""
	if Utils.isNilOrEmpty(folderpath) then
		return nil
	end
	return FileManager.tryAppendSlash(folderpath)
end

---Returns the filepath of the currently loaded ROM. Note: Only works for Bizhawk emulator
---@return string|nil filepath
function FileManager.getLoadedRomPath()
	if not Main.IsOnBizhawk() then
		return nil
	end
	local luaconsole = client.gettool("luaconsole")
	local luaImp = luaconsole and luaconsole.get_LuaImp()
	local filepath = luaImp and luaImp.PathEntries and luaImp.PathEntries.LastRomPath or ""
	if filepath ~= "" then
		return filepath
	end
	return nil
end

---@return string folderpath
function FileManager.getTdatFolderPath()
	return FileManager.getPathOverride("Tracker Data") or FileManager.prependDir(FileManager.Folders.TrackerNotes, true)
end

---@return string folderpath
---@return string filepath
function FileManager.buildImagePath(imageFolder, imageName, imageExtension)
	local listOfPaths = {
		FileManager.Folders.TrackerCode,
		FileManager.Folders.Images,
		tostring(imageFolder),
		tostring(imageName) .. (imageExtension or "")
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

---@return string filepath
function FileManager.buildSpritePath(animationType, imageName, imageExtension)
	local imageFolder = Options.getIconSet().folder
	local listOfPaths = {
		FileManager.Folders.TrackerCode,
		FileManager.Folders.Images,
		imageFolder,
		tostring(animationType),
		tostring(imageName) .. (imageExtension or "")
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

---Returns a properly formatted folder path where randomizer settings files are located; includes trailing slash
---@return string folderpath
function FileManager.getRandomizerSettingsPath()
	local listOfPaths = {
		FileManager.Folders.TrackerCode,
		FileManager.Folders.RandomizerSettings,
		"", -- Necessary to include a trailing slash, helps with appending a filename
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

---Returns a properly formatted folder path where network files are located; includes trailing slash
---@return string folderpath
function FileManager.getNetworkPath()
	local listOfPaths = {
		FileManager.Folders.TrackerCode,
		FileManager.Folders.Network,
		"", -- Necessary to include a trailing slash, helps with appending a filename
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

---Returns a properly formatted folder path where extensions code files are located; includes trailing slash.
---@return string folderpath
function FileManager.getExtensionsFolderPath()
	local listOfPaths = {
		FileManager.Folders.Custom,
		"", -- Necessary to include a trailing slash, helps with appending a filename
	}
	return FileManager.prependDir(table.concat(listOfPaths, FileManager.slash))
end

---Returns a properly formatted folder path where custom code files are located; includes trailing slash
---Note: this is a redudant/duplicate function of `FileManager.getExtensionsFolderPath()`, for convenience
---@return string folderpath
function FileManager.getCustomFolderPath()
	return FileManager.getExtensionsFolderPath()
end

---Returns a fully built URL for the tar archive to be downloaded for a Github release
---@param githubRepoUrl string
---@param branchName? string Optional, defaults to the `main` branch
---@return string url Example: https://github.com/besteon/Ironmon-Tracker/archive/main.tar.gz
function FileManager.getTarDownloadUrl(githubRepoUrl, branchName)
	githubRepoUrl = FileManager.trimSlash(githubRepoUrl or "")
	branchName = (branchName or CustomCode.DefaultBranch):lower()
	local tarEnding
	if branchName == CustomCode.DefaultBranch then
		tarEnding = string.format("/archive/%s%s", CustomCode.DefaultBranch, FileManager.Extensions.TAR_GZ)
	else
		branchName = Utils.replaceText(branchName, " ", "-")
		tarEnding = string.format("/archive/refs/heads/%s%s", branchName, FileManager.Extensions.TAR_GZ)
	end
	return githubRepoUrl .. tarEnding
end

---Returns the archive name for the tar archive that would be downloaded for a Github release
---Note: Append .tar.gz for the unextracted filename of the downloaded file
---@param githubRepoUrl string
---@param branchName? string Optional, defaults to the `main` branch
---@return string filename Example: Ironmon-Tracker-main
function FileManager.getTarDownloadArchiveName(githubRepoUrl, branchName)
	githubRepoUrl = FileManager.trimSlash(githubRepoUrl or "")
	branchName = (branchName or CustomCode.DefaultBranch):lower()
	local repoName = FileManager.extractFolderNameFromPath(githubRepoUrl)
	repoName = Utils.replaceText(repoName, " ", "-")
	branchName = Utils.replaceText(branchName, " ", "-")
	return string.format("%s-%s", repoName, branchName)
end

---@param path string
---@return string
function FileManager.extractFolderNameFromPath(path)
	if path == nil or path == "" then return "" end

	path = FileManager.trimSlash(path)

	local folderStartIndex = path:match("^.*()[\\/]") -- path to folder
	if folderStartIndex ~= nil then
		local foldername = path:sub(folderStartIndex + 1)
		if foldername ~= nil then
			return foldername
		end
	end

	return ""
end

---@param path string
---@param includeExtension? boolean Optional, includes the file extension; default: false
---@return string
function FileManager.extractFileNameFromPath(path, includeExtension)
	if path == nil or path == "" then return "" end

	local _, filename, extension = FileManager.getPathParts(path)
	if includeExtension and filename then
		return filename .. (extension or "")
	else
		return filename or ""
	end
end

---@param path string
---@return string
function FileManager.extractFileExtensionFromPath(path)
	if path == nil or path == "" then return "" end

	local _, _, extension = FileManager.getPathParts(path)
	if extension and #extension > 1 then
		return extension:sub(2) -- remove the leading '.'
	else
		return ""
	end
end

--- Returns the folder, filename, and extension for the given filepath
--- @param filepath string The full file path to split apart
--- @return string folder, string filename, string extension
function FileManager.getPathParts(filepath)
	return string.match(filepath or "", "^(.-)([^\\/]-)(%.[^\\/%.]-)%.?$")
end

-- Copies file at 'filepath' to 'filecopyPath' with option to overwrite the file if it exists, or append to it
-- overwriteOrAppend: 'overwrite' replaces any existing file, 'append' adds to it instead, otherwise no change if file already exists
function FileManager.CopyFile(filepath, filepathCopy, overwriteOrAppend)
	if filepath == nil or filepath == "" then
		return false
	end

	local originalFile = io.open(filepath, "rb")
	if originalFile == nil then
		-- The originalFile to copy doesn't exist, simply do nothing and don't copy
		return false
	end

	-- filecopyPath = filecopyPath or (filepath .. " (Copy)") -- TODO: Fix this later, currently unused

	-- If the file exists but the option to overwrite/append was not specified, avoid altering the file
	if FileManager.fileExists(filepathCopy) and not (overwriteOrAppend == "overwrite" or overwriteOrAppend == "append") then
		-- print(string.format('Error: Unable to modify file "%s", no overwrite/append option specified.', filepathCopy))
		return false
	end

	local copyOfFile
	if overwriteOrAppend == "append" then
		copyOfFile = io.open(filepathCopy, "ab")
	else
		-- Default to overwriting the file even if no option specified
		copyOfFile = io.open(filepathCopy, "wb")
	end

	if copyOfFile == nil then
		print(string.format('Error: Failed to write to file "%s"', filepathCopy))
		return false
	end

	if overwriteOrAppend == "append" then
		copyOfFile:seek("end")
	end

	local nextBlock = originalFile:read(2^13)
	while nextBlock ~= nil do
		copyOfFile:write(nextBlock)
		nextBlock = originalFile:read(2^13)
	end

	originalFile:close()
	copyOfFile:close()

	return true
end

function FileManager.deleteFile(filepath)
	if (filepath or "") == "" then
		return false
	end
	pcall(function()
		os.remove(filepath)
	end)
end

---Writes the contents of `table` to the file at `filepath`
---@param table table
---@param filepath string
function FileManager.writeTableToFile(table, filepath)
	if type(table) ~= "table" or (filepath or "") == "" then
		return
	end
	local file = io.open(filepath, "w")
	if not file then
		return
	end
	local dataString = Pickle.pickle(table)
	--append a trailing \n if one is absent
	if dataString:sub(-1) ~= "\n" then
		dataString = dataString .. "\n"
	end
	for dataLine in dataString:gmatch("(.-)\n") do
		file:write(dataLine .. "\n")
	end
	file:flush()
	file:close()
end

---Returns the contents of the file at `filepath` as a luatable
---@param filepath string
---@return table|nil
function FileManager.readTableFromFile(filepath)
	if (filepath or "") == "" then
		return nil
	end
	local file = io.open(filepath, "r")
	if not file then
		return nil
	end

	local dataString = file:read("*a")
	file:close()
	if (dataString or "") == "" then
		return nil
	end
	return Pickle.unpickle(dataString)
end

-- Returns a table that contains an entry for each line from a filename/filepath
function FileManager.readLinesFromFile(filename)
	local lines = {}

	local filepath = FileManager.getPathIfExists(filename)
	if filepath == nil then
		return lines
	end

	local file = io.open(filepath, "r")
	if file == nil then
		return lines
	end

	local fileContents = file:read("*a")
	if fileContents ~= nil and fileContents ~= "" then
		for line in fileContents:gmatch("([^\r\n]+)[\r\n]*") do
			if line ~= nil then
				table.insert(lines, line)
			end
		end
	end
	file:close()

	return lines
end

--- Returns true if data is written to file, false if resulting json is empty, or nil if no file
---@param filepath string
---@param data table
---@return boolean|nil dataWritten
function FileManager.encodeToJsonFile(filepath, data)
	local file = filepath and io.open(filepath, "w")
	if not file then
		return nil
	end
	if not FileManager.JsonLibrary then
		return false
	end
	-- Empty Json is "[]"
	local output = "[]"
	pcall(function()
		output = FileManager.JsonLibrary.encode(data) or "[]"
	end)
	file:write(output)
	file:close()
	return (#output > 2)
end

--- Returns a lua table of the decoded json string from a file, or nil if no file
---@param filepath string
---@return table|nil data
function FileManager.decodeJsonFile(filepath)
	local file = filepath and io.open(filepath, "r")
	if not file then
		return nil
	end
	if not FileManager.JsonLibrary then
		return {}
	end
	local input = file:read("*a") or ""
	file:close()
	local decodedTable = {}
	if #input > 0 then
		pcall(function()
			decodedTable = FileManager.JsonLibrary.decode(input) or {}
		end)
	end
	return decodedTable
end

function FileManager.addCustomThemeToFile(themeName, themeCode)
	if themeName == nil or themeCode == nil then
		return
	end

	local folderpath = FileManager.getPathOverride("Theme Presets") or FileManager.dir
	local filepath = folderpath .. FileManager.Files.THEME_PRESETS
	local file = io.open(filepath, "a")
	if not file then
		return
	end

	file:write(string.format("%s %s\n", themeName, themeCode))
	file:close()
end

-- Removes a saved Theme preset by rewriting the file with all presets, but excluding the one that is being removed
function FileManager.removeCustomThemeFromFile(themeName, themeCode)
	local folderpath = FileManager.getPathOverride("Theme Presets") or FileManager.dir
	local filepath = folderpath .. FileManager.Files.THEME_PRESETS

	if themeName == nil or themeCode == nil or not FileManager.fileExists(filepath) then
		return false
	end

	local existingThemePresets = FileManager.readLinesFromFile(filepath)

	local file = io.open(filepath, "w")
	if not file then
		return false
	end

	for index, line in ipairs(existingThemePresets) do
		local firstHexIndex = line:find("%x%x%x%x%x%x")
		if firstHexIndex ~= nil then
			local themeLineCode = line:sub(firstHexIndex)
			local themeLineName
			if firstHexIndex <= 2 then
				themeLineName = "Untitled " .. index
			else
				themeLineName = line:sub(1, firstHexIndex - 2)
			end

			if themeLineName ~= themeName and themeLineCode ~= themeCode then
				file:write(line .. "\n")
			end
		end
	end
	file:close()

	return true
end

---Recursively copies the contents of 'source' table into 'destination' table
---@param source table
---@param destination? table Optional, creates a new empty table if none provided
---@return table destination
function FileManager.copyTable(source, destination)
	destination = destination or {}
	for key, val in pairs(source or {}) do
		if type(val) == "table" then
			destination[key] = {}
			FileManager.copyTable(val, destination[key])
		else
			destination[key] = val
		end
	end
	return destination
end

--- Loads the external Json library into FileManager.JsonLibrary
function FileManager.setupJsonLibrary()
	if type(FileManager.JsonLibrary) == "table" then
		return
	end
	local filepath = FileManager.getPathIfExists(FileManager.Files.JSON_LIBRARY)
	if filepath ~= nil then
		FileManager.JsonLibrary = dofile(filepath)
		if type(FileManager.JsonLibrary) ~= "table" then
			FileManager.JsonLibrary = nil
		end
	end
end
