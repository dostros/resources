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



QBCore.Functions.CreateCallback('Pipou-Jobs:server:getGradeInfo', function(source, cb, jobname)
    local gradeinfo = QBShared.Jobs[jobname]  

    for grade, info in pairs(gradeinfo) do
        print("Grade: " .. info.name .. " - Paiement: " .. info.payment)
    end
    
    cb (gradeinfo)
    
    
end)
