local QBCore = exports['qb-core']:GetCoreObject()
local patients = {}
local display = false

-- Active / Désactive l'interface NUI + animation + blocage mouvements
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)

    if bool then
        PlayTabletAnim()
        SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
    else
        StopTabletAnim()
    end

    SendNUIMessage({
        type = 'ui',
        status = bool,
    })
end

-- Ouvre la tablette via la commande
RegisterCommand("ems", function()
    SetDisplay(not display)
end, false)

-- Fermer la tablette via NUI
RegisterNUICallback('exit', function(_, cb)
    SetDisplay(false)
    cb({})
end)

-- Ajouter un patient
RegisterNUICallback("addPatient", function(data, cb)
    QBCore.Functions.TriggerCallback("ems:addPatientToDatabase", function(success)
        if success then
            QBCore.Functions.Notify("Patient ajouté avec succès", "success")
        else
            QBCore.Functions.Notify("Erreur lors de l'ajout du patient", "error")
        end
        cb({ status = success and "ok" or "error" })
    end, {
        nom = data.nom,
        prenom = data.prenom,
        age = tonumber(data.age),
        sexe = data.sexe,
        maladie = data.maladie,
        remarques = data.remarques
    })
end)

-- Récupérer liste des patients
RegisterNUICallback("getpatientslist", function(_, cb)
    QBCore.Functions.TriggerCallback("ems:getPatientsFromDatabase", function(patients)
        cb(patients)
    end)
end)

-- Mettre à jour un patient
RegisterNUICallback("updatePatient", function(data, cb)
    QBCore.Functions.TriggerCallback("ems:updatePatientInDatabase", function(success)
        cb({ status = success and "ok" or "error" })
    end, data)
end)

-- Supprimer un patient
RegisterNUICallback("deletePatient", function(data, cb)
    QBCore.Functions.TriggerCallback("ems:deletePatientFromDatabase", function(success)
        cb({ status = success and "ok" or "error" })
    end, data.id)
end)

-- Animation tablette (scénario simple)
function PlayTabletAnim()
    local ped = PlayerPedId()
    if not IsPedUsingScenario(ped, "WORLD_HUMAN_SEAT_WALL_TABLET") then
        ClearPedTasks(ped)
        TaskStartScenarioInPlace(ped, "WORLD_HUMAN_TOURIST_MOBILE", 0, true)
    end
end

function StopTabletAnim()
    ClearPedTasks(PlayerPedId())
end

-- Désactivation des mouvements pendant l'ouverture de la tablette
CreateThread(function()
    while true do
        Wait(0)
        if display then
            DisableControlAction(0, 1, true)   -- Look left/right
            DisableControlAction(0, 2, true)   -- Look up/down
            DisableControlAction(0, 30, true)  -- Move left/right
            DisableControlAction(0, 31, true)  -- Move up/down
            DisableControlAction(0, 21, true)  -- Sprint
            DisableControlAction(0, 22, true)  -- Jump
            DisableControlAction(0, 24, true)  -- Attack
            DisableControlAction(0, 25, true)  -- Aim
            DisableControlAction(0, 23, true)  -- Enter vehicle
            DisableControlAction(0, 75, true)  -- Exit vehicle
            DisableControlAction(0, 289, true) -- F2
        else
            Wait(500)
        end
    end
end)
