QBCore = exports['qb-core']:GetCoreObject()



RegisterNetEvent('qb-helicopter:client:ropedown', function()

    exports['PipouUI']:Notify("Corde déployée", "success", 1500)

    local propHash <const> = "p_cs_15m_rope_s";
    local player = PlayerPedId();
    local vehicle = GetVehiclePedIsIn(player, false);
    
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 8.0, 0.5));

    
    local rope = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
    AttachEntityToEntity(rope, vehicle,  1, -1.2, -2.0, 1.9, 0.0, -180.0, 0.0, false, true, true, false, 2, true)

    exports['qb-target']:AddTargetModel('p_cs_15m_rope_s', { -- The specified entity number
        options = { -- This is your options table, in this table all the options will be specified for the target to accept
        { -- This is the first table with options, you can make as many options inside the options table as you want
            num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
            type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
            event = "Test:Event", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
            icon = 'fa-solid fa-up-long', -- This is the icon that will display next to this trigger option
            label = 'Test', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
            targeticon = 'fa-solid fa-up-long', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
            --item = 'handcuffs', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONAL
            action = function(rope) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                TriggerEvent('qb-helicopter-getup', vehicle, rope)
            end,
            --job = 'police', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
            --gang = 'ballas', -- This is the gang, this option won't show up if the player doesn't have this gang, this can also be done with multiple gangs and grades, if you want multiple gangs you always need a grade with it: gang = {["ballas"] = 0, ["thelostmc"] = 2},
            --citizenid = 'JFD98238', -- This is the citizenid, this option won't show up if the player doesn't have this citizenid, this can also be done with multiple citizenid's, if you want multiple citizenid's there is a specific format to follow: citizenid = {["JFD98238"] = true, ["HJS29340"] = true},
        }
        },
        distance = 5.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
    })



    Wait(30000)

    DeleteEntity(rope)

end)


RegisterNetEvent('qb-helicopter-getup', function(vehicle, rope)

    if IsVehicleSeatFree(vehicle, 1) or IsVehicleSeatFree(vehicle, 2) then
        local player = PlayerPedId();
        local vehicle = vehicle;
        local rope = rope;


        local positionvehicle = GetEntityCoords(vehicle)
        local positionplayer = GetEntityCoords(player)
        local positionrope = GetEntityCoords(rope)


        local distance = GetDistanceBetweenCoords(positionplayer, positionvehicle, true)
        SetEntityInvincible(player, true)

        while distance > 1 do
            Wait(500)
            SetEntityCoords(player,positionrope.x, positionrope.y, positionplayer.z + 0.1,false,false,false,false)
            FreezeEntityPosition(player, true)
            positionplayer = GetEntityCoords(player)
            distance = GetDistanceBetweenCoords(positionplayer, positionrope, true)

        end


        SetPedIntoVehicle(player, vehicle, 1)
        FreezeEntityPosition(player, false)
    else 
        exports['PipouUI']:Notify("Toutes les places sont occupées", "error", 1500)
    end

end)



RegisterCommand('fixer', function()

    local player = PlayerPedId();
    local vehicle = GetVehiclePedIsIn(player, false);

    FreezeEntityPosition(vehicle, true)









end,false)


RegisterCommand('marion', function()

    local propHash <const> = "p_cs_15m_rope_s";
    local player = PlayerPedId();
    
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(player, 0.0, 8.0, 0.5));

    
    local rope = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
    --AttachEntityToEntity(rope, player,  1, -1.2, -2.0, 1.9, 0.0, -180.0, 0.0, false, true, false, false, 2, true)

    exports['qb-target']:AddTargetModel('p_cs_15m_rope_s', { -- The specified entity number
        options = { -- This is your options table, in this table all the options will be specified for the target to accept
        { -- This is the first table with options, you can make as many options inside the options table as you want
            num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
            type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
            event = "Test:Event", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
            icon = 'fa-solid fa-up-long', -- This is the icon that will display next to this trigger option
            label = 'Test', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
            targeticon = 'fa-solid fa-up-long', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
            --item = 'handcuffs', -- This is the item it has to check for, this option will only show up if the player has this item, this is OPTIONAL
            action = function(rope) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                TriggerEvent('qb-helicopter-getup', vehicle)
            end,
            --job = 'police', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
            --gang = 'ballas', -- This is the gang, this option won't show up if the player doesn't have this gang, this can also be done with multiple gangs and grades, if you want multiple gangs you always need a grade with it: gang = {["ballas"] = 0, ["thelostmc"] = 2},
            --citizenid = 'JFD98238', -- This is the citizenid, this option won't show up if the player doesn't have this citizenid, this can also be done with multiple citizenid's, if you want multiple citizenid's there is a specific format to follow: citizenid = {["JFD98238"] = true, ["HJS29340"] = true},
        }
        },
        distance = 5.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
    })
end,false)