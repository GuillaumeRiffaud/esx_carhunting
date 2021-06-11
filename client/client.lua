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
		Citizen.Wait(0)
	end
end)


Citizen.CreateThread(function() --calling server for today's vehicle prime and checking if we've already cleared the quest
	Citizen.Wait(3000) -- waiting for stuff to be correctly registered, I wish I knew a better way to do this
	ESX.TriggerServerCallback('carhunting:picktodaysvehicle', function(primeColor, primeModel, spawnNumber, cleared)
		todaysPrimeColor = primeColor
		todaysPrimeModel = primeModel
		location = Config.Coords[spawnNumber]
		alreadyDone = cleared
	end)
	while location == nil do Citizen.Wait(100) end
	TriggerEvent('carhunting:locationandblip')
end)

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

AddEventHandler('carhunting:hasEnteredMarker', function(zone)
	local playerPed = PlayerPedId()

	if IsPedSittingInAnyVehicle(playerPed) then
		local vehicle = GetVehiclePedIsIn(playerPed, false)
		if GetPedInVehicleSeat(vehicle, -1) == playerPed then
			-- you're in car and you're driver
			local modelHash = GetEntityModel(vehicle)
			local modelName = GetDisplayNameFromVehicleModel(modelHash)
			local color1 = ESX.Game.GetVehicleProperties(vehicle).color1
			local vehicleColorGroup = getHashColorGroupLabel(color1)
			ESX.ShowHelpNotification(_U('submit_car', string.lower(vehicleColorGroup), capitalizeFirstLetter(modelName))) -- for some languages you might want to switch the 2 variables' order
			bringingVehicle = true
		end
	else
		-- you're not in car
		ESX.ShowHelpNotification(_U('bring_car'))
		bringingVehicle = false
	end
end)

AddEventHandler('carhunting:hasExitedMarker', function(zone)
	bringingVehicle = false
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if bringingVehicle then
			local playerPed = PlayerPedId()
			if IsPedSittingInAnyVehicle(playerPed) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)
				if GetPedInVehicleSeat(vehicle, -1) == playerPed then -- double or triple checking we're still driver in a vehicle

					if IsControlJustReleased(0, 38) and not isDead then
						local modelHash = GetEntityModel(vehicle)
						local modelName = GetDisplayNameFromVehicleModel(modelHash)
						local plate = ESX.Game.GetVehicleProperties(vehicle).plate
						local color1 = ESX.Game.GetVehicleProperties(vehicle).color1
						local health = ESX.Game.GetVehicleProperties(vehicle).bodyHealth
						local vehicleColorGroup = getHashColorGroupLabel(color1)
						TriggerServerEvent('carhunting:submitvehicle', plate, modelName, vehicleColorGroup, health)
					end
				end
			end
		end
	end
end)


RegisterNetEvent('carhunting:accepted')
AddEventHandler('carhunting:accepted', function(reward)
	local playerPed = PlayerPedId()
	local vehicle = GetVehiclePedIsIn(playerPed, false)
	ESX.Game.DeleteVehicle(vehicle)
	if reward == Config.FullReward then
		ESX.ShowNotification(_U('sold_for', reward))
		ESX.ShowHelpNotification(_U('great_work'))
	else
		ESX.ShowNotification(_U('sold_for', reward))
		ESX.ShowHelpNotification(_U('job_done'))
	end
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

-- Should make every client refresh location and model when someone cleared the quest (repeatable mode)
RegisterNetEvent('carhunting:someoneCleared')
AddEventHandler('carhunting:someoneCleared', function()
	ESX.TriggerServerCallback('carhunting:picktodaysvehicle', function(primeColor, primeModel, spawnNumber, cleared)
		todaysPrimeColor = primeColor
		todaysPrimeModel = primeModel
		location = Config.Coords[spawnNumber]
		alreadyDone = cleared
	end)
	Citizen.Wait(500)
	TriggerEvent('carhunting:locationandblip')
end)

AddEventHandler('esx:onPlayerDeath', function(data) isDead = true end)
AddEventHandler('esx:onPlayerSpawn', function(spawn) isDead = false end) 