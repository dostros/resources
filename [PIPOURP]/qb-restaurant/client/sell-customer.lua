 ----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------FONCTIONS-------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------------------
--RANDOM LOCATIONS CLIENT
function getRandomCustomerLocation()
    local customerLocations = Config.Locations["customer"]
    local randomIndex = math.random(1, #customerLocations) -- Generate a random index between 1 and the number of locations
    return customerLocations[randomIndex] -- Return the location at the random index
end

--RANDOM LOCATIONS MODEL
function getRandomCustomerModel()
    local customerModels = Config.ClientModels
    local randomIndex = math.random(1, #customerModels) -- Generate a random index between 1 and the number of locations
    return customerModels[randomIndex] -- Return the location at the random index
end

--DELETE PIZZA
function deletepizza ()
    ClearPedTasksImmediately(PlayerPedId())
    DeleteObject(pizza1)
    DeleteObject(pizza2)
    DeleteObject(pizza3)
    DeleteObject(pizza4)
    DeleteObject(pizza5)
    DeleteObject(pizza6)
    DeleteObject(pizza7)
    DeleteObject(pizza8)
    DeleteObject(pizzatogive)
end
 ----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------VARIABLES-------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------------------


onmission = false
ontakepizza = false
pizzaonbox = false
numberofpizzaonbox = 0
numbertakedpizza = 0

 ----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------INTERACTIONS----------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------------------


 ----------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------EVENTS----------------------------------------------------------------
 ----------------------------------------------------------------------------------------------------------------------------

RegisterNetEvent('qb-restaurant:client:payorder', function()
    onmission = false;
    deletepizza ()
    ontakepizza = false
    pizzaonbox = false
    DeleteEntity(vehicle)
end)



RegisterNetEvent('qb-restaurant:client:takeorder', function(source)
    if not onmission then
        
        onmission = true;
        ontakepizza = true;
        numbertakedpizza = 8
        local player = PlayerPedId();
        local vehiclehash = GetHashKey("faggio")
        
        



        --CREER LE VEHICULE
        local chancetosuceed = math.random(1, 100)

        local faggiopropHash <const> = "h4_prop_h4_box_delivery_01a";
        local faggioposition = Config.Locations["faggio"][1]
        local modelvehicle = "faggio"
        
        if chancetosuceed > 95  then
            vehiclehash = GetHashKey("hakuchou2")
            modelvehicle = "hakuchou2"
        end
            

        RequestModel(vehiclehash)
        local waiting = 0
        while not HasModelLoaded(vehiclehash) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 3000 then
                print("Vehicle not found")
                break
            end
        end

        vehicule = CreateVehicle(vehiclehash, faggioposition.x, faggioposition.y, faggioposition.z, faggioposition.h, false, true)
        local prop = CreateObject(GetHashKey(faggiopropHash), x, y, z, true, true, true)

        SetVehicleNumberPlateText(vehicule, "PIZZA")
        SetVehicleHasBeenOwnedByPlayer(vehicule, true)
        SetVehicleCustominfoColour(vehicule, 156, 17, 17)
        SetVehicleCustomSecondaryColour(vehicule, 27, 65, 37)
        
        if modelvehicle =="hakuchou2" then
            AttachEntityToEntity(prop, vehicule,  21, 0.0, -0.40, 0.0, 0, 0, -89.9999924, false, false, true, false, 2, true)
        else
            AttachEntityToEntity(prop, vehicule,  21, 0.0, 0.4, -0.2, 0, 0, -89.9999924, false, false, true, false, 2, true)
        end


        
        
        
        --PRENDRE LES PIZZAS
        
        local propHash <const> = "prop_pizza_box_01";
        local player = PlayerPedId();
        local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(player, 0.0, 8.0, 0.5));

        
        ExecuteCommand('e pizzabox')
        pizza1 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        pizza2 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        pizza3 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        pizza4 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        pizza5 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        pizza6 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        pizza7 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        pizza8 = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
        
        AttachEntityToEntity(pizza1, player,  1, -0.10, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
        AttachEntityToEntity(pizza2, player,  1, -0.16, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
        AttachEntityToEntity(pizza3, player,  1, -0.22, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
        AttachEntityToEntity(pizza4, player,  1, -0.28, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
        AttachEntityToEntity(pizza5, player,  1, -0.34, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
        AttachEntityToEntity(pizza6, player,  1, -0.40, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
        AttachEntityToEntity(pizza7, player,  1, -0.46, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
        AttachEntityToEntity(pizza8, player,  1, -0.52, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)


       TriggerEvent('qb-restaurant:client:continueorder')




    else
        exports['PipouUI']:Notify("Vous avez déjà une commande", "error", 1500)
    end


end)



RegisterNetEvent('qb-restaurant:client:storepizza', function()

    if ontakepizza then

        ontakepizza = false;
        pizzaonbox = true;
        numberofpizzaonbox = numbertakedpizza
        numbertakedpizza = 0
        exports['PipouUI']:Notify("Pizza bien au chaud", "success", 1500)
        
        deletepizza ()

    else
        exports['PipouUI']:Notify("Vous n'avez pas de pizza", "error", 1500)
    end


end)



RegisterNetEvent('qb-restaurant:client:getpizza', function()

    numberofpizzaonbox = numberofpizzaonbox - 1
    numbertakedpizza = 1
    if numberofpizzaonbox == 0 then
        pizzaonbox = false
    end

    local propHash <const> = "prop_pizza_box_01";
    local player = PlayerPedId();
    local x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(player, 0.0, 8.0, 0.5));
    ExecuteCommand('e pizzabox')
    pizzatogive = CreateObject(GetHashKey(propHash), x, y, z, true, true, true)
    AttachEntityToEntity(pizzatogive, player,  1, -0.10, 0.55, 0.0, 180.0, -90.0, 0.0, false, true, false, false, 2, true)
    
    ontakepizza = true;
end)


RegisterNetEvent('qb-restaurant:deliverpizza', function()

    if ontakepizza then
        ClearPedTasksImmediately(PlayerPedId())
        DeleteObject(pizzatogive)

        exports['PipouUI']:Notify("Merci beaucoup mec voilà ta thune !", "success", 1500)
        TriggerServerEvent('qb-restaurant:server:payorder')
        RemoveBlip(blip)
        FreezeEntityPosition(customer, false)

        Wait(10000)
        DeleteEntity(customer)
        ontakepizza = false
        numbertakedpizza = 0

        if numberofpizzaonbox == 0 then
            pizzaonbox = false
            TriggerEvent('qb-restaurant:client:backtorestaurant')

        else
            TriggerEvent('qb-restaurant:client:continueorder')
        end

    else
        exports['PipouUI']:Notify("Vous n'avez pas de pizza", "error", 1500)
    
    end
end)

RegisterNetEvent('qb-restaurant:client:continueorder', function()

    --Choisir un client aléatoire
    local randomLocation = getRandomCustomerLocation()
    print(randomLocation.x)

    --Afficher le blip
    blip = AddBlipForCoord(randomLocation.x , randomLocation.y, randomLocation.z)
    SetNewWaypoint(randomLocation.x,randomLocation.y)

    SetBlipSprite(blip,143 )
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 49)
    SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Client à livrer")
    EndTextCommandSetBlipName(blip)

    --CREE LE CLIENT A LIVRER
    local randomModel = getRandomCustomerModel()
    local pedHash     = GetHashKey(randomModel)
    local citizenid = QBCore.Functions.TriggerCallback('qb-restaurant:GetCitizenId', function(result)end)

    RequestModel(pedHash)
    Citizen.CreateThread(function() 
        local waiting = 0
        while not HasModelLoaded(pedHash) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 3000 then
                print("Client pas trouvé")
                break
            end
        end

        customer = CreatePed(4, pedHash, randomLocation.x, randomLocation.y, randomLocation.z, randomLocation.w, false, true)
        FreezeEntityPosition(customer, true)
        exports['qb-target']:AddTargetEntity(customer, { 
            options = { -- This is your options table, in this table all the options will be specified for the target to accept
            { -- This is the first table with options, you can make as many options inside the options table as you want
                num = 1, -- This is the position number of your option in the list of options in the qb-target context menu (OPTIONAL)
                type = "client", -- This specifies the type of event the target has to trigger on click, this can be "client", "server", "command" or "qbcommand", this is OPTIONAL and will only work if the event is also specified
                event = "qb-restaurant:deliverpizza", -- This is the event it will trigger on click, this can be a client event, server event, command or qbcore registered command, NOTICE: Normal command can't have arguments passed through, QBCore registered ones can have arguments passed through
                icon = 'fa-solid fa-truck', -- This is the icon that will display next to this trigger option
                label = 'Donner la pizza', -- This is the label of this option which you would be able to click on to trigger everything, this has to be a string
                targeticon = 'fas fa-example', -- This is the icon of the target itself, the icon changes to this when it turns blue on this specific option, this is OPTIONAL
                -- action = function(customer) -- This is the action it has to perform, this REPLACES the event and this is OPTIONAL
                -- if IsPedAPlayer(customer) then return false end -- This will return false if the entity interacted with is a player and otherwise returns true
                -- TriggerEvent('testing:event', 'test') -- Triggers a client event called testing:event and sends the argument 'test' with it
                -- end,
                -- canInteract = function(customer, distance, data) -- This will check if you can interact with it, this won't show up if it returns false, this is OPTIONAL
                -- if IsPedAPlayer(customer) then return false end -- This will return false if the entity interacted with is a player and otherwise returns true
                -- return true
                -- end,
                job = 'restaurant', -- This is the job, this option won't show up if the player doesn't have this job, this can also be done with multiple jobs and grades, if you want multiple jobs you always need a grade with it: job = {["police"] = 0, ["ambulance"] = 2},
                citizenid = citizenid, -- This is the citizenid, this option won't show up if the player doesn't have this citizenid, this can also be done with multiple citizenid's, if you want multiple citizenid's there is a specific format to follow: citizenid = {["JFD98238"] = true, ["HJS29340"] = true},
            }
            },
            distance = 2.5, -- This is the distance for you to be at for the target to turn blue, this is in GTA units and has to be a float value
        })
    end)
end)


RegisterNetEvent('qb-restaurant:client:backtorestaurant', function()

    local restaurant = Config.Locations["vehicle"][1]

    exports['PipouUI']:Notify("Retour à la pizzeria", "success", 1500)

    --Afficher le blip
    SetNewWaypoint(restaurant.x,restaurant.y)


   TriggerEvent('qb-restaurant:client:payorder')


end)

