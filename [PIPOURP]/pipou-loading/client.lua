Citizen.CreateThread(function()
    local progress = 0

    while progress < 100 do
        Citizen.Wait(1000) -- Mise à jour chaque seconde
        progress = math.floor((GetGameTimer() / 30000) * 100) -- Simulation du chargement sur 30s
        
        if progress > 100 then progress = 100 end

        SendNUIMessage({
            type = "loadingProgress",
            progress = progress
        })
    end

    -- Indiquer que le chargement est terminé
    SendNUIMessage({
        type = "loadingComplete"
    })
end)

-- Détecter le démarrage de la carte (quand le client a fini de charger)
AddEventHandler("onClientMapStart", function()
    SendNUIMessage({
        type = "loadingComplete"
    })
end)
