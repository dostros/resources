local QBCore = exports['qb-core']:GetCoreObject()
local display = false



RegisterCommand("gangmenu", function()
    SetDisplay(not display, true)
end, false)

Citizen.CreateThread(function()
    local listGangPoints = Config.GangMenu
    Citizen.Wait(1000)

    for gang, data in pairs(listGangPoints) do
        local ganglabel = data.label
        local gangid = gang
        local bossMenuCoords = data.bossmenu

        local labelInteraction = ganglabel .. " - Gang Menu"

        if bossMenuCoords and type(bossMenuCoords) == "vector3" then
            exports['qb-target']:AddCircleZone(labelInteraction, bossMenuCoords, 1.5, {
                name = labelInteraction,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        num = 1,
                        type = "client",
                        event = "OpenGangMenu:event",
                        icon = 'fas fa-skull',
                        label = 'Ouvrir le Menu Gang',
                        targeticon = 'fa-solid fa-laptop',
                        action = function(entity)
                            if IsPedAPlayer(entity) then return false end
                            local PlayerData = QBCore.Functions.GetPlayerData()
                            if PlayerData.gang and PlayerData.gang.grade and PlayerData.gang.grade.isboss then
                                TriggerEvent('OpenGangMenu:event', ganglabel, gangid)
                            else
                                exports['PipouUI']:Notify("Vous n'êtes pas le boss de ce gang.", "error")
                            end
                        end,
                        gang = gang,
                        drawDistance = 10.0,
                        drawColor = {255, 255, 255, 255},
                        successDrawColor = {255, 50, 50, 255},
                    }
                },
                distance = 2.5,
            })
        else
            print("^1[ERREUR] Coordonnées du bossmenu invalides pour le gang :", ganglabel)
        end
    end
end)

RegisterNetEvent('OpenGangMenu:event', function(ganglabel, gangid)
    SetDisplay(true, ganglabel, gangid, true)
end)


