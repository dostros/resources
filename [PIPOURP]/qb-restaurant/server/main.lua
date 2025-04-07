-- Variables
local PlayerStatus = {}
local Objects = {}
local QBCore = exports['qb-core']:GetCoreObject()


--TOMATES
RegisterNetEvent('qb-restaurant:server:receivetomato', function()

    local Player = QBCore.Functions.GetPlayer(tonumber(source))
    --local amount = math.random(Config.GrapeJuiceAmount.min, Config.GrapeJuiceAmount.max)
    local amount = 10
	Player.Functions.AddItem("tomato", amount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['tomato'], "add")




end)

--FARINE
RegisterNetEvent('qb-restaurant:server:receiveflour', function()

    local Player = QBCore.Functions.GetPlayer(tonumber(source))
    --local amount = math.random(Config.GrapeJuiceAmount.min, Config.GrapeJuiceAmount.max)
    local amount = 5
	Player.Functions.AddItem("flour", amount, false)
	TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['flour'], "add")

end)

--MOZZARELLA

RegisterServerEvent("qb-restaurant:server:receivemozzarella", function()

    local Player = QBCore.Functions.GetPlayer(tonumber(source))
    local amount = 5
    Player.Functions.AddItem("mozzarella", amount, false)
    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['mozzarella'], "add")

end)




QBCore.Functions.CreateCallback('qb-restaurant:server:loadIngredients', function(source, cb)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    local flour = Player.Functions.GetItemByName('flour')
    local tomato = Player.Functions.GetItemByName('tomato')
	if Player.PlayerData.items ~= nil then
        if flour ~= nil  and tomato ~= nil then
            if flour.amount >= 2 then
                if tomato.amount >= 1 then
                    Player.Functions.RemoveItem("flour", 2, false)
                    Player.Functions.RemoveItem("tomato", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['flour'], "remove")
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['tomato'], "remove")

                    Player.Functions.AddItem("pizzamargarita", 1, false)
                    TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['pizzamargarita'], "add")
                    cb(true)
                else
                    TriggerClientEvent('QBCore:Notify', source, "Il manque des tomates !", 'error')
                    cb(false)
                end
            else
                TriggerClientEvent('QBCore:Notify', source, "Il manque de la farine", 'error')
                cb(false)
            end
        else
            TriggerClientEvent('QBCore:Notify', source, "Pas les ingrédients nécessaires", 'error')
            cb(false)
        end
	else
		TriggerClientEvent('QBCore:Notify', source, "Pas les ingrédients nécessaires", "error")
        cb(false)
	end
end)

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


RegisterNetEvent('restaurant:server:spawnObject', function(type)
    
    local src = source
    local objectId = CreateObjectId()
    Objects[objectId] = type
    TriggerClientEvent('restaurant:client:spawnObject', src, objectId, type, src)
end)

RegisterNetEvent('restaurant:server:deleteObject', function(objectId)
    TriggerClientEvent('restaurant:client:removeObject', -1, objectId)
end)


QBCore.Functions.CreateCallback('qb-restaurant:GetCitizenId', function(source, cb)
    
    local ID = QBCore.Functions.GetIdentifier(player, "citizenid")
    
    return cb(ID)
end)


RegisterNetEvent('qb-restaurant:server:payorder', function()

    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local price = math.random(150, 500)
    Player.Functions.AddMoney('cash', price, "restaurant")
end)