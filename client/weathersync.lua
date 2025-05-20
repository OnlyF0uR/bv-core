CurrentWeather = 'EXTRASUNNY'
local lastWeather = CurrentWeather
local baseTime = 0
local timeOffset = 0
local timer = 0
local freezeTime = false
local blackout = false

RegisterNetEvent('core_adapters:weather:updateWeather')
AddEventHandler('core_adapters:weather:updateWeather', function(NewWeather, newblackout)
    CurrentWeather = NewWeather
    blackout = newblackout
end)

Citizen.CreateThread(function()
    while true do
        if lastWeather ~= CurrentWeather then
            lastWeather = CurrentWeather
            SetWeatherTypeOverTime(CurrentWeather, 15.0)

            Wait(15000)
        end

        Wait(250)

        SetBlackout(blackout)
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist(lastWeather)
        SetWeatherTypeNow(lastWeather)
        SetWeatherTypeNowPersist(lastWeather)
        if lastWeather == 'XMAS' then
            SetForceVehicleTrails(true)
            SetForcePedFootstepsTracks(true)
        else
            SetForceVehicleTrails(false)
            SetForcePedFootstepsTracks(false)
        end
    end
end)

RegisterNetEvent('core_adapters:weather:updateTime')
AddEventHandler('core_adapters:weather:updateTime', function(base, offset, freeze)
    freezeTime = freeze
    timeOffset = offset
    baseTime = base
end)

Citizen.CreateThread(function()
    local hour = 0
    local minute = 0
    while true do
        Wait(100)

        local newBaseTime = baseTime
        if GetGameTimer() - 500 > timer then
            newBaseTime = newBaseTime + 0.25
            timer = GetGameTimer()
        end

        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime
        end

        baseTime = newBaseTime
        hour = math.floor(((baseTime + timeOffset) / 60) % 24)
        minute = math.floor((baseTime + timeOffset) % 60)

        NetworkOverrideClockTime(hour, minute, 0)
    end
end)

AddEventHandler('playerSpawned', function()
    TriggerServerEvent('core_adapters:weather:requestSync')
end)

Citizen.CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/weather', 'Change the weather.', {{
        name = "Weather types",
        help = "Available types: extrasunny, clear, neutral, smog, foggy, overcast, clouds, clearing, rain, thunder, snow, blizzard, snowlight, xmas & halloween"
    }})
    TriggerEvent('chat:addSuggestion', '/time', 'Verander de tijd.', {{
        name = "hours",
        help = "Number between 0 - 23"
    }, {
        name = "minutes",
        help = "Number between 0 - 59"
    }})
    TriggerEvent('chat:addSuggestion', '/freezetime', 'Toggle frozen time.')
    TriggerEvent('chat:addSuggestion', '/freezeweather', 'Toggle dynamic weather.')
    TriggerEvent('chat:addSuggestion', '/blackout', 'Toggle blackout.')
end)