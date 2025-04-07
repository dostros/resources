local QBCore = exports['qb-core']:GetCoreObject()

-- Configuration
local DESPAWN_TIME = 120
local CHECK_INTERVAL = 20 -- Intervalle de vérification en secondes (1 minute)

-- Tableau pour suivre les joueurs actifs
activePlayers = {}

-- Fonction pour mettre à jour la liste des joueurs actifs
RegisterNetEvent('playerActivated')
AddEventHandler('playerActivated', function()
    local playerId = source
    activePlayers[playerId] = true

    -- Compter manuellement le nombre de joueurs actifs
    local activeCount = 0
    for _ in pairs(activePlayers) do
        activeCount = activeCount + 1
    end
    print("Player " .. playerId .. " activated. Total active players: " .. activeCount)
end)

-- Fonction pour supprimer un joueur de la liste lorsqu'il se déconnecte
RegisterNetEvent('playerDropped')
AddEventHandler('playerDropped', function(reason)
    local playerId = source
    activePlayers[playerId] = nil

    -- Compter manuellement le nombre de joueurs actifs
    local activeCount = 0
    for _ in pairs(activePlayers) do
        activeCount = activeCount + 1
    end
    print("Player " .. playerId .. " dropped. Total active players: " .. activeCount)
end)

-- Ajouter les joueurs en ligne lorsque la ressource démarre
Citizen.CreateThread(function()
    local players = GetPlayers()
    for _, playerId in ipairs(players) do
        activePlayers[playerId] = true
        print("Player " .. playerId .. " added to active players list.")
    end
end)

-- Déclencher l'événement playerActivated lorsque le joueur se connecte
AddEventHandler('playerConnecting', function(name, setKickReason, dropPlayer)
    local playerId = source
    TriggerEvent('playerActivated', playerId)
    print("Player " .. playerId .. " connecting.")
end)

-- Fonction pour vérifier et supprimer les véhicules inutilisés
function CheckAndDespawnVehicles()
    local vehicles = GetAllVehicles()
    for _, vehicle in ipairs(vehicles) do
        local plate = GetVehicleNumberPlateText(vehicle)
        local isVehicleInUse = IsVehicleInUse(vehicle)
        local timeSinceLastUsed = GetTimeSinceLastUsed(vehicle)

        --print("Checking vehicle: " .. plate)

        if not isVehicleInUse then
            if timeSinceLastUsed >= DESPAWN_TIME then
                IsPlateInDatabase(plate, function(exists)

                    TriggerEvent('checkVehicleDistance', vehicle)
                    

                    
                end)
            else
                print("Vehicle " .. plate .. " not deleted because it was recently used.")
            end
        else
            print("Vehicle " .. plate .. " is in use.")
        end
    end
    Citizen.SetTimeout(CHECK_INTERVAL * 1000, CheckAndDespawnVehicles)
end



RegisterNetEvent("returndistancetoserver")
AddEventHandler('returndistancetoserver', function(distance)
    
    if distance then
        print("Distance to player: " .. distance)

        if distance > 10.0 then
            if exists then
                local mods = json.encode(QBCore.Functions.GetVehicleProperties(vehicle))
                SaveVehiclePositionAndModToDatabase(vehicle, mods)
            end
            DeleteEntity(vehicle)
            SendDiscordLog("vehicledeleted", "🚗 Véhicule supprimé", "\n**Plaque :** " .. plate, 3066993)
        else
            print("Vehicle " .. plate .. " not deleted because a player is nearby.")
        end
    else
        print("Véhicule introuvable, suppression annulée.")
    end

end)




-- Fonction pour vérifier si un véhicule est utilisé
function IsVehicleInUse(vehicle)
    local driver = GetPedInVehicleSeat(vehicle, -1)
    if driver and IsPedAPlayer(driver) then
        return true
    end

    local vehicleCoords = GetEntityCoords(vehicle)
    for playerId, _ in pairs(activePlayers) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = math.sqrt((vehicleCoords.x - playerCoords.x)^2 + (vehicleCoords.y - playerCoords.y)^2 + (vehicleCoords.z - playerCoords.z)^2)
        if distance < 5.0 then
            return true
        end
    end
    return false
end

local vehicleLastUsed = {}

-- Fonction pour obtenir le temps depuis la dernière utilisation
function GetTimeSinceLastUsed(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    local lastUsedTimestamp = vehicleLastUsed[plate]
    if not lastUsedTimestamp then
        return DESPAWN_TIME
    end
    local currentTime = os.time()
    return currentTime - lastUsedTimestamp
end

-- Fonction pour mettre à jour le timestamp lorsqu'un véhicule est utilisé
function UpdateVehicleTimestamp(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)
    vehicleLastUsed[plate] = os.time()
end

-- Appelez cette fonction lorsqu'un joueur entre ou sort d'un véhicule
RegisterNetEvent('vehicle:entered')
AddEventHandler('vehicle:entered', function(vehicle)
    UpdateVehicleTimestamp(vehicle)
end)

RegisterNetEvent('vehicle:exited')
AddEventHandler('vehicle:exited', function(vehicle)
    UpdateVehicleTimestamp(vehicle)
end)

-- Fonction pour vérifier si la plaque est dans la base de données
function IsPlateInDatabase(plate, cb)
    MySQL.query('SELECT `plate` FROM `player_vehicles` WHERE `plate` = @plate', {
        ['@plate'] = plate
    }, function(response)
        if response[1] == nil then
            cb(false)
        else
            print("La plaque : " .. plate .. " existe en BDD.")
            cb(true)
        end
    end)
end

-- Fonction pour sauvegarder la position du véhicule dans la base de données
function SaveVehiclePositionAndModToDatabase(vehicle, mods)
    -- Obtenir les coordonnées du véhicule
    local coords = GetEntityCoords(vehicle)

    -- Vérifier que les coordonnées ne sont pas nil
    if not coords or not coords.x or not coords.y or not coords.z then
        print("Erreur : Coordonnées invalides.")
        return
    end

    -- Arrondir les coordonnées vers le bas à deux chiffres après la virgule
    local roundedCoords = {
        x = math.floor(coords.x * 100) / 100,
        y = math.floor(coords.y * 100) / 100,
        z = math.floor(coords.z * 100) / 100
    }

    -- Construire manuellement la chaîne JSON pour forcer l'ordre des clés
    local coordsJson = string.format('{"x": %.2f, "y": %.2f, "z": %.2f}', roundedCoords.x, roundedCoords.y, roundedCoords.z)
    --print("------------------------------------------------------------------------")
    --print("Coordonnées mise en bdd : " .. coordsJson)
    --print("------------------------------------------------------------------------")
    if plate then
        SendDiscordLog("vehiclesaveed","🚗 Véhicule enregistré", "\n**Plaque :** " .. plate, 3066993) -- Couleur verte
    end



    -- Obtenir le heading et la plaque d'immatriculation
    local heading = GetEntityHeading(vehicle)
    local plate = GetVehicleNumberPlateText(vehicle)

    -- Mettre à jour la base de données
    MySQL.update('UPDATE player_vehicles SET coords = @coords, heading = @heading, mods = @mods WHERE plate = @plate', {
        ['@coords'] = coordsJson,
        ['@heading'] = heading,
        ['@mods'] = mods,
        ['@plate'] = plate,
    }, function(response)
        --print("Vehicle saved")
    end)
end




-- Fonction pour vérifier si un joueur est à proximité du véhicule
function IsVehicleNearPed(vehicle)
    local vehicleCoords = GetEntityCoords(vehicle)
    for playerId, _ in pairs(activePlayers) do
        local playerPed = GetPlayerPed(playerId)
        local playerCoords = GetEntityCoords(playerPed)
        local distance = Vdist(vehicleCoords, playerCoords)

        -- Affiche la distance calculée pour chaque joueur actif
        --print("Checking player " .. playerId .. " for vehicle proximity: Distance = " .. distance)

        if distance < 10.0 then  -- Vérifie si la distance est inférieure à 10 mètres
            return true
        end
    end
    return false
end



-- Démarrer la vérification périodique
CheckAndDespawnVehicles()

QBCore.Functions.CreateCallback('server-d-get-all-spawnoutside', function(source, data)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player then
        MySQL.query('SELECT `coords`, `heading` FROM `player_vehicles` WHERE `citizenid` = @citizenid AND `garage` = "outside"', {
            ['@citizenid'] = Player.PlayerData.citizenid
        }, function(response)
            if response[1] == nil then
                --print("pas de véhicule à faire respawn")
                data(false)
            else
                --print(response[1].coords)
                data(response)
            end
        end)
    end
end)

QBCore.Functions.CreateCallback('server_d_respawn_vehicle_outside', function(source, data, coords)
    local Player = QBCore.Functions.GetPlayer(source)
    local jsoncoordonate = tostring(coords)
    --print("outside: "..Player.PlayerData.citizenid)
    --print("outside: "..jsoncoordonate)

    MySQL.query('SELECT `plate`, `model`, `mods` FROM `player_vehicles` WHERE `coords` = @coords AND `garage` = "outside" AND `citizenid` = @citizenid', {
        ['@coords'] = jsoncoordonate , ['@citizenid'] = Player.PlayerData.citizenid
    }, function(response)
        if response[1] == nil then
            --print("-------------------ERROR-------------------------------")
            --print("pas de véhicule à faire respawn")
            --print("--------------------------------------------------------")
            data(false)
        else
           -- print("-------------------SUCCESS------------------------------")
            --print(response[1].plate)
            -- print(response[1].model)
            --print(response[1].mods)
            --print("--------------------------------------------------------")
            data(response)
        end
    end)
end)


RegisterNetEvent('GetOutOutsidevehicle')
AddEventHandler('GetOutOutsidevehicle', function(plate)
    --print("on erased")
    --print(plate)
    MySQL.update('UPDATE player_vehicles SET coords = @coords, heading = @heading , garage = @garage WHERE plate = @plate', {
        ['@coords'] = "",
        ['@heading'] = "",
        ['garage'] = "outside",
        ['@plate'] = plate,
    }, function(response)
        --print(reponse)
    end)

end)




--------------------------------------------------------------------------------------------------------
function SendDiscordLog(type, title, message, color)
    local embed = {
        {
            ["title"] = title,
            ["description"] = message,
            ["color"] = color, -- Couleur en format décimal (ex: rouge = 16711680)
            ["footer"] = {
                ["text"] = "Logs FiveM - QBcore",
            }
        }
    }
    
    if type == "vehicledeleted" then
        local webhookURL = "https://discord.com/api/webhooks/1341445117185101916/seS8tl1_y6CFkXV9nYIfQLfn6m-QluG_qx2qZLiSzciiZJSmSbVEEhFB32KMRDfiSOdw"
        PerformHttpRequest(webhookURL, function(err, text, headers) end, "POST", json.encode({
            username = "Logs Server",
            embeds = embed
        }), { ["Content-Type"] = "application/json" })
    else if type == "vehiclesaved" then
        local webhookURL = "https://discord.com/api/webhooks/1341448936556204124/3UYI0LRzLzaOfr_BK5HgofDK1UsD4eV36zdXo5UjBDMdd9wOw73kW91UdpYjEHXgzi4G"
        PerformHttpRequest(webhookURL, function(err, text, headers) end, "POST", json.encode({
            username = "Logs Server",
            embeds = embed
        }), { ["Content-Type"] = "application/json" })


    end 
    end
end