-- -- Variables
-- local currentGarage = 0
-- local inStash = false
-- local inTrash = false
-- local inGarage = false

-- local function loadAnimDict(dict) -- interactions, job,
--     while (not HasAnimDictLoaded(dict)) do
--         RequestAnimDict(dict)
--         Wait(10)
--     end
-- end

-- local function GetClosestPlayer() -- interactions, job, tracker
--     local closestPlayers = QBCore.Functions.GetPlayersFromCoords()
--     local closestDistance = -1
--     local closestPlayer = -1
--     local coords = GetEntityCoords(PlayerPedId())

--     for i = 1, #closestPlayers, 1 do
--         if closestPlayers[i] ~= PlayerId() then
--             local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
--             local distance = #(pos - coords)

--             if closestDistance == -1 or closestDistance > distance then
--                 closestPlayer = closestPlayers[i]
--                 closestDistance = distance
--             end
--         end
--     end

--     return closestPlayer, closestDistance
-- end



-- function MenuGarage(currentSelection)
--     local vehicleMenu = {
--         {
--             header = Lang:t('menu.garage_title'),
--             isMenuHeader = true
--         }
--     }

--     local playerGrade = QBCore.Functions.GetPlayerData().job.grade.level
--     for grade = 0, playerGrade do
--         local authorizedVehicles = Config.AuthorizedVehicles[grade]
--         if authorizedVehicles then
--             for veh, label in pairs(authorizedVehicles) do
--                 vehicleMenu[#vehicleMenu + 1] = {
--                     header = label,
--                     txt = '',
--                     params = {
--                         event = 'restaurant:client:TakeOutVehicle',
--                         args = {
--                             vehicle = veh,
--                             currentSelection = currentSelection
--                         }
--                     }
--                 }
--             end
--         end
--     end

--     vehicleMenu[#vehicleMenu + 1] = {
--         header = Lang:t('menu.close'),
--         txt = '',
--         params = {
--             event = 'qb-menu:client:closeMenu'
--         }

--     }
--     exports['qb-menu']:openMenu(vehicleMenu)
-- end



-- function closeMenuFull()
--     exports['qb-menu']:closeMenu()
-- end

-- --NUI Callbacks


-- --Events 


-- RegisterNetEvent('qb-restaurant:client:openStash', function()
--     TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'restaurantstash_' .. QBCore.Functions.GetPlayerData().citizenid)
--     TriggerEvent('inventory:client:SetCurrentStash', 'restaurantstash_' .. QBCore.Functions.GetPlayerData().citizenid)
-- end)

-- RegisterNetEvent('qb-restaurant:client:openTrash', function()
--     TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'restauranttrash', {
--         maxweight = 4000000,
--         slots = 300,
--     })
--     TriggerEvent('inventory:client:SetCurrentStash', 'restauranttrash')
-- end)

-- --##### Threads #####--

-- local dutylisten = false
-- local function dutylistener()
--     dutylisten = true
--     CreateThread(function()
--         while dutylisten do
--             if PlayerJob.type == 'restaurant' then
--                 if IsControlJustReleased(0, 38) then
--                     TriggerServerEvent('QBCore:ToggleDuty')
--                     TriggerServerEvent('restaurant:server:UpdateCurrentCops')
--                     TriggerServerEvent('restaurant:server:UpdateBlips')
--                     dutylisten = false
--                     break
--                 end
--             else
--                 break
--             end
--             Wait(0)
--         end
--     end)
-- end

-- -- Personal Stash Thread
-- function stash()
--     CreateThread(function()
--         while true do
--             Wait(0)
--             if inStash and PlayerJob.type == 'restaurant' then
--                 if PlayerJob.onduty then sleep = 5 end
--                 if IsControlJustReleased(0, 38) then
--                     TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'restaurantstash_' .. QBCore.Functions.GetPlayerData().citizenid)
--                     TriggerEvent('inventory:client:SetCurrentStash', 'restaurantstash_' .. QBCore.Functions.GetPlayerData().citizenid)
--                     break
--                 end
--             else
--                 break
--             end
--         end
--     end)
-- end

-- -- Trash Thread
-- local function trash()
--     CreateThread(function()
--         while true do
--             Wait(0)
--             if inTrash and PlayerJob.type == 'restaurant' then
--                 if PlayerJob.onduty then sleep = 5 end
--                 if IsControlJustReleased(0, 38) then
--                     TriggerServerEvent('inventory:server:OpenInventory', 'stash', 'restauranttrash', {
--                         maxweight = 4000000,
--                         slots = 300,
--                     })
--                     TriggerEvent('inventory:client:SetCurrentStash', 'restauranttrash')
--                     break
--                 end
--             else
--                 break
--             end
--         end
--     end)
-- end




-- -- Garage Thread
-- local function garage()
--     CreateThread(function()
--         while true do
--             Wait(0)
--             if inGarage and PlayerJob.type == 'restaurant' then
--                 if PlayerJob.onduty then sleep = 5 end
--                 if IsPedInAnyVehicle(PlayerPedId(), false) then
--                     if IsControlJustReleased(0, 38) then
--                         QBCore.Functions.DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
--                         break
--                     end
--                 end
--             else
--                 break
--             end
--         end
--     end)
-- end

-- if Config.UseTarget then
--     CreateThread(function()
--         -- Toggle Duty
--         for k, v in pairs(Config.Locations['duty']) do
--             exports['qb-target']:AddCircleZone('RestaurantDuty_' .. k, vector3(v.x, v.y, v.z), 0.5, {
--                 name = 'RestaurantDuty_' .. k,
--                 useZ = true,
--                 debugPoly = false,
--             }, {
--                 options = {
--                     {
--                         type = 'client',
--                         event = 'qb-restaurantjob:ToggleDuty',
--                         icon = 'fas fa-sign-in-alt',
--                         label = Lang:t('target.sign_in'),
--                         jobType = 'restaurant',
--                     },
--                 },
--                 distance = 1.5
--             })
--         end

--         -- Personal Stash
--         for k, v in pairs(Config.Locations['stash']) do
--             exports['qb-target']:AddCircleZone('restaurantstash_' .. k, vector3(v.x, v.y, v.z), 1.0, {
--                 name = 'restaurantstash_' .. k,
--                 useZ = true,
--                 debugPoly = false,
--             }, {
--                 options = {
--                     {
--                         type = 'client',
--                         event = 'qb-restaurant:client:openStash',
--                         icon = 'fas fa-dungeon',
--                         label = Lang:t('target.open_personal_stash'),
--                         jobType = 'restaurant',
--                     },
--                 },
--                 distance = 1.5
--             })
--         end

--         -- Trash
--         for k, v in pairs(Config.Locations['trash']) do
--             exports['qb-target']:AddCircleZone('restauranttrash_' .. k, vector3(v.x, v.y, v.z), 0.5, {
--                 name = 'restauranttrash_' .. k,
--                 useZ = true,
--                 debugPoly = false,
--             }, {
--                 options = {
--                     {
--                         type = 'client',
--                         event = 'qb-restaurant:client:openTrash',
--                         icon = 'fas fa-trash',
--                         label = Lang:t('target.open_trash'),
--                         jobType = 'restaurant',
--                     },
--                 },
--                 distance = 1.5
--             })
--         end

--     end)
-- else
--     -- Toggle Duty
--     local dutyZones = {}
--     for _, v in pairs(Config.Locations['duty']) do
--         dutyZones[#dutyZones + 1] = BoxZone:Create(
--             vector3(vector3(v.x, v.y, v.z)), 1.75, 1, {
--                 name = 'box_zone',
--                 debugPoly = false,
--                 minZ = v.z - 1,
--                 maxZ = v.z + 1,
--             })
--     end

--     local dutyCombo = ComboZone:Create(dutyZones, { name = 'dutyCombo', debugPoly = false })
--     dutyCombo:onPlayerInOut(function(isPointInside)
--         if isPointInside then
--             dutylisten = true
--             if not PlayerJob.onduty then
--                 exports['qb-core']:DrawText(Lang:t('info.on_duty'), 'left')
--                 dutylistener()
--             else
--                 exports['qb-core']:DrawText(Lang:t('info.off_duty'), 'left')
--                 dutylistener()
--             end
--         else
--             dutylisten = false
--             exports['qb-core']:HideText()
--         end
--     end)

--     -- Personal Stash
--     local stashZones = {}
--     for _, v in pairs(Config.Locations['stash']) do
--         stashZones[#stashZones + 1] = BoxZone:Create(
--             vector3(vector3(v.x, v.y, v.z)), 1.5, 1.5, {
--                 name = 'box_zone',
--                 debugPoly = false,
--                 minZ = v.z - 1,
--                 maxZ = v.z + 1,
--             })
--     end

--     local stashCombo = ComboZone:Create(stashZones, { name = 'stashCombo', debugPoly = false })
--     stashCombo:onPlayerInOut(function(isPointInside, _, _)
--         if isPointInside then
--             inStash = true
--             if PlayerJob.type == 'restaurant' and PlayerJob.onduty then
--                 exports['qb-core']:DrawText(Lang:t('info.stash_enter'), 'left')
--                 stash()
--             end
--         else
--             inStash = false
--             exports['qb-core']:HideText()
--         end
--     end)

--     --  Trash
--     local trashZones = {}
--     for _, v in pairs(Config.Locations['trash']) do
--         trashZones[#trashZones + 1] = BoxZone:Create(
--             vector3(vector3(v.x, v.y, v.z)), 1, 1.75, {
--                 name = 'box_zone',
--                 debugPoly = false,
--                 minZ = v.z - 1,
--                 maxZ = v.z + 1,
--             })
--     end

--     local trashCombo = ComboZone:Create(trashZones, { name = 'trashCombo', debugPoly = false })
--     trashCombo:onPlayerInOut(function(isPointInside)
--         if isPointInside then
--             inTrash = true
--             if PlayerJob.type == 'restaurant' and PlayerJob.onduty then
--                 exports['qb-core']:DrawText(Lang:t('info.trash_enter'), 'left')
--                 trash()
--             end
--         else
--             inTrash = false
--             exports['qb-core']:HideText()
--         end
--     end)

-- end

-- CreateThread(function()

--     --  Garage
--     local garageZones = {}
--     for _, v in pairs(Config.Locations['vehicle']) do
--         garageZones[#garageZones + 1] = BoxZone:Create(
--             vector3(v.x, v.y, v.z), 3, 3, {
--                 name = 'box_zone',
--                 debugPoly = false,
--                 minZ = v.z - 1,
--                 maxZ = v.z + 1,
--             })
--     end

--     local garageCombo = ComboZone:Create(garageZones, { name = 'garageCombo', debugPoly = false })
--     garageCombo:onPlayerInOut(function(isPointInside, point)
--         if isPointInside then
--             inGarage = true
--             if PlayerJob.type == 'restaurant' and PlayerJob.onduty then
--                 if IsPedInAnyVehicle(PlayerPedId(), false) then
--                     exports['qb-core']:DrawText(Lang:t('info.store_veh'), 'left')
--                     garage()
--                 else
--                     local currentSelection = 0

--                     for k, v in pairs(Config.Locations['vehicle']) do
--                         if #(point - vector3(v.x, v.y, v.z)) < 4 then
--                             currentSelection = k
--                         end
--                     end
--                     exports['qb-menu']:showHeader({
--                         {
--                             header = Lang:t('menu.pol_garage'),
--                             params = {
--                                 event = 'restaurant:client:VehicleMenuHeader',
--                                 args = {
--                                     currentSelection = currentSelection,
--                                 }
--                             }
--                         }
--                     })
--                 end
--             end
--         else
--             inGarage = false
--             exports['qb-menu']:closeMenu()
--             exports['qb-core']:HideText()
--         end
--     end)
-- end)
