-- Variables
QBCore = exports['qb-core']:GetCoreObject()
PlayerJob = {}
local DutyBlips = {}


-- FONCTIONS

function EMOTE(emoteName)
	
	disableControls = true
	FreezeEntityPosition(PlayerPedId(), true)
    local playerPos = GetEntityCoords(PlayerPedId())

	TaskStartScenarioAtPosition(PlayerPedId(), emoteName, playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(PlayerPedId()), 0, false, false)

end




--BE ON DUTY
local zoneCenterduty = Config.Locations['duty'][1]
local zoneRadiusduty = 1.5 -- Radius of the zone

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    
    Citizen.CreateThread(function()

        
            local Player = QBCore.Functions.GetPlayerData()
            local jobName = Player.job.name
        
            while true do
                Citizen.Wait(0)

                if  jobName=="restaurant" then
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local dx = playerCoords.x - zoneCenterduty.x
                    local dy = playerCoords.y - zoneCenterduty.y
                    local dz = playerCoords.z - zoneCenterduty.z
                    local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

                    if distance <= zoneRadiusduty then
                        exports['qb-core']:DrawText("Prendre/Quitter son service", 'left')
                        if IsControlJustReleased(0, 38) then -- 38 is the key code for "E"
                            TriggerEvent('RestaurantToggle:Duty')
                        end
                    else
                        exports['qb-core']:HideText()
                    end


                end
                    
            end
    end)

    RegisterNetEvent('RestaurantToggle:Duty', function()
        onDuty = not onDuty
        TriggerServerEvent('QBCore:ToggleDuty')
        --TriggerServerEvent('police:server:UpdateBlips')
    end)




    --OPEN COFFRE

    RegisterNetEvent('qb-restaurant:client:openstash', function()
        TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'restaurantstash_' .. QBCore.Functions.GetPlayerData().citizenid)
        TriggerEvent('inventory:client:SetCurrentStash', 'restaurantstash_' .. QBCore.Functions.GetPlayerData().citizenid)
    end)


    --FARM TOMATO

    local zoneCenterbottle = Config.Locations['farm'][1]
    local zoneRadiusbottle = 3 -- Radius of the zone

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local Player = QBCore.Functions.GetPlayerData()
            local jobName = Player.job.name
            local onduty = Player.job.onduty

            if jobName == "restaurant" and onduty then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local dx = playerCoords.x - zoneCenterbottle.x
                local dy = playerCoords.y - zoneCenterbottle.y
                local dz = playerCoords.z - zoneCenterbottle.z
                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

                if distance <= zoneRadiusbottle then
                    DrawMarker(27, zoneCenterbottle.x, zoneCenterbottle.y, zoneCenterbottle.z-0.8, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 3.0, 3.0, 3.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                    QBCore.Functions.DrawText3D(zoneCenterbottle.x, zoneCenterbottle.y, zoneCenterbottle.z, "Appuyer sur [E] pour récolter des Tomates", 0.4)
                    if IsControlJustReleased(0, 38) then -- 38 is the key code for "E"
                        EMOTE('world_human_gardener_plant')
                        QBCore.Functions.Progressbar('recoltebottle', 'Récolte de tomates', 10000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                            }, {}, {}, {}, function()
                                exports['PipouUI']:Notify("10 tomates ramassées", "success", 1500)
                                FreezeEntityPosition(PlayerPedId(), false)
                                
                                TriggerServerEvent("qb-restaurant:server:receivetomato")

                            end, function()
                                -- This code runs if the progress bar gets cancelled
                        end)
                    end
                else
                    exports['qb-core']:HideText()
                end


            end
        end
    end)


    --FARM FLOUR

    local zoneCenterbottle = Config.Locations['farm'][2]
    local zoneRadiusbottle = 3 -- Radius of the zone

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local Player = QBCore.Functions.GetPlayerData()
            local jobName = Player.job.name
            local onduty = Player.job.onduty

            if jobName == "restaurant" and onduty then
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local dx = playerCoords.x - zoneCenterbottle.x
                local dy = playerCoords.y - zoneCenterbottle.y
                local dz = playerCoords.z - zoneCenterbottle.z
                local distance = math.sqrt(dx * dx + dy * dy + dz * dz)

                if distance <= zoneRadiusbottle then
                    DrawMarker(27, zoneCenterbottle.x, zoneCenterbottle.y, zoneCenterbottle.z-0.8, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 3.0, 3.0, 3.0, 255, 128, 0, 50, false, true, 2, nil, nil, false)
                    QBCore.Functions.DrawText3D(zoneCenterbottle.x, zoneCenterbottle.y, zoneCenterbottle.z, "Appuyer sur [E] pour récolter de la farine", 0.4)
                    if IsControlJustReleased(0, 38) then -- 38 is the key code for "E"
                        EMOTE('world_human_gardener_plant')
                        QBCore.Functions.Progressbar('recoltebottle', 'Récolte de farine', 10000, false, true, {
                            disableMovement = true,
                            disableCarMovement = true,
                            disableMouse = false,
                            disableCombat = true
                            }, {}, {}, {}, function()
                                exports['PipouUI']:Notify("5 kg de farine ramassés", "success", 1500)
                                FreezeEntityPosition(PlayerPedId(), false)
                                
                                TriggerServerEvent("qb-restaurant:server:receiveflour")

                            end, function()
                                -- This code runs if the progress bar gets cancelled
                        end)
                    end
                else
                    exports['qb-core']:HideText()
                end


            end
        end
    end)
end)


local blips = {
    -- Example {title="", colour=, id=, x=, y=, z=},

     {title="Restaurant", colour=30, id=815, x = -1338.83, y = -1080.88, z = 6.93},
     {title="Tomates", colour=30, id=208, x = -1933.47, y = 1939.74, z = 163.12},
     {title="Farine", colour=30, id=540, x = 2152.04, y = 5168.81, z = 54.91},
     {title="Vaches", colour=30, id=569, x = 2423.97, y = 4785.2, z = 34.64},
  }
      
Citizen.CreateThread(function()
    while true do
        local playerData = QBCore.Functions.GetPlayerData()  -- Récupère les données du joueur

        if playerData and playerData.job and playerData.job.name then
            local job = playerData.job.name 
        else 
            break
        end

        if job == "restaurant" then

            for _, info in pairs(blips) do
            info.blip = AddBlipForCoord(info.x, info.y, info.z)
            SetBlipSprite(info.blip, info.id)
            SetBlipDisplay(info.blip, 2)
            SetBlipScale(info.blip, 1.0)
            SetBlipColour(info.blip, info.colour)
            SetBlipAsShortRange(info.blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(info.title)
            EndTextCommandSetBlipName(info.blip)
            end
        end
        Wait(300000)
    end
end)