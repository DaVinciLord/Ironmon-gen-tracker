MiscData = {}

MiscData.Values = {
	TotalItemsGen1 = 255,
}

MiscData.TableData = {
	growth = { 1, 1, 1, 1, 1, 1, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4, 2, 2, 3, 4, 3, 4 },
	attack = { 2, 2, 3, 4, 3, 4, 1, 1, 1, 1, 1, 1, 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3 },
	effort = { 3, 4, 2, 2, 4, 3, 3, 4, 2, 2, 4, 3, 1, 1, 1, 1, 1, 1, 4, 3, 4, 3, 2, 2 },
	misc   = { 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 4, 3, 4, 3, 2, 2, 1, 1, 1, 1, 1, 1 },
}

MiscData.Gender = {
	MALE = 0,
	FEMALE = 254,
	UNKNOWN = 255,
}

MiscData.BagPocket = {
	PC = 0,
	Items = 1,
	KeyItems = 2,
	Pokeballs = 3,
	TMHM = 4,
	Berries = 5,
}

MiscData.HealingType = {
	Constant = "Constant",
	Percentage = "Percentage",
}

MiscData.StatusType = {
	None = 0,
	Sleep = 1,
	Poison = 2,
	Burn = 3,
	Freeze = 4,
	Paralyze = 5,
	Toxic = 6,
	Confusion = 30,
	Faint = 50,
	All = 100,
}

MiscData.StatusCodeMap = {
	[MiscData.StatusType.None] = "",
	[MiscData.StatusType.Burn] = "BRN",
	[MiscData.StatusType.Freeze] = "FRZ",
	[MiscData.StatusType.Paralyze] = "PAR",
	[MiscData.StatusType.Poison] = "PSN",
	[MiscData.StatusType.Toxic] = "PSN",
	[MiscData.StatusType.Sleep] = "SLP",
	[MiscData.StatusType.Faint] = "FNT",
}

MiscData.Natures = {}

MiscData.Items = {
	"Master Ball","Ultra Ball","Great Ball","Poke Ball","Town Map","Bicycle","?????","Safari Ball","Pokedex","Moon Stone",
	"Antidote","Burn Heal","Ice Heal","Awakening","Parlyz Heal","Full Restore","Max Potion","Hyper Potion","Super Potion","Potion",
	"BoulderBadge","CascadeBadge","ThunderBadge","RainbowBadge","SoulBadge","MarshBadge","VolcanoBadge","EarthBadge","Escape Rope",
	"Repel","Old Amber","Fire Stone","Thunderstone","Water Stone","HP Up","Protein","Iron","Carbos","Calcium","Rare Candy","Dome Fossil",
	"Helix Fossil","Secret Key","?????","Bike Voucher","X Accuracy","Leaf Stone","Card Key","Nugget","PP Up","Poke Doll","Full Heal",
	"Revive","Max Revive","Guard Spec.","Super Repel","Max Repel","Dire Hit","Coin","Fresh Water","Soda Pop","Lemonade","S.S. Ticket","Gold Teeth",
	"X Attack","X Defend","X Speed","X Special","Coin Case","Oak's Parcel","Itemfinder","Silph Scope","Poke Flute","Lift Key","Exp. All",
	"Old Rod","Good Rod","Super Rod","PP Up","Ether","Max Ether","Elixer","Max Elixer",
}

local function item(id, name, amount, healingType, statusType, icon)
	return { id = id, name = name, amount = amount, type = healingType or statusType, icon = icon, pocket = MiscData.BagPocket.Items }
end

MiscData.PokeBalls = { [1]=true, [2]=true, [3]=true, [4]=true, [8]=true }
MiscData.HealingItems = {
	[16]=item(16,"Full Restore",100,MiscData.HealingType.Percentage,nil,"full-restore"),
	[17]=item(17,"Max Potion",100,MiscData.HealingType.Percentage,nil,"max-potion"),
	[18]=item(18,"Hyper Potion",200,MiscData.HealingType.Constant,nil,"hyper-potion"),
	[19]=item(19,"Super Potion",50,MiscData.HealingType.Constant,nil,"super-potion"),
	[20]=item(20,"Potion",20,MiscData.HealingType.Constant,nil,"potion"),
	[60]=item(60,"Fresh Water",50,MiscData.HealingType.Constant,nil,"fresh-water"),
	[61]=item(61,"Soda Pop",60,MiscData.HealingType.Constant,nil,"soda-pop"),
	[62]=item(62,"Lemonade",80,MiscData.HealingType.Constant,nil,"lemonade"),
}
MiscData.StatusItems = {
	[11]=item(11,"Antidote",nil,nil,MiscData.StatusType.Poison,"full-heal"),
	[12]=item(12,"Burn Heal",nil,nil,MiscData.StatusType.Burn,"full-heal"),
	[13]=item(13,"Ice Heal",nil,nil,MiscData.StatusType.Freeze,"full-heal"),
	[14]=item(14,"Awakening",nil,nil,MiscData.StatusType.Sleep,"full-heal"),
	[15]=item(15,"Parlyz Heal",nil,nil,MiscData.StatusType.Paralyze,"full-heal"),
	[16]=item(16,"Full Restore",nil,nil,MiscData.StatusType.All,"full-restore"),
	[52]=item(52,"Full Heal",nil,nil,MiscData.StatusType.All,"full-heal"),
}
MiscData.PPItems = {
	[79]=item(79,"PP Up",nil,MiscData.HealingType.Constant,nil,"ether"),
	[80]=item(80,"Ether",10,MiscData.HealingType.Constant,nil,"ether"),
	[81]=item(81,"Max Ether",100,MiscData.HealingType.Percentage,nil,"ether"),
	[82]=item(82,"Elixer",10,MiscData.HealingType.Constant,nil,"elixir"),
	[83]=item(83,"Max Elixer",100,MiscData.HealingType.Percentage,nil,"elixir"),
}
MiscData.EvolutionStones = {
	[10]=item(10,"Moon Stone",nil,nil,nil,"moon-stone"),
	[32]=item(32,"Fire Stone",nil,nil,nil,"fire-stone"),
	[33]=item(33,"Thunderstone",nil,nil,nil,"thunder-stone"),
	[34]=item(34,"Water Stone",nil,nil,nil,"water-stone"),
	[47]=item(47,"Leaf Stone",nil,nil,nil,"leaf-stone"),
}
MiscData.TMs, MiscData.HMs = {}, {}
for hm = 1, 5 do
	local id = 0xC3 + hm
	MiscData.Items[id] = string.format("HM%02d", hm)
	MiscData.HMs[id] = { id = id, name = MiscData.Items[id], icon = "tiny-tm", pocket = MiscData.BagPocket.TMHM }
end
for tm = 1, 50 do
	local id = 0xC8 + tm
	MiscData.Items[id] = string.format("TM%02d", tm)
	MiscData.TMs[id] = { id = id, name = MiscData.Items[id], icon = "tiny-tm", pocket = MiscData.BagPocket.TMHM }
end
MiscData.BattleItems = {}
MiscData.OtherItems = {}

function MiscData.getTMNumber(itemId)
	return MiscData.TMs[itemId] and itemId - 0xC8 or nil
end

function MiscData.getHMNumber(itemId)
	return MiscData.HMs[itemId] and itemId - 0xC3 or nil
end

-- Besteon language packs still ship Gen 3 item ids. Keep the RBY table as-is.
function MiscData.updateResources()
end

function MiscData.getTotalItems()
	return MiscData.Values.TotalItemsGen1
end

function MiscData.getItemIcon(itemId)
	itemId = itemId or 0
	local found = MiscData.HealingItems[itemId]
		or MiscData.StatusItems[itemId]
		or MiscData.PPItems[itemId]
		or MiscData.EvolutionStones[itemId]
		or MiscData.BattleItems[itemId]
		or MiscData.OtherItems[itemId] or {}
	if found.icon then
		return FileManager.buildImagePath(FileManager.Folders.Icons, found.icon, ".png")
	end
	return nil
end

function MiscData.getMonGender(pokemonID, personality)
	return MiscData.Gender.UNKNOWN
end
