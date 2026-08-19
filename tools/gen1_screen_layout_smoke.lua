-- Game Boy screen + tracker padding, restored from the runtime-validated
-- Yellow FR tracker (agent/yellow-fr-support). GBA 240x160 leaves the panel
-- starting at x=240 on a 160px GB screen, so only about half of it is visible.
-- Run from any directory with: lua tools/gen1_screen_layout_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Main = { supportsSpecialChars = true }
dofile(repoRoot .. "ironmon_tracker/constants/Constants.lua")

assert(Constants.SCREEN.WIDTH == 160, "GB screen width must be 160, not GBA 240")
assert(Constants.SCREEN.HEIGHT == 144, "GB screen height must be 144, not GBA 160")
assert(Constants.SCREEN.RIGHT_GAP == 180, "tracker panel sits in a 180px right gap")
assert(Constants.SCREEN.DOWN_GAP == 15, "15px below the 144px game restores ~160px UI height")
assert(Constants.SCREEN.UP_GAP == 0)
assert(Constants.Font.HEADERSIZE == 15)

local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*a")
	file:close()
	return content
end
local overlay = read(repoRoot .. "ironmon_tracker/screens/LogOverlay.lua")
assert(overlay:find("drawBackgroundAndMargins(0, 0, Constants.SCREEN.WIDTH, Constants.SCREEN.HEIGHT)", 1, true),
	"the log overlay must cover the GB game screen, like Besteon")
assert(overlay:find("SCREEN.WIDTH - (m * 2)", 1, true)
	or overlay:find("SCREEN.WIDTH - (LogOverlay.margin * 2)", 1, true),
	"log TabBox width is the game screen, not the right-gap tracker panel")

local pokemonTab = read(repoRoot .. "ironmon_tracker/screens/LogTabPokemon.lua")
assert(pokemonTab:find("defaultIconCount = 1", 1, true),
	"the Pokémon log tab uses one header icon on GB, not two GBA sprites that look like duplicate tabs")

-- TrackerScreen keeps the Besteon GBA y-layout (carousel 136–155). On GB the
-- game is only 144px tall; DOWN_GAP must be painted or badges sit on black.
local trackerHeight = Constants.SCREEN.HEIGHT + Constants.SCREEN.DOWN_GAP
assert(136 + 19 <= trackerHeight, "badge carousel must fit in HEIGHT + DOWN_GAP")
local drawing = read(repoRoot .. "ironmon_tracker/drawing/Drawing.lua")
assert(drawing:find("Drawing.getTrackerHeight", 1, true),
	"the tracker panel background must use getTrackerHeight so DOWN_GAP is filled")
assert(drawing:find("height = height or Drawing.getTrackerHeight()", 1, true),
	"drawBackgroundAndMargins must default to the padded tracker height, not 144")

print("Gen 1 screen layout smoke tests passed")
