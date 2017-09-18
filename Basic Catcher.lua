--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- START OF CONFIGURATION
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Put in the pokemon you want to catch. Leave "" if none. Example: pokemonToCatch = {"Pokemon 1", "Pokemon 2", "Pokemon 3"}
-- {""} if not using!
pokemonToCatch = {"Magikarp"} --If you have a pokemonToRole, don't put them here too, unless you want to catch that pokemon with any ability.

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Must be filled in. Determines what type of ball to use when catching, and what type to buy. Example: typeBall = "Pokeball"
local typeBall = "Pokeball"
-- If buying balls, put in the amount of balls you want to have in your inventory.
-- no quotation marks!
local buyBallAmount = 25
-- Will buy more balls when your type of ball reaches X.
-- no quotation marks!
local buyBallsAt = 25

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Location you want to hunt. Example: location = "Dragons Den"
local location = "Route 17"

-- Put "Grass" for grass, "Water" for water, {x, y} for fishing cell, {x1, y1, x2, y2} for rectangle
-- If you're using a rectangle, you can set more rectangles to hunt in just by adding 4 more parameters. Example: local area = {x1, y1, x2, y2, x1, y1, x2, y2}
local huntType = {18,6,23,6}

-- If you're using multiple rectangles, this is the amount of time in minutes that we'll stay in one rectangle before moving to a different one
-- no quotation marks!
local minutesToMove = 30

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- Put in the nature of your sync Pokemon. Example: syncNature = "Adamant"
-- "" if not using!
local syncNature = ""

-- If using Role Play, put in the abilities you want to catch. If not using, put {""}. You can have multiple Abilities/multiple Pokemon. Example: roleAbility = {"Ability 1", "Ability 2", "Ability 3"}
-- {""} if not using!
local roleAbility = {""}

-- If using Role Play, put in the pokemon you want to Role. If not using, put {""}. You can have multiple Pokemon. Example: pokemonToRole = {"Pokemon 1", "Pokemon 2"}
-- {""} if not using!
local pokemonToRole = {""}

-- If using a Status Move, set true.
-- Status Move List - {"glare", "stun spore", "thunder wave", "hypnosis", "lovely kiss", "sing", "sleep spore", "spore"}
local useStatus = false

useRolePlay = false
desiredAbility = {""}

--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
-- END OF CONFIGURATION
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

name = "Basic Catcher"
author = "Crazy3001, reborn by DubsCheckum"
description = "Make sure your configuration is done properly. Press Start."

pf     = require("Pathfinder/MoveToApp")
pfLib  = require("Pathfinder/Lib/Lib")
Table  = require("syslib/Table")
Battle = require("gamelib/Battle")
Path   = require("gamelib/Path")
PC     = require("gamelib/PC")
Player = require("gamelib/Player")
Team   = require("gamelib/Team")
getPP  = getRemainingPowerPoints

function onStart()
	-- lazy config defaults
	throwHealth = 50
	buyBalls = true
	---------------------
	healCounter = 0
	shinyCounter = 0
	catchCounter = 0
	wildCounter = 0
	rand = 0 -- Used to represent each rectangle in area
	tmpRand = 0 -- Used to make sure rand is different every time we call math.random
	lineSwitch = false -- Used in moveToLine()
	rectTimer = os.time()

	hasFalseSwipe,pokeWithFalseSwipe = Team:HasMove("False Swipe")
	hasRolePlay,pokeWithRolePlay = Team:HasMove("Role Play")
	statusMoves = {"Spore","Sleep Powder","Hypnosis","Lovely Kiss","Sing","Glare","Stun Spore","Thunder Wave"}
	for moveName in pairs(statusMoves) do
		hasStatusMove,pokeWithStatusMove = Team:HasMove(moveName)
		if hasStatusMove then
			statusMove = moveName
			break
		end
	end

	log("*************************BOT STARTED**************************")
	log("Info | False Swipe ― "..tostring(hasFalseSwipe))
	log("Info | Status Move ― "..tostring(hasStatusMove))
	log("Info | Role Play ― "..tostring(hasRolePlay))
	log("Info | Pokeballs ― "
		..getItemQuantity("Pokeball")
		+ getItemQuantity("Great Ball")
		+ getItemQuantity("Ultra Ball"))
	log("Info | Pokemon to catch ― "..table.concat(pokemonToCatch,", "))
end

function onPause()
	log("********************PAUSED - SESSION STATS********************")
	log("Info | Shineys encountered: " .. shinyCounter)
	log("Info | Pokemon caught: " .. catchCounter)
	log("Info | Pokemon encountered: " .. wildCounter)
    log("**************************************************************")
end

function onDialogMessage(msg)
    if stringContains(msg, "There you go, take care of them!") then
		healCounter = healCounter + 1
		safariOver = false
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
	if useRolePlay then
		for ability in desiredAbility do
			if stringContains(msg, "is now "..ability) then
				roleMatched = true
				break
			end
		end
	end
end

function onPathAction()
	--todo: take items from newly caught pokes
	--		advanced hunt patterns
	--		heal with items
	opponentAbility = nil
	roleMatched = false
	canNotSwitch = false
	failedRun = false

	if buyBalls then
		local _ballAmt = buyBallAmount - getItemQuantity(typeBall)
		if getItemQuantity(typeBall) <= buyBallsAt then
			return Path:Pokemart(typeBall, _ballAmt)
		end
	end
	if Team:IsSorted() then
		if Team:EquippedAll("Leftovers") then
			if Team:IsUsable() then
				return Path:Hunt(location, huntType)
			end
		else
			return Team:EquipAll("Leftovers")
		end
	else
		return Team:Sort()
	end
	return Path:Pokecenter()
end

function onBattleAction()
	if Battle:IsOpponentDesirable() then
		if useRolePlay then
			return Battle:RolePlay()
		elseif hasStatusMove and getOpponentStatus() == "None" then
			return Battle:StatusMove()
		elseif hasFalseSwipe and getOpponentHealth() > 1 then
			return Battle:FalseSwipe()
		end
		return Battle:Catch()
	else
		return Battle:Run() or attack() or sendUsablePokemon() or sendAnyPokemon()
	end
end