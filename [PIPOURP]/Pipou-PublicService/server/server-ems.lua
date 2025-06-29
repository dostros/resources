local QBCore = exports['qb-core']:GetCoreObject()


RegisterNetEvent("ems:healPlayer", function(target)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player or Player.PlayerData.job.name ~= "ambulance" then return end

    TriggerClientEvent("ems:client:healPlayer", target)
    TriggerClientEvent("ems:client:DoctorhealPlayer", src)
end)
