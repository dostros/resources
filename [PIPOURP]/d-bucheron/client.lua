local QBCore = exports['qb-core']:GetCoreObject()

Citizen.CreateThread(function()
    local objets = {
        {model = "prop_logpile_02",        x = -551.8252, y = 5368.083, z = 69.62},
        {model = "prop_logpile_03:",       x = -548.7046, y = 5362.57,  z = 71.10971},
        {model = "prop_barier_conc_01a:",  x = -546.1787, y = 5372.739, z = 69.50749},
        {model = "prop_barier_conc_01a:",  x = -544.0996, y = 5372.521, z = 69.51712},
        {model = "prop_barrel_01a:",       x = -548.8134, y = 5366.298, z = 69.99842},
        {model = "prop_woodpile_04b:",     x = -499.8586, y = 5272.631, z = 79.58796},
        {model = "prop_woodpile_01b:",     x = -501.4537, y = 5268.865, z = 79.61132},
        {model = "prop_woodpile_04b:",     x = -504.7685, y = 5262.616, z = 79.61169},
        {model = "prop_woodpile_01b:",     x = -495.8838, y = 5285.444, z = 79.60996},
    }

    for _, objet in ipairs(objets) do
        local modelHash = GetHashKey(objet.model)
        local object = GetClosestObjectOfType(objet.x, objet.y, objet.z, 1.0, modelHash, false, false, false)
        if DoesEntityExist(object) then
            DeleteEntity(object)
        end
    end
end)




Citizen.CreateThread(function()
    local models = {"wastelander"}

    exports['qb-target']:RemoveTargetModel({"wastelander"})
    exports['qb-target']:AddTargetModel(models, 
    { 
        options = {
            {
                num = 1,
                type = "client",
                icon = 'fa-solid fa-tree',
                label = 'Charger le tronc',
                targeticon = "fa-solid fa-truck",
                action = function(entity)
                    local vehicleId = entity
                    TriggerEvent("d-putintrucklog", vehicleId)
                end,
                job = "timber",
            },
        },
        distance = 2.5,
    })



end)




Citizen.CreateThread(function()

    local trees = Config.Trees

    for _, tree in ipairs(trees) do

        local hashtree = "test_tree_cedar_trunk_001"

        RequestModel(hashtree)
        local waiting = 0
        while not HasModelLoaded(hashtree) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 3000 then
                print("Model not found")
                break
            end
        end
        local treespawn = CreateObject(hashtree, tree.x, tree.y, tree.z-2, true, true, false)
        FreezeEntityPosition(treespawn, true)


        exports['qb-target']:AddTargetEntity(treespawn, {
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = 'fa-solid fa-tree',
                    label = 'Couper',
                    targeticon = "fa-solid fa-scissors",
                    action = function()
                        exports['qb-target']:RemoveTargetEntity(treespawn)
                        TriggerEvent('d-timber-cut-tree',treespawn)
                    end,
                    job = "timber",
                },
            },
            distance = 2.5,
        })

    end

    local objects = Config.Objecttimber

    if objects and #objects > 0 then
    else
        print("Objects table is empty or nil")
    end

    for _, object in ipairs(objects) do
        if object then
            local hash = object.hash
            local coords = object.coords
            local rotation = object.rotation

 
            RequestModel(hash)
            local waiting = 0
            while not HasModelLoaded(hash) do
                waiting = waiting + 100
                Citizen.Wait(100)
                if waiting > 3000 then
                    print("Model not found")
                    break
                end
            end
            local objectspawn = CreateObject(hash, coords.x, coords.y, coords.z-1, true, true, false)
            SetEntityRotation(objectspawn,rotation.x,rotation.y,rotation.z )
            FreezeEntityPosition(objectspawn, true)
            
        else
            print("Object is nil")
        end
    end
end)

RegisterNetEvent('d-timber-cut-tree')
AddEventHandler('d-timber-cut-tree', function(treespawn)
    local playerPed = PlayerPedId()
    local treeCoords = GetEntityCoords(treespawn)
    local playerCoords = GetEntityCoords(playerPed)


    local axemodel = "prop_tool_fireaxe"

    RequestModel(axemodel)
    while not HasModelLoaded(axemodel) do
        Citizen.Wait(100)
    end

    local axe = CreateObject(axemodel,playerCoords.x, playerCoords.y, playerCoords.z, true, true, false)
    local boneIndex = GetEntityBoneIndexByName(playerPed, "BONE_R_HAND")


    AttachEntityToEntity(axe, playerPed, GetPedBoneIndex(playerPed, 57005), 
    0.1, 0.0, 0.0, 
    90.0, 90.0, 90.0, 
    true, true, false, false, 2, true)


    


    local animDict = "anim@melee@machete@streamed_core@" 
    local animName = "plyr_rear_takedown_b"
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(100)
    end
    SetEntityCoords(playerPed,treeCoords.x+1, treeCoords.y, treeCoords.z)
    TaskTurnPedToFaceEntity(playerPed, treespawn, -1)
    TaskPlayAnim(playerPed, animDict,animName, 1.0, 1.0, -1, 49, 0, false, false, false)

    QBCore.Functions.Progressbar('cuttreeprogressbar', 'Coupe d\'arbre en cours', 15000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
        }, {}, {}, {}, function()
        end, function()
            -- This code runs if the progress bar gets cancelled
    end)

    Citizen.Wait(15000)

    DeleteEntity(axe)


    
    ClearPedTasksImmediately(playerPed)
    UseParticleFxAssetNextCall("core")
    local particle = StartParticleFxLoopedAtCoord("ent_dst_wood_splinter", treeCoords.x, treeCoords.y, treeCoords.z + 0.1, 0.0, 0.0, 0.0, 2.5, false, false, false, false)
    PlaySoundFromEntity(-1, "Wood_Cut", treespawn, "DLC_HEIST_BIOLAB_PREP_SOUNDSET", false, 0) -- Son de coupe d'arbre (changez si besoin)

    Citizen.Wait(500)

    SetEntityCoords(treespawn, treeCoords.x, treeCoords.y, treeCoords.z + 0.5, false, false, false, false)
    local heading = GetEntityHeading(treespawn)

    local rotation = GetEntityRotation(treespawn)
    local step = 1
    local actualstate = 0
    local finalstep = 90

    while finalstep > actualstate do
        SetEntityRotation(treespawn, rotation.x + step, rotation.y, rotation.z, 0, false)
        Citizen.Wait(10)
        rotation = GetEntityRotation(treespawn)
        actualstate = actualstate + step
    end

    -- Ajouter un effet de poussière ou débris à l'impact
    StartParticleFxLoopedAtCoord("core_dust", treeCoords.x, treeCoords.y, treeCoords.z - 1.0, 0.0, 0.0, heading, 0.5, false, false, false, false)

    -- Stabiliser l’arbre après la chute
    Citizen.Wait(500)
    FreezeEntityPosition(treespawn, true)

    -- Ajouter l'option de couper l'arbre en tronçons
    exports['qb-target']:AddTargetEntity(treespawn, {
        options = {
            {
                num = 1,
                type = "client",
                icon = 'fa-solid fa-tree',
                label = 'Couper en tronçons',
                targeticon = "fa-solid fa-scissors",
                action = function()
                    exports['qb-target']:RemoveTargetEntity(treespawn)
                    local coords = GetEntityCoords(treespawn)
                    TriggerEvent('DtimberCutLog', treespawn, coords)
                    DeleteEntity(treespawn)
                end,
                job = "timber",
            },
        },
        distance = 2.5,
    })
end)



RegisterNetEvent('DtimberCutLog')
AddEventHandler('DtimberCutLog',function(tree, coords) 
    

    --for i = 1, math.random(1, 3) do

        local hashlog = "prop_log_01"

        RequestModel(hashlog)
        local waiting = 0
        while not HasModelLoaded(hashlog) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 3000 then
                print("Model not found")
                break
            end
        end
        local treelog = CreateObject(hashlog, coords.x, coords.y, coords.z-0.3, true, true, false)
        --FreezeEntityPosition(treelog, true)
        exports['qb-target']:RemoveTargetEntity(treelog)
        exports['qb-target']:AddTargetEntity(treelog, {
            options = {
                {
                    num = 1,
                    type = "client",
                    icon = 'fa-solid fa-tree',
                    label = 'Porter',
                    targeticon = "fa-solid fa-scissors",
                    action = function()
                        print("Je te porte")
                        local logcoords =GetEntityCoords(treelog)
                        TriggerEvent('d-CarryLog',treelog,logcoords)
                        exports['qb-target']:RemoveTargetEntity(treelog)
                        --DeleteEntity(treelog)
                    end,
                    job = "timber",
                },
            },
            distance = 2.5,
        })
    --end



end)


logweared = nil
RegisterNetEvent('d-CarryLog')
AddEventHandler('d-CarryLog', function(treelog, logcoords)

    local player = PlayerPedId()

    -- Vérifier si le joueur porte déjà un tronc
    if iswearinglog then
        QBCore.Functions.Notify("Vous portez déjà un tronc !", "primary", length)
        return
    end

    -- Attacher le tronc au dos du joueur
    AttachEntityToEntity(treelog, player, GetPedBoneIndex(player, 24816),  
        0.3, -0.15, 0.4, -- Position ajustée
        90, 0, 0,        -- Rotation
        false, true, false, false, 2, true
    )

    QBCore.Functions.Notify("Vous portez le tronc !\nAppuyez sur [E] pour relâcher.", "primary", length)
    iswearinglog = true
    logweared = treelog

    RequestAnimDict("move_m@hiking")
    while not HasAnimDictLoaded("move_m@hiking") do
        Citizen.Wait(10)
    end
    TaskPlayAnim(player, "move_m@hiking", "idle", 1.0, 1.0, -1, 49, 0, false, false, false)

    -- Surveiller si le joueur lâche le tronc
    Citizen.CreateThread(function()
        while iswearinglog do
            Citizen.Wait(0)
            if IsControlJustReleased(0, 38) then  -- 38 = Touche "E"0
                TriggerEvent("StopDraggingLog", treelog)
                ClearPedTasksImmediately(player)
                break
            end
        end
    end)
end)

RegisterNetEvent("StopDraggingLog")
AddEventHandler("StopDraggingLog", function(treelog)
    local player = PlayerPedId()
    iswearinglog = false
    DetachEntity(treelog, true, true)
    QBCore.Functions.Notify("Vous avez relâché le tronc !", "primary", length)

    Wait(1500)
    FreezeEntityPosition(treelog,true)
    -- exports['qb-target']:AddTargetEntity(treelog, {
    --     options = {
    --         {
    --             num = 1,
    --             type = "client",
    --             icon = 'fa-solid fa-tree',
    --             label = 'Porter',
    --             targeticon = "fa-solid fa-scissors",
    --             action = function()
    --                 local logcoords =GetEntityCoords(treelog)
    --                 TriggerEvent('d-CarryLog',treelog,logcoords)
    --                 exports['qb-target']:RemoveTargetEntity(treelog)
    --                 --DeleteEntity(treelog)
    --             end,
    --             job = "timber",
    --         },
    --     },
    --     distance = 2.5,
    -- })

end)



numberoflog = 0
logsInTruck = {} -- Tableau pour stocker les troncs attachés au camion

RegisterNetEvent('d-putintrucklog')
AddEventHandler('d-putintrucklog', function(vehicleId)
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local radius = 3.0
    local modelHash = GetHashKey("prop_log_01")

    --print("Nombre de troncs dans le camion :", numberoflog)

    local logFound = nil
    for obj in EnumerateObjects() do
        if DoesEntityExist(obj) and GetEntityModel(obj) == modelHash then
            local objCoords = GetEntityCoords(obj)
            -- Vérifie si l'objet n'est pas déjà attaché à un véhicule
            if #(playerCoords - objCoords) <= radius and GetEntityAttachedTo(obj) == 0 then
                logFound = obj
                break
            end
        end
    end

    if logFound then
        if numberoflog < 12 then
            DetachEntity(logFound, true, true)
            FreezeEntityPosition(logFound, false)

            local width = 0
            local height = 0

            if numberoflog == 0 then
                print("Premier tronc ajouté")
                numberoflog = numberoflog + 1
            elseif numberoflog == 1 then 
                print("Deuxième tronc ajouté")
                width = 0.5  
                numberoflog = numberoflog + 1
            elseif numberoflog == 2 then
                print("Troisième tronc ajouté")
                width = -0.5  
                numberoflog = numberoflog + 1
            elseif numberoflog == 3 then
                print("Quatrième tronc ajouté")
                width = 1.0  
                numberoflog = numberoflog + 1
            elseif numberoflog == 4 then
                print("Cinquième tronc ajouté")
                width = -1.0  
                numberoflog = numberoflog + 1
            elseif numberoflog == 5 then
                print("Sixième tronc ajouté")
                width = -0.25  
                height = 0.5
                numberoflog = numberoflog + 1
            elseif numberoflog == 6 then
                print("Septième tronc ajouté")
                width = 0.25  
                height = 0.5
                numberoflog = numberoflog + 1
            elseif numberoflog == 7 then
                print("Huitième tronc ajouté")
                width = -0.75  
                height = 0.5
                numberoflog = numberoflog + 1
            elseif numberoflog == 8 then
                print("Neuvième tronc ajouté")
                width = 0.75  
                height = 0.5
                numberoflog = numberoflog + 1
            elseif numberoflog == 9 then
                print("Dixième tronc ajouté")
                height = 1.0
                numberoflog = numberoflog + 1
            elseif numberoflog == 10 then
                print("Onzième tronc ajouté")
                width = 0.5  
                height = 1.0
                numberoflog = numberoflog + 1
            elseif numberoflog == 11 then
                print("Douzième tronc ajouté")
                width = -0.5  
                height = 1.0
                numberoflog = numberoflog + 1
            end

            -- Attacher le tronc avec le bon décalage
            AttachEntityToEntity(logFound, vehicleId, GetEntityBoneIndexByName(vehicleId, "chassis"),  
                width, -1.5, 1.1 + height, 
                0, 0, 0,
                false, false, false, false, 0, true
            )

            -- Ajouter le tronc au tableau des troncs attachés
            table.insert(logsInTruck, logFound)

            --print("Nouvelles coordonnées du tronc :", GetEntityCoords(logFound))
            FreezeEntityPosition(logFound, true)
            SetEntityCollision(logFound, true, true)

            QBCore.Functions.Notify("✅ Tronc placé dans le véhicule !", "primary", length)
        else
            QBCore.Functions.Notify("Tu ne peux pas charger plus ti es fada ou quoi !! Ca va benner sinon !", "error", length)
        end
    else
        QBCore.Functions.Notify("❌ Aucun tronc trouvé à proximité", "error", length)
    end
end)





-- local isPlacingLog = false
-- local ghostLog = nil

-- RegisterNetEvent("StartPlacingLog")
-- AddEventHandler("StartPlacingLog", function(treelog)

--     if not DoesEntityExist(treelog) then return end

--     isPlacingLog = true
--     local player = PlayerPedId()
--     local logModel = GetEntityModel(treelog)
--     local playerCoords = GetEntityCoords(player)

--     RequestModel(logModel)
--     while not HasModelLoaded(logModel) do
--         Citizen.Wait(10)
--     end

--     -- Rendre le tronc fantôme
--     SetEntityAlpha(treelog, 0, false)

--     -- Création d’un tronc fantôme semi-transparent pour aider au placement
--     ghostLog = CreateObject(logModel, playerCoords.x, playerCoords.y, playerCoords.z, false, false, false)
--     SetEntityAlpha(ghostLog, 150, false)
--     SetEntityCollision(ghostLog, false, false)
--     FreezeEntityPosition(ghostLog, true)

--     Citizen.CreateThread(function()
--         while isPlacingLog do
--             Citizen.Wait(0)
--             local hit, coords = RaycastFromCamera()
--             if hit then
--                 SetEntityCoords(ghostLog, coords.x, coords.y, coords.z - 1.0, false, false, false, false)
--             end

--             -- Placement du tronc
--             if IsControlJustReleased(0, 38) then -- Appuie sur E pour placer
--                 PlaceLog(treelog, coords)
--             end
--         end
--     end)
-- end)

-- function PlaceLog(treelog, coords)
--     if DoesEntityExist(ghostLog) then
--         DeleteEntity(ghostLog)
--     end

--     isPlacingLog = false
--     SetEntityAlpha(treelog, 255, false)
--     SetEntityCoords(treelog, coords.x, coords.y, coords.z - 1.0, false, false, false, false)
--     QBCore.Functions.Notify("Vous avez déposé le tronc !", "primary", length)
-- end

-- function RaycastFromCamera()
--     local camCoords = GetGameplayCamCoord()
--     local camRot = GetGameplayCamRot(2)
--     local direction = RotationToDirection(camRot)
--     local distance = 10.0
--     local endCoords = camCoords + (direction * distance)

--     local rayHandle = StartShapeTestRay(camCoords.x, camCoords.y, camCoords.z, endCoords.x, endCoords.y, endCoords.z, 1 + 2 + 4 + 8 + 16, PlayerPedId(), 0)
--     local retval, hit, hitCoords = GetShapeTestResult(rayHandle)

--     if hit == 1 and hitCoords then
--         return true, hitCoords
--     end

--     return false, vector3(0, 0, 0) -- Valeur par défaut
-- end

-- function RotationToDirection(rotation)
--     local x = math.rad(rotation.x)
--     local z = math.rad(rotation.z)
--     local cosX = math.cos(x)
--     return vector3(-math.sin(z) * cosX, math.cos(z) * cosX, math.sin(x))
-- end

function EnumerateObjects()
    return coroutine.wrap(function()
        local handle, object = FindFirstObject()
        if not object or object == 0 then
            EndFindObject(handle)
            return
        end
        local success
        repeat
            coroutine.yield(object)
            success, object = FindNextObject(handle)
        until not success
        EndFindObject(handle)
    end)
end



RegisterCommand("log", function()
    local hashlog = "prop_log_01"
    local player =PlayerPedId()
    local coords = GetEntityCoords(player)

    RequestModel(hashlog)
    local waiting = 0
    while not HasModelLoaded(hashlog) do
        waiting = waiting + 100
        Citizen.Wait(100)
        if waiting > 3000 then
            print("Model not found")
            break
        end
    end
    local treelog = CreateObject(hashlog, coords.x, coords.y, coords.z-0.5, true, true, false)
    FreezeEntityPosition(treelog, true)
end,false)

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Décharger les troncs
Citizen.CreateThread(function()
    Wait(5000)
    local objects = Config.Objecttimber
    local ButtonConvHash = objects[9].hash
    local ButtonConvHashCoords = objects[9].coords


    local closestObject = 
        GetClosestObjectOfType(
            ButtonConvHashCoords.x, ButtonConvHashCoords.y, ButtonConvHashCoords.z, 
            1.0, 
            ButtonConvHash, 
            false, false, false
        )

        -- print(ButtonConvHash)
        -- print(ButtonConvHashCoords)
        -- print(closestObject)
    

    exports['qb-target']:AddTargetEntity(closestObject, {
        options = {
            {
                num = 1,
                type = "client",
                icon = 'fa-solid fa-road',
                label = 'Décharger',
                targeticon = 'fa-solid fa-power-off',
                action = function()
                    TriggerEvent('d-timber-put-tree-on-Conv')
                end,
                job = "timber",
            },
        },
        distance = 2.5,
    })

end)


RegisterNetEvent('d-timber-put-tree-on-Conv')
AddEventHandler('d-timber-put-tree-on-Conv', function ()
    local player = PlayerPedId()
    local playerCoords = GetEntityCoords(player)
    local radius = 15.0
    local wastelanderHash = GetHashKey("wastelander")
    local wastelanderFound = nil

    for vehicle in EnumerateVehicles() do
        if DoesEntityExist(vehicle) and GetEntityModel(vehicle) == wastelanderHash then
            local vehicleCoords = GetEntityCoords(vehicle)
            if #(playerCoords - vehicleCoords) <= radius then
                wastelanderFound = vehicle
                break
            end
        end
    end

    if wastelanderFound and numberoflog > 0 then
        print("Véhicule trouvé et rondins présents")

        for i = #logsInTruck, 1, -1 do
            local log = logsInTruck[i]
            DetachEntity(log, true, true)
            FreezeEntityPosition(log, false)
            SetEntityCoords(log, -517.15, 5272.36, 80.25, false, false, false, false)
            SetEntityRotation(log, -5.2, 0.0, 70.0)
            FreezeEntityPosition(log, true)

            print("Déplacement du rondin vers les coordonnées finales")
            MoveObjectToCoords(log, GetEntityCoords(log), vector3(-526.23, 5275.73, 79.56), 25000)
            MoveObjectToCoords(log, GetEntityCoords(log), vector3(-537.64, 5279.87, 78.61), 25000)
            MoveObjectToCoords(log, GetEntityCoords(log), vector3(-549.4, 5284.19, 77.63), 25000)
            MoveObjectToCoords(log, GetEntityCoords(log), vector3(-557.28, 5287.1, 76.60), 25000, function()

                DeleteEntity(log)
            end)
            Wait(7000)
        end
        TriggerServerEvent("server-d-timber-SaveLog", numberoflog)
    else
        QBCore.Functions.Notify("Pas de véhicule à proximité ou de rondins à décharger", "error", length)
    end
end)


------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- Décharger les planches

Citizen.CreateThread(function()
    Wait(100)
    local objects = Config.Objecttimber
    local ButtonConvHash = objects[10].hash
    local ButtonConvHashCoords = objects[10].coords


    local closestObject = 
        GetClosestObjectOfType(
            ButtonConvHashCoords.x, ButtonConvHashCoords.y, ButtonConvHashCoords.z, 
            1.0, 
            ButtonConvHash, 
            false, false, false
        )
    

    exports['qb-target']:AddTargetEntity(closestObject, {
        options = {
            {
                num = 1,
                type = "client",
                icon = 'fa-solid fa-road',
                label = 'Activer la scie',
                targeticon = 'fa-solid fa-power-off',
                action = function()
                    TriggerEvent('d-timber-put-plank-on-Conv')
                end,
                job = "timber",
            },
        },
        distance = 10,
    })

end)





Citizen.CreateThread(function()
    Wait(5000)
    local objects = Config.Objecttimber
    local ButtonConvHash = objects[11].hash
    local ButtonConvHashCoords = objects[11].coords


    local closestObject = 
        GetClosestObjectOfType(
            ButtonConvHashCoords.x, ButtonConvHashCoords.y, ButtonConvHashCoords.z, 
            1.0, 
            ButtonConvHash, 
            false, false, false
        )

        -- print(ButtonConvHash)
        -- print(ButtonConvHashCoords)
        -- print(closestObject)
    

    exports['qb-target']:AddTargetEntity(closestObject, {
        options = {
            {
                num = 1,
                type = "client",
                icon = 'fa-solid fa-ruler-horizontal',
                label = 'Récupérer les planches',
                targeticon = 'fa-solid fa-power-off',
                action = function()
                    TriggerEvent("qb-timber:client:openstash") 
                end,
                job = "timber",
            },
        },
        distance = 2.5,
    })

end)

RegisterNetEvent('qb-timber:client:openstash', function()
    local PlayerData = QBCore.Functions.GetPlayerData()

    if PlayerData.job and PlayerData.job.name == "timber" then
        local stashName = "timber_stash"

        TriggerServerEvent("timber:OpenStash")
        
    else
        QBCore.Functions.Notify("🚫 Vous n'avez pas accès à ce coffre !", "error")
    end
end)




RegisterNetEvent('d-timber-put-plank-on-Conv')
AddEventHandler('d-timber-put-plank-on-Conv', function ()


    QBCore.Functions.TriggerCallback("server-d-timber-GetNumberOfLog",function(response)
    

        local player = PlayerPedId()
        local playerCoords = GetEntityCoords(player)
        local radius = 1.0


        if response > 0 then

            print("Nombre de planches : "..response)

            for i = 1, response*4 do
                
                local hashplank = "prop_rub_planks_01"
                local coords = vector3(-567.21, 5300.66, 80.17)
            
                RequestModel(hashplank)
                local waiting = 0
                while not HasModelLoaded(hashplank) do
                    waiting = waiting + 100
                    Citizen.Wait(100)
                    if waiting > 3000 then
                        print("Model not found")
                        break
                    end
                end
            
                local plank = CreateObject(hashplank, coords.x, coords.y, coords.z-0.5, true, true, false)
                --SetEntityCoords(plank, -517.15, 5272.36, 80.25, false, false, false, false)
                SetEntityRotation(plank, 105.0, -10.0, -30.0)
                FreezeEntityPosition(plank, true)
                Citizen.CreateThread(function()
                    MoveObjectToCoords(plank, GetEntityCoords(plank), vector3(-570.18, 5293.77, 78.66), 2500)
                    Citizen.Wait(2500)
                    MoveObjectToCoords(plank, GetEntityCoords(plank), vector3(-575.61, 5281.02, 74.87), 2500)
                    Citizen.Wait(2500)
                    SetEntityRotation(plank, 120.0, -10.0, -30.0)
                    MoveObjectToCoords(plank, GetEntityCoords(plank), vector3(-578.09, 5275.63, 71.56), 2500,
                    function()
                        TriggerServerEvent("qb-timber:server:storePlank")
                        DeleteEntity(plank)
                    end)
                end)
                Citizen.Wait(1000)
            end
        else
            QBCore.Functions.Notify("Pas de planches à récupérer", "error", length)
        end
    end)
end)





function MoveObjectToCoords(object, startCoords, endCoords, duration, callback)
    local startTime = GetGameTimer()
    local endTime = startTime + duration

    Citizen.CreateThread(function()
        while GetGameTimer() < endTime do
            local currentTime = GetGameTimer()
            local progress = (currentTime - startTime) / duration
            local newX = Lerp(startCoords.x, endCoords.x, progress)
            local newY = Lerp(startCoords.y, endCoords.y, progress)
            local newZ = Lerp(startCoords.z, endCoords.z, progress)
            SetEntityCoords(object, newX, newY, newZ, false, false, false, false)
            Citizen.Wait(0)
        end
        SetEntityCoords(object, endCoords.x, endCoords.y, endCoords.z, false, false, false, false)
        if callback then
            callback()
        end
    end)
end

function Lerp(a, b, t)
    return a + (b - a) * t
end

function EnumerateVehicles()
    return coroutine.wrap(function()
        local handle, vehicle = FindFirstVehicle()
        if not vehicle or vehicle == 0 then
            EndFindVehicle(handle)
            return
        end
        local success
        repeat
            coroutine.yield(vehicle)
            success, vehicle = FindNextVehicle(handle)
        until not success
        EndFindVehicle(handle)
    end)
end



RegisterCommand("plank", function()
    TriggerServerEvent("qb-timber:server:storePlank")
end, false)


-- local mainMenu = nil
-- local settingsMenu = nil
-- local checkboxState = false
-- local volumeValue = 5

-- RegisterCommand("menutest", function()
--     local menuId = exports['PipouUI']:CreateMenu("Menu Principal", "Bienvenue dans le menu test")

--     exports['PipouUI']:AddButton(menuId, "Dire Bonjour", function()
--         print("Bonjour ! 👋")
--     end)

--     exports['PipouUI']:AddOption(menuId, "checkbox", "Activer mode", {checked = false}, function()
--         print("Mode activé/désactivé ✅")
--     end)

--     exports['PipouUI']:AddOption(menuId, "slider", "Volume", {value = 3, min = 0, max = 10, step = 1}, function()
--         print("Volume modifié 🔊")
--     end)

--     exports['PipouUI']:OpenMenu(menuId)
-- end)

-- -- Sous-menu de paramètres
-- CreateThread(function()
--     settingsMenu = exports['PipouUI']:CreateMenu("Paramètres", "Réglages secondaires")

--     exports['PipouUI']:AddOption(settingsMenu, "slider", "Luminosité", {value = 5, min = 1, max = 10, step = 1}, function()
--         print("☀️ Luminosité modifiée")
--     end)

--     exports['PipouUI']:AddButton(settingsMenu, "Retour ⬅️", function()
--         exports['PipouUI']:OpenMenu(mainMenu)
--     end)
-- end)
