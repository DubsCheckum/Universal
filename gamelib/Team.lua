local Team = {}

function Team:IsSorted()
	--todo
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
	for i=1, getTeamSize(), 1 do
		if hasItem(itemName) then
			itemCount = itemCount + 1
		end
	end
	return itemCount == getTeamSize()
end

function Team:EquippedAll(itemName)
	if allHasItem(itemName) or not hasItem(itemName) then
		return true
	end
	return false
end

function Team:EquipAll(itemName)
	for i=1, getTeamSize(), 1 do
		if hasItem(itemName) then
			giveItemToPokemon(itemName, i)
		else
			break
		end
	end
end

function Team:HasMove(moveName)
	for i=1, getTeamSize(), 1 do
		if hasMove(i, moveName) then
			return true,i
		end
	end
	return false
end

function Team:HasAbility(ability)
    for i=1, getTeamSize(), 1 do
        if getPokemonAbility(i) == ability then
            return true,i
        end
    end
    return false
end

function Team:HasItem(itemName)
	for i=1, getTeamSize(), 1 do
		if getPokemonHeldItem(i) == itemName then
			return true,i
		end
	end
	return false
end

return Team