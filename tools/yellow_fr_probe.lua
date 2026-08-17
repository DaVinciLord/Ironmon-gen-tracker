-- Pokemon Yellow (French) / IronMON tracker address probe
-- BizHawk Lua script. READ-ONLY: this script never writes to emulated memory.

local ROM = "ROM"
local WRAM = "WRAM"

local function log(msg)
	if console and console.log then console.log(msg) else print(msg) end
end

local function read_u8(addr, domain)
	return memory.read_u8(addr, domain)
end

local function read_ascii(addr, len, domain)
	local chars = {}
	for i = 0, len - 1 do
		local b = read_u8(addr + i, domain)
		if b == 0 then break end
		if b >= 32 and b <= 126 then
			chars[#chars + 1] = string.char(b)
		else
			chars[#chars + 1] = string.format("\\x%02X", b)
		end
	end
	return table.concat(chars)
end

local function read_hex4(addr, domain)
	return string.format("%02X %02X %02X %02X",
		read_u8(addr, domain), read_u8(addr + 1, domain),
		read_u8(addr + 2, domain), read_u8(addr + 3, domain))
end

local title = read_ascii(0x134, 15, ROM)
local detectorBytes = read_ascii(0x13C, 4, ROM)

log("=== Pokemon Yellow FR IronMON probe ===")
log("ROM title @0134: " .. title)
log("Tracker detector @013C: " .. detectorBytes .. " [" .. read_hex4(0x13C, ROM) .. "]")

if title == "POKEMON YELAPSF" and detectorBytes == "YELA" then
	log("HEADER: OK - French Yellow (APSF) layout detected")
else
	log("HEADER: NOT EXPECTED")
	log("Expected title 'POKEMON YELAPSF' and detector bytes 'YELA'.")
end

local watches = {
	{ name = "partyCount",      addr = 0x189B, note = "Expected 0..6; normally 1 after receiving starter" },
	{ name = "badges",          addr = 0x1355, note = "Badge bitfield" },
	{ name = "bagItems",        addr = 0x131D, note = "Bag/item area candidate" },
	{ name = "mapHeader",       addr = 0x135D, note = "Should change with map context" },
	{ name = "battleType",      addr = 0x1057, note = "Useful around battle start/end" },
	{ name = "turn",            addr = 0x0CD5, note = "Changes during battle" },
	{ name = "enemyMove",       addr = 0x0FCB, note = "Changes when enemy uses moves" },
	{ name = "enemyType",       addr = 0x0FE9, note = "Enemy battle data candidate" },
	{ name = "enemyStatsBase",  addr = 0x0FE4, note = "Enemy stats structure" },
	{ name = "playerStatsBase", addr = 0x116A, note = "Player stats structure" },
	{ name = "partyIndex",      addr = 0x1162, note = "Battle party index candidate" },
	{ name = "statChange",      addr = 0x0D1A, note = "Stat change candidate" },
}

log("")
log("Watching candidate WRAM values. '+1' is shown for offset sanity checks.")
for _, w in ipairs(watches) do
	log(string.format("  %-16s WRAM:%04X -- %s", w.name, w.addr, w.note))
end
log("")

local previous = {}

while true do
	for _, w in ipairs(watches) do
		local value = read_u8(w.addr, WRAM)
		local adjacent = read_u8(w.addr + 1, WRAM)
		local signature = value * 256 + adjacent
		if previous[w.name] ~= signature then
			previous[w.name] = signature
			log(string.format("[frame %d] %-16s @%04X = %3d (0x%02X) | +1=%3d (0x%02X)",
				emu.framecount(), w.name, w.addr, value, value, adjacent, adjacent))
		end
	end
	emu.frameadvance()
end
