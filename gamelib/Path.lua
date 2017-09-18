local Path = {}

function Path:Pokecenter()
	if isNpcVisible("Nurse Joy") then
        return usePokecenter() or talkToNpc("Nurse Joy")
    else
        return pf.useNearestPokecenter(getMapName())
    end
end

function Path:Pokemart(itemName, amount)
	--todo: check if u can afford item
	log("--> Buying "..amount.." "..itemName.."s.")
	return pf.useNearestPokemart(itemName, amount)
end

local function moveToLine(coords)
	-- Alternates between 2 positions	
	if lineSwitch then
		if getPlayerX() == coords[1] and getPlayerY() == coords[2] then
			lineSwitch = not lineSwitch
		else
			return moveToCell(coords[1], coords[2])
		end
	else
		if getPlayerX() == coords[3] and getPlayerY() == coords[4] then
			lineSwitch = not lineSwitch
		else
			return moveToCell(coords[3], coords[4])
		end
	end
end

function Path:Hunt(location, huntType)
	if getMapName() == location:gsub("_%w", "") then
		if type(huntType) == "string" then
			huntType = huntType:upper()
		else
			if #huntType == 2 then
				return updateFishing(huntType)
			elseif #huntType > 4 then
				return updateTargetRect(huntType)
			elseif huntType[1] == huntType[3] or huntType[2] == huntType[4] then
				return moveToLine(huntType)
			else
				return moveToRectangle(huntType[1], huntType[2], huntType[3], huntType[4])
			end
		end
		if huntType == "GRASS" then
			return moveToGrass()
		elseif huntType == "WATER" then
			return moveToWater()
		end
	else 
		return pf.moveTo(location)
	end	
end



return Path