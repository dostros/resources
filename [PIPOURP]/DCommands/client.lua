function SavePlayerAppearance(playerId)
    local playerPed = GetPlayerPed(playerId)
    local appearanceData = {
        model = GetEntityModel(playerPed),
        components = {},
        props = {}
    }

    for i = 0, 11 do
        appearanceData.components[tostring(i)] = {
            GetPedDrawableVariation(playerPed, i),
            GetPedTextureVariation(playerPed, i)
        }
    end

    for i = 0, 7 do
        appearanceData.props[tostring(i)] = {
            GetPedPropIndex(playerPed, i),
            GetPedPropTextureIndex(playerPed, i)
        }
    end

    print(json.encode(appearanceData))
    -- Enregistrement en base à ajouter ici
end
exports('SavePlayerAppearance', SavePlayerAppearance)


function LoadPlayerAppearance(ped, garageped)
    local appearanceData = garageped

    if appearanceData.model then
        RequestModel(appearanceData.model)
        local waiting = 0
        while not HasModelLoaded(appearanceData.model) do
            Citizen.Wait(100)
            waiting = waiting + 100
            if waiting > 3000 then return end
        end
        SetPlayerModel(ped, appearanceData.model)
    else
        return
    end

    if appearanceData.components then
        for i = 0, 11 do
            local comp = appearanceData.components[tostring(i)]
            if comp then SetPedComponentVariation(ped, i, comp[1], comp[2], 2) end
        end
    end

    if appearanceData.props then
        for i = 0, 7 do
            local prop = appearanceData.props[tostring(i)]
            if prop then SetPedPropIndex(ped, i, prop[1], prop[2], 2) end
        end
    end
end
exports('LoadPlayerAppearance', LoadPlayerAppearance)

