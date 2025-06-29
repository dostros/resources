CreateThread(function()
    Wait(1000) -- attendre que tout soit chargé

    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= PlayerPedId() then
            exports['qb-target']:AddTargetEntity(targetPed, {
                options = {
                     {
                        icon = "fas fa-briefcase-medical",
                        label = "Ouvrir le menu EMS",
                        job = "ambulance",
                        action = function(entity)
                            local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                            OpenEMSActionMenu(targetId)
                        end
                    },
                },
                distance = 2.5,
                job = { "ambulance" }
            })
        end
    end
end)


function OpenEMSActionMenu(targetId)
    local items = {
        {
            label = "🩹 Soigner",
            value = "heal",
            action = function()
                TriggerServerEvent("ems:healPlayer", targetId)
            end
        },
        {
            label = "💊 Réanimer",
            value = "revive",
            action = function()
                TriggerServerEvent("ems:revivePlayer", targetId)
            end
        },
        {
            label = "🩺 Stabiliser",
            value = "stabilize",
            action = function()
                TriggerServerEvent("ems:stabilizePlayer", targetId)
            end
        },
        {
            label = "🚑 Transporter",
            value = "carry",
            action = function()
                TriggerEvent("ems:startCarry", targetId)
            end
        }
    }

    -- Ouvre le menu centré avec focus (SetNuiFocus est déjà géré dans PipouUI)
    exports['PipouUI']:OpenSimpleMenu("Actions EMS", nil, items, "menu-top-right")
end




RegisterNetEvent("ems:client:healPlayer", function()
    local ped = PlayerPedId()
    local current = GetEntityHealth(ped)
    local max = GetEntityMaxHealth(ped)
    SetEntityHealth(ped, math.min(max, current + 50)) -- ou +100
    exports['PipouUI']:Notify("Un EMS vous soigne.", "success")
end)

RegisterNetEvent("ems:client:DoctorhealPlayer", function()
    exports['PipouUI']:Notify("Patient soigné", "success")
end)
