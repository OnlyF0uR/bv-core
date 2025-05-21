Citizen.CreateThread(function()
  SetMapZoomDataLevel(0, 0.96, 0.9, 0.08, 0.0, 0.0)
  SetMapZoomDataLevel(1, 1.6, 0.9, 0.08, 0.0, 0.0)
  SetMapZoomDataLevel(2, 8.6, 0.9, 0.08, 0.0, 0.0)
  SetMapZoomDataLevel(3, 12.3, 0.9, 0.08, 0.0, 0.0)
  SetMapZoomDataLevel(4, 22.3, 0.9, 0.08, 0.0, 0.0)
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1)

    local player_ped = GetPlayerPed(-1)
    if IsPedOnFoot(player_ped) then 
      SetRadarZoom(1100)
    elseif IsPedInAnyVehicle(player_ped, true) then
      SetRadarZoom(1100)
    end
  end
end)

---@class PostalData : table<number, vec>
---@field code string
---@type table<number, PostalData>
local postals = nil
Citizen.CreateThread(function()
    postals = LoadResourceFile(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'postal_file'))
    postals = json.decode(postals)
    for i, postal in ipairs(postals) do postals[i] = { vec(postal.x, postal.y), code = postal.code } end
end)

---@class NearestResult
---@field code string
---@field dist number
nearest = nil

---@class PostalBlip
---@field 1 vec
---@field p PostalData
---@field hndl number
pBlip = nil

exports('getPostal', function() return nearest and nearest.code or nil end)

local ipairs = ipairs
local upper = string.upper
local format = string.format

---
--- [[ Nearest Postal Commands ]] ---
---

TriggerEvent('chat:addSuggestion', '/postalcode', 'Set the GPS to a specific postal code',
             { { name = 'Postal code', help = 'De postal code you would like to navigate to' } })

RegisterCommand('postalcode', function(_, args)
    if #args < 1 then
        if pBlip then
            RemoveBlip(pBlip.hndl)
            pBlip = nil
            TriggerEvent('chat:addMessage', {
                color = { 255, 0, 0 },
                args = {
                    'GPS',
                    Shared.PostalCodes.Blip.DeleteText
                }
            })
        end
        return
    end

    local userPostal = upper(args[1])
    local foundPostal

    for _, p in ipairs(postals) do
        if upper(p.code) == userPostal then
            foundPostal = p
            break
        end
    end

    if foundPostal then
        if pBlip then RemoveBlip(pBlip.hndl) end
        local blip = AddBlipForCoord(foundPostal[1][1], foundPostal[1][2], 0.0)
        pBlip = { hndl = blip, p = foundPostal }
        SetBlipRoute(blip, true)
        SetBlipSprite(blip, Shared.PostalCodes.Blup.Sprite)
        SetBlipColour(blip, Shared.PostalCodes.Blip.Color)
        SetBlipRouteColour(blip, Shared.PostalCodes.Blip.Color)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(format(Shared.PostalCodes.Blip.Text, pBlip.p.code))
        EndTextCommandSetBlipName(blip)

        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            args = {
                'GPS',
                format(Shared.PostalCodes.Blip.DrawRouteText, foundPostal.code)
            }
        })
    else
        TriggerEvent('chat:addMessage', {
            color = { 255, 0, 0 },
            args = {
                'GPS',
                Shared.PostalCodes.Blip.InvalidPostalText
            }
        })
    end
end)
