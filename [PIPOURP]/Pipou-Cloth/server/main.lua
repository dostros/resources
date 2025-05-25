-- local QBCore = exports['qb-core']:GetCoreObject()

-- RegisterNetEvent("pipou-cloth:saveOutfit", function(outfitIndex)
--     local src = source
--     local Player = QBCore.Functions.GetPlayer(src)
--     if not Player then return end

--     local citizenid = Player.PlayerData.citizenid
--     local outfit = Config.Outfits[outfitIndex]
--     if not outfit then return end

--     local jsonOutfit = json.encode(outfit)

--     -- Upsert (insert or update)
--     exports.oxmysql:execute([[
--         INSERT INTO player_outfits (citizenid, outfit)
--         VALUES (?, ?)
--         ON DUPLICATE KEY UPDATE outfit = VALUES(outfit)
--     ]], {citizenid, jsonOutfit}, function()
--         print(("[Pipou-cloth] Tenue sauvegardée pour %s : %s"):format(citizenid, outfit.label))
--     end)
-- end)

-- -- Optionnel : récupérer la tenue au login
-- AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
--     local citizenid = Player.PlayerData.citizenid

--     exports.oxmysql:fetch('SELECT outfit FROM player_outfits WHERE citizenid = ?', {citizenid}, function(result)
--         if result and result[1] then
--             local outfit = json.decode(result[1].outfit)
--             TriggerClientEvent("pipou-cloth:applySavedOutfit", Player.PlayerData.source, outfit)
--         end
--     end)
-- end)
