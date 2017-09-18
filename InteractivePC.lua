local page = 1
setTextOption(page,"1")
setTextOptionName(page,"Page")

function refreshScreen()
	log("Page: "..getTextOption(page).."/"..getPCBoxCount().." │ Pokemon: "..getPCPokemonCount())
	log("┌──────┬──────┬──────┬──────┐")
	log("│	│  2   │      │      │")
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
		time = math.floor(time/2)
	else
		meridiem = "AM"
	end
	return time.." "..meridiem
end

function submit()

end

function onStart()
	if isPCOpen() then
		if isCurrentPCBoxRefreshed() then
			log("InteractivePC has booted up!")
			log("Welcome, the time is "..time())
		end
	else
		return usePC()
	end
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