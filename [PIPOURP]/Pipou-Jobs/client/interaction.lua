CreateThread(function()
    while true do
        Wait(5000)
        for _, playerId in ipairs(GetActivePlayers()) do
            local ped = GetPlayerPed(playerId)
            if ped ~= PlayerPedId() then
                exports['qb-target']:AddTargetEntity(ped, {
                    options = {
                        {
                            num = 1,
                            type = "client",
                            event = "Test:Event",
                            icon = 'fa-solid fa-grip-lines',
                            targeticon = 'fa-solid fa-file-signature', 
                            label = 'Engager la personne',
                            action = function(data)
                                local targetPed = data.entity
                                if not IsPedAPlayer(targetPed) then return end

                                local targetPlayer = NetworkGetPlayerIndexFromPed(targetPed)
                                if targetPlayer == -1 then return end

                                local serverId = GetPlayerServerId(targetPlayer)
                                local playerData = QBCore.Functions.GetPlayerData()
                                local jobName = playerData.job.name

                                TriggerEvent('PipouJobs:client:Engage', serverId, jobName)
                            end,

                            canInteract = function(data)
                                local ped = data.entity
                                if not IsPedAPlayer(ped) then return false end
                                local playerData = QBCore.Functions.GetPlayerData()
                                return playerData.job and playerData.job.isboss
                            end,
                        },
                        {
                            num = 2,
                            type = "client",
                            event = "Test:Event",
                            icon = 'fa-solid fa-grip-lines',
                            label = 'facturer la personne',
                            targeticon = 'fa-solid fa-credit-card',
                            action = function(data)
                                local targetPed = data.entity
                                if not IsPedAPlayer(targetPed) then return end

                                local targetPlayer = NetworkGetPlayerIndexFromPed(targetPed)
                                if targetPlayer == -1 then return end

                                local serverId = GetPlayerServerId(targetPlayer)
                                local playerData = QBCore.Functions.GetPlayerData()
                                local jobName = playerData.job.name

                                QBCore.Functions.Notify("Vous essayez de facturer quelqu'un qui n'a rien demandé", "error")
                            end,

                            -- canInteract = function(data)
                            --     local ped = data.entity
                            --     if not IsPedAPlayer(ped) then return false end
                            --     local playerData = QBCore.Functions.GetPlayerData()
                            --     return playerData.job and playerData.job.isboss
                            -- end,
                        }
                    },
                    distance = 1.5,
                })
            end
        end
    end
end)
