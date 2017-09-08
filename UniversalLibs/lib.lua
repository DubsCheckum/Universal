local Lib = {}

function getTableValues(T)
	local tab = {}
	for _, v in pairs(T) do tab[v] = true end
	return tab
end

function getTableValuesZero(T)
	local tab = {}
	for _, v in pairs(T) do tab[v] = 0 end
	return tab
end

function TableLength(T)
 local count = 0
 for _ in pairs(T) do count = count + 1 end
 return count
end

function isOnList(List)
	result = false
    if List[1] ~= "" then
	    for i=1, TableLength(List), 1 do
		    if getOpponentName() == List[i] then
			    result = true
		    end
	    end
    end
    return result
end

function isOnCell(X, Y)
	if getPlayerX() == X and getPlayerY() == Y then
		return true
	end
	return false
end

function hasMoveInTeam(moveName)
	for i=1, getTeamSize() do
		if hasMove(i, moveName) then
			return true
		end
	end
	return false
end

function hasUsablePokemonWithMove(Move)
	local hasUsablePokemonWithMove = {}
	hasUsablePokemonWithMove["id"] = 0
	hasUsablePokemonWithMove["move"] = nil
	local statusMoveList = {"glare", "stun spore", "thunder wave", "hypnosis", "lovely kiss", "sing", "sleep spore", "spore"}
	if Move == statusMove then
		for _,Move in pairs(statusMoveList) do
			for i=1, getTeamSize(), 1 do
				if hasMove(i, Move) and getRemainingPowerPoints(i, Move) >= 1 and isPokemonUsable(i) then
					hasUsablePokemonWithMove["id"] = i
					hasUsablePokemonWithMove["move"] = Move
					return hasUsablePokemonWithMove, true
				end
			end
		end
	else
		for i=1, getTeamSize(), 1 do
			if hasMove(i, Move) and getRemainingPowerPoints(i, Move) >= 1 and isPokemonUsable(i) then
				return i, true
			end
		end		
	end
	return false
end

function hasPokemonWithMove(Move)
	local hasPokemonWithMove = {}
	hasPokemonWithMove["id"] = 0
	hasPokemonWithMove["move"] = nil
	local statusMoveList = {"glare", "stun spore", "thunder wave", "hypnosis", "lovely kiss", "sing", "sleep spore", "spore"}
	if Move == statusMove then
		for _,Move in pairs(statusMoveList) do
			for i=1, getTeamSize(), 1 do
				if hasMove(i, Move) then
					hasPokemonWithMove["id"] = i
					hasPokemonWithMove["move"] = Move
					return hasPokemonWithMove, true
				end
			end
		end
	else
		for i=1, getTeamSize(), 1 do
			if hasMove(i, Move) then
				return i, true
			end
		end		
	end
	return false
end

function hasUsableSync(Nature)
    for i=1, getTeamSize(), 1 do
        if getPokemonAbility(i) == "Synchronize" and getPokemonNature(i) == Nature and getPokemonHealth(i) >= 1 then
            return i, true
        end
    end
    return false
end

function hasSync(Nature)
    for i=1, getTeamSize(), 1 do
        if getPokemonAbility(i) == "Synchronize" and getPokemonNature(i) == Nature then
            return i, true
        end
    end
    return false
end

function getPokemonIdWithItem(ItemName)	
	for i=1, getTeamSize(), 1 do
		if getPokemonHeldItem(i) == ItemName then
			return i
		end
	end
	return 0
end

local function getFirstUsablePokemon()
	for i=1, getTeamSize(), 1 do
		if isPokemonUsable(i) then
			return i
		end
	end
	return 0
end

function leftovers()
	ItemName = "Leftovers"
	local PokemonNeedLeftovers = getFirstUsablePokemon()
	local PokemonWithLeftovers = getPokemonIdWithItem(ItemName)
	
	if getTeamSize() > 0 then
		if PokemonWithLeftovers > 0 then
			if PokemonNeedLeftovers == PokemonWithLeftovers  then
				return false -- now leftovers is on rightpokemon
			else
				takeItemFromPokemon(PokemonWithLeftovers)
				return true
			end
		else
			if hasItem(ItemName) and PokemonNeedLeftovers ~= 0 then
				giveItemToPokemon(ItemName,PokemonNeedLeftovers)
				return true
			else
				return false
			end
		end
	else
		return false
	end
end

function sortTeam()
	if useSync and hasSync(syncNature) then
		if hasSync(syncNature) == 1 then
			return true
		else
			return swapPokemon(hasSync(syncNature), 1)
		end
	end
	if not useSync and useRole and hasPokemonWithMove("Role Play") then
		if hasPokemonWithMove("Role Play") == 1 then
			return true
		else
			return swapPokemon(hasPokemonWithMove("Role Play"), 1)
		end
	end
	if not useSync and not useRole and useSwipe and hasPokemonWithMove("False Swipe") then
		if hasPokemonWithMove("False Swipe") == 1 then
			return true
		else
			return swapPokemon(hasPokemonWithMove("False Swipe"), 1)
		end
	end
	return false
end

function isTeamSorted()
	if useSync and hasSync(syncNature) and hasSync(syncNature) ~= 1 then
		return false
	end
	if not useSync and useRole and hasPokemonWithMove("Role Play") and hasPokemonWithMove("Role Play") ~= 1 then
		return false
	end
	if not useSync and not useRole and useSwipe and hasPokemonWithMove("False Swipe") and hasPokemonWithMove("False Swipe") ~= 1 then
		return false
	end
	return true
end

function isTeamUsable()
	if useSync and not hasUsableSync(syncNature) then
		log("--> No Usable "..syncNature.." Sync Pokemon. Using Pokecenter.")
		return false
		
	elseif useRole and not hasUsablePokemonWithMove("Role Play") then
		log("--> No Usable Pokemon With Role Play. Using Pokecenter.")
		return false
	
	elseif useSwipe and not hasUsablePokemonWithMove("False Swipe") then
		log("--> No Usable Pokemon With False Swipe. Using Pokecenter.")
		return false
	
	else
		return true
	end
end

function updateFishing(list)
	-- Moves to a position and uses rod	
	if getPlayerX() == list[1] and getPlayerY() == list[2] then
		return useItem("Super Rod") or useItem("Good Rod") or useItem("Old Rod")
	else
		return moveToCell(list[1], list[2])
	end
end

function updateTargetRect(list)
	-- Every minutesToMove minutes, picks a random integer between 1 and #list / 4 to get a number corresponding to each rectangle in list	
	if os.difftime(os.time(), rectTimer) > minutesToMove * 60 or rand == 0 or rand > #list / 4 or rand == tmpRand then
		rectTimer = os.time()
		tmpRand = rand
		rand = math.random(#list / 4)
	end
	
	local n = (rand - 1) * 4
	
	if list[n + 1] == list[n + 3] or list[n + 2] == list[n + 4] then
		return moveToLine({list[n + 1], list[n + 2], list[n + 3], list[n + 4]})
	else
		return moveToRectangle(list[n + 1], list[n + 2], list[n + 3], list[n + 4])
	end
end

function moveToLine(list)	
	-- Alternates between 2 positions	
	if lineSwitch then
		if getPlayerX() == list[1] and getPlayerY() == list[2] then
			lineSwitch = not lineSwitch
		else
			return moveToCell(list[1], list[2])
		end
	else
		if getPlayerX() == list[3] and getPlayerY() == list[4] then
			lineSwitch = not lineSwitch
		else
			return moveToCell(list[3], list[4])
		end
	end
end

function goToPath()
local map = getMapName()
local location = location
	if getMapName() == location then
		if type(area) == "string" then
			area = area:upper()
		else
			if #area == 2 then
				return updateFishing(area)
			elseif #area > 4 then
				return updateTargetRect(area)
			elseif area[1] == area[3] or area[2] == area[4] then
				return moveToLine(area)
			else
				return moveToRectangle(area[1], area[2], area[3], area[4])
			end
		end
		
		if area == "GRASS" then
			return moveToGrass()
		elseif area == "WATER" then
			return moveToWater()
		end
	else 
		pf.moveTo(map, location:gsub("_%w", ""))
	end	
end

function startRole()
	if usedRole == false then
		if hasUsablePokemonWithMove("Role Play") then
			if getActivePokemonNumber() == hasUsablePokemonWithMove("Role Play") then
				if useMove("Role Play") then
					usedRole = true
				end
			else
				if sendPokemon(hasUsablePokemonWithMove("Role Play")) then return end
			end
		else
			startBattle()
		end
	else
		if roleMatched == true then
			startBattle()
		else
			run()
		end
	end	
end

function startBattle()
	if isPokemonUsable(getActivePokemonNumber()) then
		if getOpponentHealthPercent() > throwHealth then	
			if useSwipe and hasUsablePokemonWithMove("False Swipe") then
				if getActivePokemonNumber() == hasUsablePokemonWithMove("False Swipe") then
					if useMove("False Swipe") then return end
				else
					if sendPokemon(hasUsablePokemonWithMove("False Swipe")) then return end
				end
			elseif useStatus and hasUsablePokemonWithMove(statusMove) then
				if getActivePokemonNumber() == hasUsablePokemonWithMove(statusMove)["id"] then
					if getOpponentStatus() == "None" then
						if useMove(hasPokemonWithMove(statusMove)["move"]) then return end
					else
						if useItem(typeBall) then return end
					end
				else
					if sendPokemon(hasUsablePokemonWithMove(statusMove)["id"]) then return end
				end

			else
				if isPokemonUsable(getActivePokemonNumber()) then
					if weakAttack() then return end
				else
					if sendUsablePokemon() or sendAnyPokemon() or run() then return end
				end
			end

		else
			if useStatus and hasUsablePokemonWithMove(statusMove) then
				if getActivePokemonNumber() == hasUsablePokemonWithMove(statusMove)["id"] then
					if getOpponentStatus() == "None" then
						if useMove(hasPokemonWithMove(statusMove)["move"]) then return end
					else
						if useItem(typeBall) then return end
					end
				else
					if sendPokemon(hasUsablePokemonWithMove(statusMove)["id"]) then return end
				end
			else
				if isPokemonUsable(getActivePokemonNumber()) then
					if useItem(typeBall) then return end
				else
					if sendUsablePokemon() or sendAnyPokemon() or run() then return end
				end
			end
		end	
	else
		if sendUsablePokemon() or sendAnyPokemon() or run() then return end
	end
end

return {
	getTableValues = getTableValues,
	getTableValuesZero = getTableValuesZero,
	TableLength = TableLength,
	isOnList = isOnList,
	isOnCell = isOnCell,
	hasMoveInTeam = hasMoveInTeam,
	hasUsablePokemonWithMove = hasUsablePokemonWithMove,
	hasPokemonWithMove = hasPokemonWithMove,
	hasUsableSync = hasUsableSync,
	hasSync = hasSync,
	getPokemonIdWithItem = getPokemonIdWithItem,
	getFirstUsablePokemon = getFirstUsablePokemon,
	leftovers = leftovers,
	sortTeam = sortTeam,
	isTeamSorted = isTeamSorted,
	isTeamUsable = isTeamUsable,
	updateFishing = updateFishing,
	updateTargetRect = updateTargetRect,
	moveToLine = moveToLine,
	goToPath = goToPath,
	startRole = startRole,
	startBattle = startBattle
}