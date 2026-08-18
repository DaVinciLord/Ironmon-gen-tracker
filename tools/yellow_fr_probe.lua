-- Pokemon Yellow (French) / IronMON tracker address probe
-- BizHawk Lua script. READ-ONLY: this script never writes to emulated memory.
--
-- v4 validates the first usable French Yellow WRAM map after the v2/v3
-- runtime discoveries. It intentionally uses fixed addresses now: the goal is
-- to verify the map that the real tracker uses, not to discover it again.

local ROM = "ROM"
local WRAM = "WRAM"

local A = {
	partyCount = 0x1167,
	partyMon1 = 0x116F,

	-- This low-WRAM region does NOT follow the +5 localization shift.
	playerMonNumber = 0x0C2F,
	playerSelectedMove = 0x0CDC,
	enemySelectedMove = 0x0CDD,
	enemyMoveListIndex = 0x0CE2,
	legacyTurnHeuristic = 0x0CD5,
	statMods = 0x0D1A,

	-- Battle data region: French Yellow is +5 vs English Yellow here.
	enemyMoveNum = 0x0FD0,
	playerMoveNum = 0x0FD6,
	enemyMon = 0x0FE9,
	enemyType1 = 0x0FEE,
	battleMon = 0x1018,
	isInBattle = 0x105B,
	battleType = 0x105E,

	-- Player/save-state region. Derived from pokered-fr plus the exact
	-- Yellow-vs-Red delta from pret's English symbol maps.
	bagCount = 0x1321,
	bagItems = 0x1322,
	badges = 0x135A,
	curMap = 0x1362,
}

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

local function in_four(value, base)
	for i = 0, 3 do
		if value ~= 0 and value == read_u8(base + i, WRAM) then return true end
	end
	return false
end

local title = read_ascii(0x134, 15, ROM)
local detectorBytes = read_ascii(0x13C, 4, ROM)

log("=== Pokemon Yellow FR IronMON probe v4 ===")
log("ROM title @0134: " .. title)
log("Tracker detector @013C: " .. detectorBytes .. " [" .. read_hex(0x13C, 4, ROM) .. "]")

if title ~= "POKEMON YELAPSF" or detectorBytes ~= "YELA" then
	log("HEADER: NOT EXPECTED - stop and verify the base ROM.")
	return
end
log("HEADER: OK")

log("")
log("Tracker WRAM map snapshot:")
log(string.format("  partyCount       @%04X = %d", A.partyCount, read_u8(A.partyCount, WRAM)))
log(string.format("  partyMon1        @%04X = %s", A.partyMon1, read_hex(A.partyMon1, 36, WRAM)))
log(string.format("  curMap           @%04X = %d (0x%02X)", A.curMap, read_u8(A.curMap, WRAM), read_u8(A.curMap, WRAM)))
log(string.format("  badges           @%04X = %d (0x%02X)", A.badges, read_u8(A.badges, WRAM), read_u8(A.badges, WRAM)))
log(string.format("  bagCount         @%04X = %d", A.bagCount, read_u8(A.bagCount, WRAM)))
log(string.format("  first bag bytes  @%04X = %s", A.bagItems, read_hex(A.bagItems, 12, WRAM)))

log("")
log("Start v4 OUTSIDE battle, then trigger a normal wild encounter (Route 1 is ideal).")
log("Map/bag/badge changes are logged while waiting.")

local previousMap = read_u8(A.curMap, WRAM)
local previousBagCount = read_u8(A.bagCount, WRAM)
local previousBadges = read_u8(A.badges, WRAM)

while read_u8(A.isInBattle, WRAM) == 0 do
	local map = read_u8(A.curMap, WRAM)
	local bagCount = read_u8(A.bagCount, WRAM)
	local badges = read_u8(A.badges, WRAM)
	if map ~= previousMap then
		log(string.format("[frame %d] curMap   @%04X: %d -> %d", emu.framecount(), A.curMap, previousMap, map))
		previousMap = map
	end
	if bagCount ~= previousBagCount then
		log(string.format("[frame %d] bagCount @%04X: %d -> %d", emu.framecount(), A.bagCount, previousBagCount, bagCount))
		previousBagCount = bagCount
	end
	if badges ~= previousBadges then
		log(string.format("[frame %d] badges   @%04X: 0x%02X -> 0x%02X", emu.framecount(), A.badges, previousBadges, badges))
		previousBadges = badges
	end
	emu.frameadvance()
end

local battleKind = read_u8(A.isInBattle, WRAM)
log("")
log("BATTLE START DETECTED")
log(string.format("  isInBattle      @%04X = %d (%s)", A.isInBattle, battleKind,
	battleKind == 1 and "wild" or (battleKind == 2 and "trainer" or "unexpected")))
log(string.format("  battleType      @%04X = %d", A.battleType, read_u8(A.battleType, WRAM)))
log(string.format("  playerMonNumber @%04X = %d", A.playerMonNumber, read_u8(A.playerMonNumber, WRAM)))
log(string.format("  battleMon       @%04X = %s", A.battleMon, read_hex(A.battleMon, 31, WRAM)))
log(string.format("  enemyMon        @%04X = %s", A.enemyMon, read_hex(A.enemyMon, 31, WRAM)))
log(string.format("  enemy types     @%04X = %02X %02X", A.enemyType1,
	read_u8(A.enemyType1, WRAM), read_u8(A.enemyType1 + 1, WRAM)))
log(string.format("  player moves          = %s", read_hex(A.battleMon + 8, 4, WRAM)))
log(string.format("  enemy moves           = %s", read_hex(A.enemyMon + 8, 4, WRAM)))
log("")
log("Use at least one move and let the wild Pokemon use at least one move, then finish or flee.")

local previous = {}
local playerSelectedValidated = false
local enemySelectedValidated = false
local playerMoveNumValidated = false
local enemyMoveNumValidated = false

local function watch(name, address)
	local value = read_u8(address, WRAM)
	if previous[name] ~= value then
		previous[name] = value
		log(string.format("[frame %d] %-21s @%04X = %3d (0x%02X)", emu.framecount(), name, address, value, value))
	end
	return value
end

while true do
	local inBattle = watch("isInBattle", A.isInBattle)
	watch("battleType", A.battleType)
	watch("playerMonNumber", A.playerMonNumber)
	watch("enemyMoveListIndex", A.enemyMoveListIndex)
	watch("legacyTurnHeuristic", A.legacyTurnHeuristic)

	local playerSelected = watch("playerSelectedMove", A.playerSelectedMove)
	local enemySelected = watch("enemySelectedMove", A.enemySelectedMove)
	local playerMoveNum = watch("playerMoveNum", A.playerMoveNum)
	local enemyMoveNum = watch("enemyMoveNum", A.enemyMoveNum)

	watch("playerHP_hi", A.battleMon + 1)
	watch("playerHP_lo", A.battleMon + 2)
	watch("enemySpecies", A.enemyMon)
	watch("enemyHP_hi", A.enemyMon + 1)
	watch("enemyHP_lo", A.enemyMon + 2)

	if in_four(playerSelected, A.battleMon + 8) then playerSelectedValidated = true end
	if in_four(enemySelected, A.enemyMon + 8) then enemySelectedValidated = true end
	if in_four(playerMoveNum, A.battleMon + 8) then playerMoveNumValidated = true end
	if in_four(enemyMoveNum, A.enemyMon + 8) then enemyMoveNumValidated = true end

	if inBattle == 0 then
		log("")
		log("BATTLE END DETECTED")
		log(string.format("  wild semantic (isInBattle==1): %s", battleKind == 1 and "PASS" or "FAIL/NOT TESTED"))
		log(string.format("  playerSelectedMove @0CDC:      %s", playerSelectedValidated and "PASS" or "NOT OBSERVED"))
		log(string.format("  enemySelectedMove  @0CDD:      %s", enemySelectedValidated and "PASS" or "NOT OBSERVED"))
		log(string.format("  playerMoveNum       @0FD6:      %s", playerMoveNumValidated and "PASS" or "NOT OBSERVED"))
		log(string.format("  enemyMoveNum        @0FD0:      %s", enemyMoveNumValidated and "PASS" or "NOT OBSERVED"))
		log("")
		log("Send the output from BATTLE START DETECTED through this summary.")
		return
	end

	emu.frameadvance()
end
