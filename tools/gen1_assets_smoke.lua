local function listDir(path)
	local handle = assert(io.popen('ls -1 "' .. path .. '"', "r"))
	local names = {}
	for line in handle:lines() do
		if line ~= "" then
			table.insert(names, line)
		end
	end
	handle:close()
	return names
end

local function numberedId(filename)
	local stem = filename:match("^(.*)%.[^%.]+$") or filename
	return tonumber(stem)
end

local function fileExists(path)
	local file = io.open(path, "r")
	if file then
		file:close()
		return true
	end
	return false
end

local function isKeptPokemonId(id)
	return id == 0 or (id >= 1 and id <= 151) or id == 412 or id == 413
end

local staticPacks = {
	{ dir = "ironmon_tracker/images/pokemon", ext = ".gif" },
	{ dir = "ironmon_tracker/images/pokemonStadium", ext = ".png" },
	{ dir = "ironmon_tracker/images/pokemonUpdated", ext = ".png" },
	{ dir = "ironmon_tracker/images/pokemonMysteryDungeon", ext = ".png" },
	{ dir = "ironmon_tracker/images/pokemonVPet", ext = ".png" },
}

for _, pack in ipairs(staticPacks) do
	for _, name in ipairs(listDir(pack.dir)) do
		local id = numberedId(name)
		assert(id, pack.dir .. "/" .. name .. " must be a numbered sprite")
		assert(isKeptPokemonId(id), pack.dir .. "/" .. name .. " is outside the Gen 1 keep set")
	end
	assert(fileExists(pack.dir .. "/0" .. pack.ext), pack.dir .. " must keep 0")
	for id = 1, 151 do
		assert(fileExists(pack.dir .. "/" .. id .. pack.ext), pack.dir .. " missing " .. id)
	end
	assert(fileExists(pack.dir .. "/412" .. pack.ext), pack.dir .. " must keep egg 412")
	assert(fileExists(pack.dir .. "/413" .. pack.ext), pack.dir .. " must keep ghost 413")
end

local walkingDirs = {
	"ironmon_tracker/images/spritesWalkingPals/walk",
	"ironmon_tracker/images/spritesWalkingPals/idle",
	"ironmon_tracker/images/spritesWalkingPals/faint",
	"ironmon_tracker/images/spritesWalkingPals/sleep",
}
for _, dir in ipairs(walkingDirs) do
	for _, name in ipairs(listDir(dir)) do
		local id = numberedId(name)
		assert(id, dir .. "/" .. name .. " must be a numbered sprite")
		assert(isKeptPokemonId(id), dir .. "/" .. name .. " is outside the Gen 1 keep set")
	end
end
assert(fileExists("ironmon_tracker/images/spritesWalkingPals/idle/412.png"), "Walking Pals idle must keep egg 412")
assert(fileExists("ironmon_tracker/images/spritesWalkingPals/idle/413.png"), "Walking Pals idle must keep ghost 413")

local badgeDir = "ironmon_tracker/images/badges"
for _, name in ipairs(listDir(badgeDir)) do
	assert(not name:find("^RSE_"), "RSE badge must be removed: " .. name)
end
for i = 1, 8 do
	assert(fileExists(badgeDir .. "/FRLG_badge" .. i .. ".png"), "missing FRLG_badge" .. i)
	assert(fileExists(badgeDir .. "/FRLG_badge" .. i .. "_OFF.png"), "missing FRLG_badge" .. i .. "_OFF")
end

local playerDir = "ironmon_tracker/images/player"
assert(fileExists(playerDir .. "/boy-frlg.png"), "missing boy-frlg.png")
assert(fileExists(playerDir .. "/girl-frlg.png"), "missing girl-frlg.png")
for _, name in ipairs({ "boy-e.png", "girl-e.png", "boy-rs.png", "girl-rs.png" }) do
	assert(not fileExists(playerDir .. "/" .. name), name .. " must be removed")
end

local trainerFilenames = {}
local trainerData = assert(io.open("ironmon_tracker/data/TrainerData.lua", "r"))
local trainerSource = trainerData:read("*a")
trainerData:close()
for filename in trainerSource:gmatch('filename%s*=%s*"([^"]+)"') do
	trainerFilenames[filename] = true
end

local expectedCount = 0
for _ in pairs(trainerFilenames) do
	expectedCount = expectedCount + 1
end
assert(expectedCount == 45, "TrainerData.Classes should define 45 filenames, got " .. expectedCount)

for _, dir in ipairs({
	"ironmon_tracker/images/trainers",
	"ironmon_tracker/images/trainerPortraits",
}) do
	local found = {}
	for _, name in ipairs(listDir(dir)) do
		assert(not name:find("^frlg%-"), dir .. "/" .. name .. " must not use the frlg- prefix")
		local className = name:match("^(.+)%.png$")
		assert(className, dir .. "/" .. name .. " must be a png class sprite")
		assert(trainerFilenames[className], dir .. "/" .. name .. " is not a TrainerData class")
		found[className] = true
	end
	for className in pairs(trainerFilenames) do
		assert(found[className], dir .. " missing " .. className .. ".png")
	end
end

print("Gen 1 asset smoke tests passed")
