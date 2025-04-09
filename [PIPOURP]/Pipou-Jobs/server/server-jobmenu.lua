local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('Pipou-Jobs:server:getJobInfo', function(source, cb, job)
    local employees = {} 

    MySQL.query('SELECT charinfo, job FROM players WHERE JSON_EXTRACT(job, "$.name") = ?', {job}, function(results)
        for _, row in pairs(results) do
            local charinfo = json.decode(row.charinfo)
            local jobData = json.decode(row.job)

            table.insert(employees, {
                name = ("%s %s"):format(charinfo.firstname, charinfo.lastname),
                grade = jobData.grade,
                grade_name = jobData.grade.name or "inconnu"
            })
        end

        cb(employees)

    end)

end)

QBCore.Functions.CreateCallback('Pipou-Jobs:server:getBanqueInfo', function(source, cb, job)
    local bankaccount = 0; 

    MySQL.query('SELECT account_balance FROM bank_accounts WHERE account_name = ? AND account_type = ?', {job, "job"
    }, function(response)


        if  response[1] == nil then
            print("Erreur de réception du montant de la banque.")
            bankaccount = 'ERREUR'
        else 
            bankaccount = response[1].account_balance
        end
        
        cb (bankaccount)
    end)

end)




QBCore.Functions.CreateCallback('Pipou-Jobs:server:Fireplayer', function(source, cb, firstName, lastName, jobname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    -- Vérifier si le joueur est bien le boss
    if not Player.PlayerData.job.isboss then
        ExploitBan(src, 'FireEmployee Exploiting')
        return
    end

    -- Requête pour récupérer le citizenid
	-- AND JSON_EXTRACT(job, "$.label") = ?
    MySQL.query('SELECT citizenid FROM players WHERE JSON_EXTRACT(charinfo, "$.firstname") = ? AND JSON_EXTRACT(charinfo, "$.lastname") = ?', 
    {firstName, lastName}, function(response)
        if response[1] then
            local citizenid = response[1].citizenid
            local Employee = QBCore.Functions.GetPlayerByCitizenId(citizenid) or QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
            if Employee then
                -- Vérifier si le joueur essaie de se virer lui-même
                if citizenid == Player.PlayerData.citizenid then
                    TriggerClientEvent('QBCore:Notify', src, 'You can\'t fire yourself', 'error')
                    return
                elseif Employee.PlayerData.job.grade.level > Player.PlayerData.job.grade.level then
                    TriggerClientEvent('QBCore:Notify', src, 'You cannot fire this citizen!', 'error')
                    return
                end

                -- Modifier le job de l'employé
                if Employee.Functions.SetJob('unemployed', '0') then
                    Employee.Functions.Save()
                    TriggerClientEvent('QBCore:Notify', src, 'Employee fired!', 'success')
                    TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Job Fire', 'red', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.job.name .. ')', false)

                    if Employee.PlayerData.source then -- Si le joueur est en ligne
                        TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source, 'You have been fired! Good luck.', 'error')
                    end
                else
                    TriggerClientEvent('QBCore:Notify', src, 'Error..', 'error')
                end
            else
                TriggerClientEvent('QBCore:Notify', src, 'Employee not found.', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', src, 'No matching employee found.', 'error')
        end
    end)
end)