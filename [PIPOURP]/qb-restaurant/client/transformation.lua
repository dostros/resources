function SetDisplay(bool)
    display= bool
    
    SetNuiFocus(bool, bool)

    SendNUIMessage({
        type='ui',
        status = bool;
    })

end


-------------------------------------------------------------------------------------------


RegisterNetEvent('qb-restaurant:client:cooker:menupizza' , function()
    SetDisplay(not display)
end)

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
end)
--------------------------------------------------------------------------------------------

RegisterNUICallback('makeMargarita', function(data, cb)

    local numberitem = data.amount

    for i=1, numberitem do
    
        QBCore.Functions.TriggerCallback('qb-restaurant:server:loadIngredients', numberitem, function(result)
            if not result then 
                QBCore.Functions.Notify("Manque d'ingrédient  !!!", "error", 1500)  
                
            end
            

        end)
        break;
    end
    
    
    --local numberoffpizza = data.number
    --local timeofcooking = 10000 * numberoffpizza
    
    
    local playerPos = GetEntityCoords(PlayerPedId())
	TaskStartScenarioAtPosition(PlayerPedId(),'WORLD_HUMAN_STAND_FIRE', playerPos.x, playerPos.y, playerPos.z, GetEntityHeading(PlayerPedId()), timeofcooking, false, false)


    SetDisplay(false)
end)



RegisterNetEvent("qb-restaurant-client-traire", function(source, entity)
    
    FreezeEntityPosition(entity, true)
    local entityPos = GetEntityCoords(entity)

	TaskStartScenarioAtPosition(entity, "WORLD_COW_GRAZING", entityPos.x, entityPos.y, entityPos.z, GetEntityHeading(entity), 0, false, false)

    EMOTE('world_human_gardener_plant')
    QBCore.Functions.Progressbar('trairevache', 'Traire la Vache', 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
        }, {}, {}, {}, function()
            QBCore.Functions.Notify("4 Mozzarellas Di Buffala ramassées", "success", 1500)
            FreezeEntityPosition(PlayerPedId(), false)
            FreezeEntityPosition(entity, false)
            TriggerServerEvent("qb-restaurant:server:receivemozzarella")
            

        end, function()
            -- This code runs if the progress bar gets cancelled
    end)



end)


