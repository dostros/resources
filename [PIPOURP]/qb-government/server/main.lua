local Objects = {}
local QBCore = exports['qb-core']:GetCoreObject()


local function CreateObjectId()
    if Objects then
        local objectId = math.random(10000, 99999)
        while Objects[objectId] do
            objectId = math.random(10000, 99999)
        end
        return objectId
    else
        local objectId = math.random(10000, 99999)
        return objectId
    end
end


RegisterNetEvent('gov:server:spawnObject', function(type)
    
    local src = source
    local objectId = CreateObjectId()
    Objects[objectId] = type
    TriggerClientEvent('gov:client:spawnObject', src, objectId, type, src)
end)

RegisterNetEvent('gov:server:deleteObject', function(objectId)
    TriggerClientEvent('gov:client:removeObject', -1, objectId)
end)