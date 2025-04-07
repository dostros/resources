-------------------------------------------------------------------------------------------------------
--                                           Selection Entity
-------------------------------------------------------------------------------------------------------

local markerSize = 0.2 -- Taille du marqueur
local markerColor = {0, 255, 0, 255} -- Couleur du marqueur (vert)
local lineColor = {255, 255, 0, 255} -- Couleur de la ligne (jaune)
local interactionDistance = 10.0 -- Distance à partir de laquelle l'objet devient interactif

-- Fonction pour obtenir l'objet pointé
function GetObjectPlayerIsLookingAt()
    local playerPed = PlayerPedId()
    local playerCoords = GetGameplayCamCoord() -- Position de la caméra
    local forwardVector = GetCameraDirection()
    local endCoords = playerCoords + (forwardVector * 50.0) -- Distance max du rayon
    local rayHandle = StartShapeTestRay(playerCoords, endCoords, 16, playerPed, 0)
    local _, hit, endCoords, _, entityHit = GetShapeTestResult(rayHandle)

    if hit and DoesEntityExist(entityHit) then
        return entityHit, endCoords -- Retourne l'entité et ses coordonnées
    end

    return nil, nil
end

function DrawBoundingBox(entity, r, g, b, a, width, lineDensity)
    if not DoesEntityExist(entity) then return end

    -- Récupère les dimensions du modèle de l'entité
    local min, max = GetModelDimensions(GetEntityModel(entity))

    -- Récupère les coordonnées de l'entité
    local coords = GetEntityCoords(entity)

    -- Calcule les coins de la boîte englobante en 3D
    local corners = {
        {x = min.x, y = min.y, z = min.z},
        {x = max.x, y = min.y, z = min.z},
        {x = min.x, y = max.y, z = min.z},
        {x = max.x, y = max.y, z = min.z},
        {x = min.x, y = min.y, z = max.z},
        {x = max.x, y = min.y, z = max.z},
        {x = min.x, y = max.y, z = max.z},
        {x = max.x, y = max.y, z = max.z}
    }

    -- Convertit les coins locaux en coordonnées mondiales
    for i = 1, #corners do
        corners[i] = GetOffsetFromEntityInWorldCoords(entity, corners[i].x, corners[i].y, corners[i].z)
    end

    -- Définit les arêtes de la boîte englobante
    local edges = {
        {1, 2}, {2, 4}, {4, 3}, {3, 1}, -- Face inférieure
        {5, 6}, {6, 8}, {8, 7}, {7, 5}, -- Face supérieure
        {1, 5}, {2, 6}, {3, 7}, {4, 8}  -- Arêtes verticales
    }

    -- Dessine les lignes pour chaque arête
    for _, edge in ipairs(edges) do
        -- Pour chaque arête, dessiner avec l'épaisseur
        DrawLineWithWidth(corners[edge[1]], corners[edge[2]], r, g, b, a, width, lineDensity)
    end
end

function DrawLineWithWidth(startCoords, endCoords, r, g, b, a, width, lineDensity)
    -- Calcule la direction de la ligne
    local dx = endCoords.x - startCoords.x
    local dy = endCoords.y - startCoords.y
    local dz = endCoords.z - startCoords.z
    local length = math.sqrt(dx * dx + dy * dy + dz * dz)

    -- Normalise la direction
    local direction = {x = dx / length, y = dy / length, z = dz / length}

    -- Crée un vecteur perpendiculaire pour dessiner une ligne épaisse
    local perp
    if math.abs(direction.x) > 0.1 or math.abs(direction.y) > 0.1 then
        -- Si la ligne est majoritairement horizontale (XY), on crée un vecteur perpendiculaire dans le plan XY
        perp = {x = -direction.y, y = direction.x, z = 0}
    else
        -- Si la ligne est majoritairement verticale (Z), on crée un vecteur perpendiculaire dans le plan XY
        perp = {x = 0, y = 1, z = 0}
    end

    -- Applique un décalage pour dessiner plusieurs lignes parallèles
    local offset = width / 2
    for i = -offset, offset, lineDensity do
        local offsetStartX = startCoords.x + perp.x * i
        local offsetStartY = startCoords.y + perp.y * i
        local offsetStartZ = startCoords.z + perp.z * i

        local offsetEndX = endCoords.x + perp.x * i
        local offsetEndY = endCoords.y + perp.y * i
        local offsetEndZ = endCoords.z + perp.z * i

        -- Dessine une ligne entre les points avec le décalage
        DrawLine(offsetStartX, offsetStartY, offsetStartZ, offsetEndX, offsetEndY, offsetEndZ, r, g, b, a)
    end
end

-- Fonction pour obtenir la direction de la caméra
function GetCameraDirection()
    local rot = GetGameplayCamRot(2)
    local radRotX = math.rad(rot.x)
    local radRotZ = math.rad(rot.z)

    local dirX = -math.sin(radRotZ) * math.cos(radRotX)
    local dirY = math.cos(radRotZ) * math.cos(radRotX)
    local dirZ = math.sin(radRotX)

    return vector3(dirX, dirY, dirZ)
end

-- Dessiner un marqueur autour de l'objet
function DrawGreenCircleAroundObject(coords)
    -- Dessiner un marqueur circulaire (type 28 = cercle)
    DrawMarker(28, coords.x, coords.y, coords.z - 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, markerSize, markerSize, markerSize, markerColor[1], markerColor[2], markerColor[3], markerColor[4], false, true, 2, nil, nil, false)
end

-- Dessiner une ligne entre le joueur et l'objet pointé
function DrawLineToObject(playerCoords, markerCoords)
    -- Dessiner la ligne entre le joueur et l'objet
    DrawLine(playerCoords.x, playerCoords.y, playerCoords.z, markerCoords.x, markerCoords.y, markerCoords.z-0.5, lineColor[1], lineColor[2], lineColor[3], lineColor[4])
end

-- Boucle principale pour mettre à jour l'objet pointé
function lookobject()
    local running = true
    while running do
        Citizen.Wait(0)

        local targetObject, targetCoords = GetObjectPlayerIsLookingAt()
        local interactionDistance = 5

        if targetObject then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - targetCoords)

            if distance < interactionDistance then
                DrawGreenCircleAroundObject(targetCoords)
                DrawLineToObject(playerCoords, targetCoords)
                DrawBoundingBox(targetObject,255, 0, 0, 255, 0.01,0.001)
            end
        end

        if targetObject and IsControlJustReleased(0, 38) then -- 'E'
            local model = GetEntityModel(targetObject)
            -- print("Objet validé ! ID de l'objet :", targetObject)
            -- print("Coordonnées de l'objet :", targetCoords)
            -- print("Modèle de l'objet :", model)

            return targetObject, targetCoords, model
        end


        if IsControlJustReleased(0, 177) then -- Retour
            print("Sortie de la boucle avec Retour")
            running = false
        end
    end

    Citizen.Wait(500)
    print("Fin de la boucle, tout a disparu.")
end

RegisterCommand('look', function()
    lookobject()
end, false)

--58 ->179 ->-179-> -20

-- -98 ->-20