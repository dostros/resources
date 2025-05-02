-- local QBCore = exports['qb-core']:GetCoreObject()
-- local spawnedShell = nil
-- local createdZones = {}
-- local cachedProperties = {}
-- local IsInInstance = false
-- local currentPropertyName = nil
-- local isLightOn = true
-- local previewProp = nil
-- local previewRotationThread = nil
-- local spawnedFurniture = {}
-- local activeZones = {}




function GetInstanceZ(level)
    return -100 - (level * 50)
end

-- 🏢 Affichage NUI
function SetDisplay(bool, label)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = 'ui',
        status = bool,
        label = label
    })
end

RegisterCommand("agence", function()
    SetDisplay(not display)
end, false)

RegisterNUICallback('exit', function(_, cb)
    SetDisplay(false)
    cb("ok")
end)

-- 🔁 Charger toutes les propriétés à la connexion via QBCore Callback
CreateThread(function()
    QBCore.Functions.TriggerCallback('PipouImmo:server:getAllProperties', function(properties)
        --print("📦 Propriétés chargées depuis la DB :", json.encode(properties, { indent = true }))
        for _, prop in ipairs(properties) do
            createHousePoint(prop.name, prop.coords)
            cachedProperties[prop.name] = prop
        
            -- Charger le garage si présent
            if prop.garagecoords and prop.garageout then
                exports['d-garage']:AddPrivateGarage(
                    "house_" .. prop.name,
                    "Garage de " .. prop.name,
                    vector4(prop.garagecoords.x, prop.garagecoords.y, prop.garagecoords.z, prop.garagecoords.w or 0.0),
                    vector3(prop.garageout.x, prop.garageout.y, prop.garageout.z),
                    prop.name
                )
            end
        end        
    end)
end)

CreateThread(function()
    Wait(2000)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    TriggerServerEvent("PipouImmo:server:getPlayerProperties")


    if coords.z <= -100 then
        QBCore.Functions.TriggerCallback('PipouImmo:server:getPropertyAtCoords', function(propData)
            if not propData then
                exports['PipouUI']:Notify("🚨 Intérieur inconnu, déplacement vers un lieu sûr...", "error")
                SetEntityCoords(ped, 200.0, -1000.0, 30.0) -- fallback safe zone
                return
            end

            exports['PipouUI']:Notify("Vous avez été replacé dans votre intérieur", "info")

            local shellModel = GetHashKey(propData.type)
            RequestModel(shellModel)
            while not HasModelLoaded(shellModel) do Wait(10) end

            -- Recalcule les bonnes coordonnées de l'instance
            local interiorZ = GetInstanceZ(propData.level or 1)
            local shellCoords = vector3(propData.x, propData.y, interiorZ)

            spawnedShell = CreateObject(shellModel, shellCoords.x, shellCoords.y, shellCoords.z, false, false, false)
            SetEntityHeading(spawnedShell, 0.0)
            FreezeEntityPosition(spawnedShell, true)

            -- Application des offsets pour positionner correctement le joueur et la sortie
            local shellConfig = Config.InteriorTypes[propData.type] or { diffx = 0.0, diffy = 0.0, diffz = 0.0 }
            local playerSpawn = shellCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz + 1.0)
            local exitZoneCenter = shellCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz+2.7)

            SetEntityCoords(ped, playerSpawn)
            createShellExitPoint(exitZoneCenter, propData.entrance)
            IsInInstance = true

        end, coords)
    end
end)



-- 📍 Création d'une propriété
RegisterNUICallback('Pipou-Immo-createProperty', function(data, cb)
    local propertyName = data.propertyName
    local propertyType = data.typeinterior
    local level = tonumber(data.level) or 1
    local Housecoords = data.coords1
    local Garagecoords = data.coords2
    local GarageOut = data.coords3

    if not propertyName or not propertyType or not Housecoords or not Housecoords.x then
        exports['PipouUI']:Notify("Données invalides ou incomplètes", "error")
        cb({ success = false })
        return
    end

    createHousePoint(propertyName, Housecoords)

    local model = GetHashKey(propertyType)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local instanceZ = GetInstanceZ(level)
    local shellCoords = vector3(Housecoords.x, Housecoords.y, instanceZ)

    spawnedShell = CreateObject(model, shellCoords.x, shellCoords.y, shellCoords.z, false, false, false)
    SetEntityHeading(spawnedShell, 0.0)
    FreezeEntityPosition(spawnedShell, true)

    if Garagecoords and GarageOut then
        exports['d-garage']:AddPrivateGarage(
            "house_garage_" .. propertyName,
            "Garage de " .. propertyName,
            vector4(Garagecoords.x, Garagecoords.y, Garagecoords.z, Garagecoords.w or 0.0),
            vector3(GarageOut.x, GarageOut.y, GarageOut.z),
            propertyName
        )

    end
    
    

    QBCore.Functions.TriggerCallback("PipouImmo:server:saveProperty", function(success)
        if success then
            exports['PipouUI']:Notify("Propriété enregistrée avec succès !", "success")
            SetDisplay(false)
            cb({ success = true })
        else
            exports['PipouUI']:Notify("Erreur lors de la sauvegarde", "error")
            cb({ success = false })
        end
    end, propertyName, propertyType, level, Housecoords, Garagecoords, GarageOut)

    TriggerEvent('d-garage:reloadGarages')

end)

-- 🪯 Capture des coords depuis NUI
RegisterNUICallback("Pipou-Immo-setPropertyCoords", function(data, cb)
    CreateThread(function()
        local waiting = true
        while waiting do
            Wait(0)
            SetTextComponentFormat("STRING")
            AddTextComponentString("Appuyez sur ~g~E~s~ pour placer le point")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustReleased(0, 38) then 
                local playerCoords = GetEntityCoords(PlayerPedId())
                PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)
                exports['PipouUI']:Notify("📍 Point placé : " .. playerCoords.x .. ", " .. playerCoords.y)

                SetNuiFocus(true, true)
                SendNUIMessage({
                    type = "ui",
                    status = true,
                    page = "sellPropertyForm"
                })
                SendNUIMessage({
                    type = "setPropertyCoords",
                    propertyId = data.propertyId,
                    coords = {
                        x = playerCoords.x,
                        y = playerCoords.y,
                        z = playerCoords.z
                    }
                })


                waiting = false
            end
        end
    end)
end)

-- 👥 Attribution maison
RegisterCommand("givehouse", function(source, args)
    local targetId = tonumber(args[1]) or GetPlayerServerId(PlayerId())
    local propertyName = args[2]
    if not propertyName then
        exports['PipouUI']:Notify("Utilisation : /givehouse [id] [propertyName]", "error")
        return
    end

    QBCore.Functions.TriggerCallback("PipouImmo:server:assignProperty", function(success, message)
        if success then
            exports['PipouUI']:Notify(message, "success")
            TriggerServerEvent("PipouImmo:server:getPlayerProperties")
        else
            exports['PipouUI']:Notify(message, "error")
        end
    end, targetId, propertyName)
end)

-- 🌟 Création zone d’entrée personnalisée
function createHousePoint(propertyName, coords)
    local zoneName = "housePoint_" .. propertyName:gsub("%s+", "")
    if createdZones[zoneName] then return end
    createdZones[zoneName] = true

    exports['qb-target']:AddCircleZone(zoneName, vector3(coords.x, coords.y, coords.z), 1.5, {
        name = zoneName,
        useZ = true, 
        debugPoly = false,
    }, {
        options = {
            {
                type = "client",
                event = "Pipou-Immo:enterHouse",
                icon = "fas fa-door-open",
                label = "Entrer dans la maison",
                property = propertyName
            }
        },
        distance = 2.5,
    })
end

-- 🚪 Entrée dans la maison avec chargement du shell
RegisterNetEvent('Pipou-Immo:enterHouse', function(data)
    local propertyName = data.property
    QBCore.Functions.TriggerCallback('PipouImmo:server:checkPropertyAccess', function(hasAccess, houseCoords, level, accessType)
        if hasAccess and accessType ~= 'tenant' then
            local interiorZ = GetInstanceZ(level)
            local shellCoords = vector3(houseCoords.x, houseCoords.y, interiorZ)
            local propData = cachedProperties[propertyName]
            local modelName = propData and propData.type or "shell_apartment"
            local model = GetHashKey(modelName)

            local shellConfig = Config.InteriorTypes[modelName] or { diffx = 0.0, diffy = 0.0, diffz = 0.0 }

            RequestModel(model)
            while not HasModelLoaded(model) do Wait(10) end

            spawnedShell = CreateObject(model, shellCoords.x, shellCoords.y, shellCoords.z, false, false, false)
            SetEntityHeading(spawnedShell, 0.0)
            FreezeEntityPosition(spawnedShell, true)

            -- 🧍 TP joueur avec le bon décalage
            local playerSpawn = shellCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz + 1.0)

            DoScreenFadeOut(500)
            Wait(600)
            SetEntityCoords(PlayerPedId(), playerSpawn)
            Wait(100)
            DoScreenFadeIn(500)
            IsInInstance = true
            currentPropertyName = propertyName


            -- 🚪 Créer le point de sortie à cet endroit
            local exitZoneCenter = shellCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz+2.7)
            createShellExitPoint(exitZoneCenter, houseCoords)
        
    

            -- QBCore.Functions.TriggerCallback("PipouImmo:getPlayerFurniture", function(furnitures)
            --     for _, item in pairs(furnitures) do
            --         local model = GetHashKey(item.object)
            --         RequestModel(model)
            --         while not HasModelLoaded(model) do Wait(10) end
            
            --         local obj = CreateObject(model, item.coords.x, item.coords.y, item.coords.z, true, true, true)
            --         while not DoesEntityExist(obj) do Wait(0) end

            --         SetEntityAsMissionEntity(obj, true, true)
            --         SetEntityCollision(obj, true, true)
            --         SetEntityDynamic(obj, true)

            --         SetEntityRotation(obj, item.pitch or 0.0, item.roll or 0.0, item.heading or 0.0, 2, false)
            --         PlaceObjectOnGroundProperly(obj)
            --         FreezeEntityPosition(obj, true)

            --         table.insert(spawnedFurniture, obj)

            --         -- qb-target
            --         exports['qb-target']:AddTargetEntity(obj, {
            --             options = {
            --                 {
            --                     label = "🛠️ Déplacer le meuble",
            --                     icon = "fas fa-arrows-alt",
            --                     action = function()
            --                         TriggerEvent("PipouImmo:startPlacingExistingFurniture", obj, item)
            --                     end
            --                 },
            --                 {
            --                     label = " Supprimer le meuble",
            --                     icon = "fas fa-trash",
            --                     action = function()
            --                         TriggerServerEvent("PipouImmo:server:removeFurniture", item.id)
            --                         DeleteEntity(obj)
            --                         exports['PipouUI']:Notify("🗑️ Meuble supprimé", "success")
            --                     end
            --                 }
            --             },
            --             distance = 2.5
            --         })



            --     end
            -- end, propertyName)
            
            TriggerServerEvent("PipouImmo:server:broadcastFurniture", propertyName)
            
            


        elseif hasAccess then
            exports['PipouUI']:Notify("🔒 Vous êtes locataire : l'accès est restreint.", "error")
        else
            exports['PipouUI']:Notify("Vous n'avez pas de droit d'accès à cette propriété.", "error")
        end
    end, propertyName)
end)

-- 🚪 Sortie de la maison
function createShellExitPoint(instanceCoords, returnCoords)
    local exitName = "exit_shell_" .. math.random(1000, 9999)

    AddZone(exitName, instanceCoords, 1.0, 1.0, {
        name = exitName,
        heading = 0,
        debugPoly = false,
        minZ = instanceCoords.z - 0.5,
        maxZ = instanceCoords.z + 1.5
    }, {
        options = {
            {
                type = "client",
                event = "Pipou-Immo:exitHouse",
                icon = "fas fa-sign-out-alt",
                label = "Sortir de la maison",
                returnCoords = returnCoords,
                zoneName = exitName
            }
        },
        distance = 3.0
    })
end


RegisterNetEvent('Pipou-Immo:exitHouse', function(data)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(10) end

    SetEntityCoords(PlayerPedId(), data.returnCoords.x, data.returnCoords.y, data.returnCoords.z)
    Wait(100)
    DoScreenFadeIn(500)

    if data.zoneName then
        exports['qb-target']:RemoveZone(data.zoneName)
    end

    CleanInstance()
end)



-- 🧹 Nettoyage du shell
RegisterCommand("removeappart", function()
    CleanInstance()
    exports['PipouUI']:Notify("🏠 Shell et meubles supprimés avec succès.", "success")
end)



AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        CleanInstance()
    end
end)


AddEventHandler('playerDropped', function()
    CleanInstance()
end)



-- 📦 Envoi des types d'intérieurs à la NUI
RegisterNUICallback('Pipou-Immo-getinteriortypes', function(_, cb)
    local formattedInteriorTypes = {}
    for k, v in pairs(Config.InteriorTypes) do
        table.insert(formattedInteriorTypes, {
            name = k,
            label = v.label,
        })
    end
    table.sort(formattedInteriorTypes, function(a, b)
        return a.label < b.label
    end)
    cb(formattedInteriorTypes)
end)


RegisterCommand('spawnshell', function(source, args)
    local shellName = args[1] or "shell_apartment"
    local shellModel = GetHashKey(shellName)

    RequestModel(shellModel)
    while not HasModelLoaded(shellModel) do Wait(10) end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    spawnedShell = CreateObject(shellModel, playerCoords.x, playerCoords.y, playerCoords.z - 1.0, false, false, false)
    SetEntityHeading(spawnedShell, 0.0)
    FreezeEntityPosition(spawnedShell, true)

    exports['PipouUI']:Notify("Shell spawned: " .. shellName, "success")
end)    

RegisterNetEvent('PipouImmo:client:addHouseEntryPoint', function(propertyName)
    local prop = cachedProperties[propertyName]
    if not prop then
        QBCore.Functions.TriggerCallback('PipouImmo:server:getAllProperties', function(properties)
            for _, p in ipairs(properties) do
                cachedProperties[p.name] = p
            end
            if cachedProperties[propertyName] then
                createHousePoint(propertyName, cachedProperties[propertyName].coords)
                exports['PipouUI']:Notify("📦 Propriété reçue : " .. propertyName, "success")
            else
                exports['PipouUI']:Notify(" Erreur : impossible d’ajouter la propriété", "error")
            end
        end)
    else
        createHousePoint(propertyName, prop.coords)
        exports['PipouUI']:Notify("📦 Propriété reçue : " .. propertyName, "success")
    end
end)






RegisterNetEvent('Pipou-Immo:toggleLight', function()
    SetShellLightState(not isLightOn)

    exports['PipouUI']:Notify(isLightOn and "💡 Lumière allumée" or "💡 Lumière éteinte", "info")
end)


local LightThread = nil

local LightThread = nil

function SetShellLightState(state)
    if not spawnedShell or not DoesEntityExist(spawnedShell) then return end

    isLightOn = state

    if LightThread then
        LightThread = nil
    end

    if state then
        -- 🔆 Lumière allumée ➔ normal
        ClearTimecycleModifier()
        SetArtificialLightsState(false)
    else
        -- 🌙 Lumière éteinte ➔ ambiance tamisée spéciale intérieur
        SetTimecycleModifier("int_extlght_smokey")
        SetTimecycleModifierStrength(0.5)
        SetArtificialLightsState(true)
    end
end






RegisterNetEvent("Pipou-Immo:giveKey", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestPlayer, closestDistance = -1, 999.0

    for _, player in pairs(GetActivePlayers()) do
        local target = GetPlayerPed(player)
        if target ~= playerPed then
            local dist = #(coords - GetEntityCoords(target))
            if dist < closestDistance and dist <= 3.0 then
                closestPlayer = player
                closestDistance = dist
            end
        end
    end

    if closestPlayer ~= -1 then
        local targetPed = GetPlayerPed(closestPlayer)
        local targetId = GetPlayerServerId(closestPlayer)

        exports['PipouUI']:Notify("Appuyez sur ~g~E~s~ pour donner la clef à " .. GetPlayerName(closestPlayer), "info")

        -- Affichage 3D du texte
        CreateThread(function()
            local given = false
            while not given do
                Wait(0)
                local coords = GetEntityCoords(targetPed)
                DrawText3D(coords.x, coords.y, coords.z + 1.0, "~g~[E]~s~ Donner la clef")

                if IsControlJustReleased(0, 38) then -- Touche E
                    given = true
                    TriggerServerEvent("PipouImmo:server:giveKeyTo", targetId)
                    exports['PipouUI']:Notify("🔑 Clef donnée à " .. GetPlayerName(closestPlayer), "success")
                end
            end
        end)
    else
        exports['PipouUI']:Notify(" Aucun joueur proche pour donner une clef.", "error")
    end
end)


function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local dist = #(vector3(x, y, z) - p)
    local scale = (1 / dist) * 2
    scale = scale * (1 / GetGameplayCamFov()) * 100

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


function getCurrentPlayerProperty()
    return currentPropertyName
end


RegisterNetEvent("Pipou-Immo:confirmRemoveTenant", function(data)

    exports['PipouUI']:OpenSimpleMenu(" Retirer " .. data.name .. " ?", "", {
        { label = " Oui, retirer", action = function()
            TriggerEvent("Pipou-Immo:removeTenantConfirmed", data)
            return false
        end },
        { label = "🔙 Annuler", action = function()
            TriggerEvent("Pipou-Immo:showTenantList")
            return false
        end }
    })
end)

RegisterNetEvent("Pipou-Immo:removeTenantConfirmed", function(data)
    TriggerServerEvent("PipouImmo:server:removeTenantByCitizenId", data.propertyName, data.citizenid)
    Wait(500)
    TriggerEvent("Pipou-Immo:showTenantList") -- Rafraîchit la liste
end)

local playerOwnedProperties = {}

RegisterNetEvent("PipouImmo:client:setPlayerProperties", function(properties)
    playerOwnedProperties = properties or {}

    TriggerEvent("PipouImmo:client:SendPropertiesToGarage", playerOwnedProperties)
    CreatePropertyBlips()
end)


RegisterNetEvent("PipouImmo:refreshProperties", function()
    TriggerServerEvent("PipouImmo:server:getPlayerProperties")
end)



function CreatePropertyBlips()
    -- On nettoie les anciens blips si existants
    if propertyBlips then
        for _, blip in pairs(propertyBlips) do
            RemoveBlip(blip)
        end
    end
    propertyBlips = {}

    -- Parcourt les propriétés que possède ou loue le joueur
    for _, propertyName in ipairs(playerOwnedProperties) do
        local propertyData = cachedProperties[propertyName]
        if propertyData and propertyData.coords then
            local blip = AddBlipForCoord(propertyData.coords.x, propertyData.coords.y, propertyData.coords.z)
            SetBlipSprite(blip, 40) -- Icône maison
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 0)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("🏠 Maison : " .. propertyName)
            EndTextCommandSetBlipName(blip)

            table.insert(propertyBlips, blip)
        end
    end
end


RegisterNUICallback("getAllProperties", function(_, cb)
    QBCore.Functions.TriggerCallback("PipouImmo:server:getAllPropertiesWithID", function(props)
        cb(props)
    end)
end)

RegisterNUICallback("deleteProperty", function(data, cb)
    if not data.id then
        print("[PipouImmo]  ID manquant dans deleteProperty")
        return cb({ success = false, message = "ID manquant." })
    end

    TriggerServerEvent("PipouImmo:server:deleteProperty", data.id)
    cb({ success = true })
end)


RegisterNUICallback("assignPropertyToPlayerId", function(data, cb)
    if not data.id or not data.target then
        exports['PipouUI']:Notify(" Données manquantes.", "error")
        return cb({ success = false, message = "ID ou cible manquant." })
    end

    TriggerServerEvent("PipouImmo:server:assignPropertyToPlayerId", data.id, data.target)
    cb({ success = true })
end)

RegisterNetEvent("PipouImmo:client:notifyPropertyDeleted", function(success)
    if success then
        exports['PipouUI']:Notify(" Propriété supprimée avec succès.", "success")
    else
        exports['PipouUI']:Notify(" Échec lors de la suppression.", "error")
    end
end)



RegisterNetEvent('PipouImmo:openFurnitureList', function()
    QBCore.Functions.TriggerCallback('PipouImmo:getPlayerFurnitureInventory', function(furnitureList)
        if not furnitureList or #furnitureList == 0 then
            exports['PipouUI']:Notify(" Vous n'avez aucun meuble.", "error")
            return
        end

        local buttonList = {}

        for _, item in ipairs(furnitureList) do
            table.insert(buttonList, {
                label = item.label .. " (x" .. item.quantity .. ")",
                action = function()
                    TriggerEvent('PipouImmo:startPlacingFurniture', item)
                end
            })
        end

        exports['PipouUI']:OpenSimpleMenu("🪑 Meubles disponibles", "Sélectionnez un meuble à placer", buttonList)
    end)
end)



-- 📦 Placement de mobilier avec modes Déplacement / Rotation
local ShowModeOverlay = false
local ShowPlacementUI = true
local uiOffsetY = 0.925

RegisterNetEvent("PipouImmo:startPlacingFurniture", function(item)
    local model = GetHashKey(item.object)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    -- Position de base pour spawn l'objet devant le joueur
    local spawnX, spawnY, spawnZ = coords.x, coords.y, coords.z - 1.0
    local obj = CreateObject(model, spawnX, spawnY, spawnZ, true, true, true)

    StartFurniturePlacement(obj, item, true, function(pos, rot)
        exports['PipouUI']:Notify(" Meuble placé !", "success")
        TriggerServerEvent("PipouImmo:saveObjectPlacement", {
            object = item.object,
            coords = pos,
            rotation = rot,
            property = getCurrentPlayerProperty()
        })
    end)
end)


RegisterNetEvent("PipouImmo:startPlacingExistingFurniture", function(obj, item)
    if not item.id then
        exports['PipouUI']:Notify(" Impossible de modifier ce meuble (ID manquant)", "error")
        return
    end

    StartFurniturePlacement(obj, item, false, function(pos, rot)
        exports['PipouUI']:Notify(" Position mise à jour", "success")
        TriggerServerEvent("PipouImmo:updateFurniturePlacement", {
            id = item.id,
            coords = pos,
            rotation = rot
        })
        
    end)
end)




-- Les fonctions auxiliaires (pas modifiées) :
function DrawInstructionUI(modeRotation, currentAxis)
    if not ShowPlacementUI then return end -- si masqué

    local bgColor = modeRotation and {255, 120, 0} or {0, 120, 255}
    DrawRect(0.5, uiOffsetY, 0.65, 0.11, bgColor[1], bgColor[2], bgColor[3], 180)

    if ShowModeOverlay then
        DrawRect(0.5, uiOffsetY, 0.65, 0.11, 255, 255, 255, 80)
    end

    local lines = {
        "Mode : " .. (modeRotation and "Rotation" or "Déplacement") .. " | Axe : " .. currentAxis:upper() .. " (F pour changer)",
        "ZQSD ou Flèches : " .. (modeRotation and "Tourner l'objet" or "Déplacer l'objet") .. " | PgUp/PgDn : Monter/Descendre",
        "R : Mode | F : Axe | Entrée : Valider | Retour : Annuler | H : Masquer"
    }

    for i = 1, #lines do
        SetTextFont(4)
        SetTextScale(0.38, 0.38)
        SetTextWrap(0.0, 1.0)
        SetTextCentre(true)
        SetTextColour(255, 255, 255, 230)
        SetTextOutline()
        SetTextEntry("STRING")
        AddTextComponentString(lines[i])
        DrawText(0.5, uiOffsetY - 0.035 + ((i - 1) * 0.026))
    end
end



function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

function DrawXYZGizmo(base)
    local size = 0.5
    DrawLine(base.x, base.y, base.z, base.x + size, base.y, base.z, 255, 0, 0, 255)   -- X : rouge
    DrawLine(base.x, base.y, base.z, base.x, base.y + size, base.z, 0, 255, 0, 255)   -- Y : vert
    DrawLine(base.x, base.y, base.z, base.x, base.y, base.z + size, 0, 0, 255, 255)   -- Z : bleu
end









RegisterNetEvent("PipouImmo:openFurnitureUI", function()
    QBCore.Functions.TriggerCallback("PipouImmo:getPlayerFurnitureInventory", function(furnitures)
        SetNuiFocus(true, true)
        SendNUIMessage({
            type = "showFurnitureMenu",
            furnitureList = furnitures
        })
    end)
end)

RegisterNUICallback("placeFurniture", function(data, cb)
    SetNuiFocus(false, false)

    -- Sécurité : Vérifie que l'objet est valide
    if not data.object then
        exports['PipouUI']:Notify(" Objet invalide.", "error")
        cb("error")
        return
    end

    -- Démarre le placement
    TriggerEvent("PipouImmo:startPlacingFurniture", {
        object = data.object,
        label = data.label or data.object,
        quantity = data.quantity or 1
    })

    cb("ok")
end)




RegisterNUICallback("previsualisatinFurniture", function(data, cb)

    -- Sécurité : Vérifie que l'objet est valide
    if not data.object then
        exports['PipouUI']:Notify(" Objet invalide.", "error")
        cb("error")
        return
    end

    -- Démarre le placement
    TriggerEvent("PipouImmo:startPrevisualisateFurniture", {
        object = data.object,
        label = data.label or data.object,
        quantity = data.quantity or 1
    })

    cb("ok")
end)


RegisterNUICallback("closeFurnitureUI", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)


function GetFurnitureConfig(cb)
    local FurnitureList = Config.Furniture
    if cb then
        cb(FurnitureList)
    end
end
exports("GetFurnitureConfig", GetFurnitureConfig)

function OpenSellFurnitureList()
    local furnitureByCategory = {}

    for categoryName, category in pairs(Config.Furniture) do
        furnitureByCategory[categoryName] = {
            label = category.label or categoryName,
            items = {}
        }

        for _, item in ipairs(category.items) do
            item.quantity = 1
            table.insert(furnitureByCategory[categoryName].items, item)
        end
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "showFurnitureSellMenu",
        furnitureCategories = furnitureByCategory
    })
end


exports("OpenSellFurnitureList", OpenSellFurnitureList)

RegisterCommand("sellfurniture", function()
    OpenSellFurnitureList()
end, false)





RegisterNetEvent("PipouImmo:startPrevisualisateFurniture", function(item)
    if previewProp and DoesEntityExist(previewProp) then
        DeleteEntity(previewProp)
        previewProp = nil
    end

    if previewRotationThread then
        previewRotationThread = nil
    end

    local model = GetHashKey(item.object)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local distanceForward = 1.8
    local distanceRight = 2.5

    local offsetX = -distanceForward * math.sin(math.rad(heading)) + distanceRight * math.cos(math.rad(heading))
    local offsetY = distanceForward * math.cos(math.rad(heading)) + distanceRight * math.sin(math.rad(heading))




    local spawnX = coords.x + offsetX
    local spawnY = coords.y + offsetY
    local spawnZ = coords.z - 1.0

    previewProp = CreateObject(model, spawnX, spawnY, spawnZ, false, true, false)
    SetEntityAlpha(previewProp, 250, false)
    FreezeEntityPosition(previewProp, true)
    PlaceObjectOnGroundProperly(previewProp)

    -- ➿ Rotation continue
    previewRotationThread = CreateThread(function()
        local angle = 0.0
        while previewProp and DoesEntityExist(previewProp) do
            angle = angle + 0.3
            if angle >= 360.0 then angle = 0.0 end
            SetEntityHeading(previewProp, angle)
            Wait(10)
        end
    end)
end)



RegisterNUICallback("clearPreview", function()
    if previewProp and DoesEntityExist(previewProp) then
        DeleteEntity(previewProp)
        previewProp = nil
    end
    if previewRotationThread then
        previewRotationThread = nil
    end
end)

function CleanInstance()
    for _, obj in ipairs(spawnedFurniture) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
    spawnedFurniture = {}

    if spawnedShell and DoesEntityExist(spawnedShell) then
        DeleteEntity(spawnedShell)
        spawnedShell = nil
    end

    if previewProp and DoesEntityExist(previewProp) then
        DeleteEntity(previewProp)
        previewProp = nil
    end

    previewRotationThread = nil

    IsInInstance = false
    currentPropertyName = nil

    CleanZones()
end

function AddZone(name, ...)
    exports['qb-target']:AddBoxZone(name, ...)
    activeZones[name] = true
end

function CleanZones()
    for name in pairs(activeZones) do
        exports['qb-target']:RemoveZone(name)
    end
    activeZones = {}
end


function StartFurniturePlacement(entity, itemData, isNew, onConfirm, onCancel)
    if not DoesEntityExist(entity) then
        exports['PipouUI']:Notify(" Entité non trouvée", "error")
        return
    end

    local originalPos = nil
    local originalRot = nil

    if not isNew then
        originalPos = GetEntityCoords(entity)
        originalRot = GetEntityRotation(entity, 2)
    end


    local pos = GetEntityCoords(entity)
    local rot = GetEntityRotation(entity, 2)
    local modeRotation, currentAxis = false, "yaw"
    local moveSpeed, rotSpeed = 0.03, 0.5

    FreezeEntityPosition(entity, false)
    SetEntityAlpha(entity, 180, false)
    PlaceObjectOnGroundProperly(entity)

    local placing = true
    exports['PipouUI']:Notify("🎮 " .. (isNew and "Placement" or "Modification") .. " de meuble... [Entrée] pour valider | [Retour] pour annuler", "info")

    CreateThread(function()
        while placing do
            Wait(0)

            -- 🔒 Block controls
            for i = 1, 360 do
                if not (
                    i == 191 or i == 202 or
                    i == 172 or i == 173 or i == 174 or i == 175 or
                    i == 10 or i == 11 or
                    i == 45 or i == 23 or
                    i == 1 or i == 2 or i == 237 or i == 329 or i == 330
                ) then
                    DisableControlAction(0, i, true)
                end
            end

            -- 🎮 Mode toggle
            if IsControlJustPressed(0, 45) then
                modeRotation = not modeRotation
                exports['PipouUI']:Notify(modeRotation and "🎮 Mode rotation" or "🚶 Mode déplacement", "info")
            end

            -- 🔁 Axis change
            if IsControlJustPressed(0, 23) then
                currentAxis = currentAxis == "yaw" and "pitch" or currentAxis == "pitch" and "roll" or "yaw"
                exports['PipouUI']:Notify("🌀 Axe : " .. currentAxis, "info")
            end

            -- ✨ Movement / Rotation logic
            if modeRotation then
                if currentAxis == "yaw" then
                    if IsControlPressed(0, 174) then rot = vector3(rot.x, rot.y, rot.z - rotSpeed) end
                    if IsControlPressed(0, 175) then rot = vector3(rot.x, rot.y, rot.z + rotSpeed) end
                elseif currentAxis == "pitch" then
                    if IsControlPressed(0, 172) then rot = vector3(rot.x + rotSpeed, rot.y, rot.z) end
                    if IsControlPressed(0, 173) then rot = vector3(rot.x - rotSpeed, rot.y, rot.z) end
                elseif currentAxis == "roll" then
                    if IsControlPressed(0, 174) then rot = vector3(rot.x, rot.y + rotSpeed, rot.z) end
                    if IsControlPressed(0, 175) then rot = vector3(rot.x, rot.y - rotSpeed, rot.z) end
                end
            else
                if IsControlPressed(0, 172) then pos = pos + vector3(0.0, moveSpeed, 0.0) end
                if IsControlPressed(0, 173) then pos = pos - vector3(0.0, moveSpeed, 0.0) end
                if IsControlPressed(0, 174) then pos = pos - vector3(moveSpeed, 0.0, 0.0) end
                if IsControlPressed(0, 175) then pos = pos + vector3(moveSpeed, 0.0, 0.0) end
            end

            if IsControlPressed(0, 10) then pos = pos + vector3(0.0, 0.0, moveSpeed) end
            if IsControlPressed(0, 11) then pos = pos - vector3(0.0, 0.0, moveSpeed) end

            SetEntityCoordsNoOffset(entity, pos.x, pos.y, pos.z, true, true, true)
            SetEntityRotation(entity, rot.x, rot.y, rot.z, 2, true)

            DrawInstructionUI(modeRotation, currentAxis)
            DrawText3D(pos.x, pos.y, pos.z + 1.4, "Mode : " .. (modeRotation and "Rotation" or "Déplacement") .. " | Axe : " .. currentAxis:upper())

            --  Confirm
            if IsControlJustReleased(0, 191) then
                SetEntityAlpha(entity, 255, false)
                FreezeEntityPosition(entity, true)
                placing = false
                table.insert(spawnedFurniture, entity) -- AJOUTE CECI
                onConfirm(pos, rot)
            end

            --  Cancel
            if IsControlJustReleased(0, 202) then
                exports['PipouUI']:Notify(" Annulé", "error")
                placing = false

                if isNew then
                    DeleteEntity(entity)
                else
                    -- Repositionne l'objet à son emplacement d'origine
                    SetEntityCoordsNoOffset(entity, originalPos.x, originalPos.y, originalPos.z, true, true, true)
                    SetEntityRotation(entity, originalRot.x, originalRot.y, originalRot.z, 2, true)
                    FreezeEntityPosition(entity, true)
                    SetEntityAlpha(entity, 255, false)
                end

                if onCancel then onCancel() end
            end

        end
    end)
end




RegisterNetEvent("PipouImmo:client:loadFurnitureForAll", function(propertyName, furnitureList)
    if getCurrentPlayerProperty() ~= propertyName then return end


    for _, obj in ipairs(spawnedFurniture) do
        if DoesEntityExist(obj) then
            DeleteEntity(obj)
        end
    end
    spawnedFurniture = {}
    

    for _, item in pairs(furnitureList) do
        local model = GetHashKey(item.object_model)
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end

        local obj = CreateObject(model, item.x, item.y, item.z, true, true, true)
        while not DoesEntityExist(obj) do Wait(0) end

        SetEntityAsMissionEntity(obj, true, true)
        SetEntityCollision(obj, true, true)
        SetEntityDynamic(obj, true)
        SetEntityRotation(obj, item.pitch or 0.0, item.roll or 0.0, item.heading or 0.0, 2, false)
        FreezeEntityPosition(obj, true)

        table.insert(spawnedFurniture, obj)

        exports['qb-target']:AddTargetEntity(obj, {
            options = {
                {
                    label = "🛠️ Déplacer le meuble",
                    icon = "fas fa-arrows-alt",
                    action = function()
                        TriggerEvent("PipouImmo:startPlacingExistingFurniture", obj, item)
                    end
                },
                {
                    label = " Supprimer le meuble",
                    icon = "fas fa-trash",
                    action = function()
                        TriggerServerEvent("PipouImmo:server:removeFurniture", item.id)
                    end
                }
            },
            distance = 2.5
        })
    end
end)

RegisterNUICallback("PipouImmo:buyFurniture", function(data, cb)
    local object = data.furnitureName
    local label = data.label or object
    local price = tonumber(data.price)

    QBCore.Functions.TriggerCallback("PipouImmo:server:buyFurniture", function(success, message)
        if success then
            exports['PipouUI']:Notify(message or " Meuble acheté !", "success")
            cb({ success = true })
        else
            exports['PipouUI']:Notify(message or " Achat échoué.", "error")
            cb({ success = false, message = message })
        end
    end, object, price, label)
end)


RegisterNUICallback("notify", function(data, cb)
    exports['PipouUI']:Notify(data.message or "Notification", data.type or "info")
    cb("ok")
end)

RegisterNetEvent("PipouImmo:togglePublicAccess", function()
    local propertyName = getCurrentPlayerProperty()
    if propertyName then
        TriggerServerEvent("PipouImmo:server:togglePublicAccess", propertyName)

        -- 🔁 Rafraîchir le menu après petit délai
        Wait(500)
        TriggerEvent("Pipou-Immo:openMainMenu")
    end
end)

RegisterNetEvent("PipouImmo:client:publicAccessChanged", function(propertyName, newState)
    if getCurrentPlayerProperty() == propertyName then
        local isPublic = newState == 1

        -- Notifie le joueur
        exports['PipouUI']:Notify(isPublic and "🏡 La maison est maintenant OUVERTE à tous." or "🏡 La maison est maintenant FERMÉE.", "info")

        -- Recharge le menu principal
        TriggerEvent("Pipou-Immo:openMainMenu")
    end
end)
