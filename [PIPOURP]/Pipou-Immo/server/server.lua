local QBCore = exports['qb-core']:GetCoreObject()

-- 📥 Sauvegarde d'une propriété
QBCore.Functions.CreateCallback('PipouImmo:server:saveProperty', function(source, cb, propertyName, propertyType, level, Housecoords, Garagecoords, GarageOut)
    MySQL.Async.execute('INSERT INTO properties (name, type, level, x, y, z, garage_x, garage_y, garage_z, out_x, out_y, out_z) VALUES (@name, @type, @level, @x, @y, @z, @gx, @gy, @gz, @ox, @oy, @oz)', {
        ['@name'] = propertyName,
        ['@type'] = propertyType,
        ['@level'] = level,
        ['@x'] = Housecoords.x,
        ['@y'] = Housecoords.y,
        ['@z'] = Housecoords.z,
        ['@gx'] = Garagecoords and Garagecoords.x or 0.0,
        ['@gy'] = Garagecoords and Garagecoords.y or 0.0,
        ['@gz'] = Garagecoords and Garagecoords.z or 0.0,
        ['@ox'] = GarageOut and GarageOut.x or 0.0,
        ['@oy'] = GarageOut and GarageOut.y or 0.0,
        ['@oz'] = GarageOut and GarageOut.z or 0.0,
    }, function(affectedRows)
        if affectedRows and affectedRows > 0 then
            print("✅ Propriété sauvegardée avec succès.")
            cb(true)
        else
            print("❌ Erreur lors de la sauvegarde de la propriété.")
            cb(false)
        end
    end)
end)

-- 🎁 Attribution d'une propriété à un joueur
QBCore.Functions.CreateCallback('PipouImmo:server:assignProperty', function(source, cb, targetId, propertyName)
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        cb(false, "Joueur introuvable.")
        return
    end

    local citizenid = targetPlayer.PlayerData.citizenid

    MySQL.Async.fetchAll('SELECT id FROM properties WHERE name = @name', {
        ['@name'] = propertyName
    }, function(result)
        if result and result[1] then
            local propertyId = result[1].id

            MySQL.Async.execute('INSERT IGNORE INTO property_owners (property_id, citizenid) VALUES (@propertyId, @citizenid)', {
                ['@propertyId'] = propertyId,
                ['@citizenid'] = citizenid
            }, function(rowsChanged)
                if rowsChanged and rowsChanged > 0 then
                    cb(true, "Propriété assignée à " .. targetPlayer.PlayerData.charinfo.firstname)
                    TriggerClientEvent('PipouImmo:client:addHouseEntryPoint', targetId, propertyName)
                    TriggerClientEvent('PipouImmo:client:RefreshGarages', targetId)

                else
                    cb(false, "Cette personne possède déjà cette propriété.")
                end
            end)
        else
            cb(false, "Propriété introuvable.")
        end
    end)
end)

QBCore.Functions.CreateCallback('PipouImmo:server:checkPropertyAccess', function(source, cb, propertyName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        cb(false)
        return
    end

    local citizenid = Player.PlayerData.citizenid

    MySQL.Async.fetchAll('SELECT * FROM properties WHERE name = @name', {
        ['@name'] = propertyName
    }, function(propertyResult)
        if not propertyResult or not propertyResult[1] then
            cb(false)
            return
        end

        local property = propertyResult[1]

        MySQL.Async.fetchAll('SELECT * FROM property_owners WHERE property_id = @propertyId AND citizenid = @citizenid', {
            ['@propertyId'] = property.id,
            ['@citizenid'] = citizenid
        }, function(ownerResult)
            if ownerResult and ownerResult[1] then
                local accessType = ownerResult[1].access_type or "unknown"
                cb(true, {
                    x = property.x,
                    y = property.y,
                    z = property.z
                }, property.level, accessType)
            else
                cb(false)
            end
        end)
    end)
end)


QBCore.Functions.CreateCallback('PipouImmo:server:getAllProperties', function(source, cb)
    MySQL.Async.fetchAll('SELECT name, type, x, y, z, garage_x, garage_y, garage_z, out_x, out_y, out_z, level FROM properties', {}, function(result)
        local formatted = {}

        for _, row in ipairs(result) do
            if row.x and row.y and row.z then
                table.insert(formatted, {
                    name = row.name,
                    type = row.type, 
                    coords = { x = row.x, y = row.y, z = row.z },
                    level = row.level,
                    garagecoords = (row.garage_x and row.garage_y and row.garage_z) and {
                        x = row.garage_x,
                        y = row.garage_y,
                        z = row.garage_z
                    } or nil,
                    garageout = (row.out_x and row.out_y and row.out_z) and {
                        x = row.out_x,
                        y = row.out_y,
                        z = row.out_z
                    } or nil
                })
            else
                print(("❌ Erreur : Coordonnées invalides pour la propriété '%s'"):format(row.name))
            end
        end

        cb(formatted)
    end)
end)


QBCore.Functions.CreateCallback('PipouImmo:server:getPropertyAtCoords', function(source, cb, coords)
    MySQL.Async.fetchAll('SELECT * FROM properties', {}, function(properties)
        for _, prop in ipairs(properties) do
            if #(vector3(prop.x, prop.y, -100 - (prop.level * 50)) - vector3(coords.x, coords.y, coords.z)) < 5.0 then
                cb({
                    type = prop.type,
                    level = prop.level,
                    entrance = vector3(prop.x, prop.y, prop.z)
                })
                return
            end
        end
        cb(nil)
    end)
end)

QBCore.Functions.CreateCallback('PipouImmo:server:addTenant', function(source, cb, targetId, propertyName)
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)
    if not targetPlayer then
        cb(false, "Joueur introuvable.")
        return
    end

    local citizenid = targetPlayer.PlayerData.citizenid

    MySQL.Async.fetchAll('SELECT id FROM properties WHERE name = @name', {
        ['@name'] = propertyName
    }, function(result)
        if result and result[1] then
            local propertyId = result[1].id

            MySQL.Async.execute('INSERT IGNORE INTO property_owners (property_id, citizenid, access_type) VALUES (@propertyId, @citizenid, "tenant")', {
                ['@propertyId'] = propertyId,
                ['@citizenid'] = citizenid
            }, function(rowsChanged)
                if rowsChanged and rowsChanged > 0 then
                    cb(true, "Locataire ajouté avec succès.")
                    TriggerClientEvent('PipouImmo:client:addHouseEntryPoint', targetId, propertyName)
                else
                    cb(false, "Ce joueur a déjà un accès.")
                end
            end)
        else
            cb(false, "Propriété introuvable.")
        end
    end)
end)

QBCore.Functions.CreateCallback('PipouImmo:server:removeTenant', function(source, cb, targetId, propertyName)
    local src = source
    local srcPlayer = QBCore.Functions.GetPlayer(src)
    local targetPlayer = QBCore.Functions.GetPlayer(targetId)

    if not srcPlayer or not targetPlayer then
        cb(false, "Joueur introuvable.")
        return
    end

    local citizenid = targetPlayer.PlayerData.citizenid

    MySQL.Async.fetchAll('SELECT id FROM properties WHERE name = @name', {
        ['@name'] = propertyName
    }, function(result)
        if result and result[1] then
            local propertyId = result[1].id

            MySQL.Async.execute('DELETE FROM property_owners WHERE property_id = @propertyId AND citizenid = @citizenid', {
                ['@propertyId'] = propertyId,
                ['@citizenid'] = citizenid
            }, function(affectedRows)
                if affectedRows and affectedRows > 0 then
                    cb(true, "⛔ Accès retiré.")
                else
                    cb(false, "Ce joueur n'avait pas d'accès.")
                end
            end)
        else
            cb(false, "Propriété introuvable.")
        end
    end)
end)

QBCore.Functions.CreateCallback('PipouImmo:server:getTenants', function(source, cb, propertyName)
    MySQL.Async.fetchAll([[
        SELECT po.citizenid, c.charinfo, po.access_type
        FROM property_owners po
        JOIN players c ON po.citizenid = c.citizenid
        JOIN properties p ON p.id = po.property_id
        WHERE p.name = @name
    ]], {
        ['@name'] = propertyName
    }, function(result)
        local tenants = {}
        for _, row in pairs(result) do
            local charinfo = json.decode(row.charinfo)
            table.insert(tenants, {
                citizenid = row.citizenid,
                name = charinfo.firstname .. " " .. charinfo.lastname,
                access_type = row.access_type
            })
        end
        cb(tenants)
    end)
end)

RegisterNetEvent('PipouImmo:server:removeTenantByCitizenId', function(propertyName, targetCitizenId)
    local src = source

    MySQL.Async.fetchAll('SELECT id FROM properties WHERE name = @name', {
        ['@name'] = propertyName
    }, function(result)
        if result and result[1] then
            local propertyId = result[1].id

            MySQL.Async.execute('DELETE FROM property_owners WHERE property_id = @pid AND citizenid = @cid', {
                ['@pid'] = propertyId,
                ['@cid'] = targetCitizenId
            }, function()
                TriggerClientEvent("QBCore:Notify", src, "❌ Colocataire retiré.", "success")
            end)
        end
    end)
end)


RegisterNetEvent("PipouImmo:server:getPlayerProperties", function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if not Player then
        print("❌ Impossible de récupérer le joueur avec source: " .. tostring(src))
        return
    end

    local citizenid = Player.PlayerData.citizenid

    MySQL.Async.fetchAll([[
        SELECT p.name
        FROM property_owners po
        JOIN properties p ON po.property_id = p.id
        WHERE po.citizenid = @citizenid AND po.access_type = 'owner'
    ]], {
        ['@citizenid'] = citizenid
    }, function(result)
        local ownedProps = {}
        for _, row in ipairs(result) do
            table.insert(ownedProps, row.name)
        end
        TriggerClientEvent("PipouImmo:client:setPlayerProperties", src, ownedProps)
    end)
end)




QBCore.Functions.CreateCallback('PipouImmo:server:getAllPropertiesWithID', function(source, cb)
    MySQL.Async.fetchAll([[
        SELECT 
            p.id, 
            p.name, 
            p.type, 
            p.level,
            JSON_UNQUOTE(JSON_EXTRACT(pl.charinfo, '$.firstname')) AS firstname,
            JSON_UNQUOTE(JSON_EXTRACT(pl.charinfo, '$.lastname')) AS lastname
        FROM properties p
        LEFT JOIN property_owners po ON po.property_id = p.id AND po.access_type = 'owner'
        LEFT JOIN players pl ON po.citizenid = pl.citizenid
    ]], {}, function(results)
        local props = {}

        for _, row in ipairs(results) do
            table.insert(props, {
                id = row.id,
                name = row.name,
                type = row.type,
                level = row.level,
                owner_name = (row.firstname and row.lastname) and (row.firstname .. " " .. row.lastname) or nil
            })
        end

        cb(props)
    end)
end)


RegisterNetEvent("PipouImmo:server:deleteProperty")
AddEventHandler("PipouImmo:server:deleteProperty", function(propertyId)
    MySQL.Async.execute('DELETE FROM property_owners WHERE property_id = @id', {
        ['@id'] = propertyId
    }, function()
        MySQL.Async.execute('DELETE FROM properties WHERE id = @id', {
            ['@id'] = propertyId
        }, function(affectedRows)
            print("[IMMO] Propriété supprimée : ID " .. propertyId)
            TriggerClientEvent("PipouImmo:client:notifyPropertyDeleted", src, success)
        end)
    end)
end)


RegisterNetEvent("PipouImmo:server:assignPropertyToPlayerId")
AddEventHandler("PipouImmo:server:assignPropertyToPlayerId", function(propertyId, targetId)
    local targetPlayer = QBCore.Functions.GetPlayer(tonumber(targetId))
    if targetPlayer then
        local citizenid = targetPlayer.PlayerData.citizenid

        -- Supprimer ancien propriétaire s'il existe
        MySQL.Async.execute('DELETE FROM property_owners WHERE property_id = @pid AND access_type = "owner"', {
            ['@pid'] = propertyId
        }, function()
            -- Ajouter le nouveau propriétaire
            MySQL.Async.execute('INSERT INTO property_owners (property_id, citizenid, access_type) VALUES (@pid, @cid, "owner")', {
                ['@pid'] = propertyId,
                ['@cid'] = citizenid
            }, function(rows)
                if rows > 0 then
                    TriggerClientEvent('QBCore:Notify', src, "✅ Propriété assignée.", "success")
                    TriggerClientEvent('PipouImmo:client:addHouseEntryPoint', targetId, propertyId)
                else
                    TriggerClientEvent('QBCore:Notify', source, "❌ Attribution échouée", "error")
                end
            end)
        end)

    else
        TriggerClientEvent('QBCore:Notify', source, "❌ Joueur introuvable.", "error")
    end
end)
