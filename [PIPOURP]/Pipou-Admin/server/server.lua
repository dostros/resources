RegisterServerEvent("admin:teleportPlayer")
AddEventHandler("admin:teleportPlayer", function(targetId, coords)
    TriggerClientEvent("admin:teleportHere", targetId, coords)
end)

RegisterServerEvent("admin:healPlayer")
AddEventHandler("admin:healPlayer", function(targetId)
    TriggerClientEvent("admin:healMe", targetId)
end)

RegisterServerEvent("admin:toggleFreeze")
AddEventHandler("admin:toggleFreeze", function(targetId)
    TriggerClientEvent("admin:toggleFrozen", targetId)
end)


QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent("admin:setJob", function(targetId, jobName, grade)
    local src = source
    local xPlayer = QBCore.Functions.GetPlayer(targetId)
    if xPlayer then
        xPlayer.Functions.SetJob(jobName, grade)
        TriggerClientEvent('QBCore:Notify', targetId, "Un administrateur vous a assigné le job: " .. jobName, "primary")
        print(("[ADMIN] %s a défini le job de %s en %s (%d)"):format(src, targetId, jobName, grade))
    else
        print("[ADMIN] Joueur introuvable pour setJob:", targetId)
    end
end)


QBCore.Functions.CreateCallback('admin:getJobs', function(source, cb)
    local jobs = QBCore.Shared.Jobs or {}
    local jobList = {}

    for name, job in pairs(jobs) do
        table.insert(jobList, { label = job.label or name, value = name })
    end

    cb(jobList)
end)