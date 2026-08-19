-- Keeps Besteon's log UI while constraining UPR parsing to RBY data shapes.
Gen1RandomizerLog = {}

local originalParseLog = RandomizerLog.parseLog

function Gen1RandomizerLog.setupMappings()
	local allMovesSource = MoveData.Moves
	if RandomizerLog.areLanguagesMismatched() then
		local languageToLoad = Resources.Languages[GameSettings.language:upper()] or Resources.Default.Language
		local languageGameData = RandomizerLog.loadLanguageMappings(languageToLoad)
		if languageGameData.Game.MoveNames then
			allMovesSource = {}
			for id, name in ipairs(languageGameData.Game.MoveNames) do
				table.insert(allMovesSource, { id = id, name = name })
			end
		end
	end

	RandomizerLog.PokemonNameToIdMap = {}
	RandomizerLog.MoveNameToIdMap = {}
	for _, moveInfo in ipairs(allMovesSource) do
		if moveInfo.id ~= nil and not Utils.isNilOrEmpty(moveInfo.name) then
			local formattedName = RandomizerLog.formatInput(moveInfo.name) or ""
			RandomizerLog.MoveNameToIdMap[formattedName] = tonumber(moveInfo.id) or -1
		end
	end

	-- Kept empty until the inherited parser no longer references the mapping at
	-- all. RBY has no abilities.
	RandomizerLog.AbilityNameToIdMap = {}
	-- Native RBY encounter-set mapping is intentionally separate from the
	-- inherited Hoenn/Kanto remakes tables.
	RandomizerLog.RouteSetNumToIdMap = {}
end

function Gen1RandomizerLog.parseLog(filepath)
	for _, sector in pairs(RandomizerLog.Sectors) do sector.LineNumber = nil end
	RandomizerLog.currentNidoranIsF = true
	return originalParseLog(filepath)
end

function Gen1RandomizerLog.apply()
	RandomizerLog.setupMappings = Gen1RandomizerLog.setupMappings
	RandomizerLog.parseLog = Gen1RandomizerLog.parseLog
	-- Never interpret an RBY encounter set through a Ruby/Emerald route table.
	RandomizerLog.parseRoutes = function() end
end

Gen1RandomizerLog.apply()

return Gen1RandomizerLog
