QBCore = exports['qb-core']:GetCoreObject()
local isAdminMenuOpen = false

function ToggleAdminMenu()
    if isAdminMenuOpen then
        exports.PipouUI:CloseMenu()
        Wait(0)
        isAdminMenuOpen = false
        return
    end

    isAdminMenuOpen = true
    exports.PipouUI:CloseMenu()
    Wait(0)
    exports.PipouUI:OpenSimpleMenu("Menu Admin", "Options administratives", {
        {
            label = "Téléportation (coords fixes)",
            action = function()
                SetEntityCoords(PlayerPedId(), 200.0, 200.0, 200.0)
                exports.PipouUI:Notify("Téléporté avec succès !", "success")
                return false
            end
        },
        {
            label = "Téléportation (waypoint)",
            action = function()
                local blip = GetFirstBlipInfoId(8)
                if DoesBlipExist(blip) then
                    local coords = GetBlipInfoIdCoord(blip)
                    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                    exports.PipouUI:Notify("Téléporté au marqueur !", "success")
                else
                    exports.PipouUI:Notify("Aucun marqueur trouvé", "error")
                end
                return false
            end
        },
        {
            label = "Soigner",
            action = function()
                SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
                exports.PipouUI:Notify("Vous avez été soigné !", "success")
                return false
            end
        },
        {
            label = "Donner une somme personnalisée",
            action = function()
                exports.PipouUI:OpenInputMenu("Donner de l'argent", "Entrez le montant", function(input)
                    local amount = tonumber(input)
                    if amount and amount > 0 then
                        TriggerServerEvent("admin:giveMoney", amount)
                        exports.PipouUI:Notify("Argent envoyé : $" .. amount, "info")
                    else
                        exports.PipouUI:Notify("Montant invalide", "error")
                    end
                    return false
                end)
            end
        },
        {
            label = "Gestion joueurs",
            action = function()
                OpenNearbyPlayersMenu()
                return false
            end
        },
        {
            label = "Fermer le menu",
            action = function()
                isAdminMenuOpen = false
                exports.PipouUI:CloseMenu()
                Wait(0)
                return false
            end
        }
    })
end

RegisterCommand("adminmenu", ToggleAdminMenu, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if IsControlJustPressed(1, 57) then -- F10
            ToggleAdminMenu()
        end
    end
end)

function OpenPlayerActionsMenu(serverId, ped)
    exports.PipouUI:CloseMenu()
    Wait(0)
    exports.PipouUI:OpenSimpleMenu("Gestion Joueur", ("ID %d"):format(serverId), {
        {
            label = "Téléporter à ce joueur",
            action = function()
                local coords = GetEntityCoords(ped)
                SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
                exports.PipouUI:Notify("Téléporté vers le joueur !", "success")
                return false
            end
        },
        {
            label = "Téléporter le joueur à moi",
            action = function()
                local myCoords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("admin:teleportPlayer", serverId, myCoords)
                exports.PipouUI:Notify("Joueur téléporté à toi !", "success")
                return false
            end
        },
        {
            label = "Soigner ce joueur",
            action = function()
                TriggerServerEvent("admin:healPlayer", serverId)
                exports.PipouUI:Notify("Soin envoyé au joueur !", "info")
                return false
            end
        },
        {
            label = "Changer son métier",
            action = function()
                QBCore.Functions.TriggerCallback('admin:getJobs', function(jobs)
                    if not jobs or #jobs == 0 then
                        exports.PipouUI:Notify("Aucun job trouvé", "error")
                        return
                    end
        
                    local labels = {}
                    for _, job in ipairs(jobs) do
                        table.insert(labels, job.label)
                    end
        
                    exports.PipouUI:OpenListMenu("Sélection du job", "Choisis un job", labels, function(index)
                        local selected = jobs[index + 1]
                        if selected then
                            exports.PipouUI:OpenInputMenu("Grade du job", "Entrez le grade (ex: 0, 1...)", function(grade)
                                grade = tonumber(grade) or 0
                                TriggerServerEvent("admin:setJob", serverId, selected.value, grade)
                                exports.PipouUI:Notify("Job assigné : " .. selected.label .. " (grade " .. grade .. ")", "success")
                            end)
                        else
                            exports.PipouUI:Notify("Sélection invalide", "error")
                        end
                    end)
                end)
                return false
            end
        },        
        {
            label = "Freeze/Unfreeze",
            action = function()
                TriggerServerEvent("admin:toggleFreeze", serverId)
                exports.PipouUI:Notify("Action Freeze envoyée", "info")
                return false
            end
        },
        {
            label = "Retour",
            action = function()
                exports.PipouUI:Back()
                return false
            end
        }
    })
end

function OpenNearbyPlayersMenu()
    exports.PipouUI:CloseMenu()
    Wait(0)
    local players = GetActivePlayers()
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local items = {}

    -- Ajouter soi-même en premier
    local myId = GetPlayerServerId(PlayerId())
    table.insert(items, {
        label = ("Moi-même [%d]"):format(myId),
        action = function()
            OpenPlayerActionsMenu(myId, myPed)
            return false
        end
    })

    -- Ajouter les autres joueurs à proximité
    for _, player in ipairs(players) do
        local ped = GetPlayerPed(player)
        local serverId = GetPlayerServerId(player)
        if player ~= PlayerId() then
            local dist = #(GetEntityCoords(ped) - myCoords)
            if dist < 15.0 then
                table.insert(items, {
                    label = ("Joueur [%d] (%.1fm)"):format(serverId, dist),
                    action = function()
                        OpenPlayerActionsMenu(serverId, ped)
                        return false
                    end
                })
            end
        end
    end

    exports.PipouUI:OpenSimpleMenu("Joueurs proches", "Sélectionnez un joueur", items)
end


-- Réception des actions admin depuis le serveur
RegisterNetEvent("admin:teleportHere", function(coords)
    SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z)
end)

RegisterNetEvent("admin:healMe", function()
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
end)

local isFrozen = false
RegisterNetEvent("admin:toggleFrozen", function()
    isFrozen = not isFrozen
    FreezeEntityPosition(PlayerPedId(), isFrozen)
    exports.PipouUI:Notify(isFrozen and "Vous êtes gelé !" or "Vous êtes libéré", "info")
end)