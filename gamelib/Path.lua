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
	pfLib.log1time("--> Buying "..amount.." "..itemName.."s.")
	return pf.useNearestPokemart(itemName, amount)
end

local function moveToLine(coords)
	-- Alternates between 2 positions
	if lineSwitch then
		if getPlayerX() == coords[1] and getPlayerY() == coords[2] then
			lineSwitch = not lineSwitch
		end
		return assert(moveToCell(coords[1], coords[2]),"Error | Can't moveToLine")
	else
		if getPlayerX() == coords[3] and getPlayerY() == coords[4] then
			lineSwitch = not lineSwitch
		end
		return assert(moveToCell(coords[3], coords[4]),"Error | Can't moveToLine")
	end
end

local function moveToFish(list)
	if #list[1] == 2 then
		if os.difftime(os.time(), switchTimer) > minutesToSwitch * 60 or rand == 0 then
        	switchTimer = os.time()
        	rand = math.random(#list)
        	--log("gen new rand"..#list.." "..list[rand][1].." "..list[rand][2])
    	end
    	if getPlayerX() ~= list[rand][1] and getPlayerY() ~= list[rand][2] then
    		return assert(moveToCell(list[rand][1],list[rand][2]),"Error | Can't moveToCell ("..list[rand][1]..","..list[rand][1]..")")
    	end
	else
    	if getPlayerX() ~= list[1] and getPlayerY() ~= list[2] then
        	return assert(moveToCell(list[1], list[2]),"Error | Can't moveToCell ("..list[rand][1]..","..list[rand][1]..")")
        end
    end
    return useItem("Super Rod")
    or useItem("Good Rod")
    or useItem("Old Rod")
    or fatal("Error | You don't have a fishing rod lol.")
end

local function moveToRect(list)
    -- Every minutesToSwitch minutes, picks a random integer between 1 and #list / 4 to get a number corresponding to each rectangle in list
    if os.difftime(os.time(), switchTimer) > minutesToSwitch * 60 or rand == 0 then
        switchTimer = os.time()
        rand = math.random(#list)
    end

    if list[rand][1] == list[rand][3] or list[rand][2] == list[rand][4] then
        return assert(moveToLine({list[rand][1], list[rand][2], list[rand][3], list[rand][4]}),"Error | Can't moveToLine()")
    end

    return moveToRectangle(list[rand][1], list[rand][2], list[rand][3], list[rand][4])
end

--todo: switch between rectangles
function Path:Hunt(location)
	local map = getMapName()

	if pf.mapName():lower() == location:lower() then
		local huntType = huntType -- create local huntType to manipulate
		if hunt[map] then huntType = hunt[map] end -- assign presets

		-- note moveToRect is for presets and moveToRectangle is for regular
		if type(huntType) == "string" then

			-- handle string huntType
			huntType = huntType:lower()
			if huntType == "grass" then
				return assert(moveToGrass(),"Error | Can't moveToGrass")
			elseif huntType == "water" then
				return assert(moveToWater(),"Error | Can't moveToWater")
			elseif huntType == "cave" then
				return assert(moveToNormalGround(),"Error | Can't moveToNormalGround (cave)")
			end

		else

			-- handle table and preset huntTypes
			if #huntType == 4 then -- regular rect/line
				if huntType[1] == huntType[3] or huntType[2] == huntType[4] then
					return moveToLine(huntType)
				end
				return assert(moveToRectangle(huntType[1],huntType[2],huntType[3],huntType[4]),"Error | Can't moveToRectangle")
			elseif #huntType[1] == 2 then -- preset fish
				return moveToFish(huntType)
			elseif #huntType[1] == 4 then -- preset rect/line
				return moveToRect(huntType)
			end
			return fatal("Error | huntType is invalid: "..Table:Dump(huntType))
		end

		assert(fatal("Error | Can't move to the huntType '"..huntType.."'"),"Error | Can't move to the huntType -> "..Table:Dump(huntType))
	else
		return pf.moveTo(location)
	end
end

return Path