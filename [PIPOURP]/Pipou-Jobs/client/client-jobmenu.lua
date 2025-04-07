local QBCore = exports['qb-core']:GetCoreObject()

-- OUVERTURE/FERMETURE DU MENU GARAGE
display = false

function SetDisplay(bool, joblabel, jobid)
    display= bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type='ui',
        status = bool,
        joblabel = joblabel,
        jobid = jobid,
    })

end

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
end)


RegisterCommand("bossmenu", function()
    
    SetDisplay(not display)
    
end, false)


Citizen.CreateThread(function()
    local listJobPoints = Config.BossMenu
    Citizen.Wait(1000)
    for job, jobs in pairs(listJobPoints) do
        local joblabel = jobs.label
        local jobid = job

        -- BLIP
        local BossMenuCoords = jobs.bossmenu
        local shiftpoint = jobs.shiftpoint
        local garagetakevehicle = jobs.takeVehicle
        local blipcoords = jobs.blipcoords
        local blipName = jobs.blipName
        local blipNumber = jobs.blipNumber
        local blipColor = jobs.blipColor
        local blip = AddBlipForCoord(blipcoords)
        SetBlipSprite(blip, blipNumber)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 1.2)
        SetBlipColour(blip, blipColor)
        SetBlipAsShortRange(blip, true) 
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipName)    
        EndTextCommandSetBlipName(blip)

        -- BOSS MENU
        local labelinteractionbossmenu = joblabel.." - BossMenu"


        if BossMenuCoords and type(BossMenuCoords) == "vector3" then
        
            exports['qb-target']:AddCircleZone(labelinteractionbossmenu, BossMenuCoords, 1.5, {
                name = labelinteractionbossmenu,
                useZ = true, 
                debugPoly = false,
            }, {
                options = {
                    {
                        num = 1,
                        type = "client",
                        event = "Test:Event",
                        icon = 'fas fa-example',
                        label = 'Ouvrir le Menu Patron',
                        targeticon = 'fas fa-example',
                        action = function(entity)
                            if IsPedAPlayer(entity) then return false end
                            local PlayerData = QBCore.Functions.GetPlayerData()
                            if PlayerData.job.isboss then
                                print("j'ouvre menu")
                                TriggerEvent('OpenBossMenu:event', joblabel, jobid)
                            else
                                QBCore.Functions.Notify("Vous n'êtes pas le patron de ce job.", "error")
                            end
                        end,
                        job = job,
                        drawDistance = 10.0,
                        drawColor = {255, 255, 255, 255},
                        successDrawColor = {30, 144, 255, 255},
                    }
                },
                distance = 2.5,
            })
        else
            print("^1[ERROR] BossMenuCoords invalide pour job:", joblabel)
        end
       

        -- SHIFT POINT

        local labelinteractionshiftpoint = joblabel.." - Shift Point"


        if shiftpoint and type(shiftpoint) == "vector3" then
        
            exports['qb-target']:AddCircleZone(labelinteractionshiftpoint, shiftpoint, 1.5, {
                name = labelinteractionshiftpoint,
                useZ = true, 
                debugPoly = false,
            }, {
                options = {
                    {
                        num = 1,
                        type = "client",
                        event = "Test:Event",
                        icon = 'fas fa-example',
                        label = 'Prendre son service',
                        targeticon = 'fas fa-example',
                        action = function(entity)
                            if IsPedAPlayer(entity) then return false end
                            print("je prend mon service gros")
                            TriggerEvent('TakeOrLeaveService:event')
                        end,
                        job = job,
                        drawDistance = 10.0,
                        drawColor = {255, 255, 255, 255},
                        successDrawColor = {30, 144, 255, 255},
                    }
                },
                distance = 2.5,
            })
        else
            print("^1[ERROR] BossMenuCoords invalide pour job:", joblabel)
        end


    end
end)


RegisterNetEvent('OpenBossMenu:event', function(joblabel, jobid)
    SetDisplay(not display,joblabel,jobid)
end)

RegisterNetEvent('TakeOrLeaveService:event', function()
    TriggerServerEvent('QBCore:ToggleDuty')
end)



RegisterNUICallback('getJobInfo', function(data, cb)
    local playerjob = data.JobId
    

    QBCore.Functions.TriggerCallback('Pipou-Jobs:server:getJobInfo', function(result)
        -- "result" est la table d'employés retournée depuis le serveur
        if result then

            -- Fonction de tri : du plus haut au plus bas grade
            table.sort(result, function(a, b)
                local gradeA = a.grade.level or a.grade
                local gradeB = b.grade.level or b.grade
                return gradeA > gradeB -- Tri décroissant
            end)

            SendNUIMessage({
                type='ui:jobinfo',
                listemployee = result,
                joblabel = playerjob,
            })


            -- -- Affichage après tri
            -- for _, emp in pairs(result) do
            --     -- Vérification de l'existence de 'emp.grade.level'
            --     local gradeNumber = emp.grade.level or emp.grade -- Si 'level' existe, on l'utilise, sinon on garde 'emp.grade'

            --     print(("%s | Grade %s (%s)"):format(emp.name, gradeNumber, emp.grade_name))
            -- end
        else
            print("Aucun résultat ou erreur de réception.")
        end
    end, playerjob)
end)
