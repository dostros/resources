local QBCore = exports['qb-core']:GetCoreObject()
local json = require("json")
local garagePeds = {}
local playerOwnedProperties = {}
local isLoadingGarages = false


RegisterNetEvent("PipouImmo:client:SendPropertiesToGarage", function(properties)
    playerOwnedProperties = properties or {}
    LoadGarages()
end)

RegisterNetEvent("PipouImmo:client:setPlayerProperties", function(properties)
    playerOwnedProperties = properties or {}
    LoadGarages()
end)


Citizen.CreateThread(function()
    while true do
        DisplayRadar(true)
        Wait(000)
    end   
end)

Citizen.CreateThread(function()
    LoadGarages()
end)

RegisterNetEvent('d-garage:reloadGarages', function()
    LoadGarages()
end)

RegisterNetEvent("PipouImmo:client:RefreshGarages", function()
    TriggerServerEvent("PipouImmo:server:getPlayerProperties")
    
    Wait(1000)

    LoadGarages()
end)

CreateThread(function()
    while not QBCore.Functions.GetPlayerData().citizenid do
        Wait(100)
    end
    TriggerServerEvent("PipouImmo:server:getPlayerProperties")
end)



function LoadGarages()
    if isLoadingGarages then return end
    isLoadingGarages = true
    -- 🔁 Supprimer les anciens PNJ
    for _, ped in ipairs(garagePeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    garagePeds = {}

    -- 🕒 Attente des données joueur
    while not QBCore.Functions.GetPlayerData() or not QBCore.Functions.GetPlayerData().job do
        Wait(200)
    end

    local playerData = QBCore.Functions.GetPlayerData()
    Wait(1000)

    for namegarage, garage in pairs(Config.Garages) do
        local garagelabel = garage.label
        local garagespawnpoint = garage.spawnPoint
        local getinpoint = garage.getinpoint
        local garagetakevehicle = garage.takeVehicle
        local garagetype = garage.type
        local hashpnj = GetHashKey("mp_m_freemode_01")
        local garagejob = garage.job
        local category = garage.category
        local garagegang = garage.gang
        local pedheading = garagetakevehicle[4]

        -- 💾 Vérifie propriété (pour les garages privés)
        local isOwner = true
        if garagetype == "private" then
            isOwner = false
            for _, propName in pairs(playerOwnedProperties) do
                if garage.property and propName == garage.property then
                    isOwner = true
                    break
                end
            end
        end

        -- 🎯 Crée les zones d'interaction pour tous les types
        if garagetype == "private" and isOwner then
            local zoneName = garagelabel .. "_zonegarage"

            exports['qb-target']:AddCircleZone(zoneName, vector3(garagetakevehicle[1], garagetakevehicle[2], garagetakevehicle[3]), 1.5, {
                name = zoneName,
                useZ = true, 
                debugPoly = false,
            }, {
                options = {
                    {
                        type = "client",
                        icon = 'fa-solid fa-square-parking',
                        label = 'Ouvrir le garage',
                        action = function()
                            TriggerEvent('d-garage:openGarage', namegarage, garagejob, garagetype)
                        end
                    },
                    {
                        type = "client",
                        icon = 'fa-solid fa-arrow-up-from-bracket',
                        label = 'Ranger le véhicule le plus proche',
                        action = function()
                            DGarageGetIn(namegarage, category, garagejob, garagetype)
                        end
                    }
                },
                distance = 2.5,
            })
        elseif garagetype ~= "private" then
            -- 🧍 PNJ uniquement pour gang/job/public
            if garagetype == "gang" then
                hashpnj = GetHashKey(Config.GaragePed[garagegang][1])
            elseif garagetype == "job" then
                hashpnj = GetHashKey((Config.GaragePed[garagejob] or { "a_m_y_business_01" })[1])
            end

            -- 🔍 Vérifie si un PNJ existe déjà
            local existingPed = GetClosestPed(garagetakevehicle[1], garagetakevehicle[2], garagetakevehicle[3], 1.5, 1, 0, 0, 0, -1)
            if existingPed and DoesEntityExist(existingPed) then
            else
                RequestModel(hashpnj)
                while not HasModelLoaded(hashpnj) do Wait(100) end

                local garagepedJson = Config.GaragePed.default[1]
                local appearanceData = json.decode(garagepedJson)

                local pedGarageCreated = CreatePed(4, hashpnj, garagetakevehicle[1], garagetakevehicle[2], garagetakevehicle[3] - 1, pedheading, false, true)
                FreezeEntityPosition(pedGarageCreated, true)
                SetEntityInvincible(pedGarageCreated, true)
                SetBlockingOfNonTemporaryEvents(pedGarageCreated, true)
                SetEntityAsMissionEntity(pedGarageCreated, true, true)
                exports['DCommands']:LoadPlayerAppearance(pedGarageCreated, appearanceData)
                TaskStartScenarioInPlace(pedGarageCreated, "WORLD_HUMAN_CLIPBOARD", 0, true)

                exports['qb-target']:AddTargetEntity(pedGarageCreated, {
                    options = {
                        {
                            num = 1,
                            type = "client",
                            icon = 'fa-solid fa-square-parking',
                            label = 'Ouvrir le garage',
                            targeticon = 'fa-solid fa-car',
                            action = function()
                                TriggerEvent('d-garage:openGarage', namegarage, garagejob, garagetype)
                            end,
                            job = garagejob,
                            gang = garagegang
                        },
                        {
                            num = 2,
                            type = "client",
                            icon = 'fa-solid fa-arrow-up-from-bracket',
                            label = 'Ranger le véhicule le plus proche',
                            targeticon = 'fa-solid fa-car',
                            action = function()
                                DGarageGetIn(namegarage, category, garagejob, garagetype)
                            end,
                            job = garagejob,
                            gang = garagegang
                        }
                    },
                    distance = 2.5,
                })

                table.insert(garagePeds, pedGarageCreated)
            end
        end

        -- 🗺️ Blips
        if garagetype == "gang" then
            local blip = AddBlipForCoord(garagespawnpoint[1])
            SetBlipSprite(blip, 357)
            SetBlipDisplay(blip, 0)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 67)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Garage de Faction")
            EndTextCommandSetBlipName(blip)

        elseif garagetype == "job" then
            if playerData.job and garagejob == playerData.job.name then
                local blip = AddBlipForCoord(garagespawnpoint[1])
                SetBlipSprite(blip, 357)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 0.8)
                SetBlipColour(blip, 44)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Garage " .. garagejob)
                EndTextCommandSetBlipName(blip)
            end

        elseif garagetype == "private" and isOwner then
            local blip = AddBlipForCoord(garagespawnpoint[1])
            SetBlipSprite(blip, 357)
            SetBlipDisplay(blip, 0)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 50)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Garage privé")
            EndTextCommandSetBlipName(blip)

        else
            local blip = AddBlipForCoord(garagespawnpoint[1])
            SetBlipSprite(blip, 357)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 26)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Garage publique")
            EndTextCommandSetBlipName(blip)
        end
    end
    isLoadingGarages = false
end


RegisterNetEvent("d-garage:client:requestPrivateGarages", function()
    TriggerServerEvent("PipouImmo:server:getAllProperties")
end)

AddEventHandler('onClientResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        CreateThread(function()
            while not QBCore.Functions.GetPlayerData().citizenid do Wait(100) end

            TriggerServerEvent("PipouImmo:server:getPlayerProperties")
            
            Wait(1000)
            LoadGarages()
        end)
    end
end)




Citizen.CreateThread(function()
    drawnMarkers = {}

    while true do
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)

        for namegarage, garage in pairs(Config.Garages) do
            local getinpoint = garage.getinpoint
            local distance = #(playerCoords - getinpoint)
            local category = garage.category
            local range = 20.0

            if category == "air" or category == "boat" then
                range = 10
            end

            if distance < range then -- Seulement si le joueur est proche
                local isOwner = true

                if garage.type == "private" then
                    isOwner = false
                    for _, propName in pairs(playerOwnedProperties) do
                        if garage.property and propName == garage.property then
                            isOwner = true
                            break
                        end
                    end
                end

                if isOwner then
                    drawnMarkers[namegarage] = true
                else
                    drawnMarkers[namegarage] = nil
                end
            else
                drawnMarkers[namegarage] = nil
            end
        end

        Citizen.Wait(500)
    end
end)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        for namegarage, _ in pairs(drawnMarkers) do
            local garage = Config.Garages[namegarage]
            local getinpoint = garage.getinpoint
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - getinpoint)
            local category = garage.category
            local garagejob = garage.job
            local garagetype = garage.type
            local markertype, markersize, markerrange, upmarker = 36, 1.5, 2.0, 0

            if category == "air" then
                markertype, markersize, markerrange, upmarker = 34, 2.0, 7.0, 1
            elseif category == "boat" then
                markertype, markersize, markerrange = 35, 2.0, 7
            end

            local playerData = QBCore.Functions.GetPlayerData()
            local job = playerData.job.name

            local canInteract = true
            if garagejob and garagejob ~= job then
                canInteract = false
            end

            -- Cas spécial pour les garages privés : affichage uniquement si le joueur est proprio
            if garagetype == "private" then
                local isOwner = false
                for _, propName in pairs(playerOwnedProperties) do
                    if garage.property and propName == garage.property then
                        isOwner = true
                        break
                    end
                end
                if not isOwner then
                    canInteract = false
                end
            end

            if canInteract then
                -- Affiche le marker au sol
                DrawMarker(
                    markertype,
                    getinpoint.x, getinpoint.y, getinpoint.z - 0.5 + upmarker,
                    0.0, 0.0, 0.0,
                    1.0, 1.0, 1.0,
                    markersize, markersize, markersize,
                    255, 0, 0,
                    100,
                    true,
                    true,
                    2,
                    nil, nil, false
                )

                if distance < markerrange then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString("Appuyez sur ~g~E~s~ pour garer le véhicule")
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustReleased(0, 38) then
                        DGarageGetIn(namegarage, category, garagejob, garagetype)
                    end
                end
            end
        end
    end
end)





RegisterNetEvent('d-garage:openGarage')
AddEventHandler("d-garage:openGarage", function(label, garagejob,garagetype)
    SetDisplay(not display, label, garagejob,garagetype)
end)

function DGarageGetIn(garagelabel, category, garagejob, garagetype)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local closestVehicle, distance = QBCore.Functions.GetClosestVehicle(coords)

    if closestVehicle == 0 or distance > 5.0 then
        QBCore.Functions.Notify("Aucun véhicule à ranger", "error", 3000)
        return
    end

    local vehicletype = GetVehicleCategory(closestVehicle)

    if category == nil or category == "all" then
        category = vehicletype
    end

    if vehicletype ~= category then
        QBCore.Functions.Notify("Ce type de véhicule ne peut pas être rangé ici.", "error", 3000)
        return
    end

    local plate = GetVehicleNumberPlateText(closestVehicle)
    local hash = GetEntityModel(closestVehicle)
    local model = GetLabelText(GetDisplayNameFromVehicleModel(GetEntityModel(closestVehicle)))

    local mods = json.encode(QBCore.Functions.GetVehicleProperties(closestVehicle))
    local garage = garagelabel

    print("Garage : " .. garage)



    -- ✅ Toujours vérifier le propriétaire du véhicule
    QBCore.Functions.TriggerCallback('server-d-get-owner', function(isOwner)
        if isOwner then
            local ownerLabel = (garagejob ~= nil and garagejob ~= "" and garagetype ~= "private") and garagejob or ""
            TriggerServerEvent('d-garage:server:getinvehicle', plate, model, garage, mods, ownerLabel)
            QBCore.Functions.Notify("Véhicule rangé : " .. model, "primary", 3000)
            DeleteEntity(closestVehicle)
        else
            QBCore.Functions.Notify("🚫 Ce véhicule ne vous appartient pas", "error", 3000)
        end
    end, plate)
end




function GetVehicleCategory(vehicle)
    local vehicleClass = GetVehicleClass(vehicle)  

     -- Vérification si la classe du véhicule est dans la catégorie "car"
     if table.contains(Config.VehicleClass.car, vehicleClass) then
        return "car"
    -- Vérification si la classe du véhicule est dans la catégorie "air"
    elseif table.contains(Config.VehicleClass.air, vehicleClass) then
        return "air"
    -- Vérification si la classe du véhicule est dans la catégorie "sea"
    elseif table.contains(Config.VehicleClass.sea, vehicleClass) then
        return "sea"
    -- Vérification si la classe du véhicule est dans la catégorie "rig"
    elseif table.contains(Config.VehicleClass.rig, vehicleClass) then
        return "rig"
    else
        return "unknown"
    end
end

function table.contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- OUVERTURE/FERMETURE DU MENU GARAGE

function SetDisplay(bool, label, garagejob,garagetype)
    display= bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type='ui',
        status = bool,
        label = label,
        garagejob = garagejob,
        garagetype = garagetype,
    })

end

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
    DeleteVehiclePreview()
end)

RegisterNUICallback('getGarageList', function(data, cb)
    local namegarage = data.label
    local garagejob = data.garagejob




    QBCore.Functions.TriggerCallback('server-d-get-listvehicle', function(result)
        if garagejob =='job' then

            for k,v in pairs(result) do
                
                if garagejob==nil then
                    garagejob=""
                end
                SendNUIMessage({
                    type='addVehicleonlist',
                    model = result[k].model,
                    plate = result[k].plate,
                    currentgarage = namegarage,
                    job = garagejob
                })
            end


        else
            --print("getGarageListnotjob")
            --print(result[1].model)
            for k,v in pairs(result) do
                SendNUIMessage({
                    type='addVehicleonlist',
                    model = result[k].model,
                    plate = result[k].plate,
                    currentgarage = namegarage,
                })
                --print("Model: "..result[k].model.." | Plate: "..result[k].plate.." | garage : "..namegarage)
            end
        end
        SendNUIMessage({type='updatelistener', currentgarage = namegarage})
        cb(result)
    end, namegarage, garagejob)
end)

RegisterNUICallback('getOtherList', function(data, cb)

    local namegarage = data.label
    
    QBCore.Functions.TriggerCallback('server-d-get-listothervehicle', function(result)
        for k,v in pairs(result) do
        
            
            SendNUIMessage({
                type='addOtherVehicleonlist',
                model = result[k].model,
                plate = result[k].plate,
                garage = result[k].garage,
            })
        end
        cb(result)
    end, namegarage)
end)

RegisterNUICallback('getOutsideList', function(data, cb)
    local namegarage = data.label
    
    QBCore.Functions.TriggerCallback('server-d-get-listoutsidevehicle', function(result)
        for k,v in pairs(result) do
            SendNUIMessage({
                type='addOutsideVehicleonlist',
                model = result[k].model,
                plate = result[k].plate,
                coords = result[k].coords,
            })
        end
        cb(result)
    end, namegarage)
end)



local previewVehicle = nil
local cam = nil
RegisterNUICallback('d_previsualisation', function (data, cb)

    local model = data.model
    local plate = data.plate
    
    local garage = Config.Garages
    local currentgarage = data.currentgarage
    local garageConfig = garage[currentgarage]
    local spawnpoint = nil

    if garageConfig.type == "private" then
        spawnpoint = garageConfig.getinpoint
    else
        spawnpoint = garageConfig.spawnPoint
        if type(spawnpoint) == "table" then
            spawnpoint = spawnpoint[1]
        end
    end


    CreatePrevisualisationVehicle(model,plate, spawnpoint)
 

end)

function CreatePrevisualisationVehicle (model,plate, spawnpoint) 
    if previewVehicle then
        DeleteEntity(previewVehicle)
    end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end

    QBCore.Functions.TriggerCallback('server-d-get-mods', function(response)
        local mods = response

        previewVehicle = CreateVehicle(model, spawnpoint, true, false)
        SetEntityVisible(previewVehicle, true, false)
        SetEntityAlpha(previewVehicle, 220, false) -- rendre semi-transparent
        SetVehicleNumberPlateText(previewVehicle, plate)
        SetVehicleEngineOn(previewVehicle, true, true, true)
        SetVehicleUndriveable(previewVehicle, false)
        SetVehicleFixed(previewVehicle)
        SetVehicleDirtLevel(previewVehicle, 0.0)
        SetVehicleOnGroundProperly(previewVehicle)
        SetEntityAsMissionEntity(previewVehicle, true, true)
        QBCore.Functions.SetVehicleProperties(previewVehicle, json.decode(mods))

        SetModelAsNoLongerNeeded(model)

        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
        SetCamCoord(cam, spawnpoint + 5.0)
        PointCamAtCoord(cam, spawnpoint)
        SetCamActive(cam, true)

        SetCamParams(cam, -75.0, 0.0, 250.0, 30.0, 0, 0, 1, 90.0, 0, 0, 1)
        RenderScriptCams(true, false, 0, true, false)
    end, plate)


end

function DeleteVehiclePreview()
    if previewVehicle then
        DeleteEntity(previewVehicle)
        previewVehicle = nil
    end
    if cam then
        RenderScriptCams(false, false, 0, true, false)
        DestroyCam(cam, false)
        cam = nil
    end
end



RegisterNUICallback("d-spawnVehicle", function(data, cb)

    DeleteVehiclePreview()

    local model = data.model
    local plate = data.plate
    local garage = Config.Garages
    local garageConfig = garage[data.currentgarage]
    local spawnpoint = nil

    if garageConfig.type == "private" then
        spawnpoint = garageConfig.getinpoint -- directement un vector3
    else
        spawnpoint = garageConfig.spawnPoint
        if type(spawnpoint) == "table" then
            spawnpoint = spawnpoint[1]
        end
    end

    -- heading pour private ou autres (défaut à 0)
    --local heading = (spawnpoint.w or 0.0)

    local length = 5000
    local ped = PlayerPedId()

    QBCore.Functions.TriggerCallback('server-d-get-mods', function(response)
        local mods = response

        QBCore.Functions.SpawnVehicle(model, function(vehicle)
            SetVehicleNumberPlateText(vehicle, plate)
            SetEntityCoords(vehicle, spawnpoint.x, spawnpoint.y, spawnpoint.z)
            SetEntityHeading(vehicle, heading)
            SetVehicleEngineOn(vehicle, true, true, true)
            SetVehicleUndriveable(vehicle, false)
            SetVehicleFixed(vehicle)
            SetVehicleDirtLevel(vehicle, 0.0)
            SetVehicleOnGroundProperly(vehicle)
            SetEntityAsMissionEntity(vehicle, true, true)
            SetModelAsNoLongerNeeded(model)
            SetPedIntoVehicle(ped, vehicle, -1)
            QBCore.Functions.SetVehicleProperties(vehicle, json.decode(mods))

            TriggerServerEvent('d-garage:server:spawnedVehicle', plate, model, data.currentgarage)
        end)

        QBCore.Functions.Notify("Véhicule sorti : " .. model, "primary", length)
    end, plate)
end)



RegisterNUICallback('client_set_gps_outside', function(data,cb)
    QBCore.Functions.TriggerCallback('server-d-get-coords', function(response)
    
        local jsonString = response
        local gps = json.decode(jsonString)
        local x = gps.x
        local y = gps.y

        SetNewWaypoint(x,y)

        QBCore.Functions.Notify("Un point GPS a été placé", "primary", length)

        
    end, data.plate)

end)



RegisterCommand("savevehicle", function()

    local player = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(player, false)

    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
    local garage = "outside"
    local mods = json.encode(QBCore.Functions.GetVehicleProperties(vehicle))

    QBCore.Functions.TriggerCallback('server-d-get-owner', function(result)
        if result == true then
            QBCore.Functions.Notify("Le véhicule est déja enregistré", "error", length)
        else
            TriggerServerEvent('d-garage:server:registervehicle', data, plate,model, garage,mods)
            QBCore.Functions.Notify("Le véhicule vous appartient désormais", "primary", length)
        end

    end, plate)

end, false)



-- Dans d-garage/server.lua (ou shared, selon l’archi)
function AddPrivateGarage(name, label, spawnPoint, getInPoint, property)
    Config.Garages[name] = {
        label = label,
        type = "private",
        takeVehicle = spawnPoint,
        spawnPoint = { spawnPoint },
        getinpoint = getInPoint,
        property = property,
    }
end
exports('AddPrivateGarage', AddPrivateGarage)



RegisterCommand("reloadgarages", function()
    TriggerServerEvent("PipouImmo:server:getPlayerProperties")
    Wait(1000)
    LoadGarages()
end)


Citizen.CreateThread(function()
    while true do
        Wait(0)
        for name, garage in pairs(Config.Garages) do
            -- Empêche les véhicules de spawn à proximité du point de spawn
            for _, pos in pairs(garage.spawnPoint) do
                ClearAreaOfVehicles(pos.x, pos.y, pos.z, 10.0, false, false, false, false, false)
            end

            -- Empêche les PNJ de spawn à l'entrée
            local entry = garage.getinpoint
            ClearAreaOfPeds(entry.x, entry.y, entry.z, 10.0, 1)
            ClearAreaOfEverything(x, y, z, radius, false, false, false, false)
        end
    end
end)
