PipouUI = {}
PipouUI.__index = PipouUI
PipouUI.menus = {}
PipouUI.navigationStack = {}
local menuCounter = 0

-- Création du menu : retourne un id (chaîne) pour identifier le menu
function PipouUI.CreateMenu(title, subtitle)
    local menu = {
        id = tostring(menuCounter),
        title = title or "Menu",
        subtitle = subtitle or "",
        options = {},
        callbacks = {}
    }
    setmetatable(menu, PipouUI)
    PipouUI.menus[menu.id] = menu
    menuCounter = menuCounter + 1
    return menu.id
end
exports('CreateMenu', PipouUI.CreateMenu)

-- Ajout d'une option au menu
function PipouUI:AddOption(optionType, label, data, callback)
    local option = {
        type = optionType or "button",
        label = label,
        data = data
    }

    -- Copier les donnés utiles à la racine (pour l'affichage dans la NUI)
    if data and optionType == "slider" then
        option.value = data.value or 0
        option.min = data.min or 0
        option.max = data.max or 10
        option.step = data.step or 1
    elseif data and optionType == "checkbox" then
        option.checked = data.checked or false
    elseif optionType == "section" then
        callback = function() end
    end

    table.insert(self.options, option)
    table.insert(self.callbacks, callback or function() end)
end



exports('AddOption', function(menuId, optionType, label, data, cb)
    local menu = PipouUI.menus[menuId]
    if menu then
        menu:AddOption(optionType, label, data, cb)
    else
        print("[ERROR] Menu non trouvé pour AddOption: " .. tostring(menuId))
    end
end)

-- Ajout d'un bouton (alias de AddOption avec le type "button")
function PipouUI:AddButton(label, callback)
    self:AddOption("button", label, nil, callback)
end
exports('AddButton', function(menuId, label, cb)
    local menu = PipouUI.menus[menuId]
    if menu then
        menu:AddButton(label, cb)
    else
        print("[ERROR] Menu non trouvé pour AddButton: " .. tostring(menuId))
    end
end)

-- Ouvrir le menu
function PipouUI:Open()
    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(true)
    SendNUIMessage({
        action = "OPEN_MENU",
        title = self.title,
        subtitle = self.subtitle,
        options = self.options
    })
    PipouUI.currentMenu = self
end
exports('OpenMenu', function(menuId)
    if PipouUI.currentMenu then
        table.insert(PipouUI.navigationStack, PipouUI.currentMenu.id)
        PipouUI:CloseMenu()
    end

    local menu = PipouUI.menus[menuId]
    if menu then
        menu:Open()
    else
        print("[ERROR] Menu non trouvé pour OpenMenu: " .. tostring(menuId))
    end
end)



-- Gestion des clics depuis la NUI
RegisterNUICallback("selectOption", function(data, cb)
    local index = data.index + 1
    local menu = PipouUI.currentMenu
    local shouldClose = true
    if menu and menu.callbacks[index] then
        local result = menu.callbacks[index]()
        if result == false then
            shouldClose = false
        end
    end

    if shouldClose then
        PipouUI:CloseMenu()
        SetNuiFocus(false, false)
    end
    

    cb({ close = shouldClose })
end)




RegisterNUICallback("closeMenu", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("sliderChange", function(data, cb)
    local index = data.index + 1
    local value = data.value
    local menu = PipouUI.currentMenu
    if menu and menu.callbacks[index] then
        menu.callbacks[index](value)
    end
    cb({})
end)


function PipouUI:CloseMenu()
    PipouUI.currentMenu = nil
end

exports('CloseMenu', function()
    PipouUI:CloseMenu()
    SetNuiFocus(false, false) 
end)


function PipouUI:OpenSimpleMenu(title, subtitle, itemList)
    local menuId = PipouUI.CreateMenu(title, subtitle)
    local menu = PipouUI.menus[menuId]
    if not menu then return end

    for _, item in ipairs(itemList) do
        local typ = item.type or "button"
        local label = item.label or "Option"
        local data = item.data or {}
        local action = item.action or function() end

        menu:AddOption(typ, label, data, action)
    end

    exports['PipouUI']:OpenMenu(menuId)
end




exports('OpenSimpleMenu', function(title, subtitle, buttonList)
    PipouUI:OpenSimpleMenu(title, subtitle, buttonList)
end)


function PipouUI:Back()
    local lastMenuId = table.remove(PipouUI.navigationStack)
    if lastMenuId then
        local menu = PipouUI.menus[lastMenuId]
        if menu then
            menu:Open()
        end
    else
        TriggerEvent("Pipou-Immo:openMainMenu")
    end
end

exports('Back', function()
    PipouUI:Back()
end)



function PipouUI:OpenInputMenu(title, subtitle, callback)
    SetNuiFocus(true, true)
    SetNuiFocusKeepInput(false)

    SendNUIMessage({
        action = "OPEN_INPUT",
        title = title,
        subtitle = subtitle
    })

    PipouUI.currentInputCallback = callback
end
exports('OpenInputMenu', function(title, subtitle, callback)
    PipouUI:OpenInputMenu(title, subtitle, callback)
end)

RegisterNUICallback("submitInput", function(data, cb)
    SetNuiFocus(false, false)

    if PipouUI.currentInputCallback then
        PipouUI.currentInputCallback(data.text)
    end

    PipouUI.currentInputCallback = nil
    cb({})
end)


function PipouUI:OpenListMenu(title, subtitle, options, callback)
    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(true)

    SendNUIMessage({
        action = "OPEN_LIST_MENU",
        title = title,
        subtitle = subtitle,
        options = options
    })

    PipouUI.currentListCallback = callback 
end
exports('OpenListMenu', function(title, subtitle, options, cb)
    PipouUI:OpenListMenu(title, subtitle, options, cb)
end)



RegisterNUICallback("selectListOption", function(data, cb)
    SetNuiFocus(false, false)

    if PipouUI.currentListCallback then
        PipouUI.currentListCallback(data.index)
    end

    PipouUI.currentListCallback = nil
    cb({})
end)


RegisterNUICallback('playSound', function(data, cb)
    if data.name == 'navigate' then
        PlaySoundFrontend(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif data.name == 'select' then
        PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif data.name == 'back' then
        PlaySoundFrontend(-1, "BACK", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    elseif data.name == 'error' then
        PlaySoundFrontend(-1, "ERROR", "HUD_FRONTEND_DEFAULT_SOUNDSET", true)
    end
    if cb then cb('ok') end
end)

function PipouUI:OpenTabbedMenu(title, subtitle, tabs)
    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(true)

    local tabData = {}

    for _, tab in ipairs(tabs) do
        local optList = {}
        for _, opt in ipairs(tab.options or {}) do
            local optCopy = {
                type = opt.type or "button",
                label = opt.label or "Option"
            }

            if opt.type == "slider" and opt.data then
                optCopy.value = opt.data.value or 0
                optCopy.min = opt.data.min or 0
                optCopy.max = opt.data.max or 10
                optCopy.step = opt.data.step or 1
            elseif opt.type == "checkbox" and opt.data then
                optCopy.checked = opt.data.checked or false
            end

            table.insert(optList, optCopy)
        end

        table.insert(tabData, {
            label = tab.label or "Onglet",
            options = optList
        })
    end

    -- On garde les callbacks pour chaque onglet à part
    PipouUI.tabbedCallbacks = tabs

    SendNUIMessage({
        action = "OPEN_TAB_MENU",
        title = title,
        subtitle = subtitle,
        tabs = tabData
    })
end

exports('OpenTabbedMenu', function(title, subtitle, tabs)
    PipouUI:OpenTabbedMenu(title, subtitle, tabs)
end)

