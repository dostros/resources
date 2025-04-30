local targetedPlayers = {}
local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while true do
        Wait(5000)
        for _, playerId in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(playerId)

            if ped ~= PlayerPedId() and DoesEntityExist(ped) then
                local serverId = GetPlayerServerId(playerId)

                if not targetedPlayers[serverId] then
                    exports['qb-target']:AddTargetEntity(ped, {
                        options = {
                            {
                                type = "client",
                                event = "PipouJobs:client:EngagePlayer",
                                icon = "fas fa-user-plus",
                                label = "Engager la personne",
                                action = function(data)
                                    if not data or not data.entity or not DoesEntityExist(data.entity) then return end
                                    local ped = data.entity
                                    if not IsPedAPlayer(ped) then return end

                                    local targetPlayer = NetworkGetPlayerIndexFromPed(ped)
                                    if targetPlayer == -1 then return end

                                    local serverId = GetPlayerServerId(targetPlayer)
                                    local playerData = QBCore.Functions.GetPlayerData()
                                    local jobName = playerData.job and playerData.job.name or nil

                                    if serverId and jobName then
                                        TriggerEvent('PipouJobs:client:Engage', serverId, jobName)
                                    end
                                end,
                                canInteract = function(entity)
                                    if not entity or not DoesEntityExist(entity) then
                                        return false
                                    end
                                    if not IsPedAPlayer(entity) then
                                        return false
                                    end
                                    local playerData = QBCore.Functions.GetPlayerData()
                                    if not playerData or not playerData.job then
                                        return false
                                    end
                                    return playerData.job.isboss == true
                                end,
                            },
                            {
                                type = "client",
                                event = "PipouJobs:client:BillPlayer",
                                icon = "fas fa-file-invoice-dollar",
                                label = "Facturer la personne",
                                action = function(data)
                                    if not data or not data.entity or not DoesEntityExist(data.entity) then return end
                                    local ped = data.entity
                                    if not IsPedAPlayer(ped) then return end

                                    local targetPlayer = NetworkGetPlayerIndexFromPed(ped)
                                    if targetPlayer == -1 then return end

                                    local serverId = GetPlayerServerId(targetPlayer)
                                    if serverId then
                                        exports['PipouUI']:Notify("Vous avez facturé la personne.", "success")
                                    end
                                end,
                                canInteract = function(entity)
                                    if not entity or not DoesEntityExist(entity) then
                                        return false
                                    end
                                    if not IsPedAPlayer(entity) then
                                        return false
                                    end
                                    local playerData = QBCore.Functions.GetPlayerData()
                                    if not playerData or not playerData.job then
                                        return false
                                    end
                                    return playerData.job.isboss == true
                                end,
                            }
                        },
                        distance = 2.0
                    })

                    -- Marquer que ce joueur a été ciblé pour éviter double ajout
                    targetedPlayers[serverId] = true
                end
            end
        end
    end
end)

RegisterNetEvent('PipouJobs:client:EngagePlayer', function(data)
    if not data or not data.entity or not DoesEntityExist(data.entity) then return end
    local ped = data.entity
    if not IsPedAPlayer(ped) then return end

    local targetPlayer = NetworkGetPlayerIndexFromPed(ped)
    if targetPlayer == -1 then return end

    local serverId = GetPlayerServerId(targetPlayer)
    local playerData = QBCore.Functions.GetPlayerData()
    local jobName = playerData.job and playerData.job.name or nil

    if serverId and jobName then
        TriggerEvent('PipouJobs:client:Engage', serverId, jobName)
    end
end)

RegisterNetEvent('PipouJobs:client:BillPlayer', function(data)
    if not data or not data.entity or not DoesEntityExist(data.entity) then return end
    local ped = data.entity
    if not IsPedAPlayer(ped) then return end

    local targetPlayer = NetworkGetPlayerIndexFromPed(ped)
    if targetPlayer == -1 then return end

    local serverId = GetPlayerServerId(targetPlayer)

    if serverId then
        exports['PipouUI']:Notify("Vous avez facturé la personne.", "success")
    end
end)
