--[[ ======================= ]]--
--         MENUS            --
--[[ ======================= ]]--

PipouUI = {}
PipouUI.__index = PipouUI
PipouUI.menus = {}
PipouUI.navigationStack = {}
local menuCounter = 0

-- Création du menu : retourne un id (chaîne) pour identifier le menu
function PipouUI.CreateMenu(title, subtitle, ttl, position, blockMovement)
    local menu = {
        id = tostring(menuCounter),
        title = title or "Menu",
        subtitle = subtitle or "",
        position = position or "menu-top-right", -- 👈 ici
        options = {},
        callbacks = {},
        expireAt = ttl and (GetGameTimer() + ttl) or nil,
        blockMovement = blockMovement or false
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

    if data and optionType == "slider" then
        option.value = data.value or 0
        option.min = data.min or 0
        option.max = data.max or 10
        option.step = data.step or 1
    elseif data and optionType == "checkbox" then
        option.checked = data.checked or false
    elseif optionType == "section" then
        callback = function() end
    elseif data and optionType == "clothslider" then
        option.drawable = data.drawable or 0
        option.texture = data.texture or 0
        option.drawableMin = data.drawableMin or 0
        option.drawableMax = data.drawableMax or 10
        option.textureMax = data.textureMax or 10
        option.data = nil
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
    SetNuiFocus(true, not self.blockMovement)
    SetNuiFocusKeepInput(not self.blockMovement)
    SendNUIMessage({
        action = "OPEN_MENU",
        title = self.title,
        subtitle = self.subtitle,
        options = self.options,
        position = self.position
    })
    PipouUI.currentMenu = self
end

exports('OpenMenu', function(menuId)
    if PipouUI.currentMenu then
        if #PipouUI.navigationStack == 0 or PipouUI.navigationStack[#PipouUI.navigationStack] ~= PipouUI.currentMenu.id then
            table.insert(PipouUI.navigationStack, PipouUI.currentMenu.id)
        end
        PipouUI:CloseMenu(false, true)
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

    if not menu or not menu.callbacks or not menu.callbacks[index] then
        print("[PipouUI] Option invalide ou menu déjà fermé. Ignoré.")
        cb({ close = true })
        return
    end

    local shouldClose = true
    local success, result = pcall(menu.callbacks[index])

    if not success then
        print("[PipouUI] Erreur dans le callback du menu:", result)
    elseif result == false then
        shouldClose = false
    end

    if shouldClose then
        PipouUI:CloseMenu()
        SetNuiFocus(false, false)
    end

    cb({ close = shouldClose })
end)




RegisterNUICallback("closeMenu", function(_, cb)
    PipouUI:CloseMenu()
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

RegisterNUICallback("clothsliderChange", function(data, cb)
    local index = data.index + 1
    local drawable = data.drawable
    local texture = data.texture
    local menu = PipouUI.currentMenu
    if menu and menu.callbacks[index] then
        menu.callbacks[index](drawable, texture)
    end
    cb({})
end)



function PipouUI:CloseMenu(destroyAfterClose, suppressNUI)
    if PipouUI.currentMenu then
        if destroyAfterClose then
            PipouUI.menus[PipouUI.currentMenu.id] = nil
        end

        if not suppressNUI then
            SendNUIMessage({ action = "CLOSE_MENU" })
        end

        PipouUI.currentMenu = nil
    end
end



exports('CloseMenu', function(destroyAfterClose)
    PipouUI:CloseMenu(destroyAfterClose)
    SetNuiFocus(false, false) 
end)




function PipouUI:OpenSimpleMenu(title, subtitle, itemList, position, onSelect)
    local menuId = PipouUI.CreateMenu(title, subtitle, nil, position)
    local menu = PipouUI.menus[menuId]
    if not menu then return end

    -- Ajout de la vérification de `onSelect`
    if onSelect and type(onSelect) ~= "function" then
        print("^1[Erreur] 'onSelect' n'est pas une fonction valide!")
        onSelect = nil -- On désactive onSelect s'il n'est pas valide
    end

    for _, item in ipairs(itemList) do
        local typ = item.type or "button"
        local label = item.label or "Option"
        local data = item.data or {}
        local action = item.action or function()
            if onSelect then
                onSelect(item)
            else
                print("^1[Erreur] Aucune action définie pour l'option.")
            end
        end

        menu:AddOption(typ, label, data, action)
    end

    exports['PipouUI']:OpenMenu(menuId)
end





exports('OpenSimpleMenu', function(title, subtitle, buttonList, position, onSelect)
    if PipouUI and PipouUI.OpenSimpleMenu then
        PipouUI.OpenSimpleMenu(PipouUI, title, subtitle, buttonList, position, onSelect)
    else
        print("^1[PipouUI] Erreur : OpenSimpleMenu non trouvé ou PipouUI non défini.^7")
    end
end)




function PipouUI:Back()
    local lastMenuId = table.remove(PipouUI.navigationStack)
    if lastMenuId then
        local menu = PipouUI.menus[lastMenuId]
        if menu and PipouUI.currentMenu ~= menu then
            if PipouUI.currentMenu and PipouUI.currentMenu.temp then
                PipouUI.menus[PipouUI.currentMenu.id] = nil
            end
            PipouUI.currentMenu = nil
            menu:Open()
        end
    else
        PipouUI:CloseMenu()
        SetNuiFocus(false, false)
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

function PipouUI:OpenTabbedMenu(title, subtitle, tabs, blockMovement)
    SetNuiFocus(true, true)              
    SetNuiFocusKeepInput(not blockMovement) 
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
            elseif opt.type == "clothslider" then
                optCopy.drawable = opt.drawable or 0
                optCopy.texture = opt.texture or 0
                optCopy.drawableMin = opt.drawableMin or 0
                optCopy.drawableMax = opt.drawableMax or 10
                optCopy.textureMax = opt.textureMax or 10
            end
    
            table.insert(optList, optCopy)
        end
    
        table.insert(tabData, {
            label = tab.label or "Onglet",
            options = optList
        })
    end
    

    -- Stockage du menu courant
    local tabMenu = {
        id = "tab_" .. tostring(GetGameTimer()),
        title = title,
        subtitle = subtitle,
        options = {},
        callbacks = {},
        position = "menu-top-right",
        blockMovement = blockMovement or false
    }
    setmetatable(tabMenu, PipouUI)
    PipouUI.currentMenu = tabMenu

    PipouUI.tabbedCallbacks = tabs

    SendNUIMessage({
        action = "OPEN_TAB_MENU",
        title = title,
        subtitle = subtitle,
        tabs = tabData,
        position = "menu-top-right",
        blockMovement = blockMovement
    })
end

exports('OpenTabbedMenu', function(title, subtitle, tabs, blockMovement)
    PipouUI:OpenTabbedMenu(title, subtitle, tabs, blockMovement)
end)



function PipouUI.DestroyMenu(menuId)
    if PipouUI.menus[menuId] then
        PipouUI.menus[menuId] = nil
    end
end

exports('DestroyMenu', function(menuId)
    PipouUI.DestroyMenu(menuId)
end)


function PipouUI:OpenConfirmDialog(message, callback)
    local id = "confirm_dialog_" .. math.random(1000, 9999)

    local items = {
        {
            label = "✅ Oui",
            action = function()
                callback(true)
            end
        },
        {
            label = "❌ Non",
            action = function()
                callback(false)
            end
        }
    }

    PipouUI:OpenSimpleMenu(
        message,      -- title
        nil,          -- subtitle
        items,        -- items
        nil           -- position (facultatif)
    )
end

-- Export pour l’utiliser depuis d’autres scripts
exports('OpenConfirmDialog', function(message, callback)
    PipouUI:OpenConfirmDialog(message, callback)
end)


CreateThread(function()
    while true do
        Wait(30000) -- toutes les 30 secondes
        local now = GetGameTimer()
        for id, menu in pairs(PipouUI.menus) do
            if menu.expireAt and now > menu.expireAt then
                PipouUI.menus[id] = nil
                print("[PipouUI] Menu supprimé (expiré) : " .. id)
            end
        end
    end
end)


CreateThread(function()
    while true do
        Wait(0)
        if IsControlJustReleased(0, 177) then -- Backspace
            if exports['PipouUI']:IsMenuOpen() then
                exports['PipouUI']:Back()
            end
        end
    end
end)


function PipouUI:IsMenuOpen()
    return PipouUI.currentMenu ~= nil
end

exports('IsMenuOpen', function()
    return PipouUI:IsMenuOpen()
end)


RegisterNUICallback("pipou_back", function(_, cb)
    PipouUI:Back()
    cb({})
end)

function PipouUI:FlushMenus()
    PipouUI.menus = {}
    PipouUI.navigationStack = {}
    PipouUI.currentMenu = nil
end

exports('FlushMenus', function()
    PipouUI:FlushMenus()
end)

RegisterNUICallback("SetInputFocus", function(data, cb)
    local focus = data.focus
    SetNuiFocus(true, not focus) -- Si on tape, désactiver le jeu
    cb({})
end)

RegisterNUICallback("setKeyboardFocus", function(data, cb)
    local keepInput = data.keepInput
    SetNuiFocus(true, not not keepInput) -- pour éviter nil
    SetNuiFocusKeepInput(keepInput)
    cb({})
end)

function PipouUI:UpdateSlider(index, value, max)
    SendNUIMessage({
        action = "sliderChange",
        index = index,
        value = value,
        max = max
    })
end

exports('UpdateSlider', function(index, value, max)
    PipouUI:UpdateSlider(index, value, max)
end)


CreateThread(function()
    while true do
        Wait(0)
        if PipouUI.currentMenu and PipouUI.currentMenu.blockMovement then
            DisableControlAction(0, 1, true)   -- Look left/right
            DisableControlAction(0, 2, true)   -- Look up/down
            DisableControlAction(0, 30, true)  -- Move left/right
            DisableControlAction(0, 31, true)  -- Move forward/back
            DisableControlAction(0, 21, true)  -- Sprint
            DisableControlAction(0, 22, true)  -- Jump
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 45, true)  -- Reload
            DisableControlAction(0, 44, true)  -- Cover
            DisableControlAction(0, 37, true)  -- Weapon wheel
        end
    end
end)





--------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--[[ ======================= ]]--
--        NOTIFICATIONS      --
--[[ ======================= ]]--

--                            NOTIFY
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function PipouUI:Notify(message, type, duration)
    SendNUIMessage({
        action = "SHOW_NOTIFICATION",
        message = message,
        type = type or "info", -- 'success', 'error', 'info'
        duration = duration or 3000
    })
end

exports('Notify', function(message, type, duration)
    PipouUI:Notify(message, type, duration)
end)



--------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--[[ ======================= ]]--
--        PROGRESSBAR        --
--[[ ======================= ]]--

--                            PROGRESSBAR
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------


function PipouUI:ProgressBar(text, duration, cb, allowCancel)
    SetNuiFocus(true, false)
    SetNuiFocusKeepInput(true)

    SendNUIMessage({
        action = "SHOW_PROGRESSBAR",
        text = text,
        duration = duration,
        allowCancel = allowCancel ~= false
    })

    PipouUI.currentProgressCallback = cb
end

exports('ProgressBar', function(text, duration, cb, allowCancel)
    PipouUI:ProgressBar(text, duration, cb, allowCancel)
end)


RegisterNUICallback("cancelProgressbar", function(_, cb)
    if PipouUI.currentProgressCallback then
        PipouUI.currentProgressCallback(true)
        PipouUI.currentProgressCallback = nil
    end
    cb({})
end)


RegisterNUICallback("submitInput", function(data, cb)
    SetNuiFocus(false, false)

    if PipouUI.currentInputCallback then
        PipouUI.currentInputCallback(data.text)
    end

    -- Ajout pour retour JS
    SendNUIMessage({
        action = "inputSubmitted",
        value = data.text
    })

    PipouUI.currentInputCallback = nil
    cb({})
end)