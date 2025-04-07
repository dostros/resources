local QBCore = exports['qb-core']:GetCoreObject()

-- Fonction de sauvegarde des données JSON
function saveDataToJson(resourceName, filePath, data)
    local jsonData = json.encode(data)
    local success = SaveResourceFile(resourceName, filePath, jsonData, -1)
    if not success then
        print("Échec de la sauvegarde des données.")
    end
end

-- Fonction pour charger les données depuis un fichier JSON
function loadDataFromJson(resourceName, filePath)
    local content = LoadResourceFile(resourceName, filePath)
    if content then
        return json.decode(content)
    else
        print("Échec du chargement du fichier.")
        return {}
    end
end

-- Enregistrer les bûches récoltées par le joueur
RegisterNetEvent('server-d-timber-SaveLog')
AddEventHandler('server-d-timber-SaveLog', function(numberoflog)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end

    local PlayerLicense = player.PlayerData.license
    local resourceName = GetCurrentResourceName()
    local filePath = "log.json"
    
    local logdata = {
        license = PlayerLicense, 
        numberlog = numberoflog, 
    }

    local LogJson = loadDataFromJson(resourceName, filePath)
    if not LogJson then LogJson = {} end

    local found = false
    for _, item in ipairs(LogJson) do
        if item.license == PlayerLicense then
            item.numberlog = item.numberlog + numberoflog
            found = true
            break
        end
    end

    if not found then
        table.insert(LogJson, logdata)
    end

    -- Sauvegarder les données mises à jour
    saveDataToJson(resourceName, filePath, LogJson)
end)

-- Récupérer le nombre de bûches pour un joueur
QBCore.Functions.CreateCallback("server-d-timber-GetNumberOfLog", function(source, cb, license)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return cb(false) end

    local PlayerLicense = player.PlayerData.license
    local resourceName = GetCurrentResourceName()
    local filePath = "log.json"

    local LogJson = loadDataFromJson(resourceName, filePath)
    if not LogJson then LogJson = {} end

    for _, item in ipairs(LogJson) do
        if item.license == PlayerLicense then
            cb(item.numberlog)
            return
        end
    end

    cb(false)
end)

RegisterNetEvent('timber:OpenStash')
AddEventHandler('timber:OpenStash', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)


    if Player.PlayerData.job.name == "timber" then
        local data = { label = 'Timber plank Stash', maxweight = 40000, slots = 50 }
        exports['qb-inventory']:OpenInventory(src, "timberplankstash", data)
    else
        TriggerClientEvent('QBCore:Notify', src, "Vous n'êtes pas autorisé à accéder à ce coffre !", "error")
    end
end)






-- Stocker des planches dans le coffre de l'entreprise
RegisterServerEvent("qb-timber:server:storePlank")
AddEventHandler("qb-timber:server:storePlank", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then 
        print("⚠️ ERREUR : Joueur introuvable !")
        return 
    end

    -- Vérifier si le joueur est bien un bûcheron
    if Player.PlayerData.job.name ~= "timber" then
        TriggerClientEvent('QBCore:Notify', src, "Vous n'avez pas accès à ce coffre !", "error")
        print("🚫 Tentative d'accès au coffre par un joueur non-bûcheron !")
        return
    end

    local amount = 1 -- Nombre de planches à ajouter
    local stashName = "timberplankstash" -- Nom du coffre partagé de l'entreprise

    if not QBCore.Shared.Items["plank"] then
        print("⚠️ ERREUR : L'item 'plank' n'existe pas dans qb-core/shared/items.lua")
        return
    end

    -- Ajouter les planches au coffre
    local itemplank = {
        {
            name = 'plank',
            amount = 1,
            type = 'item',
            info = {},
            slot = 1
        }
    }
    
    exports['qb-inventory']:AddItem(stashName, "plank", 1, false, {}, 'add a plank to stash')

    -- Notification
    TriggerClientEvent('QBCore:Notify', src, "Vous avez ajouté "..amount.." planche(s) au coffre d'entreprise.", "success")
    print("✅ "..amount.." planche(s) ajoutée(s) au coffre : "..stashName)

end)
