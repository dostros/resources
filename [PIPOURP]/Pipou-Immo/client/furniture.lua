CreateThread(function()
    while true do
        Wait(0)
        if IsInInstance and IsControlJustReleased(0, 38) then
            openMainPropertyMenu() 
        end
    end
end)

function openMainPropertyMenu()
    local propertyName = getCurrentPlayerProperty()
    if not propertyName then return end

    QBCore.Functions.TriggerCallback("PipouImmo:server:isPropertyPublic", function(isPublic)
        local lightLabel = isLightOn and "Éteindre la lumière" or "Allumer la lumière"
        local publicLabel = isPublic and "🔒 Fermer la maison" or "🔓 Ouvrir à tous"

        exports['PipouUI']:OpenSimpleMenu("Gestion Immobilière", "", {
            {
                type = "button",
                label = lightLabel,
                action = function()
                    TriggerEvent('Pipou-Immo:toggleLight')
                    Wait(100)
                    openMainPropertyMenu()
                    return false
                end
            },
            {
                type = "button",
                label = "Clefs de la maison",
                action = function()
                    TriggerEvent('Pipou-Immo:openKeyMenu')
                    return false
                end
            },
            {
                type = "button",
                label = "Décorer la maison",
                action = function()
                    TriggerEvent('Pipou-Immo:openDecorationMenu')
                    return false
                end
            },
            {
                type = "button",
                label = publicLabel,
                action = function()
                    TriggerEvent('PipouImmo:togglePublicAccess')
                    Wait(100)
                    openMainPropertyMenu()
                    return false
                end
            },
            { type = "section", label = "🔧 Paramètres DE LAMOUR" },
            {
                type = "slider",
                label = "Luminosité",
                data = { value = 5, min = 0, max = 10, step = 1 },
                action = function(val)
                    TriggerEvent('Pipou-Immo:setLightIntensity', val)
                end
            },
            {
                type = "button",
                label = "Fermer le menu",
                action = function()
                    exports['PipouUI']:CloseMenu()
                end
            }
        })
    end, propertyName)
end


RegisterNetEvent("Pipou-Immo:openKeyMenu", function()
    
    exports['PipouUI']:OpenSimpleMenu("🔑 Gestion des clefs", "", {
        {
            type = "button",
            label = "Gestion colocataires",
            action = function()
                TriggerEvent('Pipou-Immo:showTenantList')
                return false
            end
        },
        {
            type = "button",
            label = "Ajouter un locataire",
            action = function()
                TriggerEvent('Pipou-Immo:addTenant')
                return false
            end
        },
        {
            type = "button",
            label = "Retirer un colocataire",
            action = function()
                TriggerEvent('Pipou-Immo:removeTenant')
                return false
            end
        },
        {
            type = "button",
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
            type = "button",
            label = "📦 Placer un objet",
            action = function()
                TriggerEvent('PipouImmo:openFurnitureUI')
            end
        },
        {
            type = "button",
            label = "Retour ⬅️",
            action = function()
                exports['PipouUI']:Back()
                return false
            end
        } 
    })
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
                    type = "button",
                    label = label .. " 🔒",
                    action = function()
                        QBCore.Functions.Notify("🔒 Propriétaire principal – accès protégé.", "error")
                    end
                })
            else
                table.insert(buttonList, {
                    type = "button",
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
            type = "button",
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



RegisterCommand("testonglet", function()
    exports['PipouUI']:OpenTabbedMenu("Gestion Immobilière", "Utilitaire de test", {
        {
            label = "🏠 Général",
            options = {
                { type = "section", label = "🔧 État général" },
                {
                    type = "button",
                    label = "🔄 Rafraîchir",
                    action = function() print("↻ Rafraîchissement en cours...") end
                },
                {
                    type = "checkbox",
                    label = "Activer lumière automatique",
                    data = { checked = true },
                    action = function()
                        print("✅ Lumière auto modifiée")
                    end
                }
            }
        },
        {
            label = "🎚️ Réglages",
            options = {
                { type = "section", label = "🎛️ Audio" },
                {
                    type = "slider",
                    label = "Volume général",
                    data = { value = 5, min = 0, max = 10, step = 1 },
                    action = function(val)
                        print("🔊 Volume réglé sur :", val)
                    end
                },
                {
                    type = "slider",
                    label = "Effets sonores",
                    data = { value = 7, min = 0, max = 10, step = 1 },
                    action = function(val)
                        print("🎧 Effets réglés sur :", val)
                    end
                }
            }
        },
        {
            label = "🔐 Accès",
            options = {
                {
                    type = "button",
                    label = "🔑 Gérer les clefs",
                    action = function()
                        print("Gestion des clefs ouverte")
                        -- ou TriggerEvent("Pipou-Immo:openKeyMenu")
                    end
                },
                {
                    type = "checkbox",
                    label = "Mode sécurisé",
                    data = { checked = false },
                    action = function()
                        print("🔐 Sécurité modifiée")
                    end
                }
            }
        },
        {
            label = "🧪 Débogage",
            options = {
                {
                    type = "button",
                    label = "🔍 Voir console",
                    action = function()
                        print("🖥️ Console activée")
                    end
                },
                {
                    type = "button",
                    label = "💥 Forcer erreur",
                    action = function()
                        error("Erreur volontaire pour test")
                    end
                }
            }
        }
    })
    
    
end)
