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



RegisterNetEvent('Pipou-Jobs:server:Fireplayer', function(target)
	local src = source
	local Player = QBCore.Functions.GetPlayer(src)
	local Employee = QBCore.Functions.GetPlayerByCitizenId(target) or QBCore.Functions.GetOfflinePlayerByCitizenId(target)

	if not Player.PlayerData.job.isboss then
		ExploitBan(src, 'FireEmployee Exploiting')
		return
	end

	if Employee then
		if target == Player.PlayerData.citizenid then
			TriggerClientEvent('QBCore:Notify', src, 'You can\'t fire yourself', 'error')
			return
		elseif Employee.PlayerData.job.grade.level > Player.PlayerData.job.grade.level then
			TriggerClientEvent('QBCore:Notify', src, 'You cannot fire this citizen!', 'error')
			return
		end
		if Employee.Functions.SetJob('unemployed', '0') then
			Employee.Functions.Save()
			TriggerClientEvent('QBCore:Notify', src, 'Employee fired!', 'success')
			TriggerEvent('qb-log:server:CreateLog', 'bossmenu', 'Job Fire', 'red', Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname .. ' successfully fired ' .. Employee.PlayerData.charinfo.firstname .. ' ' .. Employee.PlayerData.charinfo.lastname .. ' (' .. Player.PlayerData.job.name .. ')', false)

			if Employee.PlayerData.source then -- Player is online
				TriggerClientEvent('QBCore:Notify', Employee.PlayerData.source, 'You have been fired! Good luck.', 'error')
			end
		else
			TriggerClientEvent('QBCore:Notify', src, 'Error..', 'error')
		end
	end
	TriggerClientEvent('qb-bossmenu:client:OpenMenu', src)
end)
