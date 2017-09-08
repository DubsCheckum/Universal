--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- START OF CONFIGURATION
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--Put in the pokemon you want to catch. Leave "" if none. Example: pokemonToCatch = {"Pokemon 1", "Pokemon 2", "Pokemon 3"}
-- "" if not using!
local pokemonToCatch = {"Magikarp"} --If you have a pokemonToRole, don't put them here too, unless you want to catch that pokemon with any ability.

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++	
	
--Must be filled in. Determines what type of ball to use when catching, and what type to buy. Example: typeBall = "Pokeball"
local typeBall = "Pokeball"
--If buying balls, put in the amount of balls you want to have in your inventory.
local buyBallAmount = 25
--Will buy more balls when your type of ball reaches X.
local buyBallsAt = 25

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--Location you want to hunt. Example: location = "Dragons Den"
local location = "Route 13"

-- Put "Grass" for grass, "Water" for water, {x, y} for fishing cell, {x1, y1, x2, y2} for rectangle
-- If you're using a rectangle, you can set more rectangles to hunt in just by adding 4 more parameters. Example: local area = {x1, y1, x2, y2, x1, y1, x2, y2}
local area = "Grass"

-- If you're using multiple rectangles, this is the amount of time in minutes that we'll stay in one rectangle before moving to a different one
local minutesToMove = 30
	
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

--Put in the nature of your All Day Sync Pokemon. Example: syncNature = "Adamant"
-- "" if not using!
local syncNature = ""

--If using Role Play, put in the abilities you want to catch. If not using, put "". You can have multiple Abilities/multiple Pokemon. Example: roleAbility = {"Ability 1", "Ability 2", "Ability 3"}
-- {""} if not using!
local roleAbility = {""}

--If using Role Play, put in the pokemon you want to Role. If not using, put "". You can have multiple Pokemon. Example: pokemonToRole = {"Pokemon 1", "Pokemon 2"}
local pokemonToRole = {""}

--If using a Status Move, set true.
--Status Move List - {"glare", "stun spore", "thunder wave", "hypnosis", "lovely kiss", "sing", "sleep spore", "spore"}
local useStatus = false

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- END OF CONFIGURATION
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

name = "Basic Catcher"
author = "Crazy3001, reborn by DubsCheckum"
description = "Make sure your configuration is done properly. Press Start."				

local pf = require "Pathfinder/MoveToApp"
local Lib = require "Pathfinder/Lib/lib"
local uLib = require "UniversalLibs/lib"
local map = nil

function onStart()
	-- lazy config defaults
	useSync = false
	if syncNature ~= nil then useSync = true end
	if roleAbility ~= nil then useRole = true end
	useSwipe = false
	throwHealth = 50
	if uLib.hasMoveInTeam("False Swipe") then 
		useSwipe = true
		throwHealth = 1
	end
	buyBalls = true
	catchNotCaught = true
	useLeftovers = true
	---------------------
	healCounter = 0
	shinyCounter = 0
	catchCounter = 0
	wildCounter = 0
	rand = 0 -- Used to represent each rectangle in area
	tmpRand = 0 -- Used to make sure rand is different every time we call math.random
	lineSwitch = false -- Used in moveToLine()
	rectTimer = os.time()
	log("****************************************BOT STARTED*****************************************")
end

function onPause()
	log("***********************************PAUSED - SESSION STATS***********************************")
    log("You have visited the PokeCenter " .. healCounter .. " times.")
	log("Info | Shineys encountered: " .. shinyCounter)
	log("Info | Pokemon caught: " .. catchCounter)
	log("Info | Pokemon encountered: " .. wildCounter)
    log("********************************************************************************************")
end

function onDialogMessage(msg)
    if stringContains(msg, "There you go, take care of them!") then
		healCounter = healCounter + 1
		safariOver = false
		log("You have visited the PokeCenter ".. healCounter .." times.")
    end
end

function onBattleMessage(msg)
	if stringContains(msg, "A Wild SHINY ") then
		shinyCounter = shinyCounter + 1
		wildCounter = wildCounter + 1
	elseif stringContains(msg, "Success! You caught ") then
		catchCounter = catchCounter + 1
	elseif stringContains(msg, "A Wild ") then
	    wildCounter = wildCounter + 1
	elseif stringContains(msg, "You failed to run away") 
		or stringContains(msg, "You can not run away!")
	then
		failedRun = true
	elseif stringContains(msg, "has fainted") then
		failedRun = false
	elseif stringContains(msg, "You can not switch this Pokemon") then	
		canNotSwitch = true
	end
	log("Info | Shineys encountered: " .. shinyCounter)
	log("Info | Pokemon caught: " .. catchCounter)
	log("Info | Pokemon encountered: " .. wildCounter)
	for _,value in pairs(roleAbility) do
		if stringContains(msg, "is now "..value) then
			roleMatched = true
			break
		end
	end
end

function onPathAction()
	usedRole = false
	roleMatched = false
	canNotSwitch = false
	failedRun = false
	local map = getMapName()
	local ballAmount = buyBallAmount - getItemQuantity(typeBall)

	if buyBalls then
		if getItemQuantity(typeBall) <= buyBallsAt then
			log("--> Buying " .. ballAmount .. " " .. typeBall .. "s.")
			return pf.useNearestPokemart(map, typeBall, ballAmount)
		end
	end

	if useLeftovers then
		if uLib.leftovers() then
			return true
		end
	end

	if not safariOver then	
		if uLib.isTeamSorted() then
			if uLib.isTeamUsable() then
				uLib.goToPath()
			else
				pf.useNearestPokecenter(map)
			end
		else
			uLib.sortTeam()
		end
	else
		log("--> Safari Time Is Over, Using Pokecenter")
		pf.useNearestPokecenter(map)
	end	
end

function onBattleAction()
	if isWildBattle() and uLib.isOnList(pokemonToRole) and useRole and uLib.hasUsablePokemonWithMove("Role Play") then
		startRole()
	elseif isWildBattle() 
		and (isOpponentShiny() 
		or uLib.isOnList(pokemonToCatch) 
		or (catchNotCaught 
		and not isAlreadyCaught())
		or getOpponentForm ~= 0) 
	then
		uLib.startBattle()
	elseif failedRun then
		log("--> Failed Run")
		return attack() or sendAnyPokemon()
	elseif canNotSwitch then
		log("--> Can Not Switch")
		canNotSwitch = false
		return attack() or run()
	else
		return run() or sendUsablePokemon() or sendAnyPokemon()
	end
end
