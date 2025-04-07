local QBCore = exports['qb-core']:GetCoreObject()
local json = require("json")

function loadDataFromJson(resourceName, filePath)
    local content = LoadResourceFile(resourceName, filePath)
    if content then
        local data = json.decode(content)
        return data
    else
        print("Failed to load file.")
        return nil
    end
end



function updateDoorStatus(doorEntity, newStatus)
    for k, v in pairs(data) do
        if v.model == GetEntityModel(doorEntity) and #(vector3(v.coords.x, v.coords.y, v.coords.z) - GetEntityCoords(doorEntity)) < 1.0 then
            v.status = newStatus
            --print("^3[DEBUG] Envoi mise à jour porte: " .. json.encode(v)) -- Debugging
            TriggerServerEvent("d-locksystem:updateDoorStatus", v)
            break
        end
    end
end



------------------------------------MENU----------------------------------------------------------
function SetDisplay(bool, label)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = 'ui',
        status = bool,
        label = label
    })
end

RegisterCommand("OpenLockSystem", function()
    SetDisplay(not display)
end, false)

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
end)

RegisterNUICallback("getcoords", function(data)
    local label = data.coordslot
    SetDisplay(false)
    local objectid, objectcoords, objectmodel = lookobject()
    SendNUIMessage({
        type = 'coords',
        label = label,
        objectid = objectid,
        objectcoords = objectcoords,
        objectmodel = objectmodel
    })
    SetDisplay(true)
end)


RegisterNUICallback('updatetabdoor', function(data)
    QBCore.Functions.TriggerCallback("server-d-locksystem:GetListDoor",function(response)
        SendNUIMessage({
            type = 'addnewdoortotitletable'
        })
        
        for k, v in pairs(response) do
            SendNUIMessage({
                type = 'addnewdoortotable',
                doorname = v.name ,
                doorcoords = v.coords ,
                doortype = v.type ,
                doorautomaticornot = v.automatic ,
                doorstatus = v.status ,
                doorangle = v.angle ,
                doorjob = v.job ,
            })
        end

    end)



end)
--------------------------------------------------------------------------------------------------
RegisterNUICallback('seedoorangle', function(data)
    local entity = tonumber(data.door)
    if DoesEntityExist(entity) then
        local angle = tonumber(data.angle)
        if angle then
            NetworkRequestControlOfEntity(entity)
            local startTime = GetGameTimer()
            while not NetworkHasControlOfEntity(entity) and GetGameTimer() - startTime < 2000 do
                Citizen.Wait(100)
                NetworkRequestControlOfEntity(entity)
            end

            if NetworkHasControlOfEntity(entity) then
                FreezeEntityPosition(entity, false)
                SetEntityRotation(entity, 0.0, 0.0, angle + 0.01, 2, true)
                local newHeading = GetEntityHeading(entity)
            else
                print("Échec du contrôle de l'entité")
            end
        else
            print("Valeur d'angle invalide:", data.angle)
        end
    else
        print("L'entité n'existe pas:", entity)
    end
end)

RegisterNUICallback('putalock', function(data)
    SetDisplay(false)

    local coordsString = data.coords
    local x, y, z = coordsString:match("([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+)")
    local doorCoords = vector3(tonumber(x), tonumber(y), tonumber(z))
    local doortype = data.type
    local automaticornot = data.automatic
    local doorModel = GetEntityModel(data.model)
    local isDoorLocked = data.status
    local doorEntity = GetDoorEntity(doorModel, doorCoords)
    local targetRotation = data.angle
    local jobdoor = data.job
    local namedoor = data.name

    if doortype == 'simpledoor' then
        TriggerServerEvent('d-locksystem:saveDoorData', {
            name = namedoor,
            job = jobdoor,
            type = doortype,
            automatic = automaticornot,
            angle = targetRotation,
            status = isDoorLocked,
            model = doorModel,
            coords = doorCoords
        })
    elseif doortype == 'doubledoor' then
        local coordsString2 = data.coords2
        local x2, y2, z2 = coordsString2:match("([%-%.%d]+),%s*([%-%.%d]+),%s*([%-%.%d]+)")
        local doorCoords2 = vector3(tonumber(x2), tonumber(y2), tonumber(z2))
        local targetRotation2 = data.angle2
        local doorModel2 = data.model2
        TriggerServerEvent('d-locksystem:saveDoorData', {
            name = namedoor,
            job = jobdoor,
            type = doortype,
            automatic = automaticornot,
            angle = targetRotation,
            angle2 = targetRotation2,
            status = isDoorLocked,
            model = doorModel,
            model2 = doorModel2,
            coords = doorCoords,
            coords2 = doorCoords2
        })
    end
end)


------------------------------------------------------------------------------------------

data = {}

-- Fonction pour dessiner un marqueur avec une texture
function CreateLockOpen(coords, isdouble, coords2)
    local textureDict = "lockopen"
    local spriteName = "lockopen"

    RequestStreamedTextureDict(textureDict, true)
    local timeout = 5000
    local timer = 0

    while not HasStreamedTextureDictLoaded(textureDict) do
        Citizen.Wait(100)
        timer = timer + 100
        if timer > timeout then
            print("Failed to load texture dict for lockopen.")
            return
        end
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - coords)
    if isdouble then
        local distance2 = #(playerCoords - coords2)
        if distance > distance2 then
            distance = distance2
        end

        local centerCoords = (coords + coords2) / 2
        if distance < 1.5 then
            SetDrawOrigin(centerCoords.x, centerCoords.y, centerCoords.z + 0.2, 0)
            DrawSprite(textureDict, spriteName, 0, 0, 0.015, 0.015, 0.0, 238, 238, 238, 255)
            ClearDrawOrigin()
        end
    else 
        if distance < 1.5 then
            SetDrawOrigin(coords.x, coords.y, coords.z + 0.2, 0)
            DrawSprite(textureDict, spriteName, 0, 0, 0.015, 0.015, 0.0, 238, 238, 238, 255)
            ClearDrawOrigin()
        end
    end
end

function CreateLockClose(coords, isdouble, coords2)
    local textureDict = "lockclose"
    local spriteName = "lockclose"

    RequestStreamedTextureDict(textureDict, true)
    local timeout = 5000
    local timer = 0

    while not HasStreamedTextureDictLoaded(textureDict) do
        Citizen.Wait(100)
        timer = timer + 100
        if timer > timeout then
            print("Failed to load texture dict for lockclose.")
            return
        end
    end

    local playerCoords = GetEntityCoords(PlayerPedId())
    local distance = #(playerCoords - coords)

    if isdouble then
        local distance2 = #(playerCoords - coords2)
        if distance > distance2 then
            distance = distance2
        end

    

        local centerCoords = vector3(((coords.x + coords2.x) / 2),((coords.y + coords2.y) / 2),((coords.z + coords2.z) / 2))
        
        
        if distance < 1.5 then
            SetDrawOrigin(centerCoords.x, centerCoords.y, centerCoords.z + 0.2, 0)
            DrawSprite(textureDict, spriteName, 0, 0, 0.015, 0.015, 0.0, 238, 238, 238, 255)
            ClearDrawOrigin()
        end
    else 
        if distance < 1.5 then
            SetDrawOrigin(coords.x, coords.y, coords.z + 0.2, 0)
            DrawSprite(textureDict, spriteName, 0, 0, 0.015, 0.015, 0.0, 238, 238, 238, 255)
            ClearDrawOrigin()
        end
    end
end

function GetDoorEntity(model, coords)
    if not model or not coords then
        print("Modèle ou coordonnées invalides.")
        return nil
    end

    --print("Recherche de l'entité pour le modèle :", model, "aux coordonnées :", coords)
    local doorEntity = GetClosestObjectOfType(coords, 1.5, model, false, false, false)

    if doorEntity == 0 then
        print("Aucune entité trouvée.")
        return nil
    else
        --print("Entité trouvée :", doorEntity)
    end

    return doorEntity
end



-- Déclaration de la table initialRotation en dehors de la fonction (si elle n'est pas déjà déclarée)
local initialRotation = {}

function RotateDoorGradually(door, targetAngle, isDouble, door2, targetAngle2)
    -- Vérifier si les portes sont valides avant de continuer
    if not DoesEntityExist(door) then
        print("Erreur : La porte 1 n'existe pas !")
        return
    end

    if isDouble and (not DoesEntityExist(door2)) then
        print("Erreur : La porte 2 n'existe pas !")
        return
    end

    -- Si c'est la première fois, on récupère l'angle initial de chaque porte
    if initialRotation[door] == nil then
        local currentRotation = GetEntityRotation(door, 2)
        initialRotation[door] = currentRotation.z
    end

    if isDouble and initialRotation[door2] == nil then
        local currentRotation2 = GetEntityRotation(door2, 2)
        initialRotation[door2] = currentRotation2.z
    end

    Citizen.CreateThread(function()
        while true do
            -- Calcul des angles actuels et différences pour la porte 1
            local currentRotation = GetEntityRotation(door, 2)
            local currentAngle = normalizeRotation(currentRotation.z)
            local deltaAngle = targetAngle - currentAngle
            if deltaAngle > 180 then deltaAngle = deltaAngle - 360
            elseif deltaAngle < -180 then deltaAngle = deltaAngle + 360 end

            -- Ajuste la rotation progressivement
            local step = math.sign(deltaAngle) * 1.0
            local newAngle = currentAngle + step
            if math.abs(deltaAngle) < 1.0 then break end

            -- Applique la nouvelle rotation à la porte
            SetEntityRotation(door, currentRotation.x, currentRotation.y, newAngle, 0, true)

            -- Si c'est une double porte, applique aussi la rotation à la deuxième porte
            if isDouble then
                local currentRotation2 = GetEntityRotation(door2, 2)
                local currentAngle2 = normalizeRotation(currentRotation2.z)
                local deltaAngle2 = targetAngle2 - currentAngle2
                if deltaAngle2 > 180 then deltaAngle2 = deltaAngle2 - 360
                elseif deltaAngle2 < -180 then deltaAngle2 = deltaAngle2 + 360 end

                local step2 = math.sign(deltaAngle2) * 1.0
                local newAngle2 = currentAngle2 + step2
                SetEntityRotation(door2, currentRotation2.x, currentRotation2.y, newAngle2, 0, true)
            end

            Citizen.Wait(0)
        end
    end)
end

function CloseAutomaticDoor(doorEntity,targetAngle, isDouble, doorEntity2, targetAngle2)
    
    RemoveDoorFromSystem(doorEntity)
    AddDoorToSystem(doorEntity, GetEntityModel(doorEntity), GetEntityCoords(doorEntity), false, false, false)
    DoorSystemSetDoorState(doorEntity, 2, false, false)
end

function OpenAutomaticDoor(doorEntity,targetAngle, isDouble, doorEntity2, targetAngle2)

    RemoveDoorFromSystem(doorEntity)
    AddDoorToSystem(doorEntity, GetEntityModel(doorEntity), GetEntityCoords(doorEntity), false, false, false)
    DoorSystemSetDoorState(doorEntity, 0, false, false)
end

function normalizeRotation(rotation)
    if rotation then
        return (rotation % 360 + 360) % 360
    else
        print("Invalid rotation value:", rotation)
        return 0.0
    end
end

--118274
--854291622
--vector3(313.4801, -595.4583, 43.43398)

local DoorsJson = {}

-- Charger les données une seule fois
Citizen.CreateThread(function()
    DoorsJson = loadDataFromJson("d-locksystem", "doors.json")
    if not DoorsJson then
        DoorsJson = {}
    end
end)

-- Fonction pour mettre à jour l'état de la porte localement
function updateDoorStatusLocally(doorEntity, newStatus)
    for k, v in pairs(DoorsJson) do
        -- print("------------------------------updateDoorStatusLocally----------------------")
        -- print(v.model)
        -- print(GetEntityModel(doorEntity))
        -- print(v.coords.x, v.coords.y, v.coords.z)
        -- print(GetEntityCoords(doorEntity))
        -- print(#(vector3(v.coords.x, v.coords.y, v.coords.z) - GetEntityCoords(doorEntity)))
        if v.model == GetEntityModel(doorEntity) and #(vector3(v.coords.x, v.coords.y, v.coords.z) - GetEntityCoords(doorEntity)) < 1.0 then
            v.status = newStatus
            --print("------------------------------updateDoorStatusLocally----------------------")
            TriggerServerEvent("d-locksystem:updateDoorStatus", v)  -- Envoie la mise à jour au serveur
            break
        end
    end
end


-- RegisterNetEvent('d-locksystem:updateDoorsState')
-- AddEventHandler('d-locksystem:updateDoorsState', function(doorsJson)
--     for _, door in pairs(doorsJson) do
--         if door.type == "doubledoor" then
--             -- Trouver les deux portes dans le groupe
--             if door.status == "open" then
--                 -- Animation pour ouvrir les deux portes
--                 -- Appliquer l'animation de porte ouverte sur les deux portes
--                 SetDoorState(door.model, door.coords, true)
--                 SetDoorState(door.model2, door.coords2, true)
--             else
--                 -- Animation pour fermer les deux portes
--                 SetDoorState(door.model, door.coords, false)
--                 SetDoorState(door.model2, door.coords2, false)
--             end
--         elseif door.type == "simpledoor" then
--             -- Appliquer l'état à la porte simple
--             if door.status == "open" then
--                 SetDoorState(door.model, door.coords, true)
--             else
--                 SetDoorState(door.model, door.coords, false)
--             end
--         end
--     end
-- end)



RegisterNetEvent('d-locksystem:AddANewDoor')
AddEventHandler('d-locksystem:AddANewDoor', function (newdoor)

    if type(DoorsJson) ~= "table" then
        DoorsJson = json.decode(DoorsJson) or {}
    end
    if type(newdoor) ~= "table" then
        newdoor = json.decode(newdoor) or {}
    end
    for _, door in ipairs(newdoor) do
        table.insert(DoorsJson, door)
    end


    table.insert(newdoor,DoorsJson)
    DoorsJson = json.encode(DoorsJson, { indent = true })
end)

--MAIN THREAD
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if type(DoorsJson) == "string" then
            local success, decodedData = pcall(json.decode, DoorsJson)
            if success and type(decodedData) == "table" then
                DoorsJson = decodedData
            else
                print("Erreur : DoorsJson n'est pas une table valide.")
                return
            end
        end

        if DoorsJson and type(DoorsJson) == "table" then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            for k, v in pairs(DoorsJson) do
                local doorCoords = vector3(v.coords.x, v.coords.y, v.coords.z)
                local distance = #(playerCoords - doorCoords)

                if distance < 10.0 then

                    local doorModel = v.model
                    local doorEntity = GetDoorEntity(doorModel, doorCoords)
                    local targetRotation = tonumber(v.angle)
                    local isDoorLocked = (v.status == 'close')
                    local playerjob = QBCore.Functions.GetPlayerData().job.name
                    local automaticornot = v.automatic

                    if v.type == 'doubledoor' then
                        local doorCoords2 = vector3(v.coords2.x, v.coords2.y, v.coords2.z)
                        local targetRotation2 = tonumber(v.angle2)
                        local doorModel2 = v.model2
                        local doorEntity2 = doorModel2

                        if doorEntity and doorEntity2 then
                            --RotateDoorGradually(doorEntity, targetRotation, true, doorEntity2, targetRotation2)

                            --local isDoorLocked = (v.status == 'close')

                            if IsControlJustPressed(0, 38) then
                                if playerjob==v.job then
                                    ToggleDoorLock(isDoorLocked, doorEntity, targetRotation, automaticornot)
                                    ToggleDoorLock(isDoorLocked, doorEntity2, targetRotation2, automaticornot)
                                    updateDoorStatusLocally(doorEntity, (v.status == 'open' and 'close' or 'open'))
                                    updateDoorStatusLocally(doorEntity2, (v.status == 'open' and 'close' or 'open'))

                                else
                                    QBCore.Functions.Notify("Vous n'avez pas l'autorisation", "primary", length)
                                end
                            end

                            if isDoorLocked then
                                CreateLockClose(doorCoords, true, doorCoords2)
                                --CreateLockClose(doorCoords2)
                                FreezeEntityPosition(doorEntity, true)
                                FreezeEntityPosition(doorEntity2, true)
                            else
                                CreateLockOpen(doorCoords, true,doorCoords2)
                                --CreateLockOpen(doorCoords2)
                                FreezeEntityPosition(doorEntity, false)
                                FreezeEntityPosition(doorEntity2, false)
                            end
                        else
                            print("Invalid door entities for double door:", v.name)
                        end
                    elseif v.type == 'simpledoor' then
                        if doorEntity then
                            --RotateDoorGradually(doorEntity, targetRotation)

                            if IsControlJustPressed(0, 38) then
                                if playerjob==v.job then
                                    
                                    ToggleDoorLock(isDoorLocked, doorEntity, targetRotation,automaticornot)
                                    updateDoorStatusLocally(doorEntity, (v.status == 'open' and 'close' or 'open'))
                                else
                                    QBCore.Functions.Notify("Vous n'avez pas l'autorisation", "primary", length)
                                end
                            end

                            if isDoorLocked then
                                CreateLockClose(doorCoords, false)
                                FreezeEntityPosition(doorEntity, true)
                            else
                                CreateLockOpen(doorCoords, false)
                                FreezeEntityPosition(doorEntity, false)
                            end
                        else
                            print("Invalid door entity for door:", v.name)
                        end
                    end
                end
            end
        else
            print("Failed to load door data or data is not a table.")
        end
    end
end)

function ToggleDoorLock(isDoorLocked, doorEntity, targetAngle, automaticornot)
    --print(isDoorLocked)
    if isDoorLocked then
        if DoesEntityExist(doorEntity) then
            if RequestControlOfDoor(doorEntity) then
                --FreezeEntityPosition(doorEntity, false)
                --SetEntityDynamic(doorEntity, true)
                --PlaceObjectOnGroundProperly(doorEntity)
                OpenAutomaticDoor(doorEntity)

            end
        end
    else
        if DoesEntityExist(doorEntity) then
            if RequestControlOfDoor(doorEntity) then
                --FreezeEntityPosition(doorEntity, true)

                if not automaticornot then
                    RotateDoorGradually(doorEntity, targetAngle)
                    CloseAutomaticDoor(doorEntity,targetAngle)
                else
                    CloseAutomaticDoor(doorEntity,targetAngle)
                end

            end
        end
    end
end

function RequestControlOfDoor(doorEntity)
    NetworkRequestControlOfEntity(doorEntity)
    local startTime = GetGameTimer()
    while not NetworkHasControlOfEntity(doorEntity) and (GetGameTimer() - startTime < 2000) do
        Citizen.Wait(0)
        NetworkRequestControlOfEntity(doorEntity)
    end
    return NetworkHasControlOfEntity(doorEntity)
end

--Fonction pour obtenir le signe d'un nombre (positif ou négatif)
function math.sign(x)
    if x < 0 then
        return -1
    elseif x > 0 then
        return 1
    else
        return 0
    end
end



RegisterCommand("closedoor", function()
    RemoveDoorFromSystem(91906)
    AddDoorToSystem(91906, -487908756, vector3(299.23,-585.93,42.28), false, false, false)
    DoorSystemSetDoorState(91906, 2, false, false)
end, false)

RegisterCommand("opendoor", function()
    RemoveDoorFromSystem(91906)
    AddDoorToSystem(91906, -487908756, vector3(299.23,-585.93,42.28), false, false, false)
    DoorSystemSetDoorState(91906, 0, true, true)
end, false)


