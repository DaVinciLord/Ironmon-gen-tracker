Gen1ItemData = {}

Gen1ItemData.Names = {
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

function Gen1ItemData.apply()
	MiscData.Values.TotalItemsGen1 = 255
	MiscData.Items = Gen1ItemData.Names
	MiscData.Natures = {}
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
		Gen1ItemData.Names[id] = string.format("HM%02d", hm)
		MiscData.HMs[id] = { id = id, name = Gen1ItemData.Names[id], icon = "tiny-tm", pocket = MiscData.BagPocket.TMHM }
	end
	for tm = 1, 50 do
		local id = 0xC8 + tm
		Gen1ItemData.Names[id] = string.format("TM%02d", tm)
		MiscData.TMs[id] = { id = id, name = Gen1ItemData.Names[id], icon = "tiny-tm", pocket = MiscData.BagPocket.TMHM }
	end
	MiscData.getTMNumber = function(itemId) return MiscData.TMs[itemId] and itemId - 0xC8 or nil end
	MiscData.getHMNumber = function(itemId) return MiscData.HMs[itemId] and itemId - 0xC3 or nil end
	MiscData.BattleItems, MiscData.OtherItems = {}, {}
	MiscData.getTotalItems = function() return MiscData.Values.TotalItemsGen1 end
end

function Gen1ItemData.updateResources()
	-- Game-language resources bundled with Besteon use Gen 3 item ids. Keep the
	-- native RBY table stable until dedicated RBY translations are loaded.
end

Gen1ItemData.apply()
MiscData.updateResources = Gen1ItemData.updateResources

return Gen1ItemData
