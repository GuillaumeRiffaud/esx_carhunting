ESX = nil
local npcSpawned = false
local npc = nil
local bringingVehicle = false
local hasAlreadyEnteredMarker = false
local randomLocation
local LastZone
local blip
local location = nil
local alreadyDone --variable to only let players complete the quest once per server reboot (optimal when daily)
local todaysPrimeModel = "car I guess"
local todaysPrimeColor = "unidentified"

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Wait(0)
	end

    Wait(1000)

    while not ESX.IsPlayerLoaded() do
        Wait(10)
    end

    ESX.TriggerServerCallback('carhunting:picktodaysvehicle', function(primeColor, primeModel, spawnNumber, cleared)
		todaysPrimeColor = primeColor
		todaysPrimeModel = primeModel
		location = Config.Coords[spawnNumber]
		alreadyDone = cleared
	end)

	while location == nil do Wait(100) end

	TriggerEvent('carhunting:locationandblip')

    StartThreads()
end)

local function capitalizeFirstLetter(word)
    local firstLetter = string.sub(word, 1, 1)
    local restOfTheWord = string.sub(word, 2)
    return (string.upper(firstLetter) .. string.lower(restOfTheWord))
end

AddEventHandler('carhunting:locationandblip', function()
	if DoesBlipExist(blip) then
		RemoveBlip(blip)
	end

	if not alreadyDone or Config.Repeatable then
		blip = AddBlipForCoord(location.NPCcoords)
		SetBlipSprite(blip, 530)
		SetBlipAsShortRange(blip, true)
		SetBlipDisplay(blip, 2)
		SetBlipColour (blip, 23)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(_U('blip_name'))
		EndTextCommandSetBlipName(blip)
	end
end)

local currentVehicleData = {};

AddEventHandler('carhunting:hasEnteredMarker', function(zone)
	local playerPed = PlayerPedId();
    local currentVehicle = GetVehiclePedIsIn(playerPed, false);

    if DoesEntityExist(currentVehicle) and GetPedInVehicleSeat(currentVehicle, -1) == playerPed then
        local modelHash = GetEntityModel(currentVehicle); local modelName = GetDisplayNameFromVehicleModel(modelHash);
        local primaryColor = GetVehicleColours(currentVehicle); local colorName = Config.Colors[tostring(primaryColor)];
        ESX.ShowHelpNotification(_U('submit_car', colorName, capitalizeFirstLetter(modelName))); bringingVehicle = true

        currentVehicleData = {
            colorName = colorName,
            modelName = modelName,
            Plate = ESX.Math.Trim(GetVehicleNumberPlateText(currentVehicle)),
            bodyHealth = GetVehicleBodyHealth(currentVehicle)
        }
    else
        ESX.ShowHelpNotification(_U('bring_car')); bringingVehicle = false;
    end
end)

AddEventHandler('carhunting:hasExitedMarker', function(zone) bringingVehicle = false; currentVehicleData = {}; end)


function StartThreads()
    -- Enter / Exit marker events & Draw Markers
    Citizen.CreateThread(function()
        while not alreadyDone or Config.Repeatable do
            Citizen.Wait(1)
            local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, nil, true

            if location then

                local distance = #(playerCoords - location.SellPoint) --we use distance to the sell point as a reference to spawn things

                if distance < 40 then
                    letSleep = false
                    DrawMarker(1, location.SellPoint, 0.0, 0.0, 0.0, location.Rotation.x, location.Rotation.y, location.Rotation.z, 2.5, 2.5, 1.0, 255, 0, 0, 100, false, false, 2, false, nil, nil, false)


                    --spawn NPC if not yet
                    if not npcSpawned then
                        RequestModel(GetHashKey("a_m_m_og_boss_01"))
        
                        while not HasModelLoaded(GetHashKey("a_m_m_og_boss_01")) do
                            Wait(1)
                        end
                        npc = CreatePed(4, "a_m_m_og_boss_01", location.NPCcoords, location.NPCheading, false, true)
                        FreezeEntityPosition(npc, true)
                        SetEntityInvincible(npc, true)
                        SetBlockingOfNonTemporaryEvents(npc, true)
                        npcSpawned = true
                    end

                    if distance < 2 then
                        isInMarker, currentZone = true, k
                    end
                end

                local distanceToTalk = #(playerCoords - location.NPCcoords) -- distance to the actual npc, to read his request

                if distanceToTalk <= 2 then
                    ESX.ShowHelpNotification(_U('request', string.lower(todaysPrimeColor), capitalizeFirstLetter(todaysPrimeModel))) -- for some languages you might want to switch the 2 variables' order
                end


            end

            if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
                HasAlreadyEnteredMarker, LastZone = true, currentZone
                TriggerEvent('carhunting:hasEnteredMarker', currentZone)
            end

            if not isInMarker and HasAlreadyEnteredMarker then
                HasAlreadyEnteredMarker = false
                TriggerEvent('carhunting:hasExitedMarker', LastZone)
            end

            if letSleep or (alreadyDone and not Config.Repeatable) then
                npcSpawned = false
                if npc then --delete npc when we're away
                    DeletePed(npc)
                end
                Citizen.Wait(500)
            end
        end
    end)

    -- Key controls
    Citizen.CreateThread(function()
        while true do

            if bringingVehicle then
                local playerPed = PlayerPedId();
                local currentVehicle = GetVehiclePedIsIn(playerPed, false);

                if DoesEntityExist(currentVehicle) and GetPedInVehicleSeat(currentVehicle, -1) == playerPed then
                    if IsControlJustReleased(0, 38) and not isDead then
                        TriggerServerEvent('carhunting:submitvehicle', currentVehicleData)
                    end
                end
            else
                Wait(500)
            end

            Wait(0)
        end
    end)
end

RegisterNetEvent('carhunting:accepted')
AddEventHandler('carhunting:accepted', function(reward)
	local playerPed = PlayerPedId()
	local currentVehicle = GetVehiclePedIsIn(playerPed, false);

	ESX.Game.DeleteVehicle(currentVehicle);

	if reward == Config.FullReward then
		ESX.ShowNotification(_U('sold_for', reward))
		ESX.ShowHelpNotification(_U('great_work'))
	else
		ESX.ShowNotification(_U('sold_for', reward))
		ESX.ShowHelpNotification(_U('job_done'))
	end

	ESX.TriggerServerCallback('carhunting:picktodaysvehicle', function(primeColor, primeModel, spawnNumber, cleared)
		todaysPrimeColor = primeColor
		todaysPrimeModel = primeModel
		location = Config.Coords[spawnNumber]
		alreadyDone = cleared
	end)
    
    Wait(500);
    
	TriggerEvent('carhunting:locationandblip')
end)


RegisterNetEvent('carhunting:notaccepted')
AddEventHandler('carhunting:notaccepted', function(reason)
	if reason == "belongs to a player" then
		ESX.ShowHelpNotification(_U('wrong_person'))
	elseif reason == "too low health" then
		ESX.ShowHelpNotification(_U('too_low_health'))
	elseif reason == "wrong model" then
		ESX.ShowHelpNotification(_U('wrong_car'))
	end
end)

AddEventHandler('esx:onPlayerDeath', function(data) isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end)