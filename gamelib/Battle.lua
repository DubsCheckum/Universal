local Battle = {}

-- todo: smart catch (just throw pokeballs at low leveled pokemon)

local function isOpponentOnCatchList()
	return Table:Contains(pokemonToCatch,getOpponentName())
end

function Battle:IsOpponentDesirable()
	if not isAlreadyCaught() then
		--todo: count how many new pokemon caught
		pfLib.log1time("Info | Catching uncaught Pokemon ["..getOpponentName().."]. Do not be alarmed.")
		return true
	end
	if isWildBattle()
		and (isOpponentShiny()
		or not isAlreadyCaught()
		or getOpponentForm() ~= 0
		or isOpponentOnCatchList())
	then
		return true
	end
	return false
end

-- pokemon w/ recoil moves
function Battle:IsOnBlacklist(blacklist)
	types = getOpponentType()

	-- types are returned like: {[1] = "Normal", [2] = "None"}
	for k,_type in ipairs(types) do
		if Table:Contains(blacklist.Types, _type) then
			log("Info | Blacklisted type for "..blacklist.Name.." [".._type.."]")
			return true
		end
	end

	if Table:Contains(blacklist.Pokemon, getOpponentName()) then
		log("Info | Blacklisted Pokemon for "..blacklist.Name.." ["..getOpponentName().."]")
		return true
	end
	return false
end

local function cantUse(moveName)
	fatal("Error | Can't use "..moveName.." for some reason.")
end

function Battle:RolePlay()
	if hasRolePlay then
		if isPokemonUsable(pokeWithRolePlay) and getActivePokemonNumber() ~= pokeWithRolePlay then
			return sendPokemon(pokeWithRolePlay)
		elseif not Table:Contains(desiredAbility,opponentAbility) and opponentAbility ~= nil then
			return self:Run()
		end
		return useMove("Role Play") or cantUse("Role Play")
	else
		fatal("Error: You don't have a Pokemon with Role Play!")
	end
end

function Battle:FalseSwipe()
	if Team:IsFalseSwiperUsable() and getActivePokemonNumber() ~= pokeWithFalseSwipe then
		return sendPokemon(pokeWithFalseSwipe)
	elseif getActivePokemonNumber() == pokeWithFalseSwipe then
		return useMove("False Swipe") or cantUse("False Swipe")
	end
	return false
end

function Battle:StatusMove()
	if hasStatusMove then
		if Team:IsStatusMoverUsable(pokeWithStatusMove) then
			if hasMove(getActivePokemonNumber(),statusMove) then
				return useMove(statusMove)
			end
			return sendPokemon(pokeWithStatusMove)
		end
	end
end

function Battle:Catch()
	if getItemQuantity("Ultra Ball")
		+ getItemQuantity("Great Ball")
		+ getItemQuantity("Pokeball")
		== 0
	then
		pfLib.log1time("Info | No pokeballs, oh well")
		return false
	end
	return useItem(typeBall) or useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball")
end

function Battle:SendHighestUsable()
	local highestLvl = 0
	local highestLvlIndex = 1
	for i=1, getTeamSize() do
		if getPokemonLevel(i) > highestLvl then
			highestLvl = getPokemonLevel(i)
			highestLvlIndex = i
		end
	end
	return swapPokemonWithLeader(highestLvlIndex)
end

function Battle:WeakAttack()
	return weakAttack()
end

function Battle:Attack()
	return attack()
end

function Battle:Run()
	if failedRun then
		return false
	end
	return run()
end

return Battle