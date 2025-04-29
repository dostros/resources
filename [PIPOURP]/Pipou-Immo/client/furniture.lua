CreateThread(function()
    while true do
        Wait(0)

        if IsInInstance and IsControlJustReleased(0, 38) then
            local propertyName = getCurrentPlayerProperty()
            if not propertyName then return end
        
            QBCore.Functions.TriggerCallback("PipouImmo:server:isPropertyPublic", function(isPublic)
                exports['PipouUI']:OpenSimpleMenu("Gestion Immobilière", "", {
                    {
                        label = isLightOn and "Éteindre la lumière" or "Allumer la lumière",
                        action = function()
                            TriggerEvent('Pipou-Immo:toggleLight')
                        end
                    },
                    {
                        label = "Clefs de la maison",
                        action = function()
                            TriggerEvent('Pipou-Immo:openKeyMenu')
                            return false
                        end
                    },
                    {
                        label = "Décorer la maison",
                        action = function()
                            TriggerEvent('Pipou-Immo:openDecorationMenu')
                            return false
                        end
                    },
                    {
                        label = isPublic and "🔒 Fermer la maison" or "🔓 Ouvrir à tous",
                        action = function()
                            TriggerEvent('PipouImmo:togglePublicAccess')
                        end
                    },
                    {
                        label = "Fermer le menu",
                        action = function()
                            exports['PipouUI']:CloseMenu()
                        end
                    }
                })
            end, propertyName)
            
        end
        
    end
end)

RegisterNetEvent("Pipou-Immo:openKeyMenu", function()
    
    exports['PipouUI']:OpenSimpleMenu("🔑 Gestion des clefs", "", {
        {
            label = "Gestion colocataires",
            action = function()
                TriggerEvent('Pipou-Immo:showTenantList')
                return false
            end
        },
        {
            label = "Ajouter un locataire",
            action = function()
                TriggerEvent('Pipou-Immo:addTenant')
                return false
            end
        },
        {
            label = "Retirer un colocataire",
            action = function()
                TriggerEvent('Pipou-Immo:removeTenant')
                return false
            end
        },
        {
            label = "Retour ⬅️",
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        }        
    })
end)



RegisterNetEvent("Pipou-Immo:openDecorationMenu", function()
    exports['PipouUI']:OpenSimpleMenu("🛋️ Mode décoration", "", {
        {
            label = "📦 Placer un objet",
            action = function()
                TriggerEvent('PipouImmo:openFurnitureUI')
            end
        },
        {
            label = "Retour ⬅️",
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        } 
    })
end)




RegisterNetEvent("Pipou-Immo:reopenMainMenu", function()
    TriggerEvent("Pipou-Immo:openMainMenu")
end)

RegisterNetEvent("Pipou-Immo:openMainMenu", function()
    local propertyName = getCurrentPlayerProperty()
    if not propertyName then return end

    QBCore.Functions.TriggerCallback("PipouImmo:server:isPropertyPublic", function(isPublic)
        exports['PipouUI']:OpenSimpleMenu("Gestion Immobilière", "", {
            {
                label = isLightOn and "Éteindre la lumière" or "Allumer la lumière",
                action = function()
                    TriggerEvent('Pipou-Immo:toggleLight')
                    return false
                end
            },
            {
                label = "Clefs de la maison",
                action = function()
                    TriggerEvent('Pipou-Immo:openKeyMenu')
                    return false
                end
            },
            {
                label = "Décorer la maison",
                action = function()
                    TriggerEvent('Pipou-Immo:openDecorationMenu')
                    return false
                end
            },
            {
                label = isPublic and "🔒 Fermer la maison" or "🔓 Ouvrir à tous",
                action = function()
                    TriggerEvent('PipouImmo:togglePublicAccess')
                    return false
                end
            },
            {
                label = "Fermer le menu",
                action = function()
                    exports['PipouUI']:CloseMenu()
                end
            }
        })
    end, propertyName)
end)






----------------------------------------------------------------------------------------------------------

RegisterNetEvent("Pipou-Immo:showTenantList", function()
    local propertyName = getCurrentPlayerProperty()
    if not propertyName then
        QBCore.Functions.Notify("❌ Propriété inconnue.", "error")
        return
    end

    QBCore.Functions.TriggerCallback('PipouImmo:server:getTenants', function(tenants)
        if not tenants or #tenants == 0 then
            QBCore.Functions.Notify("Aucun colocataire trouvé.", "error")
            return
        end

        local buttonList = {}

        for _, tenant in pairs(tenants) do
            local label = tenant.name .. " (" .. tenant.access_type .. ")"
        
            if tenant.access_type == "owner" then
                table.insert(buttonList, {
                    label = label .. " 🔒",
                    action = function()
                        QBCore.Functions.Notify("🔒 Propriétaire principal – accès protégé.", "error")
                    end
                })
            else
                table.insert(buttonList, {
                    label = label,
                    action = function()
                        TriggerEvent("Pipou-Immo:confirmRemoveTenant", {
                            propertyName = propertyName,
                            citizenid = tenant.citizenid,
                            name = tenant.name
                        })
                    end
                })
            end
        end

        table.insert(buttonList, {
            label = "Retour ⬅️",
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        })

        exports['PipouUI']:OpenSimpleMenu("👥 Liste des colocataires", "", buttonList)

    end, propertyName)
end)


RegisterNetEvent("Pipou-Immo:addTenant", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestPlayer, closestDistance = -1, 999.0

    for _, player in pairs(GetActivePlayers()) do
        local target = GetPlayerPed(player)
        if target ~= playerPed then
            local dist = #(coords - GetEntityCoords(target))
            if dist < closestDistance and dist <= 3.0 then
                closestPlayer = player
                closestDistance = dist
            end
        end
    end

    if closestPlayer ~= -1 then
        local targetId = GetPlayerServerId(closestPlayer)
        local propName = getCurrentPlayerProperty() -- à toi de définir la logique

        if propName then
            QBCore.Functions.TriggerCallback('PipouImmo:server:addTenant', function(success, msg)
                QBCore.Functions.Notify(msg, success and "success" or "error")
                TriggerNetEvent("PipouImmo:refreshProperties")
            end, targetId, propName)
        else
            QBCore.Functions.Notify("❌ Propriété inconnue.", "error")
        end
    else
        QBCore.Functions.Notify("❌ Aucun joueur proche.", "error")
    end
end)

RegisterNetEvent("Pipou-Immo:removeTenant", function()
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local closestPlayer, closestDistance = -1, 999.0

    for _, player in pairs(GetActivePlayers()) do
        local target = GetPlayerPed(player)
        if target ~= playerPed then
            local dist = #(coords - GetEntityCoords(target))
            if dist < closestDistance and dist <= 3.0 then
                closestPlayer = player
                closestDistance = dist
            end
        end
    end

    if closestPlayer ~= -1 then
        local targetId = GetPlayerServerId(closestPlayer)
        local propName = getCurrentPlayerProperty() -- 🔧 À implémenter selon ton contexte

        if propName then
            QBCore.Functions.TriggerCallback('PipouImmo:server:removeTenant', function(success, msg)
                QBCore.Functions.Notify(msg, success and "success" or "error")
                TriggerNetEvent("PipouImmo:refreshProperties")
            end, targetId, propName)
        else
            QBCore.Functions.Notify("❌ Propriété inconnue.", "error")
        end
    else
        QBCore.Functions.Notify("❌ Aucun joueur proche.", "error")
    end
end)