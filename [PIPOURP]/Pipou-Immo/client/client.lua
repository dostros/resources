local QBCore = exports['qb-core']:GetCoreObject()
local spawnedShell = nil
local createdZones = {}
local cachedProperties = {}
local IsInInstance = false
local currentPropertyName = nil
local isLightOn = true

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
                QBCore.Functions.Notify("🚨 Intérieur inconnu, déplacement vers un lieu sûr...", "error")
                SetEntityCoords(ped, 200.0, -1000.0, 30.0) -- fallback safe zone
                return
            end

            QBCore.Functions.Notify("⛔ Vous avez été replacé dans votre intérieur", "primary")

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
            local exitZoneCenter = shellCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz)

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
        QBCore.Functions.Notify("❌ Données invalides ou incomplètes", "error")
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
            QBCore.Functions.Notify("✅ Propriété enregistrée avec succès !", "success")
            SetDisplay(false)
            cb({ success = true })
        else
            QBCore.Functions.Notify("❌ Erreur lors de la sauvegarde", "error")
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
                QBCore.Functions.Notify("📍 Point placé : " .. playerCoords.x .. ", " .. playerCoords.y)

                SetNuiFocus(true, true)
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
        QBCore.Functions.Notify("Utilisation : /givehouse [id] [propertyName]", "error")
        return
    end

    QBCore.Functions.TriggerCallback("PipouImmo:server:assignProperty", function(success, message)
        if success then
            QBCore.Functions.Notify(message, "success")
            TriggerServerEvent("PipouImmo:server:getPlayerProperties")
        else
            QBCore.Functions.Notify(message, "error")
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
            local exitZoneCenter = shellCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz)
            createShellExitPoint(exitZoneCenter, houseCoords)


        elseif hasAccess then
            QBCore.Functions.Notify("🔒 Vous êtes locataire : l'accès est restreint.", "error")
        else
            QBCore.Functions.Notify("🚫 Vous n'avez pas de droit d'accès à cette propriété.", "error")
        end
    end, propertyName)
end)

-- 🚪 Sortie de la maison
function createShellExitPoint(instanceCoords, returnCoords)
    local exitName = "exit_shell_" .. math.random(1000, 9999)

    exports['qb-target']:AddBoxZone(exitName, instanceCoords, 1.0, 1.0, {
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
                zoneName = exitName -- pour pouvoir supprimer après
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

    -- Supprimer le shell
    if spawnedShell then
        DeleteEntity(spawnedShell)
        spawnedShell = nil
    end

    -- Supprimer la zone de sortie
    if data.zoneName then
        exports['qb-target']:RemoveZone(data.zoneName)
    end

    IsInInstance = false
    currentPropertyName = nil

end)



-- 🧹 Nettoyage du shell
RegisterCommand("removeappart", function()
    if spawnedShell then
        DeleteEntity(spawnedShell)
        spawnedShell = nil
    end
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

    QBCore.Functions.Notify("Shell spawned: " .. shellName, "success")
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
                QBCore.Functions.Notify("📦 Propriété reçue : " .. propertyName, "success")
            else
                QBCore.Functions.Notify("❌ Erreur : impossible d’ajouter la propriété", "error")
            end
        end)
    else
        createHousePoint(propertyName, prop.coords)
        QBCore.Functions.Notify("📦 Propriété reçue : " .. propertyName, "success")
    end
end)




CreateThread(function()
    while true do
        Wait(0)

        if IsInInstance and IsControlJustReleased(0, 38) then -- touche E
            local menuData = {
                {
                    header = "Gestion immobilière",
                    isMenuHeader = true,
                },
                {
                    header = isLightOn and "Éteindre la lumière" or "Allumer la lumière",
                    txt = "Contrôle de la luminosité",
                    params = {
                        event = "Pipou-Immo:toggleLight",
                        args = { number = 1 }
                    }
                },
                {
                    header = "Clefs de la maison",
                    txt = "Gérer les clefs de la maison",
                    params = {
                        event = "Pipou-Immo:openKeyMenu",
                        args = { number = 2 }
                    }
                },
                {
                    header = "Décorer la maison",
                    txt = "Accéder au menu de décoration",
                    params = {
                        event = "Pipou-Immo:openDecorationMenu",
                        args = { number = 3 }
                    }
                },
                {
                    header = "Fermer le menu",
                    txt = "Retourner au jeu",
                    params = {
                        event = "qb-menu:closeMenu"
                    }
                }
            }

            exports['qb-menu']:openMenu(menuData)
        end
    end
end)

RegisterNetEvent("Pipou-Immo:openKeyMenu", function()
    local keyMenu = {
        {
            header = "🔑 Gestion des clefs",
            isMenuHeader = true,
        },
        {
            header = "👥 Voir les colocataires",
            txt = "Voir la liste des personnes ayant accès",
            params = {
                event = "Pipou-Immo:showTenantList"
            }
        },
        
        {
            header = "Ajouter un locataire",
            txt = "Donner accès en tant que locataire",
            params = {
                event = "Pipou-Immo:addTenant"
            }
        },
        {
            header = "Retirer un colocataire",
            txt = "Supprimer l'accès d’un joueur proche",
            params = {
                event = "Pipou-Immo:removeTenant"
            }
        },        
        {
            header = "Retour",
            txt = "Retour au menu principal",
            params = {
                event = "Pipou-Immo:reopenMainMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(keyMenu)
end)

RegisterNetEvent("Pipou-Immo:openDecorationMenu", function()
    local DecorationMenu = {
        {
            header = "🛋️ Mode décoration",
            isMenuHeader = true
        },
        {
            header = "📦 Placer un objet",
            txt = "Choisir un meuble à placer",
            params = {
                event = "PipouImmo:openFurnitureUI"
            }
        },
        {
            header = "❌ Fermer",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(DecorationMenu)
end)





RegisterNetEvent('Pipou-Immo:toggleLight', function()
    SetShellLightState(not isLightOn)

    QBCore.Functions.Notify(isLightOn and "💡 Lumière allumée" or "💡 Lumière éteinte", "primary")
end)


function SetShellLightState(state)
    if spawnedShell and DoesEntityExist(spawnedShell) then
        -- Activation de la lumière artificielle autour du shell
        -- Cela simule un éclairage ON/OFF
        if state then
            SetArtificialLightsState(false)
        else
            SetArtificialLightsState(true)
        end

        isLightOn = state
    end
end


RegisterNetEvent("Pipou-Immo:reopenMainMenu", function()
    TriggerEvent("Pipou-Immo:openMainMenu")
end)

RegisterNetEvent("Pipou-Immo:openMainMenu", function()
    -- Remets ici le même contenu que dans le menu principal
    local menuData = {
        {
            header = "Gestion immobilière",
            isMenuHeader = true,
        },
        {
            header = isLightOn and "Éteindre la lumière" or "Allumer la lumière",
            txt = "Contrôle de la luminosité",
            params = {
                event = "Pipou-Immo:toggleLight"
            }
        },
        {
            header = "Clefs de la maison",
            txt = "Gérer les clefs de la maison",
            params = {
                event = "Pipou-Immo:openKeyMenu"
            }
        },
        {
            header = "Décorer la maison",
            txt = "Accéder au menu de décoration",
            params = {
                event = "Pipou-Immo:decorateMenu"
            }
        },
        {
            header = "Fermer le menu",
            txt = "Retourner au jeu",
            params = {
                event = "qb-menu:closeMenu"
            }
        }
    }

    exports['qb-menu']:openMenu(menuData)
end)


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

        QBCore.Functions.Notify("Appuyez sur ~g~E~s~ pour donner la clef à " .. GetPlayerName(closestPlayer), "primary")

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
                    QBCore.Functions.Notify("🔑 Clef donnée à " .. GetPlayerName(closestPlayer), "success")
                end
            end
        end)
    else
        QBCore.Functions.Notify("❌ Aucun joueur proche pour donner une clef.", "error")
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

RegisterNetEvent("Pipou-Immo:addTenant", function()
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
        local targetId = GetPlayerServerId(closestPlayer)
        local propName = getCurrentPlayerProperty() -- à toi de définir la logique

        if propName then
            QBCore.Functions.TriggerCallback('PipouImmo:server:addTenant', function(success, msg)
                QBCore.Functions.Notify(msg, success and "success" or "error")
                TriggerNetEvent("PipouImmo:refreshProperties")
            end, targetId, propName)
        else
            QBCore.Functions.Notify("❌ Propriété inconnue.", "error")
        end
    else
        QBCore.Functions.Notify("❌ Aucun joueur proche.", "error")
    end
end)

RegisterNetEvent("Pipou-Immo:removeTenant", function()
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
        local targetId = GetPlayerServerId(closestPlayer)
        local propName = getCurrentPlayerProperty() -- 🔧 À implémenter selon ton contexte

        if propName then
            QBCore.Functions.TriggerCallback('PipouImmo:server:removeTenant', function(success, msg)
                QBCore.Functions.Notify(msg, success and "success" or "error")
                TriggerNetEvent("PipouImmo:refreshProperties")
            end, targetId, propName)
        else
            QBCore.Functions.Notify("❌ Propriété inconnue.", "error")
        end
    else
        QBCore.Functions.Notify("❌ Aucun joueur proche.", "error")
    end
end)

function getCurrentPlayerProperty()
    return currentPropertyName
end

RegisterNetEvent("Pipou-Immo:showTenantList", function()
    local propertyName = getCurrentPlayerProperty()
    if not propertyName then
        QBCore.Functions.Notify("❌ Propriété inconnue.", "error")
        return
    end

    QBCore.Functions.TriggerCallback('PipouImmo:server:getTenants', function(tenants)
        if not tenants or #tenants == 0 then
            QBCore.Functions.Notify("Aucun colocataire trouvé.", "error")
            return
        end

        local menu = {
            {
                header = "👥 Liste des colocataires",
                isMenuHeader = true
            }
        }

        for _, tenant in pairs(tenants) do
            local headerText = tenant.name .. " (" .. tenant.access_type .. ")"
        
            if tenant.access_type == "owner" then
                table.insert(menu, {
                    header = headerText,
                    txt = "🔒 Propriétaire principal – accès protégé",
                    isMenuHeader = true
                })
            else
                table.insert(menu, {
                    header = headerText,
                    txt = "Cliquer pour retirer l’accès",
                    params = {
                        event = "Pipou-Immo:confirmRemoveTenant",
                        args = {
                            propertyName = propertyName,
                            citizenid = tenant.citizenid,
                            name = tenant.name
                        }
                    }
                })
            end
        end
        

        table.insert(menu, {
            header = "Retour",
            params = {
                event = "Pipou-Immo:openKeyMenu"
            }
        })

        exports['qb-menu']:openMenu(menu)
    end, propertyName)
end)

RegisterNetEvent("Pipou-Immo:confirmRemoveTenant", function(data)
    local confirmMenu = {
        {
            header = "❌ Retirer " .. data.name .. " ?",
            txt = "Cette action est irréversible.",
            isMenuHeader = true
        },
        {
            header = "✅ Oui, retirer",
            params = {
                event = "Pipou-Immo:removeTenantConfirmed",
                args = data
            }
        },
        {
            header = "🔙 Annuler",
            params = {
                event = "Pipou-Immo:showTenantList"
            }
        }
    }

    exports['qb-menu']:openMenu(confirmMenu)
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
        print("[PipouImmo] ❌ ID manquant dans deleteProperty")
        return cb({ success = false, message = "ID manquant." })
    end

    TriggerServerEvent("PipouImmo:server:deleteProperty", data.id)
    cb({ success = true })
end)


RegisterNUICallback("assignPropertyToPlayerId", function(data, cb)
    if not data.id or not data.target then
        QBCore.Functions.Notify("❌ Données manquantes.", "error")
        return cb({ success = false, message = "ID ou cible manquant." })
    end

    TriggerServerEvent("PipouImmo:server:assignPropertyToPlayerId", data.id, data.target)
    cb({ success = true })
end)

RegisterNetEvent("PipouImmo:client:notifyPropertyDeleted", function(success)
    if success then
        QBCore.Functions.Notify("✅ Propriété supprimée avec succès.", "success")
    else
        QBCore.Functions.Notify("❌ Échec lors de la suppression.", "error")
    end
end)



RegisterNetEvent('PipouImmo:openFurnitureList', function()
    QBCore.Functions.TriggerCallback('PipouImmo:getPlayerFurnitureInventory', function(furnitureList)
        if not furnitureList or #furnitureList == 0 then
            QBCore.Functions.Notify("❌ Vous n'avez aucun meuble.", "error")
            return
        end

        local menu = {
            { header = "🪑 Meubles disponibles", isMenuHeader = true }
        }

        for _, item in ipairs(furnitureList) do
            table.insert(menu, {
                header = item.label .. " (x" .. item.quantity .. ")",
                txt = "Modèle : " .. item.object,
                params = {
                    event = "PipouImmo:startPlacingFurniture",
                    args = item
                }
            })
        end

        table.insert(menu, {
            header = "❌ Fermer",
            params = { event = "qb-menu:closeMenu" }
        })

        exports['qb-menu']:openMenu(menu)
    end)
end)


RegisterNetEvent("PipouImmo:startPlacingFurniture", function(item)
    local model = GetHashKey(item.object)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(model, coords.x, coords.y, coords.z - 1.0, true, true, false)

    SetEntityAlpha(prop, 180, false)
    FreezeEntityPosition(prop, true)
    PlaceObjectOnGroundProperly(prop)

    local heading = GetEntityHeading(prop)
    local pos = coords

    QBCore.Functions.Notify("🛠️ Placement en cours... Appuie sur [Entrée] pour valider, [Retour] pour annuler", "primary")

    -- Utilitaire pour obtenir la droite du joueur
    local function GetRightVector(forwardVec)
        return vector3(-forwardVec.y, forwardVec.x, 0.0)
    end

    CreateThread(function()
        local placing = true
        local rot = vector3(0.0, 0.0, heading) -- yaw = heading
    
        while placing do
            Wait(0)
    
            -- 🔒 Bloque les actions gênantes
            DisableControlAction(0, 24, true)
            DisableControlAction(0, 25, true)
            DisableControlAction(0, 75, true)
            DisableControlAction(0, 23, true)
    
            local moveSpeed = 0.03
            local rotSpeed = 0.5
    
            -- 📦 Déplacement
            if IsControlPressed(0, 172) then pos = pos + vector3(0.0, moveSpeed, 0.0) end -- ↑
            if IsControlPressed(0, 173) then pos = pos - vector3(0.0, moveSpeed, 0.0) end -- ↓
            if IsControlPressed(0, 174) then pos = pos - vector3(moveSpeed, 0.0, 0.0) end -- ←
            if IsControlPressed(0, 175) then pos = pos + vector3(moveSpeed, 0.0, 0.0) end -- →
    
            -- ↕ Hauteur
            if IsControlPressed(0, 10) then pos = pos + vector3(0, 0, moveSpeed) end -- PgUp
            if IsControlPressed(0, 11) then pos = pos - vector3(0, 0, moveSpeed) end -- PgDn
    
            -- ↻ Yaw : SHIFT + ← / →
            if IsControlPressed(0, 21) then
                if IsControlPressed(0, 174) then rot.z = rot.z - rotSpeed end
                if IsControlPressed(0, 175) then rot.z = rot.z + rotSpeed end
            end
    
            -- ↻ Pitch / Roll : ALT + ← / → / ↑ / ↓
            if IsControlPressed(0, 19) then
                if IsControlPressed(0, 172) then rot.x = rot.x + rotSpeed end -- pitch +
                if IsControlPressed(0, 173) then rot.x = rot.x - rotSpeed end -- pitch -
                if IsControlPressed(0, 174) then rot.y = rot.y + rotSpeed end -- roll +
                if IsControlPressed(0, 175) then rot.y = rot.y - rotSpeed end -- roll -
            end
    
            -- Application
            SetEntityCoordsNoOffset(prop, pos.x, pos.y, pos.z, true, true, true)
            SetEntityRotation(prop, rot.x, rot.y, rot.z, 2, true)
    
            -- ✅ Valider
            if IsControlJustReleased(0, 191) then
                SetEntityAlpha(prop, 255, false)
                FreezeEntityPosition(prop, true)
                placing = false
    
                QBCore.Functions.Notify("✅ Meuble placé !", "success")
                TriggerServerEvent("PipouDeco:saveObjectPlacement", {
                    object = item.object,
                    coords = pos,
                    rotation = rot,
                    property = getCurrentPlayerProperty()
                })
            end
    
            -- ❌ Annuler
            if IsControlJustReleased(0, 202) then
                DeleteEntity(prop)
                QBCore.Functions.Notify("❌ Placement annulé", "error")
                placing = false
            end
    
            -- Aide + gizmo
            DrawText3D(pos.x, pos.y, pos.z + 1.2, "~b~↑↓←→~s~ déplacement · ~y~PgUp/PgDn~s~ hauteur · ~c~SHIFT+←/→~s~ tourner YAW · ~g~ALT+↑↓←→~s~ PITCH/ROLL")
            DrawXYZGizmo(pos)
        end
    end)
    
    
end)


function DrawPlacementHelp()
    SetTextFont(4)
    SetTextScale(0.4, 0.4)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName("↑↓←→ Déplacer | PgUp/PgDn Monter/Descendre | SHIFT+←→ Rotation Yaw | ALT+←→↑↓ Pitch & Roll | Entrée = OK | Retour = Annuler")
    EndTextCommandDisplayText(0.5, 0.02)
end


function DrawXYZGizmo(base)
    local size = 0.5
    -- X : rouge
    DrawLine(base.x, base.y, base.z, base.x + size, base.y, base.z, 255, 0, 0, 255)
    -- Y : vert
    DrawLine(base.x, base.y, base.z, base.x, base.y + size, base.z, 0, 255, 0, 255)
    -- Z : bleu
    DrawLine(base.x, base.y, base.z, base.x, base.y, base.z + size, 0, 0, 255, 255)
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
        QBCore.Functions.Notify("❌ Objet invalide.", "error")
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


RegisterNUICallback("closeFurnitureUI", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

