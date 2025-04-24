PipouUI = {}
PipouUI.__index = PipouUI
PipouUI.menus = {}  -- Les menus seront stockés ici, indexés par leur id

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
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OPEN_MENU",
        title = self.title,
        subtitle = self.subtitle,
        options = self.options
    })
    PipouUI.currentMenu = self
end
exports('OpenMenu', function(menuId)
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
    if menu and menu.callbacks[index] then
        menu.callbacks[index]()
    end
    SetNuiFocus(false, false)
    cb({})
end)

RegisterNUICallback("closeMenu", function(_, cb)
    SetNuiFocus(false, false)
    cb({})
end)
