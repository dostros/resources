local QBCore = exports['qb-core']:GetCoreObject()
local furniturePed = nil
local furnitureCoords = vector4(2749.96, 3459.67, 55.89, 24.57)

-- 🔹 Coffre du job timber
RegisterNetEvent('timber:client:openstash', function()
    local PlayerData = QBCore.Functions.GetPlayerData()

    if PlayerData.job and PlayerData.job.name == "timber" then
        TriggerServerEvent("timber:OpenSellStash")
    else
        QBCore.Functions.Notify("🚫 Vous n'avez pas accès à ce coffre !", "error")
    end
end)

-- 🔹 Thread principal
Citizen.CreateThread(function()
    Wait(1000)

    -- 📦 Zone de vente timber
    exports['qb-target']:AddBoxZone("TimberSellZone", vector3(2763.71, 3499.63, 55.31), 2.0, 2.0, {
        name = "TimberSellZone",
        heading = 0,
        debugPoly = false,
        minZ = 54.31,
        maxZ = 57.31,
    }, {
        options = {
            {
                type = "client",
                icon = "fas fa-warehouse",
                label = "Ouvrir la réserve",
                action = function()
                    TriggerEvent("timber:client:openstash")
                end,
                job = "timber",
            },
        },
        distance = 2.5,
    })

end)
