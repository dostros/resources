local QBCore = exports['qb-core']:GetCoreObject()

local spawnedShell = nil

RegisterCommand("spawnappart", function(source, args)
    local typeappart = args[1] -- Exemple : "shell_apartment"

    if not typeappart then
        print("❌ Utilisation : /spawnappart nom_du_shell")
        return
    end

    local model = GetHashKey(typeappart)
    local coords = GetEntityCoords(PlayerPedId()) + vector3(0, 5, 0)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local spawnedShell = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(spawnedShell, 0.0)
    FreezeEntityPosition(spawnedShell, true)

    -- TP le joueur à l’intérieur du shell
    local shellOffset = vector3(0.0, 0.0, 1.0) -- ajuste si besoin
    SetEntityCoords(PlayerPedId(), coords + shellOffset)

    print("✅ Shell spawné :", typeappart)
end)



RegisterCommand("removeappart", function()
    if spawnedShell then
        DeleteEntity(spawnedShell)
        spawnedShell = nil
    end
end)

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

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
end)

RegisterNUICallback("showProperties", function(_, cb)
    QBCore.Functions.Notify("Affichage des propriétés à venir...")
    cb("ok")
end)

RegisterNUICallback("sellProperty", function(_, cb)
    QBCore.Functions.Notify("Vente de propriété à venir...")
    cb("ok")
end)

RegisterNUICallback("rentProperty", function(_, cb)
    QBCore.Functions.Notify("Location de propriété à venir...")
    cb("ok")
end)


RegisterNUICallback("Pipou-Immo-setPropertyCoords", function(data, cb)
    print(data.propertyId)

    CreateThread(function()
        local waiting = true
        while waiting do
            Wait(0)
            SetTextComponentFormat("STRING")
            AddTextComponentString("Appuyez sur ~g~E~s~ pour placer le point")
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustReleased(0, 38) then 
                local playerCoords = GetEntityCoords(PlayerPedId())

                -- Jouer un son
                PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)

                -- Afficher une notification avec les coordonnées
                QBCore.Functions.Notify("Point placé aux coordonnées : " .. playerCoords.x .. ", " .. playerCoords.y .. ", " .. playerCoords.z)

                waiting = false
                SetDisplay(not display)
                -- Envoi des coordonnées au serveur
                SendNUIMessage ({
                    type = "setPropertyCoords",
                    propertyId = data.propertyId,
                    coords = {
                        x = playerCoords.x,
                        y = playerCoords.y,
                        z = playerCoords.z
                    }
                })
            end
        end
    end)
end)



RegisterNUICallback('Pipou-Immo-createProperty', function(data, cb)
    local propertyName = data.propertyName
    local propertyType = data.typeinterior
    local level = data.level or 0
    local Housecoords = data.coords1
    local Garagecoords = data.coords2
    local GarageOut = data.coords3

    -- ✅ Vérification des données
    if not propertyName or not propertyType or not Housecoords or not Housecoords.x then
        print("❌ Données manquantes ou invalides")
        cb({ success = false, msg = "Données manquantes." })
        return
    end

    -- 🎄 Crée les arbres de Noël à titre décoratif
    createHousePoint(Housecoords)
    createGaragePoint(Garagecoords)
    createOutGarage(GarageOut)

    -- 🏠 Spawn du shell d’intérieur à la porte d’entrée
    local model = GetHashKey(propertyType)

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(10)
    end

    local spawnedShell = CreateObject(model, Housecoords.x, Housecoords.y, Housecoords.z-5-5*level, false, false, false)
    SetEntityHeading(spawnedShell, 0.0)
    FreezeEntityPosition(spawnedShell, true)

    -- ✅ Notification + fermeture de l'interface
    QBCore.Functions.Notify("Propriété créée avec succès !", "success")

    SetDisplay(false)

    -- Optionnel : retour vers le NUI si tu veux
    cb({ success = true })
end)


function createHousePoint (coords)
    exports['qb-target']:AddBoxZone("housePoint", vector3(coords.x, coords.y, coords.z), 1.0, 1.0, {
        name = "housePoint",
        heading = 0,
        debugPoly = false,
        minZ = coords.z - 1.0,
        maxZ = coords.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "Pipou-Immo:enterHouse",
                icon = "fas fa-home",
                label = "Entrer dans la maison",
            },
        },
        distance = 2.0
    })
end


function createGaragePoint (coords)
    exports['qb-target']:AddBoxZone("GaragePoint", vector3(coords.x, coords.y, coords.z), 1.0, 1.0, {
        name = "GaragePoint",
        heading = 0,
        debugPoly = false,
        minZ = coords.z - 1.0,
        maxZ = coords.z + 1.0,
    }, {
        options = {
            {
                type = "client",
                event = "Pipou-Immo:enterHouse",
                icon = "fas fa-home",
                label = "Garage",
            },
        },
        distance = 2.0
    })
end


function createOutGarage(coords)
    
    CreateThread(function()
        while true do
            Wait(0)
            DrawMarker(36, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0, 255, 0, 100, false, true, 2, nil, nil, false)

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - vector3(coords.x, coords.y, coords.z))

            if distance < 2.0 then
                -- Afficher un message d'aide
                SetTextComponentFormat("STRING")
                AddTextComponentString("Appuyez sur ~g~E~s~ pour sortir un véhicule")
                DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                -- Vérifier si le joueur appuie sur E
                if IsControlJustReleased(0, 38) then
                    -- Logique pour sortir un véhicule
                    local vehicleModel = GetHashKey("adder") -- Exemple : voiture "Adder"
                    RequestModel(vehicleModel)
                    while not HasModelLoaded(vehicleModel) do
                        Wait(10)
                    end

                    local vehicle = CreateVehicle(vehicleModel, coords.x, coords.y, coords.z, 0.0, true, false)
                    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    SetModelAsNoLongerNeeded(vehicleModel)

                    -- Jouer un son
                    PlaySoundFrontend(-1, "SELECT", "HUD_LIQUOR_STORE_SOUNDSET", true)

                    -- Notification
                    QBCore.Functions.Notify("Véhicule sorti avec succès !", "success")
                end
            end
        end
    end)


end