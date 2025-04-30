local QBCore = exports['qb-core']:GetCoreObject()

------------------------------GPS-------------------------------------------------------------
AddEventHandler('playerConnecting', function(name, setKickReason, dropPlayer)
    local playerId = source
    TriggerEvent('client-activate-gps', playerId)

end)
----------------------------------------------------------------------------------------------



QBCore.Functions.CreateCallback('server-d-get-owner', function(source, data, plate)
    local Player = QBCore.Functions.GetPlayer(source)
    --print(Player.PlayerData.citizenid)


    MySQL.query('SELECT `citizenid` FROM `player_vehicles` WHERE `plate` = @plate', {
    ['@plate'] = plate
    }, function(response)

        if  response[1] == nil then
            print("pas de véhicule trouvé")
            data (false)
        else 
            if response[1].citizenid == Player.PlayerData.citizenid  then
                data (true)
            else
                data (false)
            end
        end
    end)

end)


QBCore.Functions.CreateCallback('server-d-getjobowner', function(source, data, plate)

    MySQL.query('SELECT `job` FROM `player_vehicles` WHERE `plate` = @plate', {
    ['@plate'] = plate
    }, function(response)

        if  response[1] == nil then
            print("pas de véhicule trouvé")
            data (false)
        else 
            data (response[1].job)
        end
    end)

end)



RegisterServerEvent('d-garage:server:getinvehicle')
AddEventHandler('d-garage:server:getinvehicle', function(plate, model, garage, mods, garagejob)
    local Player = QBCore.Functions.GetPlayer(source)

    print("[Garage Debug] Plate:", plate)
    print("[Garage Debug] Model:", model)
    print("[Garage Debug] Garage:", garage)
    print("[Garage Debug] Job:", garagejob)

    MySQL.update('UPDATE player_vehicles SET garage = @garage, model = @model, mods = @mods, job = @job WHERE plate = @plate', {
        ['@garage'] = garage,
        ['@model']  = model,
        ['@mods']   = mods,
        ['@job']    = garagejob,
        ['@plate']  = plate
    }, function(response)
        print("[Garage Debug] Update response:", response)
    end)
end)


RegisterServerEvent('d-garage:server:registervehicle')
AddEventHandler('d-garage:server:registervehicle', function(data, plate, model, garage, mods)

    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.update('INSERT INTO player_vehicles (garage, mods, plate, model, license, citizenid) VALUES (?, ?, ?, ?, ?, ?)', {
        garage, mods, plate, model, Player.PlayerData.license, Player.PlayerData.citizenid
    }, function(response)
    end)
end)

QBCore.Functions.CreateCallback('server-d-get-listvehicle', function(source, data, namegarage, garagejob)


    
    if not garagejob or garagejob == "nojob" or garagejob == "" then
        local Player = QBCore.Functions.GetPlayer(source)


        MySQL.query('SELECT `model`, `plate` FROM `player_vehicles` WHERE `garage` = @garage AND `citizenid` = @citizenid', {
            ['@garage'] = namegarage, ['@citizenid'] = Player.PlayerData.citizenid
        }, function(response)
            data(response)
        end)
    else
        MySQL.query('SELECT `model`, `plate` FROM `player_vehicles` WHERE `garage` = @garage AND `job` = @job', {
            ['@garage'] = namegarage, ['@job'] = garagejob
        }, function(response)
            data(response)
        end)

    end

end)

QBCore.Functions.CreateCallback('server-d-get-listothervehicle', function(source, data, namegarage)
    print("[DEBUG] server-d-get-listvehicle appelé :", namegarage, garagejob)
    local Player = QBCore.Functions.GetPlayer(source)   

    MySQL.query('SELECT `model`, `plate`, `garage` FROM `player_vehicles` WHERE `citizenid` = @citizenid AND `garage` != @excludedGarage AND `garage` != "outside"', {
        ['@citizenid'] = Player.PlayerData.citizenid,
        ['@excludedGarage'] = namegarage
    }, function(response)
        data(response)
    end)

end)

QBCore.Functions.CreateCallback('server-getlistothervehiclejob', function(source, data, namegarage,garagejob)

    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.query('SELECT `model`, `plate`, `garage` FROM `player_vehicles` WHERE `job` = @garagejob AND `garage` != @excludedGarage AND `garage` != "outside"', {
        ['@garagejob'] = garagejob,
        ['@excludedGarage'] = namegarage
    }, function(response)
        data(response)
    end)

end)

QBCore.Functions.CreateCallback('server-d-get-listoutsidevehicle', function(source, data, namegarage)

    local Player = QBCore.Functions.GetPlayer(source)
    MySQL.query('SELECT `model`, `plate`, `coords` FROM `player_vehicles` WHERE `citizenid` = @citizenid AND `garage` = "outside"', {
        ['@citizenid'] = Player.PlayerData.citizenid
    }, function(response)
        data(response)
    end)

end)



QBCore.Functions.CreateCallback('server-d-get-mods', function(source, data, plate)
    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.query('SELECT `mods` FROM `player_vehicles` WHERE `plate` = @plate', {
    ['@plate'] = plate
    }, function(response)

        if  not response then
            print("pas de véhicule trouvé")
            data ("false")
        else 
            data (response[1].mods)
        end
    end)

end)

QBCore.Functions.CreateCallback('server-d-get-coords', function(source, data, plate)
    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.query('SELECT `coords` FROM `player_vehicles` WHERE `plate` = @plate', {
    ['@plate'] = plate
    }, function(response)

        if  not response then
            print("pas de coordonnée trouvée")
            data ("false")
        else 
            data (response[1].coords)
        end
    end)

end)


RegisterNetEvent('d-garage:server:spawnedVehicle')
AddEventHandler('d-garage:server:spawnedVehicle', function(plate)
    local Player = QBCore.Functions.GetPlayer(source)


    MySQL.update('UPDATE player_vehicles SET garage = @garage WHERE plate = @plate', {
        ['@garage'] = "outside",
        ['@plate'] = plate
    }, function(response)
    end)

end)