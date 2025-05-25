--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--                          VARIABLES

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------










--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--                          Fonctions

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function SetDisplay(bool, label)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = 'ui',
        status = bool,
        label = label
    })
end

local function getMax(componentId)
    local ped = PlayerPedId()
    local count = GetNumberOfPedDrawableVariations(ped, componentId)
    return (count and count > 0) and (count - 1) or nil
end

local function getPropMax(propId)
    local ped = PlayerPedId()
    local count = GetNumberOfPedPropDrawableVariations(ped, propId)
    return (count and count > 0) and (count - 1) or nil
end



local function EnsureFreemodePed()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)

    -- mp_m_freemode_01 : 0x705E61F2 / 1885233650
    if model == `mp_m_freemode_01` or model == `mp_f_freemode_01` then
        return ped -- déjà bon ped
    end

    local freemodeModel = `mp_m_freemode_01`
    RequestModel(freemodeModel)
    while not HasModelLoaded(freemodeModel) do
        Wait(0)
    end

    SetPlayerModel(PlayerId(), freemodeModel)
    SetPedDefaultComponentVariation(PlayerPedId())
    return PlayerPedId()
end


local function createComponentSliders(label, componentId)
    local ped = PlayerPedId()
    local drawableMax = GetNumberOfPedDrawableVariations(ped, componentId) - 1
    if drawableMax <= 0 then return {} end

    local textureMax = GetNumberOfPedTextureVariations(ped, componentId, 0) - 1
    local currentDrawable = 0
    local currentTexture = 0

    return { {
        label = label,
        type = "clothslider",
        drawable = currentDrawable,
        texture = currentTexture,
        drawableMin = 0,
        drawableMax = drawableMax,
        textureMax = textureMax,
        action = function(drawable, texture)
            currentDrawable = drawable
            currentTexture = texture
            local newTextureMax = GetNumberOfPedTextureVariations(ped, componentId, drawable) - 1

            SetPedComponentVariation(ped, componentId, drawable, texture, 2)

            -- Mise à jour JS de textureMax pour le redraw
            exports['PipouUI']:UpdateSlider(GetMenuIndexFromLabel(label), drawable, newTextureMax)
        end
    } }
end


local function createPropSliders(label, propId)
    local ped = PlayerPedId()
    local drawableMax = GetNumberOfPedPropDrawableVariations(ped, propId) - 1
    if drawableMax <= 0 then return {} end

    local textureMax = GetNumberOfPedPropTextureVariations(ped, propId, 0) - 1

    return {{
        label = label,
        type = "clothslider",
        drawable = 0,
        texture = 0,
        drawableMin = 0,
        drawableMax = drawableMax,
        textureMax = textureMax,
        action = function(drawable, texture)
            local newTexMax = GetNumberOfPedPropTextureVariations(ped, propId, drawable) - 1
            SetPedPropIndex(ped, propId, drawable, texture, true)
        end
    }}
    
end


local function GetCurrentSkinData(ped)
    local skin = {
        components = {},
        props = {}
    }

    for i = 0, 11 do
        local drawable = GetPedDrawableVariation(ped, i)
        local texture = GetPedTextureVariation(ped, i)
        table.insert(skin.components, {component = i, drawable = drawable, texture = texture})
    end

    for i = 0, 7 do
        local drawable = GetPedPropIndex(ped, i)
        local texture = GetPedPropTextureIndex(ped, i)
        if drawable ~= -1 then
            table.insert(skin.props, {prop = i, drawable = drawable, texture = texture})
        end
    end

    return skin
end




--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--                          MAIN

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

RegisterCommand("clothmenu", function()
    local ped = EnsureFreemodePed()

    local sliders = {}

    for _, entry in ipairs({
        {label = "Torse", id = 3, type = "component"},
        {label = "Chemise", id = 11, type = "component"},
        {label = "Sous-vêtement", id = 8, type = "component"},
        {label = "Pantalon", id = 4, type = "component"},
        {label = "Chaussures", id = 6, type = "component"},
        {label = "Chapeau", id = 0, type = "prop"},
        {label = "Lunettes", id = 1, type = "prop"},
    }) do
        local drawableMax = (entry.type == "component")
            and GetNumberOfPedDrawableVariations(ped, entry.id) - 1
            or GetNumberOfPedPropDrawableVariations(ped, entry.id) - 1

        local textureMax = (entry.type == "component")
            and GetNumberOfPedTextureVariations(ped, entry.id, 0) - 1
            or GetNumberOfPedPropTextureVariations(ped, entry.id, 0) - 1

        table.insert(sliders, {
            label = entry.label,
            id = entry.id,
            type = entry.type,
            drawable = 0,
            texture = 0,
            drawableMax = drawableMax,
            textureMax = textureMax
        })
    end
    
    SetDisplay(not display)
    
end, false)


RegisterNUICallback("closeMenu", function(_, cb)
    SetDisplay(false)
    cb({})
end)


RegisterNUICallback("updateClothing", function(data, cb)
    local ped = PlayerPedId()
    if data.type == "component" then
        SetPedComponentVariation(ped, data.id, data.drawable, data.texture, 2)
    elseif data.type == "prop" then
        ClearPedProp(ped, data.id)
        SetPedPropIndex(ped, data.id, data.drawable, data.texture, true)
    end
    cb({})
end)

RegisterNUICallback("saveClothing", function(_, cb)
    local skin = GetCurrentSkinData(PlayerPedId())
    print("==== TENUE ACTUELLE ====")
    print(json.encode(skin, { indent = true }))
    cb({})
end)
