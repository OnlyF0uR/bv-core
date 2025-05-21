-- Set this to false if you don't want the weather to change automatically every 10 minutes.
DynamicWeather = true
--------------------------------------------------

-------------------- DON'T CHANGE THIS --------------------
AvailableWeatherTypes = {'EXTRASUNNY', 'CLEAR', 'NEUTRAL', 'SMOG', 'FOGGY', 'OVERCAST', 'CLOUDS', 'CLEARING', 'RAIN', 'THUNDER', 'SNOW', 'BLIZZARD', 'SNOWLIGHT', 'XMAS', 'HALLOWEEN'}
CurrentWeather = "EXTRASUNNY"
local baseTime = 0
local timeOffset = 0
local freezeTime = false
local blackout = false
local newWeatherTimer = 15

RegisterServerEvent('core-adapters:weather:requestSync')
AddEventHandler('core-adapters:weather:requestSync', function()
    TriggerClientEvent('core-adapters:weather:updateWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('core-adapters:weather:updateTime', -1, baseTime, timeOffset, freezeTime)
end)

RegisterCommand('freezetime', function(src, args)
    if src ~= 0 then
        if IsPlayerAceAllowed(src, "fu_sync.cmd") then
            freezeTime = not freezeTime
            if freezeTime then
                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Time is now frozen.' })
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Time is no longer frozen.' })
            end
        else
            TriggerClientEvent('chatMessage', src, '', {255, 255, 255}, '^8Error: ^1Not permitted.')
        end
    else
        freezeTime = not freezeTime
        if freezeTime then
            print("Time is now frozen.")
        else
            print("Time is no longer frozen.")
        end
    end
end)

RegisterCommand('freezeweather', function(src, args)
    if src ~= 0 then
        if IsPlayerAceAllowed(src, "fu_sync.cmd") then
            DynamicWeather = not DynamicWeather
            if not DynamicWeather then
                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Dynamic weather is now disabled.' })
            else
                TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Dynamic weather is now enabled.' })
            end
        else
            TriggerClientEvent('chatMessage', src, '', {255, 255, 255}, '^8Error: ^1Not permitted.')
        end
    else
        DynamicWeather = not DynamicWeather
        if not DynamicWeather then
            print("Weather is now frozen.")
        else
            print("Weather is no longer frozen.")
        end
    end
end)

RegisterCommand('weather', function(src, args)
    if src == 0 then
        local validWeatherType = false
        if args[1] == nil then
            print("Invalid syntax, correct syntax is: /weather <weathertype> ")
            return
        else
            for i, wtype in ipairs(AvailableWeatherTypes) do
                if wtype == string.upper(args[1]) then
                    validWeatherType = true
                end
            end
            if validWeatherType then
                print("Weather has been updated.")
                CurrentWeather = string.upper(args[1])
                newWeatherTimer = 15
                TriggerEvent('core-adapters:weather:requestSync')
            else
                print("Invalid weather type, valid weather types are: \nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ")
            end
        end
    else
        if IsPlayerAceAllowed(src, "fu_sync.cmd") then
            local validWeatherType = false
            if args[1] == nil then
                TriggerClientEvent('chatMessage', src, '', {255, 255, 255},
                    '^8Error: ^1Invalid syntax, use ^0/weather <weatherType> ^1instead!')
            else
                for i, wtype in ipairs(AvailableWeatherTypes) do
                    if wtype == string.upper(args[1]) then
                        validWeatherType = true
                    end
                end
                if validWeatherType then
                    TriggerClientEvent('mythic_notify:client:SendAlert', src, { type = 'inform', text = 'Changed weather to ' .. string.lower(args[1]) .. '.' })
                    CurrentWeather = string.upper(args[1])
                    newWeatherTimer = 15
                    TriggerEvent('core-adapters:weather:requestSync')
                else
                    TriggerClientEvent('chatMessage', src, '', {255, 255, 255},
                        '^8Error: ^1Invalid weather type, valid weather types are: ^0\nEXTRASUNNY CLEAR NEUTRAL SMOG FOGGY OVERCAST CLOUDS CLEARING RAIN THUNDER SNOW BLIZZARD SNOWLIGHT XMAS HALLOWEEN ')
                end
            end
        else
            TriggerClientEvent('chatMessage', src, '', {255, 255, 255}, '^8Error: ^1Je hebt geen toegang tot die command.')
        end
    end
end, false)

RegisterServerEvent('core-adapters:weather:toggleBlackout')
AddEventHandler('core-adapters:weather:toggleBlackout', function()
    blackout = not blackout
    if blackout then
        TriggerClientEvent('mythic_notify:client:SendAlert', -1, { type = 'inform', text = 'Blackout enabled.' })
    else
        TriggerClientEvent('mythic_notify:client:SendAlert', -1, { type = 'inform', text = 'Blackout disabled.' })
    end
    TriggerEvent('core-adapters:weather:requestSync')
end)

RegisterCommand('blackout', function(src)
    if IsPlayerAceAllowed(src, "fu_sync.cmd") or src == 0 then
        TriggerEvent('core-adapters:weather:toggleBlackout')
    end
end)

function ShiftToMinute(minute)
    timeOffset = timeOffset - (((baseTime + timeOffset) % 60) - minute)
end

function ShiftToHour(hour)
    timeOffset = timeOffset - ((((baseTime + timeOffset) / 60) % 24) - hour) * 60
end

RegisterCommand('time', function(src, args, rawCommand)
    if src == 0 then
        if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil then
            local argh = tonumber(args[1])
            local argm = tonumber(args[2])
            if argh < 24 then
                ShiftToHour(argh)
            else
                ShiftToHour(0)
            end
            if argm < 60 then
                ShiftToMinute(argm)
            else
                ShiftToMinute(0)
            end
            print("Time has changed to " .. argh .. ":" .. argm .. ".")
            TriggerEvent('core-adapters:weather:requestSync')
        else
            print("Invalid syntax, correct syntax is: time <hour> <minute>!")
        end
    elseif src ~= 0 then
        if IsPlayerAceAllowed(src, "fu_sync.cmd") then
            if tonumber(args[1]) ~= nil and tonumber(args[2]) ~= nil then
                local argh = tonumber(args[1])
                local argm = tonumber(args[2])
                if argh < 24 then
                    ShiftToHour(argh)
                else
                    ShiftToHour(0)
                end
                if argm < 60 then
                    ShiftToMinute(argm)
                else
                    ShiftToMinute(0)
                end
                local newtime = math.floor(((baseTime + timeOffset) / 60) % 24) .. ":"
                local minute = math.floor((baseTime + timeOffset) % 60)
                if minute < 10 then
                    newtime = newtime .. "0" .. minute
                else
                    newtime = newtime .. minute
                end

                TriggerClientEvent('mythic_notify:client:SendAlert', -1, { type = 'inform', text = 'Time was changed to ' .. newtime .. '.' })
                TriggerEvent('core-adapters:weather:requestSync')
            else
                TriggerClientEvent('chatMessage', src, '', {255, 255, 255}, '^8Error: ^1Invalid syntax. Use ^0/time <hour> <minute> ^1instead!')
            end
        else
            TriggerClientEvent('chatMessage', src, '', {255, 255, 255}, '^8Error: ^1Je hebt geen toegang tot die command.')
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local newBaseTime = os.time(os.date("!*t")) / 2 + 360
        if freezeTime then
            timeOffset = timeOffset + baseTime - newBaseTime
        end
        baseTime = newBaseTime
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        TriggerClientEvent('core-adapters:weather:updateTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000)
        TriggerClientEvent('core-adapters:weather:updateWeather', -1, CurrentWeather, blackout)
    end
end)

Citizen.CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Citizen.Wait(60000)
        if newWeatherTimer == 0 then
            if DynamicWeather then
                NextWeatherStage()
            end
            newWeatherTimer = 15
        end
    end
end)

function NextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY" then
        local new = math.random(1, 2)
        if new == 1 then
            CurrentWeather = "CLEARING"
        else
            CurrentWeather = "OVERCAST"
        end
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1, 6)
        if new == 1 then
            if CurrentWeather == "CLEARING" then
                CurrentWeather = "FOGGY"
            else
                CurrentWeather = "RAIN"
            end
        elseif new == 2 then
            CurrentWeather = "CLOUDS"
        elseif new == 3 then
            CurrentWeather = "CLEAR"
        elseif new == 4 then
            CurrentWeather = "EXTRASUNNY"
        elseif new == 5 then
            CurrentWeather = "SMOG"
        else
            CurrentWeather = "FOGGY"
        end
    elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then
        CurrentWeather = "CLEARING"
    elseif CurrentWeather == "SMOG" or CurrentWeather == "FOGGY" then
        CurrentWeather = "CLEAR"
    end
    TriggerEvent("core-adapters:weather:requestSync")
end