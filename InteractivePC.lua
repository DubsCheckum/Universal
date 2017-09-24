local openBox = openPCBox
local getBoxCount = getPCBoxCount
local getBox = getCurrentPCBoxId
local getBoxSize = getCurrentPCBoxSize
local getPokeID = getPokemonIdFromPC
local isBoxRefreshed = isCurrentPCBoxRefreshed

setTextOption(1,"1")
setTextOptionName(1,"Page")

setTextOption(2,"")
setTextOptionName(2,"Search")

setOption(3,false)
setOptionName(3,"Submit")

-- while true do
-- 	if openPCBox(1) then
-- 		getTime()
-- 	else
-- 		openPCBox(2)
-- 	end
-- end

-- function errorChecks()
-- 	assert(stringContains(getMapName(),"Pokecenter"),"You must be in a Pokecenter.")
-- end



function onStart()
	if isPCOpen() then
		if isBoxRefreshed() then
			local page = getOption(1)
			log("InteractivePC has booted up!")
			log("Welcome, the time is "..time())
			if openBox(page) then
				pokes = getAllPokeIDsInBox(page)
				if #pokes == 0 then log("Box empty") end
				for i=1,#pokes,1 do
					log(i..": "..pokes[i])
				end
			end
		end
	else
		return usePC()
	end
end

-- registerHook("onStart",errorChecks())

function getAllPokeIDsInBox(box)
	pokes = {}
	for poke=1,getCurrentPCBoxSize(),1 do
		pokes[poke] = getPokeID(box,poke)
	end
	return pokes
end

function getAllPokeIDs()
	local pc = {}
	for box=1,getBoxCount(),1 do
		for poke=1,getBoxSize(),1 do
			pc[box][poke] = getPokeID(box,ii)
		end
	end
	return pc
end

function refreshScreen()
	log("Box: "..getBoxId().."/"..getBoxCount().." │ Pokemon: "..getPCPokemonCount())
	log("┌──────┬──────┬──────┬──────┐")
	--log("│".. .."│".. .."│".. .."│".. .."│")
	log("├──────┼──────┼──────┼──────┤")
	log("│  16  │  8   │      │      │")
	log("├──────┼──────┼──────┼──────┤")
	log("│  64  │  32  │  16  │      │")
	log("├──────┼──────┼──────┼──────┤")
	log("│ 128  │ 512  │ 128  │  64  │")
	log("└──────┴──────┴──────┴──────┘")
end



function time()
	time = getTime()
	if time > 12 then
		meridiem = "PM"
		time = math.floor(time/2)-1
	else
		meridiem = "AM"
	end
	return time.." "..meridiem
end

-- if isPCOpen() then
-- 	if isCurrentPCBoxRefreshed() then
-- 		log("inside box")
-- 		-- while true do
-- 		-- -- if getOption(submit) then
-- 		-- -- 	submit()
-- 		-- -- 	setOption(submit,false)
-- 		-- -- end
-- 		-- 	return refreshScreen()
-- 		-- end
-- 	end
-- else
-- 	usePC()
-- end

