local banlength = nil
local developermode = false
local showCoords = false
local vehicleDevMode = false
local banreason = 'Unknown'
local kickreason = 'Unknown'
local menuLocation = 'topright' -- e.g. topright (default), topleft, bottomright, bottomleft


local function OpenMenu(title, items, callback)
    exports['PipouUI']:OpenSimpleMenu(title, items, callback)
end



RegisterNetEvent('qb-admin:client:openMenu', function()
    QBCore.Functions.TriggerCallback('qb-admin:isAdmin', function(isAdmin)
        if not isAdmin then return end

        -- Vérification que la fonction OpenSimpleMenu est définie
        if not exports['PipouUI'].OpenSimpleMenu then
            print("^1[PipouUI] OpenSimpleMenu n'est pas disponible.")
            return
        end

        -- Appeler le menu avec les actions directement dans les options
        exports['PipouUI']:OpenSimpleMenu("Menu Admin", "", {
            { 
                type = "button", 
                label = Lang:t('menu.admin_options'), 
                action = function() OpenAdminOptionsMenu() return false end 
            },
            { 
                type = "button", 
                label = Lang:t('menu.player_management'), 
                action = function() OpenPlayerListMenu() return false end 
            },
            { 
                type = "button", 
                label = Lang:t('menu.server_management'), 
                action = function() OpenServerOptionsMenu() return false end 
            },
            {
                type = "button",
                label = Lang:t('menu.vehicles'), 
                action = function() OpenVehicleMenu() return false end
            },
            {
                type = "button",
                label = Lang:t('menu.developer_options'),
                action = function() ToggleDeveloperMode() return false end
            },
        })
    end)
end)



function OpenServerOptionsMenu()
    local menuItems = {
        {
            label = Lang:t('menu.weather_options'),
            value = 'weather',
            action = function()
                OpenWeatherMenu()
                return false
            end
        },
        {
            label = Lang:t('menu.server_time'),
            value = 'time',
            action = function()
                OpenTimeMenu()
                return false
            end
        }
    }

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.server_management'), "", menuItems, "top-left")
end


function OpenWeatherMenu()
    local weathers = {
        {
            icon = '☀️',
            label = Lang:t('weather.extra_sunny'),
            action = function()
                TriggerServerEvent('qb-weathersync:server:setWeather', 'EXTRASUNNY')
                TriggerEvent('PipouUI:Notify', Lang:t('weather.weather_changed', { value = Lang:t('weather.extra_sunny') }), 'success')
                return false
            end
        },
        {
            icon = '☀️',
            label = Lang:t('weather.clear'),
            action = function()
                TriggerServerEvent('qb-weathersync:server:setWeather', 'CLEAR')
                TriggerEvent('PipouUI:Notify', Lang:t('weather.weather_changed', { value = Lang:t('weather.clear') }), 'success')
                return false
            end
        },
        {
            icon = '☀️',
            label = Lang:t('weather.neutral'),
            action = function()
                TriggerServerEvent('qb-weathersync:server:setWeather', 'NEUTRAL')
                TriggerEvent('PipouUI:Notify', Lang:t('weather.weather_changed', { value = Lang:t('weather.neutral') }), 'success')
                return false
            end
        },
        {
            icon = '🌁',
            label = Lang:t('weather.smog'),
            action = function()
                TriggerServerEvent('qb-weathersync:server:setWeather', 'SMOG')
                TriggerEvent('PipouUI:Notify', Lang:t('weather.weather_changed', { value = Lang:t('weather.smog') }), 'success')
                return false
            end
        },
        -- [... répète pour les autres types ...]
        {
            icon = '🎃',
            label = Lang:t('weather.halloween'),
            action = function()
                TriggerServerEvent('qb-weathersync:server:setWeather', 'HALLOWEEN')
                TriggerEvent('PipouUI:Notify', Lang:t('weather.weather_changed', { value = Lang:t('weather.halloween') }), 'success')
                return false
            end
        }
    }

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.weather_conditions'), "", weathers)
end


function OpenTimeMenu()
    local selectedHour = GetClockHours() or 12

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.server_time'), "", {
        {
            type = "slider",
            label = "Changer l'heure",
            data = {
                value = selectedHour,
                min = 0,
                max = 23,
                step = 1
            },
            action = function(val)
                selectedHour = val
                return false
            end
        },
        {
            label = "Confirmer",
            action = function()
                local hourStr = string.format("%02d", selectedHour or 12)
                TriggerServerEvent('qb-weathersync:server:setTime', hourStr, hourStr)
                TriggerEvent('PipouUI:Notify', Lang:t('time.changed', { time = hourStr }), 'success')
                return false
            end
        },
        {
            label = "⬅️ Retour",
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        }
    })
end





-- Admin Options Menu Buttons
local invisible = false
local godmode = false

function OpenAdminOptionsMenu()
    -- Vérification des options de menu
    local menuItems = {
        { 
            label = Lang:t('menu.noclip'), 
            value = 'noclip', 
            action = function() ToggleNoClip() return false end 
        },
        { 
            label = Lang:t('menu.revive'), 
            value = 'revive', 
            action = function() TriggerEvent('hospital:client:Revive', PlayerPedId()) return false end 
        },
        { 
            label = Lang:t('menu.invisible'), 
            value = 'invisible', 
            action = function() 
                local ped = PlayerPedId()
                invisible = not invisible
                SetEntityVisible(ped, not invisible, 0)
                if invisible then
                    TriggerEvent('PipouUI:Notify', Lang:t('menu.invisible_on'), 'success')  -- Notification pour la visibilité
                else
                    TriggerEvent('PipouUI:Notify', Lang:t('menu.invisible_off'), 'error')  -- Notification pour la visibilité
                end
            return false end
        },
        { 
            label = Lang:t('menu.god'), 
            value = 'god', 
            action = function() 
                godmode = not godmode
                SetPlayerInvincible(PlayerId(), godmode)
                if godmode then
                    TriggerEvent('PipouUI:Notify', Lang:t('menu.god_on'), 'success')  -- Notification pour Godmode
                else
                    TriggerEvent('PipouUI:Notify', Lang:t('menu.god_off'), 'error')  -- Notification pour Godmode
                end
            return false end
        },
        { 
            label = Lang:t('menu.names'), 
            value = 'names', 
            action = function() TriggerEvent('qb-admin:client:toggleNames') return false end 
        },
        { 
            label = Lang:t('menu.blips'), 
            value = 'blips', 
            action = function() TriggerEvent('qb-admin:client:toggleBlips') return false end 
        },
        { 
            label = Lang:t('menu.spawn_weapons'), 
            value = 'spawn_weapons', 
            action = function() OpenSpawnWeaponsMenu() return false end 
        },
        {
            label = "Retour",
            value = 'back',
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        }
    }

    -- Vérification de l'intégrité de `menuItems`
    if type(menuItems) ~= "table" then
        print("^1[Erreur] 'menuItems' n'est pas une table valide!")
        return
    end

    -- Appeler OpenSimpleMenu avec les options de menu
    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.admin_options'), "", menuItems, "top-left")
end




--[[
    General Functions
--]]
local function LocalInput(text, number, windows)
    AddTextEntry('FMMC_MPM_NA', text)
    DisplayOnscreenKeyboard(1, 'FMMC_MPM_NA', '', windows or '', '', '', '', number or 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end

    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return result
    end
end

local function LocalInputInt(text, number, windows)
    AddTextEntry('FMMC_MPM_NA', text)
    DisplayOnscreenKeyboard(1, 'FMMC_MPM_NA', '', windows or '', '', '', '', number or 30)
    while (UpdateOnscreenKeyboard() == 0) do
        DisableAllControlActions(0)
        Wait(0)
    end
    if (GetOnscreenKeyboardResult()) then
        local result = GetOnscreenKeyboardResult()
        return tonumber(result)
    end
end



-- Player List
function OpenPermsMenu(player)
    QBCore.Functions.TriggerCallback('qb-admin:server:getrank', function(rank)
        if not rank then return end

        local groupIndex = 1
        local groups = { 'user', 'admin', 'god' }
        local groupLabels = { 'User', 'Admin', 'God' }

        exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.permissions') .. ' - ' .. player.name, "", {
            {
                type = "slider",
                label = Lang:t('menu.set_group'),
                data = {
                    value = groupIndex,
                    min = 1,
                    max = #groups,
                    step = 1
                },
                action = function(val)
                    groupIndex = val
                    exports['PipouUI']:Notify(Lang:t('info.group_set') .. ': ' .. groupLabels[groupIndex], 'info')
                    return false
                end
            },
            {
                label = Lang:t('info.confirm'),
                action = function()
                    local selectedGroup = groups[groupIndex]
                    TriggerServerEvent('qb-admin:server:setPermissions', player.id, selectedGroup)
                    exports['PipouUI']:Notify(Lang:t('success.changed_perm') .. ': ' .. selectedGroup, 'success')
                    return false
                end
            },
            {
                label = "⬅️ Retour",
                action = function()
                    exports['PipouUI']:Back()
                    return false
                end
            }
        })
    end)
end




function OpenKickMenu(player)
    local kickReason = 'Unknown'

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.kick') .. ' ' .. player.name, {
        { label = Lang:t('info.reason'), value = 'reason' },
        { label = Lang:t('info.confirm'), value = 'kick' },
    }, function(data)
        if data.value == 'reason' then
            local input = LocalInput(Lang:t('desc.kick_reason'), 255)
            if input then
                kickReason = input
                exports['PipouUI']:Notify(Lang:t('info.reason_set') .. ': ' .. input, 'success')
            end
        elseif data.value == 'kick' then
            if kickReason ~= 'Unknown' then
                TriggerServerEvent('qb-admin:server:kick', player, kickReason)
            else
                exports['PipouUI']:Notify(Lang:t('error.missing_reason'), 'error')
            end
        end
    end)
end


function OpenBanMenu(player)
    local banReason = nil
    local banLength = nil

    local durations = {
        { label = Lang:t('time.onehour'),      value = 3600 },
        { label = Lang:t('time.sixhour'),      value = 21600 },
        { label = Lang:t('time.twelvehour'),   value = 43200 },
        { label = Lang:t('time.oneday'),       value = 86400 },
        { label = Lang:t('time.threeday'),     value = 259200 },
        { label = Lang:t('time.oneweek'),      value = 604800 },
        { label = Lang:t('time.onemonth'),     value = 2678400 },
        { label = Lang:t('time.threemonth'),   value = 8035200 },
        { label = Lang:t('time.sixmonth'),     value = 16070400 },
        { label = Lang:t('time.oneyear'),      value = 32140800 },
        { label = Lang:t('time.permanent'),    value = 99999999999 },
        { label = Lang:t('time.self'),         value = 'self' }
    }

    local function askReason()
        local input = LocalInput(Lang:t('desc.ban_reason'), 255)
        if input and input ~= '' then
            banReason = input
            exports['PipouUI']:Notify(Lang:t('info.reason_set') .. ': ' .. input, 'success')
        end
    end

    local function askLength()
        local items = {}
        for _, entry in ipairs(durations) do
            table.insert(items, { label = entry.label, value = entry.value })
        end

        exports['PipouUI']:OpenSimpleMenu(Lang:t('info.length'), items, function(choice)
            if choice.value == 'self' then
                local custom = LocalInputInt('Ban Length (seconds)', 11)
                if custom then
                    banLength = custom
                    exports['PipouUI']:Notify(Lang:t('info.length_set') .. ': ' .. tostring(custom), 'success')
                end
            else
                banLength = choice.value
                exports['PipouUI']:Notify(Lang:t('info.length_set') .. ': ' .. choice.label, 'success')
            end
        end)
    end

    local function confirmBan()
        if not banReason then
            return exports['PipouUI']:Notify(Lang:t('error.missing_reason'), 'error')
        end
        if not banLength then
            return exports['PipouUI']:Notify(Lang:t('error.invalid_reason_length_ban'), 'error')
        end

        TriggerServerEvent('qb-admin:server:ban', player, banLength, banReason)
    end

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.ban') .. ' ' .. player.name, {
        { label = Lang:t('info.reason'), value = 'reason' },
        { label = Lang:t('info.length'), value = 'length' },
        { label = Lang:t('info.confirm'), value = 'ban' },
    }, function(data)
        if data.value == 'reason' then
            askReason()
        elseif data.value == 'length' then
            askLength()
        elseif data.value == 'ban' then
            confirmBan()
        end
    end)
end



function OpenPlayerActionMenu(player)
    local items = {
        {
            icon = '💀',
            label = Lang:t('menu.kill'),
            action = function() TriggerServerEvent('qb-admin:server:kill', player) return false end
        },
        {
            icon = '🏥',
            label = Lang:t('menu.revive'),
            action = function() TriggerServerEvent('qb-admin:server:revive', player) return false end
        },
        {
            icon = '🥶',
            label = Lang:t('menu.freeze'),
            action = function() TriggerServerEvent('qb-admin:server:freeze', player) return false end
        },
        {
            icon = '👀',
            label = Lang:t('menu.spectate'),
            action = function() TriggerServerEvent('qb-admin:server:spectate', player) return false end
        },
        {
            icon = '➡️',
            label = Lang:t('info.go_to'),
            action = function() TriggerServerEvent('qb-admin:server:goto', player) return false end
        },
        {
            icon = '⬅️',
            label = Lang:t('menu.bring'),
            action = function() TriggerServerEvent('qb-admin:server:bring', player) return false end
        },
        {
            icon = '🚗',
            label = Lang:t('menu.sit_in_vehicle'),
            action = function() TriggerServerEvent('qb-admin:server:intovehicle', player) return false end
        },
        {
            icon = '🎒',
            label = Lang:t('menu.open_inv'),
            action = function() TriggerServerEvent('qb-admin:server:inventory', player) return false end
        },
        {
            icon = '👕',
            label = Lang:t('menu.give_clothing_menu'),
            action = function() TriggerServerEvent('qb-admin:server:cloth', player) return false end
        },
        {
            icon = '🥾',
            label = Lang:t('menu.kick'),
            action = function() OpenKickMenu(player) return false end
        },
        {
            icon = '🚫',
            label = Lang:t('menu.ban'),
            action = function() OpenBanMenu(player)  return false end
        },
        {
            icon = '🎟️',
            label = Lang:t('menu.permissions'),
            action = function() OpenPermsMenu(player) return false end
        },
    }

    exports['PipouUI']:OpenSimpleMenu(player.cid .. Lang:t('info.options'), "", items)
end



function OpenPlayerListMenu()
    QBCore.Functions.TriggerCallback('test:getplayers', function(players)
        if not players or #players == 0 then
            TriggerEvent('PipouUI:Notify', Lang:t('menu.no_players'), 'error')
            return
        end

        local menuItems = {}

        for _, v in pairs(players) do
            table.insert(menuItems, {
                label = ('%s%d | %s'):format(Lang:t('info.id'), v.id, v.name),
                value = v,
                action = function()
                    OpenPlayerActionMenu(v)
                    return false
                end
            })
        end

        exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.online_players'), "", menuItems, "top-left")
    end)
end





-- Set vehicle Categories
local vehicles = {}
for k, v in pairs(QBCore.Shared.Vehicles) do
    local category = v['category']
    if vehicles[category] == nil then
        vehicles[category] = {}
    end
    vehicles[category][k] = v
end

-- Car Categories
local function OpenCarModelsMenu(category)
    local items = {}

    for model, data in pairs(category) do
        table.insert(items, {
            label = data.name,
            description = '🚗 ' .. Lang:t('menu.spawn_vehicle_named', { name = data.name }),
            action = function()
                TriggerServerEvent('QBCore:CallCommand', 'car', { model })
                TriggerEvent('PipouUI:Notify', Lang:t('notif.vehicle_spawned', { name = data.name }), 'success')
                return false
            end
        })
    end

    table.insert(items, {
        label = '⬅️ Retour',
        action = function()
            exports['PipouUI']:Back()
            return false
        end
    })

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.vehicle_models'), "", items)
end


function OpenVehicleMenu()
    local items = {
        {
            label = Lang:t('menu.spawn_vehicle'),
            value = 'spawn',
            action = function()
                OpenVehicleCategoryMenu()
                return false
            end
        },
        {
            label = Lang:t('menu.fix_vehicle'),
            value = 'fix',
            action = function()
                TriggerServerEvent('QBCore:CallCommand', 'fix', {})
                return false
            end
        },
        {
            label = Lang:t('menu.buy'),
            value = 'buy',
            action = function()
                TriggerServerEvent('QBCore:CallCommand', 'admincar', {})
                return false
            end
        },
        {
            label = Lang:t('menu.remove_vehicle'),
            value = 'remove',
            action = function()
                TriggerServerEvent('QBCore:CallCommand', 'dv', {})
                return false
            end
        },
        {
            label = Lang:t('menu.max_mods'),
            value = 'maxmods',
            action = function()
                TriggerServerEvent('QBCore:CallCommand', 'maxmods', {})
                return false
            end
        }
    }

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.vehicles'), "", items, "top-left")
end



local function CopyToClipboard(dataType)
    local ped = PlayerPedId()
    if dataType == 'coords2' then
        local coords = GetEntityCoords(ped)
        local x = QBCore.Shared.Round(coords.x, 2)
        local y = QBCore.Shared.Round(coords.y, 2)
        SendNUIMessage({
            string = string.format('vector2(%s, %s)', x, y)
        })
        QBCore.Functions.Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'coords3' then
        local coords = GetEntityCoords(ped)
        local x = QBCore.Shared.Round(coords.x, 2)
        local y = QBCore.Shared.Round(coords.y, 2)
        local z = QBCore.Shared.Round(coords.z, 2)
        SendNUIMessage({
            string = string.format('vector3(%s, %s, %s)', x, y, z)
        })
        QBCore.Functions.Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'coords4' then
        local coords = GetEntityCoords(ped)
        local x = QBCore.Shared.Round(coords.x, 2)
        local y = QBCore.Shared.Round(coords.y, 2)
        local z = QBCore.Shared.Round(coords.z, 2)
        local heading = GetEntityHeading(ped)
        local h = QBCore.Shared.Round(heading, 2)
        SendNUIMessage({
            string = string.format('vector4(%s, %s, %s, %s)', x, y, z, h)
        })
        QBCore.Functions.Notify(Lang:t('success.coords_copied'), 'success')
    elseif dataType == 'heading' then
        local heading = GetEntityHeading(ped)
        local h = QBCore.Shared.Round(heading, 2)
        SendNUIMessage({
            string = h
        })
        QBCore.Functions.Notify(Lang:t('success.heading_copied'), 'success')
    elseif dataType == 'freeaimEntity' then
        local entity = GetFreeAimEntity()

        if entity then
            local entityHash = GetEntityModel(entity)
            local entityName = Entities[entityHash] or 'Unknown'
            local entityCoords = GetEntityCoords(entity)
            local entityHeading = GetEntityHeading(entity)
            local entityRotation = GetEntityRotation(entity)
            local x = QBCore.Shared.Round(entityCoords.x, 2)
            local y = QBCore.Shared.Round(entityCoords.y, 2)
            local z = QBCore.Shared.Round(entityCoords.z, 2)
            local rotX = QBCore.Shared.Round(entityRotation.x, 2)
            local rotY = QBCore.Shared.Round(entityRotation.y, 2)
            local rotZ = QBCore.Shared.Round(entityRotation.z, 2)
            local h = QBCore.Shared.Round(entityHeading, 2)
            SendNUIMessage({
                string = string.format('Model Name:\t%s\nModel Hash:\t%s\n\nHeading:\t%s\nCoords:\t\tvector3(%s, %s, %s)\nRotation:\tvector3(%s, %s, %s)', entityName, entityHash, h, x, y, z, rotX, rotY, rotZ)
            })
            QBCore.Functions.Notify(Lang:t('success.entity_copy'), 'success')
        else
            QBCore.Functions.Notify(Lang:t('error.failed_entity_copy'), 'error')
        end
    end
end

RegisterNetEvent('qb-admin:client:copyToClipboard', function(dataType)
    CopyToClipboard(dataType)
end)

local function Draw2DText(content, font, colour, scale, x, y)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(colour[1], colour[2], colour[3], 255)
    BeginTextCommandDisplayText('STRING')
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    AddTextComponentSubstringPlayerName(content)
    EndTextCommandDisplayText(x, y)
end

function ToggleShowCoordinates()
    local x = 0.4
    local y = 0.025
    showCoords = not showCoords
    CreateThread(function()
        while showCoords do
            local coords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            local c = {}
            c.x = QBCore.Shared.Round(coords.x, 2)
            c.y = QBCore.Shared.Round(coords.y, 2)
            c.z = QBCore.Shared.Round(coords.z, 2)
            heading = QBCore.Shared.Round(heading, 2)
            Wait(0)
            Draw2DText(string.format('~w~' .. Lang:t('info.ped_coords') .. '~b~ vector4(~w~%s~b~, ~w~%s~b~, ~w~%s~b~, ~w~%s~b~)', c.x, c.y, c.z, heading), 4, { 66, 182, 245 }, 0.4, x + 0.0, y + 0.0)
        end
    end)
end

local function Round(value, decimals)
    local power = 10 ^ (decimals or 0)
    return math.floor(value * power + 0.5) / power
end

function ToggleDeveloperMode()
    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.developer_options'), "", {
        {
            label = "📋 " .. Lang:t('menu.copy_vector3'),
            description = Lang:t('desc.vector3_desc'),
            action = function()
                CopyToClipboard('coords3')
                ToggleDeveloperMode()
                return false
            end
        },
        {
            label = "📋 " .. Lang:t('menu.copy_vector4'),
            description = Lang:t('desc.vector4_desc'),
            action = function()
                CopyToClipboard('coords4')
                ToggleDeveloperMode()
                return false
            end
        },
        {
            label = "📋 " .. Lang:t('menu.copy_heading'),
            description = Lang:t('desc.copy_heading_desc'),
            action = function()
                CopyToClipboard('heading')
                ToggleDeveloperMode()
                return false
            end
        },
        {
            type = 'checkbox',
            icon = '📍',
            label = Lang:t('menu.display_coords'),
            description = Lang:t('desc.display_coords_desc'),
            checked = coordsDisplay or false,
            action = function(checked)
                coordsDisplay = checked
                ToggleShowCoordinates()
                return false
            end
        },
        {
            type = 'checkbox',
            icon = '🚘',
            label = Lang:t('menu.vehicle_dev_mode'),
            description = Lang:t('desc.vehicle_dev_mode_desc'),
            checked = vehicleDevMode or false,
            action = function(checked)
                vehicleDevMode = checked
                ToggleVehicleDeveloperMode()
                return false
            end
        },
        {
            type = 'button',
            icon = '⚫',
            label = Lang:t('menu.hud_dev_mode'),
            description = Lang:t('desc.hud_dev_mode_desc'),
            checked = infoDisplay or false,
            action = function(checked)
                infoDisplay = checked
                ToggleHudDevMode()
                return false
            end
        },
        {
            type = 'checkbox',
            icon = '🎥',
            label = Lang:t('menu.noclip'),
            description = Lang:t('desc.noclip_desc'),
            checked = isNoclip or false,
            action = function(checked)
                isNoclip = checked
                ToggleNoClip()
                return false
            end
        },
        {
            label = "⬅️ Retour",
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        }
    })
end




RegisterNetEvent('qb-admin:client:ToggleCoords', function()
    ToggleShowCoordinates()
end)


local vehicleDevMode = false
local showVehicleDebug = false

function ToggleVehicleDeveloperMode()
    vehicleDevMode = not vehicleDevMode

    TriggerEvent('PipouUI:Notify',
        vehicleDevMode and Lang:t('menu.dev_mode_on') or Lang:t('menu.dev_mode_off'),
        vehicleDevMode and 'success' or 'error'
    )

    showVehicleDebug = vehicleDevMode
end

-- Ce thread tourne en permanence, mais n’affiche que si activé
CreateThread(function()
    local x, y = 0.4, 0.888

    while true do
        Wait(0)

        if showVehicleDebug then
            local ped = PlayerPedId()
            if IsPedInAnyVehicle(ped, false) then
                local vehicle = GetVehiclePedIsIn(ped, false)
                local netID = VehToNet(vehicle)
                local hash = GetEntityModel(vehicle)
                local modelName = GetLabelText(GetDisplayNameFromVehicleModel(hash))
                local eHealth = GetVehicleEngineHealth(vehicle)
                local bHealth = GetVehicleBodyHealth(vehicle)

                Draw2DText(Lang:t('info.vehicle_dev_data'), 4, { 66, 182, 245 }, 0.4, x, y)
                Draw2DText(string.format('%s~b~%s~s~ | %s~b~%s~s~', Lang:t('info.ent_id'), vehicle, Lang:t('info.net_id'), netID), 4, { 255, 255, 255 }, 0.4, x, y + 0.025)
                Draw2DText(string.format('%s~b~%s~s~ | %s~b~%s~s~', Lang:t('info.model'), modelName, Lang:t('info.hash'), hash), 4, { 255, 255, 255 }, 0.4, x, y + 0.050)
                Draw2DText(string.format('%s~b~%.2f~s~ | %s~b~%.2f~s~', Lang:t('info.eng_health'), eHealth, Lang:t('info.body_health'), bHealth), 4, { 255, 255, 255 }, 0.4, x, y + 0.075)
            end
        end
    end
end)

EntityFreeAim = false
EntityVehicleView = false
EntityObjectView = false
EntityPedView = false
EntityViewEnabled = false

function ToggleHudDevMode()
    exports['PipouUI']:OpenSimpleMenu("Menu entités", "", {
        {
            icon = '📋',
            label = "📋 Copier les informations de la visée libre),
            description = Lang:t('desc.entity_view_freeaim_copy_desc'),
            action = function()
                CopyToClipboard('freeaimEntity')
                return false
            end
        },
        {
            type = 'checkbox',
            icon = '🔫',
            label = Lang:t('menu.entity_view_freeaim'),
            description = Lang:t('desc.entity_view_freeaim_desc'),
            checked = EntityFreeAim or false,
            action = function(checked)
                EntityFreeAim = checked
                ToggleEntityFreeView()
                return false
            end
        },
        {
            type = 'checkbox',
            icon = '🚗',
            label = Lang:t('menu.entity_view_vehicles'),
            description = Lang:t('desc.entity_view_vehicles_desc'),
            checked = EntityVehicleView or false,
            action = function(checked)
                EntityVehicleView = checked
                ToggleEntityVehicleView()
                return false
            end
        },
        {
            type = 'checkbox',
            icon = '🧍‍♂️',
            label = Lang:t('menu.entity_view_peds'),
            description = Lang:t('desc.entity_view_peds_desc'),
            checked = EntityPedView or false,
            action = function(checked)
                EntityPedView = checked
                ToggleEntityPedView()
                return false
            end
        },
        {
            type = 'checkbox',
            icon = '📦',
            label = Lang:t('menu.entity_view_objects'),
            description = Lang:t('desc.entity_view_objects_desc'),
            checked = EntityObjectView or false,
            action = function(checked)
                EntityObjectView = checked
                ToggleEntityObjectView()
                return false
            end
        },
        
        {
            label = "⬅️ Retour",
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        }
    })
end




function OpenSpawnWeaponsMenu()
    local items = {}

    for _, v in pairs(QBCore.Shared.Weapons) do
        table.insert(items, {
            label = v.label,
            value = v.name,
            icon = '🎁',
            description = Lang:t('desc.spawn_weapons_desc'),
            action = function()
                TriggerServerEvent('qb-admin:giveWeapon', v.name)
                exports['PipouUI']:Notify(('Vous avez reçu un %s'):format(v.label), 'success')
                return false
            end
        })
    end

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.spawn_weapons'), "", items, "top-left")
end




function OpenVehicleCategoryMenu ()
    local elements = {}

    for k, v in pairs(vehicles) do
        table.insert(elements, {
            label = QBCore.Shared.FirstToUpper(k),
            description = Lang:t('menu.category_name'),
            action = function()
                OpenCarModelsMenu(v) -- Ouvre la liste des modèles de la catégorie sélectionnée
                return false
            end
        })
    end

    table.insert(elements, {
        label = "⬅️ Retour",
        action = function()
            exports['PipouUI']:Back()
            return false
        end
    })

    exports['PipouUI']:OpenSimpleMenu(Lang:t('menu.spawn_vehicle'), "", elements)
end
    

