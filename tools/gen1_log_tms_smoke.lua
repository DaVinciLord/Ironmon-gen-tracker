-- Gym TMs overlay is still GBA-sized: names clip at x=160, gym labels
-- ignore pagination so badge 1 and 8 overlap and page 2 redraws every row.
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")
if repoRoot == "" then repoRoot = "./" end
if not repoRoot:match("[/\\]$") then repoRoot = repoRoot .. "/" end

local function read(path)
	local file = assert(io.open(path, "r"))
	local content = file:read("*a")
	file:close()
	return content
end

local tmsTab = read(repoRoot .. "ironmon_tracker/ui/screens/log/LogTabTMs.lua")
assert(not tmsTab:find("gymColOffsetX = 80 + 17", 1, true),
	"GBA name column (TM width 80 + 17) starts leader names at ~x=136; the GB overlay ends at 160")
assert(not tmsTab:find("self.box[1] + 55", 1, true),
	"GBA 'Gym N' text at nameX+55 is drawn in the tracker gap, eating leader names")
assert(not tmsTab:find("isVisible = function(self) return LogOverlay.Windower.filterGrid == self.group end", 1, true),
	"gym labels that only check the filter stay on every page, so badges 1 and 8 overlap")
assert(tmsTab:find("pageVisible", 1, true),
	"gym TM labels must follow the TM row's pageVisible")

Main = { OS = "Linux", supportsSpecialChars = false, IsOnBizhawk = function() return false end }
Constants = {
	SCREEN = { WIDTH = 160, HEIGHT = 144, RIGHT_GAP = 180, MARGIN = 5, LINESPACING = 11, DOWN_GAP = 15 },
	ButtonTypes = { NO_BORDER = 2 },
	Font = { SIZE = 9, FAMILY = "Franklin Gothic Medium" },
	charWidth = function() return 4 end,
}
dofile(repoRoot .. "ironmon_tracker/utils/Utils.lua")

FileManager = {
	Folders = { Badges = "badges" },
	Extensions = { BADGE = ".png" },
	buildImagePath = function() return "badge.png" end,
}
GameSettings = { badgePrefix = "FRLG" }
Resources = { LogOverlay = { FilterGym = "Gym", LabelFilterBy = "Filter by", FilterGymTMs = "Gym TMs", FilterTMNumber = "TM #" } }
Options = { ["Use Custom Trainer Names"] = false }
RandomizerLog = { Data = { Trainers = {}, TMs = {} } }
MoveData = { isValid = function() return false end, Moves = {} }
Theme = { COLORS = { ["Default text"] = 1 } }
Drawing = { drawImage = function() end, drawText = function() end, drawUnderline = function() end, drawButton = function() end }
Program = { redraw = function() end, changeScreenView = function() end }
InfoScreen = { Screens = { MOVE_INFO = 1 }, changeScreenView = function() end }
TrainerInfoScreen = { buildScreen = function() return false end }
Input = { checkButtonsClicked = function() end }

LogOverlay = {
	TabBox = { x = 2, y = 12, width = 156, height = 129 },
	Windower = {
		currentPage = 1,
		totalPages = 1,
		filterGrid = "Gym TMs",
		changeTab = function() end,
	},
	NavFilters = {
		TMs = {
			TMNumber = { getText = function() return "TM #" end, group = "TM #", index = 10, sortFunc = function(a, b) return a.tmNumber < b.tmNumber end },
			GymTMs = { getText = function() return "Gym TMs" end, group = "Gym TMs", index = 11, sortFunc = function(a, b) return (a.gymNumber or 0) < (b.gymNumber or 0) end },
		},
	},
}

dofile(repoRoot .. "ironmon_tracker/ui/screens/log/LogTabTMs.lua")

local gymTMs = {}
for gymNumber = 1, 8 do
	local tmNumber = gymNumber
	gymTMs[tmNumber] = { gymNumber = gymNumber, trainerId = gymNumber }
	RandomizerLog.Data.TMs[tmNumber] = { name = "Move" .. tmNumber, moveId = 0 }
	RandomizerLog.Data.Trainers[gymNumber] = { name = ({ "Pierre", "Ondine", "Bob", "Erika", "Koga", "Morgane", "Auguste", "Giovanni" })[gymNumber] }
end
-- Extra non-gym TMs so TM # still paginates; Gym TMs filter should only include the 8.
for tmNumber = 9, 12 do
	RandomizerLog.Data.TMs[tmNumber] = { name = "Other" .. tmNumber, moveId = 0 }
end

LogTabTMs.buildPagedButtons(gymTMs)

local tabRight = LogOverlay.TabBox.x + LogOverlay.TabBox.width
assert(#LogTabTMs.GymLabelButtons == 8, "eight Kanto gym TMs get leader labels")

for _, gymButton in ipairs(LogTabTMs.GymLabelButtons) do
	assert(gymButton.box, "gym label has a box")
	local right = gymButton.box[1] + gymButton.box[3]
	assert(right <= tabRight, string.format("leader name box ends at x=%s, past the %s overlay edge", right, tabRight))
	assert(right >= tabRight - 4, "leader names are right-aligned to the overlay edge")
	local name = gymButton:getText()
	assert(name ~= nil and name ~= "", "leader name is present")
end

local function visibleGymCount()
	local n = 0
	for _, gymButton in ipairs(LogTabTMs.GymLabelButtons) do
		if gymButton:isVisible() then
			n = n + 1
		end
	end
	return n
end

LogOverlay.Windower.currentPage = 1
local page1Count = visibleGymCount()
assert(page1Count > 0, "page 1 shows gym TM rows")

if (LogOverlay.Windower.totalPages or 1) > 1 then
	LogOverlay.Windower.currentPage = 2
	local page2Count = visibleGymCount()
	assert(page2Count > 0, "page 2 shows the leftover gym TM")
	assert(page2Count < 8, "page 2 must not redraw every gym row")
	assert(page1Count + page2Count == 8, "each gym label appears on exactly one page")

	-- Badges 1 and 8 would share the first-row Y if both drew on page 1.
	LogOverlay.Windower.currentPage = 1
	local page1Ys = {}
	for _, gymButton in ipairs(LogTabTMs.GymLabelButtons) do
		if gymButton:isVisible() then
			local y = gymButton.box[2]
			assert(not page1Ys[y], "two gym badges share the same row (badges 1/8 overlap)")
			page1Ys[y] = true
		end
	end
end

print("Gen 1 log TMs smoke tests passed")
