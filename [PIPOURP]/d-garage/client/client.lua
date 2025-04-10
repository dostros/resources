local QBCore = exports['qb-core']:GetCoreObject()
local json = require("json")


Citizen.CreateThread(function()
    while true do
        DisplayRadar(true)
        Wait(000)
    end   
end)


Citizen.CreateThread(function()
    local listgarage = Config.Garages
    Citizen.Wait(1000)
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
        if garagetype == "gang" then
            hashpnj = GetHashKey(Config.GaragePed[garagegang][1])
        elseif garagetype =='job' then
            if GetHashKey(Config.GaragePed[garagejob][1]) then
                hashpnj = GetHashKey(Config.GaragePed[garagejob][1])
            else
                hashpnj = GetHashKey("a_m_y_business_01")
            end
        end





        ---------------------------------------PNJ--------------------------------------------

        local pedheading = garagetakevehicle[4]
        RequestModel(hashpnj)
        local waiting = 0
        while not HasModelLoaded(hashpnj) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 3000 then
                print("Model not found")
                break
            end
        end

        local garagepedJson = Config.GaragePed.default[1]
        local appearanceData = json.decode(garagepedJson)




        local pedGarageCreated = CreatePed(4, hashpnj, garagetakevehicle[1], garagetakevehicle[2], garagetakevehicle[3]-1, pedheading, false, true)
        FreezeEntityPosition(pedGarageCreated, true)
        SetEntityInvincible(pedGarageCreated, true)
        SetBlockingOfNonTemporaryEvents(pedGarageCreated, true)
        SetEntityAsMissionEntity(pedGarageCreated, true, true)
        exports['DCommands']:LoadPlayerAppearance(pedGarageCreated,appearanceData)
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
                        TriggerEvent('d-garage:openGarage', namegarage,garagejob,garagetype )
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
                        DGarageGetIn(namegarage,category,garagejob)
                    end,
                    job = garagejob,
                    gang = garagegang
                }
            },
            distance = 2.5,
        })

        ------------------------------------------------------------------------------------
        ---------------------------------------BLIP------------------------------------------
        
        if garagetype== "gang" then
            
            local blip = AddBlipForCoord(garagespawnpoint[1])
            SetBlipSprite(blip, 357)  -- Choisis l'icône du blip
            SetBlipDisplay(blip, 0)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 67)  
            SetBlipAsShortRange(blip, true)  -- Le blip sera visible même de loin
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Garage de Faction")  -- Remplace par le nom de ton blip
            EndTextCommandSetBlipName(blip)
    
        else if garagetype ~= "job" then

            local blip = AddBlipForCoord(garagespawnpoint[1])
            SetBlipSprite(blip, 357)  -- Choisis l'icône du blip
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 26)  
            SetBlipAsShortRange(blip, true)  -- Le blip sera visible même de loin
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Garage publique")  -- Remplace par le nom de ton blip
            EndTextCommandSetBlipName(blip)
        
    
            
        else 

            local playerData = QBCore.Functions.GetPlayerData()  -- Récupère les données du joueur

            if playerData and playerData.job and playerData.job.name  then
                local job = playerData.job.name
            else
                break
            end
            
            if garagejob == job then
                local blip = AddBlipForCoord(garagespawnpoint[1])
                SetBlipSprite(blip, 357)  -- Choisis l'icône du blip
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, 0.8)
                SetBlipColour(blip, 25)  
                SetBlipAsShortRange(blip, true)  -- Le blip sera visible même de loin
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Garage "..garagejob)  -- Remplace par le nom de ton blip
                EndTextCommandSetBlipName(blip)
            end
        end

    end
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

            if category == "air" or category =="boat" then
                range = 10
            end



            if distance < range then -- Seulement si le joueur est proche
                drawnMarkers[namegarage] = true
            else
                drawnMarkers[namegarage] = nil
            end
        end

        Citizen.Wait(500) -- Vérifie toutes les 500ms au lieu de 0ms (évite le surmenage du CPU)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0) -- Minimum requis pour afficher les marqueurs

        for namegarage, _ in pairs(drawnMarkers) do
            local garage = Config.Garages[namegarage]
            local getinpoint = garage.getinpoint
            local ped = PlayerPedId()
            local playerCoords = GetEntityCoords(ped)
            local distance = #(playerCoords - getinpoint)
            local category = garage.category
            local garagejob = garage.job
            local markertype = 0
            local markersize = 0
            local markerrange = 0
            local upmarker =0

            if category == "air" then
                markertype = 34
                markersize = 2.0
                markerrange = 7.0
                upmarker = 1
            elseif category == "boat" then
                markertype= 35
                markersize = 2.0
                markerrange = 7
            else
                markertype= 36
                markersize = 1.5
                markerrange = 2.0
            end
            
            -- Récupérer les données du joueur
            local playerData = QBCore.Functions.GetPlayerData()
            local job = playerData.job.name

            -- Vérifier si le joueur est autorisé à utiliser ce garage (métier)
            local canInteract = true
            if garage.job and garage.job ~= job then
                canInteract = false
            end

            if canInteract then
                -- Dessiner le marqueur
                DrawMarker(
                    markertype, -- Type de marqueur
                    getinpoint.x, getinpoint.y, getinpoint.z-0.5+upmarker, -- Coordonnées ajustées
                    0.0, 0.0, 0.0, -- Direction
                    1.0, 1.0, 1.0, -- Rotation
                    markersize, markersize, markersize, -- Taille
                    255, 0, 0, -- Couleur RGB
                    100, -- Opacité (100 pour mieux voir)
                    true, -- Bob up and down
                    true, -- Face caméra
                    2, -- Rotation
                    nil, nil, false
                )

                if distance < markerrange then -- Distance à laquelle le texte devient visible
                    SetTextComponentFormat("STRING")
                    AddTextComponentString("Appuyez sur ~g~E~s~ pour garer le véhicule")
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
                    if IsControlJustReleased(0, 38) then -- 38 est le code de la touche E
                        DGarageGetIn(namegarage,category,garagejob)
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

function DGarageGetIn(garagelabel, category,garagejob)
    
    local coords = GetEntityCoords(PlayerPedId())
    local closestVehicle, distance = QBCore.Functions.GetClosestVehicle(coords)

    local vehicletype = GetVehicleCategory(closestVehicle)



    if category == nil then
        category = vehicletype
    end
    
    if category == "all" then
        category=  vehicletype
    end
    
    if vehicletype ~= category then
        QBCore.Functions.Notify("Ce type de véhicule ne peut pas être rangé ici.", "error", 3000)
        return
    end




    if closestVehicle == 0 or distance > 5.0 then
        QBCore.Functions.Notify("Aucun véhicule à ranger", "error", length)
        return
    end
    local plate = GetVehicleNumberPlateText(closestVehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(closestVehicle))
    local garage = garagelabel
    local mods = json.encode(QBCore.Functions.GetVehicleProperties(closestVehicle))

    if garagejob == '' then

        QBCore.Functions.TriggerCallback('server-d-get-owner', function(result)
            if result == true then
                TriggerServerEvent('d-garage:server:getinvehicle', data, plate,model, garage,mods,garagejob)
                QBCore.Functions.Notify("Véhicule rangé : "..model, "primary", length)
                DeleteEntity(closestVehicle)
            else
                QBCore.Functions.Notify("Ce véhicule ne vous appartient pas", "error", length)
            end

        end, plate)
    else
        
        TriggerServerEvent('d-garage:server:getinvehicle', data, plate,model, garage,mods,garagejob )
        QBCore.Functions.Notify("Véhicule rangé : "..model, "primary", length)
        DeleteEntity(closestVehicle)

    end

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
            print("getGarageListnotjob")
            print(result[1].model)
            for k,v in pairs(result) do
                SendNUIMessage({
                    type='addVehicleonlist',
                    model = result[k].model,
                    plate = result[k].plate,
                    currentgarage = namegarage,
                })
                print("Model: "..result[k].model.." | Plate: "..result[k].plate.." | garage : "..namegarage)
            end
        end
        SendNUIMessage({type='updatelistener', currentgarage = namegarage})
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
    end, namegarage)
end)



local previewVehicle = nil
local cam = nil
RegisterNUICallback('d_previsualisation', function (data, cb)

    local model = data.model
    local plate = data.plate
    
    local garage = Config.Garages
    local currentgarage = data.currentgarage
    local spawnposition = garage[currentgarage].spawnPoint[1]

    CreatePrevisualisationVehicle(model,plate, spawnposition)
 

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
    local spawnposition = garage[data.currentgarage].spawnPoint
    local heading = spawnposition[1].w
    local length = 5000
    local ped = PlayerPedId()
    local coords = QBCore.Functions.GetCoords(ped)

    
    QBCore.Functions.TriggerCallback('server-d-get-mods', function(response)

        local mods = response

        QBCore.Functions.SpawnVehicle(model, function(vehicle)
            SetVehicleNumberPlateText(vehicle, plate)
            SetEntityCoords(vehicle, spawnposition[1], spawnposition[2], spawnposition[3])
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
        QBCore.Functions.Notify("Véhicule sorti : "..model, "primary", length)
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