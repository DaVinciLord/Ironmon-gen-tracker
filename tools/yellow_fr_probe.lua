-- Pokemon Yellow (French) / IronMON tracker address probe
-- BizHawk Lua script. READ-ONLY: this script never writes to emulated memory.
--
-- v3 validates the confirmed French party layout, then discovers the active
-- battle-mon structure dynamically and derives nearby battle addresses using
-- the canonical Pokemon Yellow (UE) relative layout from pret/pokeyellow.

local ROM = "ROM"
local WRAM = "WRAM"
local PIKACHU = 0x54
local WRAM_SIZE = 0x2000
local PARTY_COUNT_CONFIRMED = 0x1167
local PARTY_MON1_CONFIRMED = 0x116F

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

local function same_byte(a, b)
	return read_u8(a, WRAM) == read_u8(b, WRAM)
end

-- PartyMon and BattleMon share species/HP/status/types/catch-rate/moves.
-- BattleMon byte +3 is party position rather than BoxLevel, so it is skipped.
-- Battle level/max HP are stored earlier than in PartyMon, and are checked too.
local function matches_party_as_battle_mon(candidate, partyMon)
	if candidate == partyMon then return false end
	if not same_byte(candidate + 0, partyMon + 0) then return false end -- species
	if not same_byte(candidate + 1, partyMon + 1) then return false end -- HP hi
	if not same_byte(candidate + 2, partyMon + 2) then return false end -- HP lo
	if not same_byte(candidate + 4, partyMon + 4) then return false end -- status
	if not same_byte(candidate + 5, partyMon + 5) then return false end -- type 1
	if not same_byte(candidate + 6, partyMon + 6) then return false end -- type 2
	if not same_byte(candidate + 7, partyMon + 7) then return false end -- catch rate
	for i = 8, 11 do
		if not same_byte(candidate + i, partyMon + i) then return false end -- moves
	end
	if read_u8(candidate + 14, WRAM) ~= read_u8(partyMon + 33, WRAM) then return false end -- level
	if read_u8(candidate + 15, WRAM) ~= read_u8(partyMon + 34, WRAM) then return false end -- max HP hi
	if read_u8(candidate + 16, WRAM) ~= read_u8(partyMon + 35, WRAM) then return false end -- max HP lo
	return true
end

local function find_battle_mon_candidates(partyMon)
	local candidates = {}
	for addr = 0, WRAM_SIZE - 17 do
		if read_u8(addr, WRAM) == read_u8(partyMon, WRAM) and matches_party_as_battle_mon(addr, partyMon) then
			candidates[#candidates + 1] = addr
		end
	end
	return candidates
end

local title = read_ascii(0x134, 15, ROM)
local detectorBytes = read_ascii(0x13C, 4, ROM)

log("=== Pokemon Yellow FR IronMON probe v3 ===")
log("ROM title @0134: " .. title)
log("Tracker detector @013C: " .. detectorBytes .. " [" .. read_hex(0x13C, 4, ROM) .. "]")

if title ~= "POKEMON YELAPSF" or detectorBytes ~= "YELA" then
	log("HEADER: NOT EXPECTED - stop this probe and verify the base ROM.")
	return
end
log("HEADER: OK - French Yellow (APSF) layout detected")

log("")
log("Confirmed party layout from probe v2:")
log(string.format("  partyCount   = WRAM:%04X -> %d", PARTY_COUNT_CONFIRMED, read_u8(PARTY_COUNT_CONFIRMED, WRAM)))
log(string.format("  partySpecies = WRAM:%04X -> %02X", PARTY_COUNT_CONFIRMED + 1, read_u8(PARTY_COUNT_CONFIRMED + 1, WRAM)))
log(string.format("  partyMon1    = WRAM:%04X -> %s", PARTY_MON1_CONFIRMED, read_hex(PARTY_MON1_CONFIRMED, 36, WRAM)))

if read_u8(PARTY_COUNT_CONFIRMED, WRAM) ~= 1 or read_u8(PARTY_MON1_CONFIRMED, WRAM) ~= PIKACHU then
	log("")
	log("PARTY CHECK FAILED - keep Pikachu as the only party member before running v3.")
	return
end

log("")
log("PARTY CHECK: OK")
log("Start this probe OUTSIDE battle, then enter a normal wild battle.")
log("Scanning every 30 frames for the BattleMon copy of Pikachu...")

local battleMonAddr = nil
local scanCounter = 0
while battleMonAddr == nil do
	if scanCounter % 30 == 0 then
		local candidates = find_battle_mon_candidates(PARTY_MON1_CONFIRMED)
		if #candidates == 1 then
			battleMonAddr = candidates[1]
		elseif #candidates > 1 then
			log(string.format("[frame %d] BattleMon scan ambiguous: %d candidates", emu.framecount(), #candidates))
			for _, addr in ipairs(candidates) do
				log(string.format("  WRAM:%04X -> %s", addr, read_hex(addr, 20, WRAM)))
			end
		end
	end
	scanCounter = scanCounter + 1
	emu.frameadvance()
end

-- Canonical Pokemon Yellow (UE) relative offsets from pret/pokeyellow symbols:
-- wBattleMon=$D013, wEnemyMon=$CFE4, wEnemyMoveNum=$CFCB,
-- wPlayerMoveNum=$CFD1, wIsInBattle=$D056, wBattleType=$D059,
-- wPlayerSelectedMove=$CCDC, wEnemySelectedMove=$CCDD, wPlayerMonNumber=$CC2F.
local addr = {
	battleMon = battleMonAddr,
	enemyMon = battleMonAddr - 0x2F,
	enemyMoveNum = battleMonAddr - 0x48,
	playerMoveNum = battleMonAddr - 0x42,
	isInBattle = battleMonAddr + 0x43,
	battleType = battleMonAddr + 0x46,
	playerSelectedMove = battleMonAddr - 0x337,
	enemySelectedMove = battleMonAddr - 0x336,
	playerMonNumber = battleMonAddr - 0x3E4,
}

log("")
log("BATTLE MON: UNIQUE MATCH")
log(string.format("  battleMon          = WRAM:%04X  bytes: %s", addr.battleMon, read_hex(addr.battleMon, 31, WRAM)))
log(string.format("  enemyMon           = WRAM:%04X  bytes: %s", addr.enemyMon, read_hex(addr.enemyMon, 31, WRAM)))
log(string.format("  isInBattle         = WRAM:%04X -> %d", addr.isInBattle, read_u8(addr.isInBattle, WRAM)))
log(string.format("  battleType         = WRAM:%04X -> %d", addr.battleType, read_u8(addr.battleType, WRAM)))
log(string.format("  playerMonNumber    = WRAM:%04X -> %d", addr.playerMonNumber, read_u8(addr.playerMonNumber, WRAM)))
log(string.format("  enemyMoveNum       = WRAM:%04X -> %d", addr.enemyMoveNum, read_u8(addr.enemyMoveNum, WRAM)))
log(string.format("  playerMoveNum      = WRAM:%04X -> %d", addr.playerMoveNum, read_u8(addr.playerMoveNum, WRAM)))
log(string.format("  playerSelectedMove = WRAM:%04X -> %d", addr.playerSelectedMove, read_u8(addr.playerSelectedMove, WRAM)))
log(string.format("  enemySelectedMove  = WRAM:%04X -> %d", addr.enemySelectedMove, read_u8(addr.enemySelectedMove, WRAM)))
log("")
log(string.format("  player: species=%02X hp=%02X%02X level=%d maxHP=%02X%02X",
	read_u8(addr.battleMon, WRAM), read_u8(addr.battleMon + 1, WRAM), read_u8(addr.battleMon + 2, WRAM),
	read_u8(addr.battleMon + 14, WRAM), read_u8(addr.battleMon + 15, WRAM), read_u8(addr.battleMon + 16, WRAM)))
log(string.format("  enemy : species=%02X hp=%02X%02X level=%d maxHP=%02X%02X moves=%s",
	read_u8(addr.enemyMon, WRAM), read_u8(addr.enemyMon + 1, WRAM), read_u8(addr.enemyMon + 2, WRAM),
	read_u8(addr.enemyMon + 14, WRAM), read_u8(addr.enemyMon + 15, WRAM), read_u8(addr.enemyMon + 16, WRAM),
	read_hex(addr.enemyMon + 8, 4, WRAM)))

log("")
log("Use a few moves and finish/escape the battle. Changes below are logged automatically.")

local previous = {}
local seenBattle = false
local function watch(name, address)
	local value = read_u8(address, WRAM)
	if previous[name] ~= value then
		previous[name] = value
		log(string.format("[frame %d] %-18s @%04X = %3d (0x%02X)", emu.framecount(), name, address, value, value))
	end
	return value
end

while true do
	local inBattle = watch("isInBattle", addr.isInBattle)
	watch("battleType", addr.battleType)
	watch("playerMonNumber", addr.playerMonNumber)
	watch("playerMoveNum", addr.playerMoveNum)
	watch("enemyMoveNum", addr.enemyMoveNum)
	watch("playerSelectedMove", addr.playerSelectedMove)
	watch("enemySelectedMove", addr.enemySelectedMove)
	watch("playerHP_hi", addr.battleMon + 1)
	watch("playerHP_lo", addr.battleMon + 2)
	watch("enemySpecies", addr.enemyMon)
	watch("enemyHP_hi", addr.enemyMon + 1)
	watch("enemyHP_lo", addr.enemyMon + 2)

	if inBattle ~= 0 then seenBattle = true end
	if seenBattle and inBattle == 0 then
		log("")
		log("BATTLE END DETECTED")
		log("Send the complete v3 console output back for validation.")
		return
	end
	emu.frameadvance()
end
