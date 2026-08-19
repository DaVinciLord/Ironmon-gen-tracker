-- Game Boy screen + tracker padding, restored from the runtime-validated
-- Yellow FR tracker (agent/yellow-fr-support). GBA 240x160 leaves the panel
-- starting at x=240 on a 160px GB screen, so only about half of it is visible.
-- Run from any directory with: lua tools/gen1_screen_layout_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Main = { supportsSpecialChars = true }
dofile(repoRoot .. "ironmon_tracker/Constants.lua")

assert(Constants.SCREEN.WIDTH == 160, "GB screen width must be 160, not GBA 240")
assert(Constants.SCREEN.HEIGHT == 144, "GB screen height must be 144, not GBA 160")
assert(Constants.SCREEN.RIGHT_GAP == 180, "tracker panel sits in a 180px right gap")
assert(Constants.SCREEN.DOWN_GAP == 15, "15px below the 144px game restores ~160px UI height")
assert(Constants.SCREEN.UP_GAP == 0)
assert(Constants.Font.HEADERSIZE == 15)

print("Gen 1 screen layout smoke tests passed")
