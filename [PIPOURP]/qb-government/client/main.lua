QBCore = exports['qb-core']:GetCoreObject()
local ObjectList = {}

local function GetClosestPoliceObject()
    local pos = GetEntityCoords(PlayerPedId(), true)
    local current = nil
    local dist = nil

    for id, _ in pairs(ObjectList) do
        local dist2 = #(pos - ObjectList[id].coords)
        if current then
            if dist2 < dist then
                current = id
                dist = dist2
            end
        else
            dist = dist2
            current = id
        end
    end
    return current, dist
end

--------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------

RegisterNetEvent('gov:client:spawnMalette', function()
    QBCore.Functions.Progressbar('spawn_object', 'Barre de progression', 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'anim@narcotics@trash',
        anim = 'drop_front',
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        TriggerServerEvent('gov:server:spawnObject', 'malette')
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        QBCore.Functions.Notify(Lang:t('error.canceled'), 'error')
    end)
end)

RegisterNetEvent('gov:client:spawnCash', function()
    QBCore.Functions.Progressbar('spawn_object', 'Barre de progression', 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'anim@narcotics@trash',
        anim = 'drop_front',
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        TriggerServerEvent('gov:server:spawnObject', 'cash')
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        QBCore.Functions.Notify(Lang:t('error.canceled'), 'error')
    end)
end)

RegisterNetEvent('gov:client:spawnFlag', function()
    QBCore.Functions.Progressbar('spawn_object', 'Barre de progression', 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'anim@narcotics@trash',
        anim = 'drop_front',
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        TriggerServerEvent('gov:server:spawnObject', 'flag')
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        QBCore.Functions.Notify(Lang:t('error.canceled'), 'error')
    end)
end)

RegisterNetEvent('gov:client:spawnTent', function()
    QBCore.Functions.Progressbar('spawn_object', 'Barre de progression', 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = 'anim@narcotics@trash',
        anim = 'drop_front',
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        TriggerServerEvent('gov:server:spawnObject', 'tent')
    end, function() -- Cancel
        StopAnimTask(PlayerPedId(), 'anim@narcotics@trash', 'drop_front', 1.0)
        QBCore.Functions.Notify(Lang:t('error.canceled'), 'error')
    end)
end)




--------------------------------------------------------------------------------------------------------------
---




RegisterNetEvent('gov:client:spawnObject', function(objectId, type, player)
    local coords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(player)))
    local heading = GetEntityHeading(GetPlayerPed(GetPlayerFromServerId(player)))
    local forward = GetEntityForwardVector(PlayerPedId())
    local x, y, z = table.unpack(coords + forward * 0.5)
    local spawnedObj = CreateObject(Config.Objects[type].model, x, y, z, true, false, false)
    PlaceObjectOnGroundProperly(spawnedObj)
    SetEntityHeading(spawnedObj, heading)
    FreezeEntityPosition(spawnedObj, Config.Objects[type].freeze)
    ObjectList[objectId] = {
        id = objectId,
        object = spawnedObj,
        coords = vector3(x, y, z - 0.3),
    }
end)

RegisterNetEvent('gov:client:deleteObject', function()
    local objectId, dist = GetClosestPoliceObject()
    if dist < 5.0 then
        QBCore.Functions.Progressbar('remove_object', 'Barre de progression', 2500, false, true, {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        }, {
            animDict = 'weapons@first_person@aim_rng@generic@projectile@thermal_charge@',
            anim = 'plant_floor',
            flags = 16,
        }, {}, {}, function() -- Done
            StopAnimTask(PlayerPedId(), 'weapons@first_person@aim_rng@generic@projectile@thermal_charge@', 'plant_floor', 1.0)
            TriggerServerEvent('gov:server:deleteObject', objectId)
        end, function() -- Cancel
            StopAnimTask(PlayerPedId(), 'weapons@first_person@aim_rng@generic@projectile@thermal_charge@', 'plant_floor', 1.0)
            QBCore.Functions.Notify(Lang:t('error.canceled'), 'error')
        end)
    end
end)

RegisterNetEvent('gov:client:removeObject', function(objectId)
    NetworkRequestControlOfEntity(ObjectList[objectId].object)
    DeleteObject(ObjectList[objectId].object)
    ObjectList[objectId] = nil
end)



