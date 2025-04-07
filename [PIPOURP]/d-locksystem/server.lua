local QBCore = exports['qb-core']:GetCoreObject()

RegisterServerEvent('d-locksystem:saveDoorData')
AddEventHandler('d-locksystem:saveDoorData', function(doorData)

    local resourceName = GetCurrentResourceName()
    local filePath = "doors.json"

    -- Charger les données existantes
    local DoorsJson = loadDataFromJson(resourceName, filePath)
    if not DoorsJson then
        DoorsJson = {}
    end

    -- Ajouter le nouvel élément
    table.insert(DoorsJson, doorData)

    -- Sauvegarder les données mises à jour
    saveDataToJson(resourceName, filePath, DoorsJson)
    TriggerClientEvent ('d-locksystem:AddANewDoor', -1,DoorsJson)
end)


RegisterNetEvent("d-locksystem:updateDoorStatus")
AddEventHandler("d-locksystem:updateDoorStatus", function(doorData)
    -- Charger les données existantes
    --print("updateDoorStatusLocally")
    local DoorsJson = loadDataFromJson("d-locksystem", "doors.json")
    if not DoorsJson then
        DoorsJson = {}
    end

    -- Mettre à jour le statut de la porte
    local found = false
    for k, v in pairs(DoorsJson) do
        if v.type == "simpledoor" then
            if v.model == doorData.model and v.coords.x == doorData.coords.x and v.coords.y == doorData.coords.y and v.coords.z == doorData.coords.z then
                v.status = doorData.status
                found = true
                break
            end
        elseif v.type == "doubledoor" then
            local isFirstDoor = (v.model == doorData.model and v.coords.x == doorData.coords.x and v.coords.y == doorData.coords.y and v.coords.z == doorData.coords.z)
            local isSecondDoor = (v.model2 == doorData.model and v.coords2.x == doorData.coords.x and v.coords2.y == doorData.coords.y and v.coords2.z == doorData.coords.z)

            if isFirstDoor or isSecondDoor then
                -- Mise à jour de la première porte
                v.status = doorData.status
                -- Mise à jour de la deuxième porte si elle existe
                if v.model2 then
                    for k2, v2 in pairs(DoorsJson) do
                        if v2.model == v.model2 then
                            v2.status = doorData.status
                            break
                        end
                    end
                end
                found = true
                break
            end
        end
    end

    -- Si la porte a été trouvée et mise à jour, sauvegarder les données
    if found then
        saveDataToJson("d-locksystem", "doors.json", DoorsJson) -- Sauvegarde les données mises à jour
        
        -- Informer tous les clients pour mettre à jour l'état des portes
        TriggerClientEvent('d-locksystem:updateDoorsState', -1, DoorsJson)
    else
        print("^1Erreur: porte non trouvée dans le JSON")
    end
end)

QBCore.Functions.CreateCallback('server-d-locksystem:GetListDoor', function(source, data)
    local resourceName = GetCurrentResourceName()
    local filePath = "doors.json"
    local DoorsJson = loadDataFromJson(resourceName, filePath)


    data (DoorsJson)

end)




-- Fonction de sauvegarde des données JSON
function saveDataToJson(resourceName, filePath, data)
    local jsonData = json.encode(data)
    local success = SaveResourceFile(resourceName, filePath, jsonData, -1)
    if success then
        --print("Données sauvegardées avec succès dans " .. filePath)
    else
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



