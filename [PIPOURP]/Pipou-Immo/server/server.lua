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
    MySQL.Async.fetchAll('SELECT name, type, x, y, z, level FROM properties', {}, function(result)
        local formatted = {}

        for _, row in ipairs(result) do
            if row.x and row.y and row.z then
                table.insert(formatted, {
                    name = row.name,
                    type = row.type, 
                    coords = { x = row.x, y = row.y, z = row.z },
                    level = row.level
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
        SELECT p.citizenid, c.charinfo, po.access_type
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
