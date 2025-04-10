local QBCore = exports['qb-core']:GetCoreObject()
tabspawnoutside = {}


Citizen.CreateThread(function()
    while true do
        QBCore.Functions.TriggerCallback('server-d-get-all-spawnoutside', function(result)
            if result == false then
                return
            else
                for k, v in pairs(result) do
                    --print("Vehicles updated")
                    tabspawnoutside[k] = {
                        coords = json.decode(v.coords),
                        heading = v.heading
                    }

                end
            end
        end)

        -- Attendre 60 secondes avant de répéter
        Citizen.Wait(60000)
    end
    
end)

RegisterNetEvent('checkVehicleDistance')
AddEventHandler('checkVehicleDistance', function(vehicle, callback)
    local playerPed = PlayerPedId()
    local vehicleCoords = GetEntityCoords(vehicle)
    local playerCoords = GetEntityCoords(playerPed)
    local distance = Vdist(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, playerCoords.x, playerCoords.y, playerCoords.z)

    -- Envoyer la distance au serveur
    TriggerEvent("returndistancetoserver", source, distance)
end)


Citizen.CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        --print(playerPed)
        local playerCoords = GetEntityCoords(playerPed)

        for k, v in pairs(tabspawnoutside) do
            if v.coords and v.coords.x and v.coords.y and v.coords.z then
                local distance = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))

                if distance < 30.0 then -- Distance à laquelle le marqueur devient visible
                    DrawMarker(
                        36,                      -- Type de marqueur
                        v.coords.x, v.coords.y, v.coords.z + 0.5, -- Coordonnées avec ajustement en Z
                        0.0, 0.0, 0.0,          -- Directions
                        0.0, 0.0, 0.0,          -- Rotation
                        2.5, 2.5, 2.5,          -- Échelle
                        255, 174, 73,           -- Couleur RGB (orange)
                        70,                     -- Opacité
                        true,                   -- Bob up and down
                        true,                   -- Face camera
                        2,                      -- Rotationner
                        nil, nil, false
                    )

                    if distance < 2.0 then -- Distance à laquelle le texte devient visible
                        SetTextComponentFormat("STRING")
                        AddTextComponentString("Appuyez sur ~g~E~s~ pour sortir le véhicule")
                        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                        if IsControlJustReleased(0, 38) then -- 38 est le code de la touche E
                            local coordsJson = string.format('{"x": %.2f, "y": %.2f, "z": %.2f}', v.coords.x, v.coords.y, v.coords.z)
                            DRespawnVehicleOutside (coordsJson,v.heading, playerPed)
                            return
                        end
                    end
                end
            end
        end

        Citizen.Wait(0) -- Attendre une frame
    end
end)

function DrawText2D(text)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.5, 0.5) -- Augmenter la taille du texte
    SetTextColour(255, 255, 255, 255) -- Couleur blanche
    SetTextDropshadow(2, 2, 0, 0, 255) -- Ajouter une ombre pour plus de lisibilité
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)

    -- Calculer la position du texte
    local textWidth = GetTextScaleHeight(0.5, 4) * string.len(text) / 250
    local x = 0.85
    local y = 0.05
    -- Dessiner le rectangle noir en arrière-plan
    DrawRect(
        x + textWidth / 2, -- x
        y + 0.0150,        -- y
        0.15,              -- width (ajusté pour mieux correspondre au texte)
        0.06,              -- height
        0,                 -- R
        0,                 -- G
        0,                 -- B
        150                -- A (opacité ajustée)
    )
    -- Dessiner le texte
    DrawText(x, y)
end


function DRespawnVehicleOutside (coords, heading, ped)

    
    QBCore.Functions.TriggerCallback('server_d_respawn_vehicle_outside', function(response)
        if response then


            local mods = response[1].mods
            local coordonate = json.decode(coords)


            QBCore.Functions.SpawnVehicle(response[1].model, function(vehicle)
                SetVehicleNumberPlateText(vehicle, response[1].plate)
                SetEntityCoords(vehicle, coordonate.x, coordonate.y, coordonate.z,false,false,false, false)
                SetEntityHeading(vehicle, heading)
                SetVehicleEngineOn(vehicle, true, true, true)

                SetVehicleFixed(vehicle)
                SetVehicleDirtLevel(vehicle, 0.0)
                SetVehicleOnGroundProperly(vehicle)
                SetEntityAsMissionEntity(vehicle, true, true)
                SetModelAsNoLongerNeeded(response[1].model)

                Citizen.Wait(100) -- Attendre 500ms
                local pedentity = PlayerPedId()
                if DoesEntityExist(pedentity) then
                    SetPedIntoVehicle(pedentity, vehicle, -1)
                else
                    print("🚨 Erreur : PlayerPedId() retourne un ped invalide !")
                end
                Citizen.Wait(100)
                QBCore.Functions.SetVehicleProperties(vehicle, json.decode(mods))

                TriggerServerEvent('GetOutOutsidevehicle', response[1].plate)
                tabspawnoutside[response[1].plate] = nil
                
            end)
        else
            print("Une erreur est survenue")
            QBCore.Functions.Notify("Une erreur est survenue", "error", 5000)
        end
    end, coords)
end


-- Fonction pour dessiner du texte en 3D (commentée)
-- Citizen.CreateThread(function()
--     while true do
--         local playerPed = PlayerPedId()
--         local playerCoords = GetEntityCoords(playerPed)

--         for k, v in pairs(tabspawnoutside) do
--             if v.coords and v.coords.x and v.coords.y and v.coords.z then
--                 local distance = #(playerCoords - vector3(v.coords.x, v.coords.y, v.coords.z))

--                 if distance < 30.0 then -- Distance à laquelle le marqueur devient visible
--                     DrawMarker(
--                         36,                      -- Type de marqueur
--                         v.coords.x, v.coords.y, v.coords.z + 0.5, -- Coordonnées avec ajustement en Z
--                         0.0, 0.0, 0.0,          -- Directions
--                         0.0, 0.0, 0.0,          -- Rotation
--                         2.5, 2.5, 2.5,          -- Échelle
--                         255, 0, 0,              -- Couleur RGB (rouge)
--                         70,                     -- Opacité
--                         true,                   -- Bob up and down
--                         true,                   -- Face camera
--                         2,                      -- Rotationner
--                         nil, nil, false
--                     )

--                     if distance < 2.0 then -- Distance à laquelle le texte devient visible
--                         DrawText3D(v.coords.x, v.coords.y, v.coords.z + 1.0, "Appuyez sur ~g~E~s~ pour sortir le véhicule")

--                         if IsControlJustReleased(0, 38) then -- 38 est le code de la touche E
--                             TriggerEvent('mon_evenement') -- Remplacez 'mon_evenement' par le nom de votre événement
--                         end
--                     end
--                 end
--             else
--                 print("Coordonnées invalides pour le marqueur : ", k)
--             end
--         end

--         Citizen.Wait(0) -- Attendre une frame
--     end
-- end)
-- function DrawText3D(x, y, z, text)
--     local onScreen, _x, _y = World3dToScreen2d(x, y, z)
--     local p = GetGameplayCamCoords()
--     local distance = #(vector3(p.x, p.y, p.z) - vector3(x, y, z))
--     local scale = (1 / distance) * 2
--     local fov = (1 / GetGameplayCamFov()) * 100
--     local scale = scale * fov

--     if onScreen then
--         SetTextScale(0.35, 0.35)
--         SetTextFont(4)
--         SetTextProportional(1)
--         SetTextColour(255, 255, 255, 215)
--         SetTextEntry("STRING")
--         SetTextCentre(1)
--         AddTextComponentString(text)
--         DrawText(_x, _y)
--         local factor = (string.len(text)) / 370
--         DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
--     end
-- end