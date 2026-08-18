-- Pokemon Yellow (French) / IronMON tracker address probe
-- BizHawk Lua script. READ-ONLY: this script never writes to emulated memory.
--
-- v2 focuses on discovering the actual French Yellow party layout instead of
-- trusting the legacy Gen 1 tracker WRAM constants.

local ROM = "ROM"
local WRAM = "WRAM"
local PIKACHU = 0x54
local WRAM_SIZE = 0x2000

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

local function read_hex(addr, len, domain)
	local bytes = {}
	for i = 0, len - 1 do
		bytes[#bytes + 1] = string.format("%02X", read_u8(addr + i, domain))
	end
	return table.concat(bytes, " ")
end

local title = read_ascii(0x134, 15, ROM)
local detectorBytes = read_ascii(0x13C, 4, ROM)

log("=== Pokemon Yellow FR IronMON probe v2 ===")
log("ROM title @0134: " .. title)
log("Tracker detector @013C: " .. detectorBytes .. " [" .. read_hex(0x13C, 4, ROM) .. "]")

if title == "POKEMON YELAPSF" and detectorBytes == "YELA" then
	log("HEADER: OK - French Yellow (APSF) layout detected")
else
	log("HEADER: NOT EXPECTED")
	log("Expected title 'POKEMON YELAPSF' and detector bytes 'YELA'.")
end

log("")
log("Legacy tracker sanity check:")
log(string.format("  legacy gPlayerPartyCount candidate @189B = %d (expected 1 with Pikachu)", read_u8(0x189B, WRAM)))
log("  Note: the upstream Gen 1 tracker currently derives this from 0x189C, which appears to be incorrect.")

-- In Gen 1, party metadata is laid out as:
--   count, species[0..5], terminator, then the first party-mon struct.
-- With exactly one Pikachu we therefore expect a strong signature:
--   01 54 FF ... and the first byte of the struct 8 bytes after count is 54.
local strictCandidates = {}
local looseCandidates = {}

for addr = 0, WRAM_SIZE - 9 do
	local b0 = read_u8(addr, WRAM)
	local b1 = read_u8(addr + 1, WRAM)
	local b2 = read_u8(addr + 2, WRAM)

	if b0 == 0x01 and b1 == PIKACHU and b2 == 0xFF then
		looseCandidates[#looseCandidates + 1] = addr
		if read_u8(addr + 8, WRAM) == PIKACHU then
			strictCandidates[#strictCandidates + 1] = addr
		end
	end
end

log("")
log("Party layout scan (expected one Pikachu):")
log(string.format("  strict candidates (01 54 FF + struct species @+8): %d", #strictCandidates))
for _, addr in ipairs(strictCandidates) do
	log(string.format("    WRAM:%04X  bytes: %s", addr, read_hex(addr, 24, WRAM)))
end

if #strictCandidates == 0 then
	log(string.format("  no strict match; loose 01 54 FF candidates: %d", #looseCandidates))
	for _, addr in ipairs(looseCandidates) do
		log(string.format("    WRAM:%04X  bytes: %s", addr, read_hex(addr, 24, WRAM)))
	end
end

if #strictCandidates == 1 then
	local partyCountAddr = strictCandidates[1]
	local partyMon1Addr = partyCountAddr + 8
	log("")
	log("PARTY SIGNATURE: UNIQUE MATCH")
	log(string.format("  partyCount  = WRAM:%04X", partyCountAddr))
	log(string.format("  partySpecies= WRAM:%04X", partyCountAddr + 1))
	log(string.format("  partyMon1   = WRAM:%04X", partyMon1Addr))
	log("Keep the game running with Pikachu in the party and send this output back for the next probe.")
elseif #strictCandidates > 1 then
	log("")
	log("PARTY SIGNATURE: AMBIGUOUS - send all candidates back; do not choose one manually.")
else
	log("")
	log("PARTY SIGNATURE: NOT FOUND - keep Pikachu as the only party member and send this output back.")
end

log("")
log("Probe v2 stops here intentionally. Battle-address discovery will use the confirmed party layout in the next step.")
