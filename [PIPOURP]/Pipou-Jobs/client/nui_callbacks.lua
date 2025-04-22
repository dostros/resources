local QBCore = exports['qb-core']:GetCoreObject()

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
end)

RegisterNUICallback('getJobInfo', function(data, cb)
    local playerjob = data.JobId
    local isgang = data.isgang
    

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
          
        else
            print("Aucun résultat ou erreur de réception.")
        end
    end, playerjob, isgang)
end)


RegisterNUICallback('getBanqueInfo', function(data, cb)
    local playerjob = data.JobId
    

    QBCore.Functions.TriggerCallback('Pipou-Jobs:server:getBanqueInfo', function(result)
        if result then

            SendNUIMessage({
                type='ui:banqueinfo',
                bankaccount = result,
            })
        else
            print("Aucun résultat ou erreur de réception.")
        end
    end, playerjob)
end)

RegisterNUICallback('getGradeInfo', function(data, cb)
    local playerjob = data.JobId
    local isgang = data.isgang

    print(isgang)
    local organisation =''

    if isgang then
        organisation = QBCore.Shared.Gangs[tostring(playerjob)]
    else
        organisation = QBCore.Shared.Jobs[tostring(playerjob)]
    end

    

    if organisation then
        -- Vérifier que 'grades' existe avant de commencer la boucle
        if organisation.grades then
            local grades = {}
            
            -- Itérer sur les grades d'un job
            for grade, info in pairs(organisation.grades) do
                -- Vérifier si 'name' et 'payment' existent avant de les utiliser
                local gradeName = info.name or "Nom non défini"  -- Si 'name' est nil, on utilise "Nom non défini"
                
                -- Vérifier si 'payment' existe, sinon, mettre une valeur par défaut
                local payment = info.payment or "Non défini"  -- Si 'payment' est nil, on utilise "Non défini"
                -- Ajouter à la liste des grades
                table.insert(grades, {
                    grade = grade,
                    name = gradeName,
                    payment = payment
                })
                
            end

            -- Trier les grades du plus haut au plus bas (en utilisant la clé numérique)
            table.sort(grades, function(a, b)
                return tonumber(a.grade) > tonumber(b.grade)  -- Trier du plus élevé au plus bas
            end)

            -- Envoi des informations triées au NUI
            cb({
                type = 'ui:gradeinfo',
                grades = grades,
            })
        else
            print("Aucun grade trouvé pour ce job.")
            cb({
                type = 'ui:gradeinfo',
                grades = {} -- Si aucun grade n'est trouvé, renvoyer une liste vide
            })
        end
    else
        print("Job introuvable: " .. tostring(playerjob))
        cb({
            type = 'ui:gradeinfo',
            grades = {} -- Si le job n'est pas trouvé, renvoyer une liste vide
        })
    end
end)


RegisterNUICallback('editGrade', function(data, cb)
    local jobName = data.jobName           -- ex: "police"
    local gradeId = tostring(data.gradeId) -- ex: "2", attention c’est une STRING !
    local newName = data.name              -- ex: "Lieutenant"
    local newPayment = tonumber(data.payment)



    if QBCore.Shared.Jobs[jobName] and QBCore.Shared.Jobs[jobName].grades[gradeId] then
        local grade = QBCore.Shared.Jobs[jobName].grades[gradeId]
        grade.name = newName
        grade.payment = newPayment

        print("Grade mis à jour pour le job " .. jobName .. ", Grade: " .. gradeId .. ", Nom: " .. newName .. ", Paiement: " .. newPayment)
    else
        print("Grade ou Job introuvable.")
    end

    cb({})
end)


RegisterNuiCallback('FireSomeone', function(data, cb)
    local playername = data.fullName
    local jobname = data.jobname


    local firstName, lastName = playername:match("^(%S+) (%S+)$")

    QBCore.Functions.TriggerCallback('Pipou-Jobs:server:Fireplayer', function(result)
        if result then
            QBCore.Functions.Notify("Vous avez licencié " .. playername .. " du job " .. jobname, "success")
            
        else
            print("Aucun résultat ou erreur de réception.")
        end
    end, firstName, lastName, jobname)

end)