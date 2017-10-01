local Team = {}

function Team:IsSorted()
	local name = name:lower()
	if stringContains(name,"catch") then
		if hasSync then
			return getPokemonUniqueId(1) == syncID
		elseif hasRolePlay then
			return getPokemonUniqueId(1) == rolePlayID
		elseif hasFalseSwipe then
			return getPokemonUniqueId(1) == falseSwipeID
		elseif hasStatusMove then
			return getPokemonUniqueId(1) == statusMoveID
		end
	elseif stringContains(name,"level") then
		return isTeamSortedByLevelAscending()
	end
	return true
end

--[[
use the name to determine the type of script
and thus, the type of sort needed
]]--
function Team:Sort()
	--todo: optimize this lol
	hasTeamOrderChanged = true
	local name = name:lower()
	if stringContains(name,"catch") then
		if hasSync then
			if getPokemonUniqueId(1) ~= syncID then
				return swapPokemonWithLeader(pokeWithSync)
			end
		end
		if hasRolePlay then
			if getPokemonUniqueId(1) ~= rolePlayID then
				return swapPokemonWithLeader(pokeWithSync)
			end
		end
		if hasFalseSwipe then
			if getPokemonUniqueId(1) ~= falseSwipeID then
				return swapPokemonWithLeader(pokeWithSync)
			end
		end
		if hasStatusMove then
			if getPokemonUniqueId(1) ~= statusMoveID then
				return swapPokemonWithLeader(pokeWithSync)
			end
		end
	elseif stringContains(name,"level") then
		return sortTeamByLevelAscending()
	end
	return true
end

function Team:IsSyncUsable()
	if not hasSync then return true end
	return isPokemonUsable(pokeWithSync)
end

function Team:IsFalseSwiperUsable()
	if not hasFalseSwipe then return true end
	return getPP(pokeWithFalseSwipe,"False Swipe") > 0 and isPokemonUsable(pokeWithFalseSwipe)
end

function Team:IsRolePlayerUsable()
	if not hasRolePlay then return true end
	return getPP(pokeWithRolePlay,"Role Play") > 0 and isPokemonUsable(pokeWithRolePlay)
end

function Team:IsStatusMoverUsable()
	if not hasStatusMove then return true end
	return getPP(pokeWithStatusMove,statusMove) > 0 and isPokemonUsable(pokeWithStatusMove)
end

function Team:IsUsable()
	return self:IsSyncUsable()
		and self:IsFalseSwiperUsable()
		and self:IsStatusMoverUsable()
		and self:IsRolePlayerUsable()
end

local function allHasItem(itemName)
	local itemCount = 1
	for i=1, getTeamSize() do
		if hasItem(itemName) then
			itemCount = itemCount + 1
		end
	end
	return itemCount == getTeamSize()
end

function Team:EquippedAll(itemName)
	return allHasItem(itemName) or not hasItem(itemName)
end

function Team:EquipAll(itemName)
	for i=1, getTeamSize() do
		if hasItem(itemName) then
			giveItemToPokemon(itemName, i)
		else
			break
		end
	end
end

function Team:HasMove(moveName)
	for i=1, getTeamSize() do
		if hasMove(i, moveName) then
			return true,i
		end
	end
	return false
end

function Team:HasAbility(ability)
    for i=1, getTeamSize() do
        if getPokemonAbility(i) == ability then
            return true,i
        end
    end
    return false
end

function Team:HasItem(itemName)
	for i=1, getTeamSize() do
		if getPokemonHeldItem(i) == itemName then
			return true,i
		end
	end
	return false
end

return Team