local CurrentWeather = Shared.WeatherSync.StartWeather
local baseTime = Shared.WeatherSync.BaseTime
local timeOffset = Shared.WeatherSync.TimeOffset
local freezeTime = Shared.WeatherSync.FreezeTime
local blackout = Shared.WeatherSync.Blackout
local newWeatherTimer = Shared.WeatherSync.NewWeatherTimer

--- Is the source a client or the server
--- @param src string | number - source to check
--- @return int - source
local function getSource(src)
    return src == '' and 0 or src
end

--- Does source have permissions to run admin commands
--- @param src number - Source to check
--- @return boolean - has permission
local function isAllowedToChange(src)
    return src == 0 or Core.Functions.HasPermission(src, "admin") or IsPlayerAceAllowed(src, 'command')
end

--- Sets time offset based on minutes provided
--- @param minute number - Minutes to offset by
local function shiftToMinute(minute)
    timeOffset = timeOffset - (((baseTime + timeOffset) % 60) - minute)
end

--- Sets time offset based on hour provided
--- @param hour number - Hour to offset by
local function shiftToHour(hour)
    timeOffset = timeOffset - ((((baseTime + timeOffset) / 60) % 24) - hour) * 60
end

--- Triggers event to switch weather to next stage
local function nextWeatherStage()
    if CurrentWeather == "CLEAR" or CurrentWeather == "CLOUDS" or CurrentWeather == "EXTRASUNNY" then
        CurrentWeather = (math.random(1, 5) > 2) and "CLEARING" or "OVERCAST" -- 60/40 chance
    elseif CurrentWeather == "CLEARING" or CurrentWeather == "OVERCAST" then
        local new = math.random(1, 6)
        if new == 1 then
            CurrentWeather = (CurrentWeather == "CLEARING") and "FOGGY" or "RAIN"
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
    else
        CurrentWeather = "CLEAR"
    end
    TriggerEvent("bv-weathersync:server:RequestStateSync")
end

--- Switch to a specified weather type
--- @param weather string - Weather type from Shared.WeatherSync.AvailableWeatherTypes
--- @return boolean - success
local function setWeather(weather)
    local validWeatherType = false
    for _, weatherType in pairs(Shared.WeatherSync.AvailableWeatherTypes) do
        if weatherType == string.upper(weather) then
            validWeatherType = true
        end
    end
    if not validWeatherType then return false end
    CurrentWeather = string.upper(weather)
    newWeatherTimer = Shared.WeatherSync.NewWeatherTimer
    TriggerEvent('bv-weathersync:server:RequestStateSync')
    return true
end

--- Sets sun position based on time to specified
--- @param hour number|string - Hour to set (0-24)
--- @param minute number|string `optional` - Minute to set (0-60)
--- @return boolean - success
local function setTime(hour, minute)
    local argh = tonumber(hour)
    local argm = tonumber(minute) or 0
    if argh == nil or argh > 24 then
        print(Lang:t('weathersync.time.invalid'))
        return false
    end
    shiftToHour((argh < 24) and argh or 0)
    shiftToMinute((argm < 60) and argm or 0)
    print(Lang:t('weathersync.time.change', { value = argh, value2 = argm }))
    TriggerEvent('bv-weathersync:server:RequestStateSync')
    return true
end

--- Sets or toggles blackout state and returns the state
--- @param state boolean `optional` - enable blackout?
--- @return boolean - blackout state
local function setBlackout(state)
    if state == nil then state = not blackout end
    if state then
        blackout = true
    else
        blackout = false
    end
    TriggerEvent('bv-weathersync:server:RequestStateSync')
    return blackout
end

--- Sets or toggles time freeze state and returns the state
--- @param state boolean `optional` - Enable time freeze?
--- @return boolean - Time freeze state
local function setTimeFreeze(state)
    if state == nil then state = not freezeTime end
    if state then
        freezeTime = true
    else
        freezeTime = false
    end
    TriggerEvent('bv-weathersync:server:RequestStateSync')
    return freezeTime
end

--- Sets or toggles dynamic weather state and returns the state
--- @param state boolean `optional` - Enable dynamic weather?
--- @return boolean - Dynamic Weather state
local function setDynamicWeather(state)
    if state == nil then state = not Shared.WeatherSync.DynamicWeather end
    if state then
        Shared.WeatherSync.DynamicWeather = true
    else
        Shared.WeatherSync.DynamicWeather = false
    end
    TriggerEvent('bv-weathersync:server:RequestStateSync')
    return Shared.WeatherSync.DynamicWeather
end

--- Retrieves the current time from api.timezonedb.com
local function retrieveTimeFromApi(callback)
    Citizen.CreateThread(function()
        local apiKey = "REPLACE_ME_TO_YOUR_API" -- 🔐 Replace with your actual key from your email
        local zone = "America/Los_Angeles"      -- 🔐 Replace with your actual TimeZone, ex: America/Los_Angeles
        local url = "http://api.timezonedb.com/v2.1/get-time-zone?key=" .. apiKey .. "&format=json&by=zone&zone=" .. zone
        -- print(response) -- 🛠️ Debug: uncomment to inspect raw API response
        PerformHttpRequest(url, function(statusCode, response)
            if statusCode == 200 and response then
                local data = json.decode(response)
                if data and data.timestamp then
                    callback(data.timestamp)
                    return
                end
            end
            callback(nil)
        end, "GET", nil, nil)
    end)
end

-- EVENTS
RegisterNetEvent('bv-weathersync:server:RequestStateSync', function()
    TriggerClientEvent('bv-weathersync:client:SyncWeather', -1, CurrentWeather, blackout)
    TriggerClientEvent('bv-weathersync:client:SyncTime', -1, baseTime, timeOffset, freezeTime)
end)

RegisterNetEvent('bv-weathersync:server:setWeather', function(weather)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local success = setWeather(weather)
        if src > 0 then
            if (success) then
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.weather.updated'))
            else
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.weather.invalid'))
            end
        end
    end
end)

RegisterNetEvent('bv-weathersync:server:setTime', function(hour, minute)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local success = setTime(hour, minute)
        if src > 0 then
            if (success) then
                TriggerClientEvent('Core:Notify', src,
                    Lang:t('weathersync.time.change', { value = hour, value2 = minute or "00" }))
            else
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.time.invalid'))
            end
        end
    end
end)

RegisterNetEvent('bv-weathersync:server:toggleBlackout', function(state)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local newstate = setBlackout(state)
        if src > 0 then
            if (newstate) then
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.blackout.enabled'))
            else
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.blackout.disabled'))
            end
        end
    end
end)

RegisterNetEvent('bv-weathersync:server:toggleFreezeTime', function(state)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local newstate = setTimeFreeze(state)
        if src > 0 then
            if (newstate) then
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.time.now_frozen'))
            else
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.time.now_unfrozen'))
            end
        end
    end
end)

RegisterNetEvent('bv-weathersync:server:toggleDynamicWeather', function(state)
    local src = getSource(source)
    if isAllowedToChange(src) then
        local newstate = setDynamicWeather(state)
        if src > 0 then
            if (newstate) then
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.weather.now_unfrozen'))
            else
                TriggerClientEvent('Core:Notify', src, Lang:t('weathersync.weather.now_frozen'))
            end
        end
    end
end)

-- COMMANDS
Core.Commands.Add('freezetime', Lang:t('weathersync.help.freezecommand'), {}, false, function(source)
    local newstate = setTimeFreeze()
    if source > 0 then
        if (newstate) then return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.time.frozenc')) end
        return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.time.unfrozenc'))
    end
    if (newstate) then return print(Lang:t('weathersync.time.now_frozen')) end
    return print(Lang:t('weathersync.time.now_unfrozen'))
end, 'admin')

Core.Commands.Add('freezeweather', Lang:t('weathersync.help.freezeweathercommand'), {}, false, function(source)
    local newstate = setDynamicWeather()
    if source > 0 then
        if (newstate) then return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.dynamic_weather.enabled')) end
        return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.dynamic_weather.disabled'))
    end
    if (newstate) then return print(Lang:t('weathersync.weather.now_unfrozen')) end
    return print(Lang:t('weathersync.weather.now_frozen'))
end, 'admin')

Core.Commands.Add('weather', Lang:t('weathersync.help.weathercommand'),
    { { name = Lang:t('weathersync.help.weathertype'), help = Lang:t('weathersync.help.availableweather') } }, true,
    function(source, args)
        local success = setWeather(args[1])
        if source > 0 then
            if (success) then
                return TriggerClientEvent('Core:Notify', source,
                    Lang:t('weathersync.weather.willchangeto', { value = string.lower(args[1]) }))
            end
            return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.weather.invalidc'), 'error')
        end
        if (success) then return print(Lang:t('weathersync.weather.updated')) end
        return print(Lang:t('weathersync.weather.invalid'))
    end, 'admin')

Core.Commands.Add('blackout', Lang:t('weathersync.help.blackoutcommand'), {}, false, function(source)
    local newstate = setBlackout()
    if source > 0 then
        if (newstate) then return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.blackout.enabledc')) end
        return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.blackout.disabledc'))
    end
    if (newstate) then return print(Lang:t('weathersync.blackout.enabled')) end
    return print(Lang:t('weathersync.blackout.disabled'))
end, 'admin')

Core.Commands.Add('morning', Lang:t('weathersync.help.morningcommand'), {}, false, function(source)
    setTime(9, 0)
    if source > 0 then return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.time.morning')) end
end, 'admin')

Core.Commands.Add('noon', Lang:t('weathersync.help.nooncommand'), {}, false, function(source)
    setTime(12, 0)
    if source > 0 then return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.time.noon')) end
end, 'admin')

Core.Commands.Add('evening', Lang:t('weathersync.help.eveningcommand'), {}, false, function(source)
    setTime(18, 0)
    if source > 0 then return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.time.evening')) end
end, 'admin')

Core.Commands.Add('night', Lang:t('weathersync.help.nightcommand'), {}, false, function(source)
    setTime(23, 0)
    if source > 0 then return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.time.night')) end
end, 'admin')

Core.Commands.Add('time', Lang:t('weathersync.help.timecommand'),
    { { name = Lang:t('weathersync.help.timehname'), help = Lang:t('weathersync.help.timeh') }, { name = Lang:t('weathersync.help.timemname'), help = Lang:t('weathersync.help.timem') } },
    true, function(source, args)
        local success = setTime(args[1], args[2])
        if source > 0 then
            if (success) then
                return TriggerClientEvent('Core:Notify', source,
                    Lang:t('weathersync.time.changec', { value = args[1] .. ':' .. (args[2] or "00") }))
            end
            return TriggerClientEvent('Core:Notify', source, Lang:t('weathersync.time.invalidc'), 'error')
        end
        if (success) then return print(Lang:t('weathersync.time.change', { value = args[1], value2 = args[2] or "00" })) end
        return print(Lang:t('weathersync.time.invalid'))
    end, 'admin')

-- THREAD LOOPS
CreateThread(function()
    local previous = 0
    local realTimeFromApi = nil
    local failedCount = 0

    if Shared.WeatherSync.RealTimeSync then
        retrieveTimeFromApi(function(unixTime)
            if unixTime then
                baseTime = unixTime
            else
                baseTime = os.time(os.date("!*t"))
            end
        end)
    else
        baseTime = os.time(os.date("!*t")) / 2 + 360
    end

    while true do
        Wait(2000) -- Increase baseTime every 2 seconds
        baseTime = baseTime + 2

        TriggerClientEvent('bv-weathersync:client:SyncTime', -1, baseTime, timeOffset, freezeTime)
    end
end)

CreateThread(function()
    while true do
        Wait(300000) -- Check every 5 minutes
        TriggerClientEvent('bv-weathersync:client:SyncWeather', -1, CurrentWeather, blackout)
    end
end)

CreateThread(function()
    while true do
        newWeatherTimer = newWeatherTimer - 1
        Wait((1000 * 60) * Shared.WeatherSync.NewWeatherTimer)
        if newWeatherTimer == 0 then
            if Shared.WeatherSync.DynamicWeather then
                nextWeatherStage()
            end
            newWeatherTimer = Shared.WeatherSync.NewWeatherTimer
        end
    end
end)

-- EXPORTS
exports('nextWeatherStage', nextWeatherStage)
exports('setWeather', setWeather)
exports('setTime', setTime)
exports('setBlackout', setBlackout)
exports('setTimeFreeze', setTimeFreeze)
exports('setDynamicWeather', setDynamicWeather)
exports('getBlackoutState', function() return blackout end)
exports('getTimeFreezeState', function() return freezeTime end)
exports('getWeatherState', function() return CurrentWeather end)
exports('getDynamicWeather', function() return Shared.WeatherSync.DynamicWeather end)

exports('getTime', function()
    local hour = math.floor(((baseTime + timeOffset) / 60) % 24)
    local minute = math.floor((baseTime + timeOffset) % 60)

    return hour, minute
end)
