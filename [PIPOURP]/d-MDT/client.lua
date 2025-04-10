local QBCore = exports['qb-core']:GetCoreObject()
local json = require("json")



------------------------------------MENU----------------------------------------------------------
function SetDisplay(bool, label)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = 'ui',
        status = bool,
        label = label
    })
end

RegisterCommand("openmdt", function()
    SetDisplay(not display)
end, false)

RegisterNUICallback('exit', function(data, cb)
    SetDisplay(false)
end)

