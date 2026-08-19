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

-- Yellow FR probes confirmed party data at WRAM:116F (encoded 0x0200116F),
-- not GBA EWRAM and not System Bus with the raw 0x116F offset.
local domain, address = Memory.splitDomainAndAddress(0x0200116F)
assert(domain == "WRAM" and address == 0x116F)
domain, address = Memory.splitDomainAndAddress(0x0400D16F)
assert(domain == "WRAM" and address == 0xD16F)
domain, address = Memory.splitDomainAndAddress(0x0803B1DB)
assert(domain == "ROM" and address == 0x03B1DB)
domain, address = Memory.splitDomainAndAddress(0x02000CF9)
assert(domain == "WRAM" and address == 0x0CF9)


-- GBA leftovers (FriendshipRequiredToEvo, gSaveBlock1, ...) are nil on Gen 1.
-- BizHawk then crashes in Utils.bit_rshift: "attempt to perform arithmetic on a nil value (local 'value')".
local ok, resultDomain, resultAddress = pcall(Memory.splitDomainAndAddress, nil)
assert(ok, "splitDomainAndAddress(nil) must not throw: " .. tostring(resultDomain))
assert(resultDomain == nil and (resultAddress == 0 or resultAddress == nil))

ok, resultDomain, resultAddress = pcall(Memory.splitDomainAndAddress, "not-an-address")
assert(ok, "splitDomainAndAddress(non-number) must not throw: " .. tostring(resultDomain))

Main = { IsOnBizhawk = function() return true end }
local readCalls = 0
memory = {
	read_u8 = function()
		readCalls = readCalls + 1
		return 7
	end,
	read_u16_le = function()
		readCalls = readCalls + 1
		return 7
	end,
	read_u32_le = function()
		readCalls = readCalls + 1
		return 7
	end,
}
Memory.hasInitialized = false
Memory.initialize()
assert(Memory.readbyte(nil) == 0, "nil address must read as 0")
assert(Memory.readword(nil) == 0)
assert(Memory.readdword(nil) == 0)
assert(readCalls == 0, "BizHawk must not be asked to read a nil address")
assert(Memory.readbyte(0x0800013C) == 7)

-- Same call Program.initialize makes for the GBA friendship threshold.
GameSettings = {}
local friendshipRequired = (Memory.readbyte(GameSettings.FriendshipRequiredToEvo) or 0) + 1
assert(friendshipRequired == 1)

print("Gen 1 memory domain smoke tests passed")
