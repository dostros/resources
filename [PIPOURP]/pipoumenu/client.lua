


function SetDisplay(bool)
    display= bool
    SetNuiFocus(bool, bool)

    SendNUIMessage({
        type='ui',
        status = bool;
    })

end


RegisterKeyMapping("openAdminMenu", "Open Admin Menu", 'keyboard', 'F10')

RegisterCommand("openAdminMenu", function()
    SetDisplay(not display)
end)



RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
    liveryindex = 0;
end)

RegisterNUICallback('getjob', function(data, cb)
    local job = data.job
    local grade = data.grade
    local serverid = GetPlayerServerId(PlayerId())
    print(GetPlayerServerId(PlayerId()))
    ExecuteCommand("setjob "..serverid.." "..job.." "..grade)
end)

local liveryindex = 0


RegisterNUICallback('change_livery_vehicle', function(data, cb)
    
    
    local actualvehicle = GetPlayersLastVehicle()
    liveryindex = data.numbersticker
    
    SetVehicleLivery(actualvehicle, liveryindex)

    print("you did it")


end)


RegisterNUICallback('getJobList', function(data, cb)
    
    local QBCore = exports['qb-core']:GetCoreObject()
    local listJob = QBCore.Shared.Jobs

    local joblist = {}
    
    for jobName, jobData in pairs(listJob) do
        SendNUIMessage({
            type='joblistmenucreate',
            name = jobName,
            label = jobData.label,
            grade = jobData.grades
        })
    end
    
end)