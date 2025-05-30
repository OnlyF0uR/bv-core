local points       = {}
local isCollecting = false

local function startCollectionThread()
    points = {}
    AddTextEntry('bvPosAlert', 'Press ~INPUT_PICKUP~ to save the current location.')

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            if not isCollecting then
                return
            end

            BeginTextCommandDisplayHelp('bvPosAlert')
            EndTextCommandDisplayHelp(0, false, false, -1)

            if IsControlJustReleased(0, 38) then
                local playerCoordinates = GetEntityCoords(PlayerPedId())

                playerCoordinates = (playerCoordinates - vector3(0.0, 0.0, 1.0))

                table.insert(points, playerCoordinates)

                TriggerEvent('chat:addMessage', {
                    color     = { 255, 0, 0 },
                    multiline = true,
                    args      = { "PointCollect", ("Saved Point #%s: vector3(%s, %s, %s)"):format(
                        #points,
                        playerCoordinates.x,
                        playerCoordinates.y,
                        playerCoordinates.z
                    ) }
                })
            end
        end
    end)
end

-- Instead use client event for poscollect
RegisterNetEvent('core_dev:client:poscollect')
AddEventHandler('core_dev:client:poscollect', function()
    if not isCollecting then
        isCollecting = true
        startCollectionThread()
        return
    end

    -- We are now done collecting
    TriggerServerEvent('core_dev:server:possave', points)
    isCollecting = false
end)

RegisterNetEvent('core_dev:client:poscollect:getheading')
AddEventHandler('core_dev:client:poscollect:getheading', function()
    local ped = GetPlayerPed(PlayerId())
    local heading = GetEntityHeading(ped)
    TriggerEvent('chat:addMessage', {
        color     = { 255, 0, 0 },
        multiline = true,
        args      = { "FuPos", heading }
    })
end)

-- (Re)set locals at start
local infoOn = false   -- Disables the info on restart.
local coordsText = ""  -- Removes any text the coords had stored.
local headingText = "" -- Removes any text the heading had stored.
local modelText = ""   -- Removes any text the model had stored.


local function getEntity(player)
    local _, entity = GetEntityPlayerIsFreeAimingAt(player)
    return entity
end

-- Thread that makes everything happen.
Citizen.CreateThread(function()                                                                                 -- Create the thread.
    while true do                                                                                               -- Loop it infinitely.
        local pause = 250                                                                                       -- If infos are off, set loop to every 250ms. Eats less resources.
        if infoOn then                                                                                          -- If the info is on then...
            pause = 5                                                                                           -- Only loop every 5ms (equivalent of 200fps).
            if IsPlayerFreeAiming(PlayerId()) then                                                              -- If the player is free-aiming (update texts)...
                local entity = getEntity(PlayerId())                                                            -- Get what the player is aiming at. This isn't actually the function, that's below the thread.
                local coords = GetEntityCoords(entity)                                                          -- Get the coordinates of the object.
                local heading = GetEntityHeading(entity)                                                        -- Get the heading of the object.
                local model = GetEntityModel(entity)                                                            -- Get the hash of the object.
                coordsText = coords                                                                             -- Set the coordsText local.
                headingText = heading                                                                           -- Set the headingText local.
                modelText = model                                                                               -- Set the modelText local.
            end                                                                                                 -- End (player is not freeaiming: stop updating texts).
            DrawInfos("Coordinates: " .. coordsText .. "\nHeading: " .. headingText .. "\nHash: " .. modelText) -- Draw the text on screen
        end                                                                                                     -- Info is off, don't need to do anything.
        Citizen.Wait(pause)                                                                                     -- Now wait the specified time.
    end                                                                                                         -- End (stop looping).
end)                                                                                                            -- Endind the entire thread here.

-- Function to draw the text.
function DrawInfos(text)
    SetTextColour(255, 255, 255, 255)  -- Color
    SetTextFont(1)                     -- Font
    SetTextScale(0.4, 0.4)             -- Scale
    SetTextWrap(0.0, 1.0)              -- Wrap the text
    SetTextCentre(false)               -- Align to center(?)
    SetTextDropshadow(0, 0, 0, 0, 255) -- Shadow. Distance, R, G, B, Alpha.
    SetTextEdge(50, 0, 0, 0, 255)      -- Edge. Width, R, G, B, Alpha.
    SetTextOutline()                   -- Necessary to give it an outline.
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.015, 0.51) -- Position
end

RegisterNetEvent("core_dev:client:idgun")
AddEventHandler("core_dev:client:idgun", function()
    infoOn = not infoOn
end)
