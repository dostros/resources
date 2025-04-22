local lastMenuData = {}

RegisterCommand("myMenu", function()
    OpenCustomMenu({
        title = "Mon Menu Test",
        options = {
            { label = "Option 1", event = "event1" },
            { label = "Option 2", client = "client:action" },
            { label = "Option 3", server = "server:doSomething" }
        }
    })
end)

local lastMenuData = {}

function OpenCustomMenu(data)
    lastMenuData = data

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OPEN_MENU",
        title = data.title or "Menu",
        options = data.options or {}
    })
end

exports("OpenMenu", OpenCustomMenu)


RegisterNUICallback("selectOption", function(data, cb)
    local option = lastMenuData.options[data.index + 1]

    if option then
        if option.event then
            TriggerEvent(option.event)
        elseif option.client then
            TriggerClientEvent(option.client)
        elseif option.server then
            TriggerServerEvent(option.server)
        end
    end

    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("closeMenu", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

