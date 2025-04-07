function SavePlayerAppearance(playerId)
    local playerPed = GetPlayerPed(playerId)
    local appearanceData = {}

    -- Capturer les données d'apparence
    appearanceData.model = GetEntityModel(playerPed)
    appearanceData.components = {}
    appearanceData.props = {}

    -- Capturer les composants avec des clés sous forme de chaînes de caractères
    for i = 0, 11 do
        appearanceData.components[tostring(i)] = {GetPedDrawableVariation(playerPed, i), GetPedTextureVariation(playerPed, i)}
    end

    -- Capturer les props avec des clés sous forme de chaînes de caractères
    for i = 0, 7 do
        appearanceData.props[tostring(i)] = {GetPedPropIndex(playerPed, i), GetPedPropTextureIndex(playerPed, i)}
    end

    -- Afficher les données d'apparence
    print(appearanceData)
    print(json.encode(appearanceData))

    -- Sauvegarder les données dans une base de données ou un fichier
    -- Exemple avec une base de données SQL (pseudo-code)
    -- ExecuteSQL("UPDATE players SET appearance = ? WHERE identifier = ?", {json.encode(appearanceData), GetPlayerIdentifier(playerId)})
end

exports ('SavePlayerAppearance', SavePlayerAppearance)


-- Fonction pour charger l'apparence du joueur
function LoadPlayerAppearance(ped, garageped)
    local appearanceData = garageped

    -- Vérifiez si 'model' existe et affichez-le
    if appearanceData.model then
        --print("Model:", appearanceData.model)

        -- Charger le modèle
        RequestModel(appearanceData.model)
        local waiting = 0
        while not HasModelLoaded(appearanceData.model) do
            waiting = waiting + 100
            Citizen.Wait(100)
            if waiting > 3000 then
                print("Model not found")
                return -- Sortir de la fonction si le modèle n'est pas trouvé
            end
        end

        -- Appliquer le modèle au pédestre
        SetPlayerModel(ped, appearanceData.model)
        --print("Model appliqué")
    else
        --print("Model is nil or not defined")
        return -- Sortir de la fonction si le modèle n'est pas défini
    end

    -- Vérifiez et appliquez les composants
    if appearanceData.components then
        for i = 0, 11 do
            local component = appearanceData.components[tostring(i)]
            if component then
                --print("Component", i, ":", component[1], component[2])
                SetPedComponentVariation(ped, i, component[1], component[2], 2)
            else
                --print("Component", i, "is nil or not defined")
            end
        end
    else
        --print("Components table is nil or not defined")
    end

    -- Vérifiez et appliquez les props
    if appearanceData.props then
        for i = 0, 7 do
            local prop = appearanceData.props[tostring(i)]
            if prop then
                --print("Prop", i, ":", prop[1], prop[2])
                SetPedPropIndex(ped, i, prop[1], prop[2], 2)
            else
                print("Prop", i, "is nil or not defined")
            end
        end
    else
        --print("Props table is nil or not defined")
    end
end


exports ('LoadPlayerAppearance', LoadPlayerAppearance)


