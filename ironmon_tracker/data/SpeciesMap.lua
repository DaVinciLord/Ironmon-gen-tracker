-- RBY stores species in a historical internal order unrelated to the Pokédex.
Gen1SpeciesMap = {}

Gen1SpeciesMap.NamesByInternalId = {
	[0x1] = "RHYDON",
	[0x2] = "KANGASKHAN",
	[0x3] = "NIDORAN M",
	[0x4] = "CLEFAIRY",
	[0x5] = "SPEAROW",
	[0x6] = "VOLTORB",
	[0x7] = "NIDOKING",
	[0x8] = "SLOWBRO",
	[0x9] = "IVYSAUR",
	[0xa] = "EXEGGUTOR",
	[0xb] = "LICKITUNG",
	[0xc] = "EXEGGCUTE",
	[0xd] = "GRIMER",
	[0xe] = "GENGAR",
	[0xf] = "NIDORAN F",
	[0x10] = "NIDOQUEEN",
	[0x11] = "CUBONE",
	[0x12] = "RHYHORN",
	[0x13] = "LAPRAS",
	[0x14] = "ARCANINE",
	[0x15] = "MEW",
	[0x16] = "GYARADOS",
	[0x17] = "SHELLDER",
	[0x18] = "TENTACOOL",
	[0x19] = "GASTLY",
	[0x1a] = "SCYTHER",
	[0x1b] = "STARYU",
	[0x1c] = "BLASTOISE",
	[0x1d] = "PINSIR",
	[0x1e] = "TANGELA",
	[0x1f] = "MISSINGNO.",
	[0x20] = "MISSINGNO.",
	[0x21] = "GROWLITHE",
	[0x22] = "ONIX",
	[0x23] = "FEAROW",
	[0x24] = "PIDGEY",
	[0x25] = "SLOWPOKE",
	[0x26] = "KADABRA",
	[0x27] = "GRAVELER",
	[0x28] = "CHANSEY",
	[0x29] = "MACHOKE",
	[0x2a] = "MR.MIME",
	[0x2b] = "HITMONLEE",
	[0x2c] = "HITMONCHAN",
	[0x2d] = "ARBOK",
	[0x2e] = "PARASECT",
	[0x2f] = "PSYDUCK",
	[0x30] = "DROWZEE",
	[0x31] = "GOLEM",
	[0x32] = "MISSINGNO.",
	[0x33] = "MAGMAR",
	[0x34] = "MISSINGNO.",
	[0x35] = "ELECTABUZZ",
	[0x36] = "MAGNETON",
	[0x37] = "KOFFING",
	[0x38] = "MISSINGNO.",
	[0x39] = "MANKEY",
	[0x3a] = "SEEL",
	[0x3b] = "DIGLETT",
	[0x3c] = "TAUROS",
	[0x3d] = "MISSINGNO.",
	[0x3e] = "MISSINGNO.",
	[0x3f] = "MISSINGNO.",
	[0x40] = "FARFETCH'D",
	[0x41] = "VENONAT",
	[0x42] = "DRAGONITE",
	[0x43] = "MISSINGNO.",
	[0x44] = "MISSINGNO.",
	[0x45] = "MISSINGNO.",
	[0x46] = "DODUO",
	[0x47] = "POLIWAG",
	[0x48] = "JYNX",
	[0x49] = "MOLTRES",
	[0x4a] = "ARTICUNO",
	[0x4b] = "ZAPDOS",
	[0x4c] = "DITTO",
	[0x4d] = "MEOWTH",
	[0x4e] = "KRABBY",
	[0x4f] = "MISSINGNO.",
	[0x50] = "MISSINGNO.",
	[0x51] = "MISSINGNO.",
	[0x52] = "VULPIX",
	[0x53] = "NINETALES",
	[0x54] = "PIKACHU",
	[0x55] = "RAICHU",
	[0x56] = "MISSINGNO.",
	[0x57] = "MISSINGNO.",
	[0x58] = "DRATINI",
	[0x59] = "DRAGONAIR",
	[0x5a] = "KABUTO",
	[0x5b] = "KABUTOPS",
	[0x5c] = "HORSEA",
	[0x5d] = "SEADRA",
	[0x5e] = "MISSINGNO.",
	[0x5f] = "MISSINGNO.",
	[0x60] = "SANDSHREW",
	[0x61] = "SANDSLASH",
	[0x62] = "OMANYTE",
	[0x63] = "OMASTAR",
	[0x64] = "JIGGLYPUFF",
	[0x65] = "WIGGLYTUFF",
	[0x66] = "EEVEE",
	[0x67] = "FLAREON",
	[0x68] = "JOLTEON",
	[0x69] = "VAPOREON",
	[0x6a] = "MACHOP",
	[0x6b] = "ZUBAT",
	[0x6c] = "EKANS",
	[0x6d] = "PARAS",
	[0x6e] = "POLIWHIRL",
	[0x6f] = "POLIWRATH",
	[0x70] = "WEEDLE",
	[0x71] = "KAKUNA",
	[0x72] = "BEEDRILL",
	[0x73] = "MISSINGNO.",
	[0x74] = "DODRIO",
	[0x75] = "PRIMEAPE",
	[0x76] = "DUGTRIO",
	[0x77] = "VENOMOTH",
	[0x78] = "DEWGONG",
	[0x79] = "MISSINGNO.",
	[0x7a] = "MISSINGNO.",
	[0x7b] = "CATERPIE",
	[0x7c] = "METAPOD",
	[0x7d] = "BUTTERFREE",
	[0x7e] = "MACHAMP",
	[0x7f] = "MISSINGNO.",
	[0x80] = "GOLDUCK",
	[0x81] = "HYPNO",
	[0x82] = "GOLBAT",
	[0x83] = "MEWTWO",
	[0x84] = "SNORLAX",
	[0x85] = "MAGIKARP",
	[0x86] = "MISSINGNO.",
	[0x87] = "MISSINGNO.",
	[0x88] = "MUK",
	[0x89] = "MISSINGNO.",
	[0x8a] = "KINGLER",
	[0x8b] = "CLOYSTER",
	[0x8c] = "MISSINGNO.",
	[0x8d] = "ELECTRODE",
	[0x8e] = "CLEFABLE",
	[0x8f] = "WEEZING",
	[0x90] = "PERSIAN",
	[0x91] = "MAROWAK",
	[0x92] = "MISSINGNO.",
	[0x93] = "HAUNTER",
	[0x94] = "ABRA",
	[0x95] = "ALAKAZAM",
	[0x96] = "PIDGEOTTO",
	[0x97] = "PIDGEOT",
	[0x98] = "STARMIE",
	[0x99] = "BULBASAUR",
	[0x9a] = "VENUSAUR",
	[0x9b] = "TENTACRUEL",
	[0x9c] = "MISSINGNO.",
	[0x9d] = "GOLDEEN",
	[0x9e] = "SEAKING",
	[0x9f] = "MISSINGNO.",
	[0xa0] = "MISSINGNO.",
	[0xa1] = "MISSINGNO.",
	[0xa2] = "MISSINGNO.",
	[0xa3] = "PONYTA",
	[0xa4] = "RAPIDASH",
	[0xa5] = "RATTATA",
	[0xa6] = "RATICATE",
	[0xa7] = "NIDORINO",
	[0xa8] = "NIDORINA",
	[0xa9] = "GEODUDE",
	[0xaa] = "PORYGON",
	[0xab] = "AERODACTYL",
	[0xac] = "MISSINGNO.",
	[0xad] = "MAGNEMITE",
	[0xae] = "MISSINGNO.",
	[0xaf] = "MISSINGNO.",
	[0xb0] = "CHARMANDER",
	[0xb1] = "SQUIRTLE",
	[0xb2] = "CHARMELEON",
	[0xb3] = "WARTORTLE",
	[0xb4] = "CHARIZARD",
	[0xb5] = "MISSINGNO.",
	[0xb6] = "MISSINGNO.",
	[0xb7] = "MISSINGNO.",
	[0xb8] = "MISSINGNO.",
	[0xb9] = "ODDISH",
	[0xba] = "GLOOM",
	[0xbb] = "VILEPLUME",
	[0xbc] = "BELLSPROUT",
	[0xbd] = "WEEPINBELL",
	[0xbe] = "VICTREEBEL",



}

local function normalize(name)
	return tostring(name or ""):upper():gsub("[^A-Z0-9]", "")
end

-- PokemonData.Pokemon[].name is replaced with the UI language during
-- Resources.updateResources. French Yellow therefore stores "Lamantine"
-- and "Kicklee" before initializePokemonData rebuilds this map. The
-- internal index table is English, so snapshot names at file load.
local englishNameByDexId = {}
for dexId, pokemon in ipairs(PokemonData.Pokemon or {}) do
	englishNameByDexId[dexId] = pokemon.name
end

function Gen1SpeciesMap.rebuildDexMap()
	Gen1SpeciesMap.DexByInternalId = {}
	Gen1SpeciesMap.InternalIdByDexId = {}
	local dexByName = {}
	for dexId, pokemon in ipairs(PokemonData.Pokemon or {}) do
		dexByName[normalize(englishNameByDexId[dexId] or pokemon.name)] = dexId
	end
	for internalId, name in pairs(Gen1SpeciesMap.NamesByInternalId) do
		if name ~= "MISSINGNO." then
			local dexId = dexByName[normalize(name)]
			Gen1SpeciesMap.DexByInternalId[internalId] = dexId
			if dexId then Gen1SpeciesMap.InternalIdByDexId[dexId] = internalId end
		end
	end
end

function Gen1SpeciesMap.getInternalId(dexId)
	if not Gen1SpeciesMap.InternalIdByDexId then Gen1SpeciesMap.rebuildDexMap() end
	return Gen1SpeciesMap.InternalIdByDexId[dexId]
end

function Gen1SpeciesMap.getDexId(internalId)
	if not Gen1SpeciesMap.DexByInternalId then Gen1SpeciesMap.rebuildDexMap() end
	return Gen1SpeciesMap.DexByInternalId[internalId]
end

function Gen1SpeciesMap.getName(internalId)
	return Gen1SpeciesMap.NamesByInternalId[internalId]
end

function Gen1SpeciesMap.initialize()
	Gen1SpeciesMap.rebuildDexMap()
end

return Gen1SpeciesMap

