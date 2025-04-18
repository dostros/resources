local QBCore = exports['qb-core']:GetCoreObject()

-- Niveau minimum de preview
local BASE_LEVEL = 1
local usedLevels = {}
local playerLevel = nil

function GetInstanceZ(level)
    return -250.0 - (level * 10)
end

function GetPreviewCoords(level)
    return vector3(-707.24, 272.57, GetInstanceZ(level))
end

function FindAvailablePreviewLevel()
    for i = BASE_LEVEL, BASE_LEVEL + 100 do
        if not usedLevels[i] then
            usedLevels[i] = true
            return i
        end
    end
    return BASE_LEVEL
end

function ReleasePreviewLevel(level)
    usedLevels[level] = nil
end

local previewShell = nil
local isPreviewing = false
local previewPlayers = 0
local exitZone = nil

-- Point d'accès au catalogue
CreateThread(function()
    local coords = vector3(-707.24, 272.57, 83.15)
    exports['qb-target']:AddBoxZone("catalogueInterieurs", coords, 1.5, 1.5, {
        name = "catalogueInterieurs",
        heading = 0,
        debugPoly = false,
        minZ = coords.z - 1.0,
        maxZ = coords.z + 1.0
    }, {
        options = {
            {
                type = "client",
                event = "Pipou-Immo:openInteriorCatalogue",
                icon = "",
                label = "📖 Voir le catalogue d’intérieurs"
            }
        },
        distance = 2.5
    })
end)

-- Menu catalogue
RegisterNetEvent("Pipou-Immo:openInteriorCatalogue", function()
    local menu = {
        {
            header = "🏠 Catalogue des Intérieurs",
            isMenuHeader = true
        }
    }

    for key, interior in pairs(Config.InteriorTypes) do
        table.insert(menu, {
            header = interior.label,
            txt = "Type: " .. key,
            params = {
                event = "Pipou-Immo:previewInterior",
                args = { shell = key }
            }
        })
    end

    table.insert(menu, {
        header = "❌ Fermer",
        params = {
            event = "qb-menu:closeMenu"
        }
    })

    exports['qb-menu']:openMenu(menu)
end)

-- Prévisualisation d’un shell
RegisterNetEvent("Pipou-Immo:previewInterior", function(data)
    if isPreviewing then
        QBCore.Functions.Notify("⛔ Vous êtes déjà en prévisualisation.", "error")
        return
    end

    playerLevel = FindAvailablePreviewLevel()
    local previewCoords = GetPreviewCoords(playerLevel)

    local shellName = data.shell
    local shellModel = GetHashKey(shellName)
    local shellConfig = Config.InteriorTypes[shellName] or { diffx = 0.0, diffy = 0.0, diffz = 0.0 }

    local playerSpawn = previewCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz + 1.0)
    local exitCoords = previewCoords + vector3(shellConfig.diffx, shellConfig.diffy, shellConfig.diffz)
    local ped = PlayerPedId()

    RequestModel(shellModel)
    while not HasModelLoaded(shellModel) do Wait(10) end
    previewShell = CreateObject(shellModel, previewCoords.x, previewCoords.y, previewCoords.z, false, false, false)
    SetEntityHeading(previewShell, 0.0)
    FreezeEntityPosition(previewShell, true)

    DoScreenFadeOut(500)
    Wait(600)
    SetEntityCoords(ped, playerSpawn)
    Wait(100)
    DoScreenFadeIn(500)

    isPreviewing = true
    previewPlayers = previewPlayers + 1

    QBCore.Functions.Notify("🏠 Vous visitez : " .. (Config.InteriorTypes[shellName].label or shellName), "success")

    exitZone = "previewExit_" .. math.random(1000, 9999)
    exports['qb-target']:AddBoxZone(exitZone, exitCoords, 1.0, 1.0, {
        name = exitZone,
        heading = 0,
        debugPoly = false,
        minZ = exitCoords.z - 0.5,
        maxZ = exitCoords.z + 1.5
    }, {
        options = {
            {
                type = "client",
                event = "Pipou-Immo:exitPreview",
                icon = "fas fa-sign-out-alt",
                label = "❌ Quitter la prévisualisation",
                args = { zoneName = exitZone }
            }
        },
        distance = 2.0
    })
end)

-- Sortie de la preview
RegisterNetEvent("Pipou-Immo:exitPreview", function(data)
    if not isPreviewing then return end

    DoScreenFadeOut(500)
    Wait(600)
    SetEntityCoords(PlayerPedId(), -707.24, 272.57, 83.15)

    if data and data.zoneName then
        exports['qb-target']:RemoveZone(data.zoneName)
    elseif exitZone then
        exports['qb-target']:RemoveZone(exitZone)
    end

    previewPlayers = previewPlayers-1

    if previewShell then
        DeleteEntity(previewShell)
        previewShell = nil
    end

    if playerLevel then
        ReleasePreviewLevel(playerLevel)
        playerLevel = nil
    end

    isPreviewing = false
    DoScreenFadeIn(500)
    QBCore.Functions.Notify("🔙 Retour à l'agence", "primary")
end)
