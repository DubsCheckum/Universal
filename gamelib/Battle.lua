local Battle = {}

-- todo:
-- smart catch (just throw pokeballs at low leveled pokemon)

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
		or isOpponentOnCatchList()
		or opponentAbility == desiredAbility)
	then
		return true
	end
	return false
end

function Battle:RolePlay()
	if hasRolePlay then
		if isPokemonUsable(pokeWithRolePlay) then
			return swapPokemon(pokeWithRolePlay)
		elseif not Table:Contains(desiredAbility,opponentAbility) and opponentAbility ~= nil then
			self:Run()
		end
		return useMove("Role Play")
	else
		fatal("Error: You don't have a Pokemon with Role Play!")
	end
end

-- pokemon w/ recoil moves
local function isOpponentOnFalseSwipeBlacklist()
	-- take-down doesn't affect ghost types
	types = getPokemonType(pokeWithFalseSwipe)
	for pokeType in pairs(types) do
		if pokeType == "Ghost" then
			return false
		end
	end

	local falseSwipeBlacklist = {"Eevee","Beldum","Stantler"}
	return Table:Contains(falseSwipeBlacklist,getOpponentName())
end

function Battle:FalseSwipe()
	if hasFalseSwipe then
		if Team:IsFalseSwiperUsable() and getActivePokemonNumber() ~= pokeWithFalseSwipe then
			return swapPokemon(pokeWithFalseSwipe)
		elseif not isOpponentOnFalseSwipeBlacklist() then
			return useMove("False Swipe")
		end
	end
	return false
end

function Battle:StatusMove()
	if hasStatusMove then
		if Team:IsStatusMoverUsable(statusMove) then
			return swapPokemon(pokeWithStatusMove)
		end
	end
end

function Battle:Catch()

	return useItem("Ultra Ball") or useItem("Great Ball") or useItem("Pokeball")
end

function Battle:WeakAttack()
	return weakAttack()
end

function Battle:Attack()
	return attack()
end

function Battle:Run()
	--todo
	return run()
end

return Battle