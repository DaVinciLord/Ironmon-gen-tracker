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
assert(overlay:find("TabBox.height = Drawing.getTrackerHeight() - LogOverlay.tabHeight - m - 1", 1, true),
	"TabBox must include DOWN_GAP or row 2 of the trainer grid is clipped")
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
assert(not drawing:find("Drawing.drawImage(button.image, x, y, width, height)", 1, true),
	"BizHawk bilinear resize turns 4-color RBY sprites into gray mush; draw native pixels")

assert(not overlay:find("pagerOffsetX = 155", 1, true),
	"GBA pagerOffsetX=155 draws Page N/M off the 160px GB overlay")
assert(overlay:find('string.format("%s/%s"', 1, true),
	"GB overlay page chrome is N/M, not the GBA 'Page N/M' string that collides with tab icons")

local trainersTab = read(repoRoot .. "ironmon_tracker/screens/LogTabTrainers.lua")
assert(not trainersTab:find("box = { LogOverlay.TabBox.x + nextNavX", 1, true),
	"trainer filter buttons must not add TabBox.x twice (pushes Boss off the 156px tab)")
assert(not trainersTab:find("Drawing.drawText(LogOverlay.TabBox.x + 2, LogOverlay.TabBox.y + 1, filterByText", 1, true),
	"Filter by: plus All/Rival/Gym/Elite 4/Boss does not fit the GB tab; drop the label")
assert(trainersTab:find("width = 56", 1, true),
	"RBY trainer portraits stay 56px native so they stay sharp on the GB overlay")
assert(trainersTab:find("extraY = 12", 1, true),
	"trainer names stay above the portrait, not drawn on top of it")
assert(trainersTab:find("button.box[2] - Constants.SCREEN.LINESPACING", 1, true),
	"trainer names stay above the 56px portrait")
assert(trainersTab:find("button.box[2] + button.box[4] + 2", 1, true),
	"party pokeballs stay below the 56px portrait")
assert(trainersTab:find("Drawing.getTrackerHeight()", 1, true),
	"the trainer grid cutoff must use tracker height or the 2x2 second row is dropped")
assert(not trainersTab:find("TabBox.y + 18", 1, true),
	"grid start y + 18 leaves no room for a second 56px row on GB")

local trainerDetails = read(repoRoot .. "ironmon_tracker/screens/LogTabTrainerDetails.lua")
assert(not trainerDetails:find("i % 2 == 1", 1, true),
	"trainer details cannot use the GBA 2-column party layout on a 156px GB tab")
assert(trainerDetails:find("monsPerPage = 3", 1, true),
	"a full party of 6 is shown 3 per page on GB")

local trainerInfo = read(repoRoot .. "ironmon_tracker/screens/TrainerInfoScreen.lua")
assert(not trainerInfo:find("MARGIN + 79", 1, true),
	"party icon grid must start high enough for two rows of 6 on GB 144px")
assert(trainerInfo:find("cols = 3", 1, true),
	"a party of 6 is a 3x2 grid so the 56px rival portrait cannot sit on slot 4")
assert(not trainerInfo:find("y + 56", 1, true),
	"the #class-number label must not be drawn under the 56px portrait (it painted over slot 4)")
assert(trainerInfo:find("getTrackerHeight()", 1, true),
	"the trainer info box uses the padded tracker height so the back arrow sits inside the border")
assert(trainerInfo:find("cutoffY = Drawing.getTrackerHeight()", 1, true),
	"the 3x2 party grid must use tracker height as cutoff or the second row is dropped")

local tmsTab = read(repoRoot .. "ironmon_tracker/screens/LogTabTMs.lua")
assert(not tmsTab:find("gymColOffsetX = 80 + 17", 1, true),
	"GBA gym TM name column (offset 97) clips leader names on the 160px GB overlay")
assert(not tmsTab:find("self.box[1] + 55", 1, true),
	"GBA 'Gym N' text at nameX+55 is drawn in the tracker gap")
assert(tmsTab:find("tmButton.pageVisible", 1, true),
	"gym TM labels must follow the TM row page or badges 1 and 8 overlap")

print("Gen 1 screen layout smoke tests passed")
