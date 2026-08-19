-- Random-evolution percentages for Gen 3 NatDex are not used in RBY.
-- RandomizerLog already stores per-seed evolutions from the UPR log.
PokemonRevoData = {
	RevoData = nil,
}

function PokemonRevoData.initialize()
	PokemonRevoData.RevoData = nil
end

function PokemonRevoData.getEvoTable(pokemonID, targetEvoId)
	PokemonRevoData.tryLoadData()
	if not PokemonData.isValid(pokemonID) or not PokemonRevoData.RevoData[pokemonID] then
		return nil
	end
	local revo = PokemonRevoData.RevoData[pokemonID]
	if not revo.options then
		return revo
	end
	targetEvoId = targetEvoId or revo.options[1]
	if not PokemonData.isValid(targetEvoId) or not revo[targetEvoId] then
		return nil
	end
	return revo[targetEvoId]
end

function PokemonRevoData.getEvoOptions(pokemonID)
	PokemonRevoData.tryLoadData()
	if not PokemonData.isValid(pokemonID) or not PokemonRevoData.RevoData[pokemonID] then
		return nil
	end
	return PokemonRevoData.RevoData[pokemonID].options
end

function PokemonRevoData.tryLoadData()
	if PokemonRevoData.RevoData then return end
	PokemonRevoData.RevoData = {}
end
