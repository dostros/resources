local currentVoiceMode = "normal" -- "whisper", "normal", "shout"

RegisterNetEvent('pma-voice:transmissionActive', function(talking)
    SendNUIMessage({
        action = 'setTalking',
        talking = talking
    })
end)



-- client/main.lua

local isTalking = false
RegisterNetEvent('pma-voice:setTalkingMode', function(mode)
    currentVoiceMode = mode
    SendNUIMessage({
        action = 'setVoiceMode',
        mode = mode
    })
end)


RegisterNetEvent('pma-voice:radioActive', function(active)
    SendNUIMessage({
        action = 'radioTalking',
        active = active
    })
end)

RegisterNetEvent('pma-voice:talking', function(talking)
    isTalking = talking
    SendNUIMessage({
        action = 'setTalking',
        talking = talking
    })
end)

-- HUD updates (ex: health/hunger/thirst, si tu veux ajouter ça plus tard)
local QBCore = exports['qb-core']:GetCoreObject()
local voiceMode = 1


CreateThread(function()
    while true do
        local player = PlayerPedId()
        local health = math.floor((GetEntityHealth(player) - 100) / 3)
        local hunger, thirst = 100, 100
        local isTalking = exports["pma-voice"]:isPlayerTalking()
        
        local voiceMode = exports["pma-voice"]:getVoiceMode()

        local playerData = QBCore.Functions.GetPlayerData()
        if playerData and playerData.metadata then
            hunger = playerData.metadata.hunger or 100
            thirst = playerData.metadata.thirst or 100
        end

        SendNUIMessage({
            action = 'updateHud',
            health = health,
            hunger = hunger,
            thirst = thirst,
            isTalking = isTalking,
            voiceMode = voiceMode
        })

        Wait(1000)
    end
end)



CreateThread(function()
    while true do
        local isTalking = NetworkIsPlayerTalking(PlayerId())
        SendNUIMessage({
            action = 'setTalking',
            talking = isTalking
        })
        Wait(200)
    end
end)
