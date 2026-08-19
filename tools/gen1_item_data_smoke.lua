-- Run from any directory with: lua tools/gen1_item_data_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

MiscData = {
	Values = {}, BagPocket = { Items = 1 },
	HealingType = { Constant = "Constant", Percentage = "Percentage" },
	StatusType = { Poison = 2, Burn = 3, Freeze = 4, Sleep = 1, Paralyze = 5, All = 100 },
}
dofile(repoRoot .. "ironmon_tracker/gen1/ItemData.lua")

assert(MiscData.getTotalItems() == 255)
assert(MiscData.Items[4] == "Poke Ball" and MiscData.PokeBalls[4])
assert(MiscData.HealingItems[20].name == "Potion" and MiscData.HealingItems[20].amount == 20)
assert(MiscData.HealingItems[62].name == "Lemonade" and MiscData.HealingItems[62].amount == 80)
assert(MiscData.StatusItems[11].type == MiscData.StatusType.Poison)
assert(MiscData.PPItems[80].name == "Ether")
assert(MiscData.EvolutionStones[47].name == "Leaf Stone")
assert(next(MiscData.TMs) == nil and next(MiscData.HMs) == nil)

print("Gen 1 item data smoke tests passed")
