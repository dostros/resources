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
