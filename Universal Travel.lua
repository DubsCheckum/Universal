
--+++++++++++++++++++++++++++++++++++++++--
--+ THERE IS NO SCRIPT CONFIG FOR THIS, +--
--+  LOAD THE SCRIPT INTO PROSHINE TO   +--
--+           SEE THE CONFIG            +--
--+++++++++++++++++++++++++++++++++++++++--

--Favorites:

--KANTO
--Pokecenter Celadon      --Pokecenter Lavender     --Pokecenter Pewter                 --Safari Entrance
--Pokecenter Cerulean     --Pokecenter Saffron      --Pokemon League Reception Gate     --Power Plant
--Pokecenter Cinnabar     --Pokecenter Vermilion    --Mt. Silver Pokecenter             --Indigo Plateau Center
--Pokecenter Fuchsia      --Pokecenter Viridian     --Seafoam B4F
--

--JOHTO
--Pokecenter Azalea             --Pokecenter Ecruteak     --Pokecenter Violet City     --Ruins Of Alph
--Pokecenter Blackthorn         --Pokecenter Goldenrod    --Dragons Den                --Ilex Forest
--Pokecenter Cherrygrove City   --Pokecenter Mahogany     --Johto Safari Zone Lobby
--Pokecenter Cianwood           --Olivine Pokecenter
--

--HOENN
--Pokecenter Dewford Town       --Pokecenter Lavaridge Town    --Pokecenter Oldale Town       --Pokecenter Slateport
--Pokecenter Ever Grande City   --Pokecenter Lilycove City     --Pokecenter Pacifidlog Town   --Pokecenter Sootopolis City
--Pokecenter Fallarbor Town      --Pokecenter Mauville City     --Pokecenter Petalburg City    --Pokecenter Verdanturf
--Pokecenter Fortree City       --Pokecenter Mossdeep City     --Pokecenter Rustboro City     --Pokemon League Hoenn
--

setOptionName(1,"Go To Nearest Pokecenter")
setOptionDescription(1,"Go to the nearest Pokecenter, and disregard the other options.")

setTextOptionName(1,"Location")
setTextOptionDescription(1,"The location you wish to travel to, and disregard the other options.")

setTextOptionName(2,"Buy Item")
setTextOptionDescription(2,"An item to purchase from the Pokemart, and disregard the other options.")

setTextOptionName(3,"Buy Amount")
setTextOptionDescription(3,"The amount of the specified 'Buy Item' to buy.")

opt = {
	goToNearestPokecenter = || getOption(1),
	location = || getTextOption(1),
	buyItem = || getTextOption(2),
	buyAmt = || getTextOption(3),
}

name = "Universal Traveler"
author = "DubsCheckum"
description = "Press Start."

local pf = require("Pathfinder/MoveToApp")
local Path = require("gamelib/Path")
local Battle = require("gamelib/Battle")

function onStart()
    shinyCounter = 0
    catchCounter = 0
    wildCounter = 0
	onPause()
end

function onPause()
 	if goToNearestPokecenter == true then
		log("Info | Travelling to " .. getMapName(goToNearestPokecenter) .. ".")
	else
		log("Info | Travelling to " .. location .. ".")
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
		failedSwitch = true
	end
end

function onPathAction()
	local map = getMapName()
	failedSwitch = false

	if goToNearestPokecenter == true then
		pf.useNearestPokecenter(map)
	elseif opt.buyItem() then
		if not pf.useNearestPokemart(map, opt.buyItem, opt.buyAmt) then
			fatal("Info | Finished Buying Item.")
		end
	else
		pf.moveTo(map, location)
		if getMapName() == opt.location() then
		end
	end
end

function onBattleAction()
	if Battle:IsOpponentDesirable() then
		if Battle:Catch() then
			return
		end
	end
	return Battle:Run() or sendUsablePokemon()
end
