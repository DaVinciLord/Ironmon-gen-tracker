-- Run from any directory with: lua tools/gen1_memory_domains_smoke.lua
local scriptPath = debug.getinfo(1, "S").source:sub(2)
local toolsDir = scriptPath:match("^(.*[/\\])") or ""
local repoRoot = toolsDir:gsub("tools[/\\]$", "")

Utils = {
	bit_rshift = function(value, bits) return math.floor(value / (2 ^ bits)) end,
	bit_and = function(left, right)
		local result, bitValue = 0, 1
		while left > 0 or right > 0 do
			if left % 2 == 1 and right % 2 == 1 then result = result + bitValue end
			left, right, bitValue = math.floor(left / 2), math.floor(right / 2), bitValue * 2
		end
		return result
	end,
}
dofile(repoRoot .. "ironmon_tracker/Memory.lua")

local domain, address = Memory.splitDomainAndAddress(0x0200116F)
assert(domain == "WRAM" and address == 0x116F)
domain, address = Memory.splitDomainAndAddress(0x0400D16F)
assert(domain == "WRAM" and address == 0xD16F)
domain, address = Memory.splitDomainAndAddress(0x0803B1DB)
assert(domain == "ROM" and address == 0x03B1DB)

print("Gen 1 memory domain smoke tests passed")
