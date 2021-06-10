ESX = nil
local playersCompleted = {}
local todaysPrimeModel = nil
local todaysPrimeColor = nil
local todaysLocation = nil
local firstPick = true
local newPick = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('carhunting:picktodaysvehicle', function(source, cb)

    if firstPick or newPick then    --We only want the location and requested vehicle to change the first time this is executed OR if someone has completed it and it's repeatable (in config)
    -- pick a random spawn for the quest
        print("Generating prime vehicle")
        local coordsCount = 0
        for index in pairs(Config.Coords) do
            coordsCount = coordsCount + 1
        end
        todaysLocation = math.random(1,coordsCount)

    --pick a random car model and color for the quest
        local nbOfPossibleModels = #(Config.Primes)
        local randomModel = math.random(1,nbOfPossibleModels)
        todaysPrimeModel = Config.Primes[randomModel]

        local randomColor = math.random(1,10) --We'll ignore pink, gold and chrome as they might be too rare
        todaysPrimeColor = Config.Colors[randomColor].label

        firstPick = false
        newPick = false
    end

    -- checking if player has already completed the quest
    local xPlayer = ESX.GetPlayerFromId(source)
    local cleared = getPlayerCleared(xPlayer.identifier)

    --give all that info to the client    
    cb(todaysPrimeColor, todaysPrimeModel, todaysLocation, cleared)
end)

function getPlayerCleared(player)
    for k,v in pairs (playersCompleted) do
        if v == player then
            return true
        end
    end
    return false
end

RegisterServerEvent('carhunting:submitvehicle')
AddEventHandler('carhunting:submitvehicle', function(plate, modelName, vehicleColorGroup, health)

    local xPlayer = ESX.GetPlayerFromId(source) 

    --check if the car belongs to a player, we don't want that
    MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE @plate = plate', {
        ['@plate'] = plate
    }, function(result)
        if result[1] then   --refuse any player's personal car
            local reason = "belongs to a player"
            TriggerClientEvent('carhunting:notaccepted', xPlayer.source, reason)
        else
            if modelName == todaysPrimeModel then
                if (Config.CheckHealth and health >= Config.RequiredHealth) or not Config.CheckHealth then
                    if vehicleColorGroup == todaysPrimeColor then -- Delivered the right car with the right color
                        if Config.GiveBlackMoney then
                            xPlayer.addAccountMoney('black_money', Config.FullReward)
                        else
                            xPlayer.addMoney(Config.FullReward)
                        end
                        if not Config.Repeatable then
                            table.insert(playersCompleted, xPlayer.identifier)   --Make a list of players who have completed the quest so they don't see it anymore until reboot
                        else
                            newPick = true
                        end
                        TriggerClientEvent('carhunting:accepted', xPlayer.source, Config.FullReward)
                    else    -- delivered the right car with the wrong color
                        if Config.GiveBlackMoney then
                            xPlayer.addAccountMoney('black_money', Config.PartialReward)
                        else
                            xPlayer.addMoney(Config.PartialReward)
                        end
                        if not Config.Repeatable then
                            table.insert(playersCompleted, xPlayer.identifier)   --Make a list of players who have completed the quest so they don't see it anymore until reboot
                        else
                            newPick = true --if the quest is repeatable, we tell the server it's allowed to generate a new car and location
                        end
                        TriggerClientEvent('carhunting:accepted', xPlayer.source, Config.PartialReward)
                    end
                else    -- car refused for bad driving reasons (can be turned off)
                    local reason = "too low health"
                    TriggerClientEvent('carhunting:notaccepted', xPlayer.source, reason)
                end
            else    -- dude's drunk and got the wrong car model
                local reason = "wrong model"
                TriggerClientEvent('carhunting:notaccepted', xPlayer.source, reason)
            end
        end
    end)
end)
