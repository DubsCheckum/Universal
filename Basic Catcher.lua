-- Encounter an issue? Contact me on PROShine forums (DubsCheckum)
-- or on the PROShine Discord server (@nothingispossible#2522)

--+++++++++++++++++++--
--+ REQUIRED FIELDS +--
--+++++++++++++++++++--

-- Put in the pokemon you want to catch. Leave {""} if none. Example: pokemonToCatch = {"Pokemon 1", "Pokemon 2", "Pokemon 3"}
pokemonToCatch = {"Grimer","Muk"} --If you have a pokemonToRole, don't put them here too, unless you want to catch that pokemon with any ability.

-- Location you want to hunt. Example: location = "Dragons Den"
location = "Route 17"

-- Put "Grass" for grass, "Water" for water, "Cave" for cave, {x, y} for fishing cell, {x1, y1, x2, y2} for rectangle
-- If you're using a rectangle, you can set more rectangles to hunt in just by putting the coord tables in another table. Example: huntType = { {x1,y1,x2,y2}, {x1,y1,x2,y2} }
huntType = {{19,13,20,13}, {22,6,24,7}}

--+++++++++++++++++++--
--+ OPTIONAL FIELDS +--
--+++++++++++++++++++--

--[[ POKEBALLS ]]--
typeBall      = "Pokeball" -- Determines what type of ball to use when catching, and what type to buy.
buyBallsAt    = 25 -- Will buy more balls when your type of ball reaches X. default = 25
buyBallAmount = 25 -- If buying balls, put in the amount of balls you want to have in your inventory. default = 25

--[[ SYNCHRONIZE ]]--
syncNature = "Timid" -- Put in the nature of your sync Pokemon. Example: syncNature = "Adamant". If not using, put "".

--[[ STATUS MOVE ]]--
useStatus = false

--[[ ROLE PLAY ]]--
useRolePlay    = true -- Use role play? true/false
pokemonToRole  = {""} -- If using Role Play, put in the pokemon you want to Role. Example: pokemonToRole = {"Pokemon 1", "Pokemon 2"}.
desiredAbility = {""} -- If using Role Play, catch pokemon with these desired abilities. Example: desiredAbility = {"Blaze", "Overgrow"}.

--[[ HUNT ]]--
minutesToSwitch = 1 -- If you're using multiple rectangles or fishing spots, this is the amount of time in minutes that we'll stay in one rectangle before moving to a different one

-- You can also set huntType presets here for each location (advanced)
-- These have priority over huntType
-- Don't touch this if you have no experience with Lua.
hunt = {
	["Cerulean Cave"] = "cave",
	["Route 18"] = {{30,23,33,23},{30,20,30,23}},
	--["Route 17"] = {{10,27},{21,27}},
	["Route 17"] = {18,6,23,6}
	--["Route 17"] = "grass"
}

  --========================--     --========================--     --========================--
--=== END OF CONFIGURATION ===-- --=== END OF CONFIGURATION ===-- --=== END OF CONFIGURATION ===--
  --========================--     --========================--     --========================--

-- todo: disablepms setOption

name = "Universal Catcher"
author = "DubsCheckum"
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
	lineSwitch = false -- Used in moveToLine()
	switchTimer = os.time()
	startTime = os.time()
	rand = 0 -- Used to represent each rectangle in area
	tmpRand = 0 -- Used to make sure rand is different every time we call math.random

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
	hasSync,pokeWithSync = Team:HasAbility("Synchronize")

	log("*************************BOT STARTED**************************")
	log("Info | Synchronize ― "..tostring(hasSync))
	log("Info | False Swipe ― "..tostring(hasFalseSwipe))
	log("Info | Status Move ― "..tostring(hasStatusMove))
	log("Info | Role Play ― "..tostring(hasRolePlay))
	log("Info | Pokeballs ― "
		..getItemQuantity("Pokeball")
		+ getItemQuantity("Great Ball")
		+ getItemQuantity("Ultra Ball"))
	log("Info | Pokemon to catch ― "..table.concat(pokemonToCatch,", "))

	if hasSync then syncID = getPokemonUniqueId(pokeWithSync) end
	if hasFalseSwipe then falseSwipeID = getPokemonUniqueId(pokeWithFalseSwipe) end
	if hasStatus then statusMoveID = getPokemonUniqueId(pokeWithStatusMove) end
	if hasRolePlay then rolePlayID = getPokemonUniqueId(pokeWithRolePlay) end

	-- move sync to first
	-- if hasSync and  then
	-- 	swapPokemonWithLeader(syncID) end
end

function onPause()
	--todo: pause timer
	local timeElapsed = |s| string.format("%02d:%02d:%02d",math.floor(s/(60*60)),math.floor(s/60%60),math.floor(s%60))
	log("******************** PAUSED - "..timeElapsed(os.difftime(os.time(),startTime)).." ********************")
	log("Info | Shineys encountered: " .. shinyCounter)
	log("Info | Pokemon caught: " .. catchCounter)
	log("Info | Pokemon encountered: " .. wildCounter)
    log("*************************************************************")
end

function onLearningMove()
	--todo
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
		-- take item from newly caught poke
		catchCounter = catchCounter + 1
		local lastIndex = getTeamSize()
		local item = getPokemonHeldItem(lastIndex)
		if item then
			log("Info | Took "..item.." from "..getPokemonName(lastIndex)..".")
			return takeItemFromPokemon(lastIndex)
		end
	elseif stringContains(msg, "A Wild ") then
	    wildCounter = wildCounter + 1
	elseif stringContains(msg, "You failed to run away")
		or stringContains(msg, "You can not run away!")
	then
		failedRun = true
	elseif stringContains(msg, "has fainted") then
		failedRun = false
	elseif stringContains(msg, "You can not switch this Pokemon") then
		failedSwitch = true
	elseif stringContains(msg, "You can't store any more Pokemon.") then
		fatal("Error | Free some space in the PC, it is full.")
	end
	-- check for role play match
	if useRolePlay and stringContains(msg, "is now") then
		opponentAbility = msg:match("is now (.+)!")
		log(opponentAbility)
	end
end

--todo:
--		advanced hunt patterns
--		heal status and health with items
--      heal when safari is over
--      settings 4 individual coords for each location

function onPathAction()
	opponentAbility = nil
	roleMatched = false
	failedSwitch = false
	failedRun = false

	if buyBalls then
		if getItemQuantity(typeBall) <= buyBallsAt then
			return Path:Pokemart(typeBall, buyBallAmount)
		end
	end
	if Team:IsSorted() then
		if Team:EquippedAll("Leftovers") then
			if Team:IsUsable() then
				return Path:Hunt(location)
			end
		else
			return Team:EquipAll("Leftovers")
		end
	else
		return Team:Sort()
	end
	return Path:Pokecenter()
end

--todo: calculate damages for health predictions (if no false swipe)
Blacklist = {
	RolePlay = {Name = "Role Play", Pokemon = {}, Types = {}},
	FalseSwipe = {Name = "False Swipe", Pokemon = {"Eevee","Beldum","Stantler"}, Types = {"Ghost"}},
	Status = {Name = "Status Move", Pokemon = {}, Types = {"Grass"}},
}

function onBattleAction()
	if Battle:IsOpponentDesirable() then

		-- handle syncs
		if hasSync
			and not useRolePlay
			and not hasFalseSwipe
			and not hasStatusMove
		then
			-- syncs are often weak, so we should switch out if there isn't enough leverage for them
			if getPokemonLevel(1) + 20 < getOpponentLevel() then
				return Battle:SendHighestUsable()
			end
		end

		-- handle role play
		if useRolePlay then
			if getPP(pokeWithRolePlay,"Role Play") > 0 and not Battle:IsOnBlacklist(Blacklist.RolePlay) then
				return Battle:RolePlay()
			end
		end

		-- handle false swipe
		if hasFalseSwipe and getOpponentHealth() > 1 then
			if getPP(pokeWithFalseSwipe,"False Swipe") > 0 and not Battle:IsOnBlacklist(Blacklist.FalseSwipe) then
				return Battle:FalseSwipe()
			end
		end

		-- handle status moves
		if hasStatusMove and getOpponentStatus() == "None" then
			if getPP(pokeWithStatusMove,statusMove) > 0 and not Battle:IsOnBlacklist(Blacklist.Status) then
				return Battle:StatusMove()
			end
		end

		return Battle:Catch() or Battle:Run() or sendAnyPokemon()
	else
		return Battle:Run() or attack() or sendUsablePokemon() or sendAnyPokemon()
	end
end