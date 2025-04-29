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
    table.insert(self.options, {
        type = optionType or "button",
        label = label,
        data = data
    })
    table.insert(self.callbacks, callback)
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


function PipouUI:OpenSimpleMenu(title, subtitle, buttonList)
    local menuId = PipouUI.CreateMenu(title, subtitle)
    for _, v in ipairs(buttonList) do
        exports['PipouUI']:AddButton(menuId, v.label, v.action)
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

