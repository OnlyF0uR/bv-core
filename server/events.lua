-- Event Handler

AddEventHandler('chatMessage', function(_, _, message)
    if string.sub(message, 1, 1) == '/' then
        CancelEvent()
        return
    end
end)

AddEventHandler('playerDropped', function(reason)
    local src = source
    if not Core.Players[src] then return end
    local Player = Core.Players[src]
    TriggerEvent('bv-log:server:CreateLog', 'joinleave', 'Dropped', 'red',
        '**' .. GetPlayerName(src) .. '** (' .. Player.PlayerData.license .. ') left..' .. '\n **Reason:** ' .. reason)
    TriggerEvent('Core:Server:PlayerDropped', Player)
    Player.Functions.Save()
    Core.Player_Buckets[Player.PlayerData.license] = nil
    Core.Players[src] = nil
end)

AddEventHandler("onResourceStop", function(resName)
    for i, v in pairs(Core.UsableItems) do
        if v.resource == resName then
            Core.UsableItems[i] = nil
        end
    end
end)

-- Player Connecting
local readyFunction = MySQL.ready
local databaseConnected, bansTableExists = readyFunction == nil, readyFunction == nil
if readyFunction ~= nil then
    MySQL.ready(function()
        databaseConnected = true

        local DatabaseInfo = Core.Functions.GetDatabaseInfo()
        if not DatabaseInfo or not DatabaseInfo.exists then return end

        local result = MySQL.query.await(
            'SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = ? AND TABLE_NAME = "bans";',
            { DatabaseInfo.database })
        if result and result[1] then
            bansTableExists = true
        end
    end)
end

local function onPlayerConnecting(name, _, deferrals)
    local src = source
    deferrals.defer()

    if Core.Config.Server.Closed and not IsPlayerAceAllowed(src, 'qbadmin.join') then
        return deferrals.done(Core.Config.Server.ClosedReason)
    end

    if not databaseConnected then
        return deferrals.done(Lang:t('error.connecting_database_error'))
    end

    if Core.Config.Server.Whitelist then
        Wait(0)
        deferrals.update(string.format(Lang:t('info.checking_whitelisted'), name))
        if not Core.Functions.IsWhitelisted(src) then
            return deferrals.done(Lang:t('error.not_whitelisted'))
        end
    end

    Wait(0)
    deferrals.update(string.format('Hello %s. Your license is being checked', name))
    local license = Core.Functions.GetIdentifier(src, 'license')

    if not license then
        return deferrals.done(Lang:t('error.no_valid_license'))
    elseif Core.Config.Server.CheckDuplicateLicense and Core.Functions.IsLicenseInUse(license) then
        return deferrals.done(Lang:t('error.duplicate_license'))
    end

    Wait(0)
    deferrals.update(string.format(Lang:t('info.checking_ban'), name))

    if not bansTableExists then
        return deferrals.done(Lang:t('error.ban_table_not_found'))
    end

    local success, isBanned, reason = pcall(Core.Functions.IsPlayerBanned, src)
    if not success then return deferrals.done(Lang:t('error.connecting_database_error')) end
    if isBanned then return deferrals.done(reason) end

    Wait(0)
    deferrals.update(string.format(Lang:t('info.join_server'), name))
    deferrals.done()

    TriggerClientEvent('Core:Client:SharedUpdate', src, Core.Shared)
end

AddEventHandler('playerConnecting', onPlayerConnecting)

-- Open & Close Server (prevents players from joining)

RegisterNetEvent('Core:Server:CloseServer', function(reason)
    local src = source
    if Core.Functions.HasPermission(src, 'admin') then
        reason = reason or 'No reason specified'
        Core.Config.Server.Closed = true
        Core.Config.Server.ClosedReason = reason
        for k in pairs(Core.Players) do
            if not Core.Functions.HasPermission(k, Core.Config.Server.WhitelistPermission) then
                Core.Functions.Kick(k, reason, nil, nil)
            end
        end
    else
        Core.Functions.Kick(src, Lang:t('error.no_permission'), nil, nil)
    end
end)

RegisterNetEvent('Core:Server:OpenServer', function()
    local src = source
    if Core.Functions.HasPermission(src, 'admin') then
        Core.Config.Server.Closed = false
    else
        Core.Functions.Kick(src, Lang:t('error.no_permission'), nil, nil)
    end
end)

-- Callback Events --

-- Client Callback
RegisterNetEvent('Core:Server:TriggerClientCallback', function(name, ...)
    if Core.ClientCallbacks[name] then
        Core.ClientCallbacks[name].promise:resolve(...)

        if Core.ClientCallbacks[name].callback then
            Core.ClientCallbacks[name].callback(...)
        end

        Core.ClientCallbacks[name] = nil
    end
end)

-- Server Callback
RegisterNetEvent('Core:Server:TriggerCallback', function(name, ...)
    if not Core.ServerCallbacks[name] then return end

    local src = source

    Core.ServerCallbacks[name](src, function(...)
        TriggerClientEvent('Core:Client:TriggerCallback', src, name, ...)
    end, ...)
end)

-- Player

RegisterNetEvent('Core:UpdatePlayer', function()
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end
    local newHunger = Player.PlayerData.metadata['hunger'] - Core.Config.Player.HungerRate
    local newThirst = Player.PlayerData.metadata['thirst'] - Core.Config.Player.ThirstRate
    if newHunger <= 0 then
        newHunger = 0
    end
    if newThirst <= 0 then
        newThirst = 0
    end
    Player.Functions.SetMetaData('thirst', newThirst)
    Player.Functions.SetMetaData('hunger', newHunger)
    TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
    Player.Functions.Save()
end)

RegisterNetEvent('Core:ToggleDuty', function()
    local src = source
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.onduty then
        Player.Functions.SetJobDuty(false)
        TriggerClientEvent('Core:Notify', src, Lang:t('info.off_duty'))
    else
        Player.Functions.SetJobDuty(true)
        TriggerClientEvent('Core:Notify', src, Lang:t('info.on_duty'))
    end

    TriggerEvent('Core:Server:SetDuty', src, Player.PlayerData.job.onduty)
    TriggerClientEvent('Core:Client:SetDuty', src, Player.PlayerData.job.onduty)
end)

-- BaseEvents

-- Vehicles
RegisterServerEvent('baseevents:enteringVehicle', function(veh, seat, modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Entering'
    }
    TriggerClientEvent('Core:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteredVehicle', function(veh, seat, modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Entered'
    }
    TriggerClientEvent('Core:Client:VehicleInfo', src, data)
end)

RegisterServerEvent('baseevents:enteringAborted', function()
    local src = source
    TriggerClientEvent('Core:Client:AbortVehicleEntering', src)
end)

RegisterServerEvent('baseevents:leftVehicle', function(veh, seat, modelName)
    local src = source
    local data = {
        vehicle = veh,
        seat = seat,
        name = modelName,
        event = 'Left'
    }
    TriggerClientEvent('Core:Client:VehicleInfo', src, data)
end)

-- Items

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon.
RegisterNetEvent('Core:Server:UseItem', function(item)
    print(string.format(
        '%s triggered Core:Server:UseItem by ID %s with the following data. This event is deprecated due to exploitation, and will be removed soon. Check bv-inventory for the right use on this event.',
        GetInvokingResource(), source))
    Core.Debug(item)
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot)
RegisterNetEvent('Core:Server:RemoveItem', function(itemName, amount)
    local src = source
    print(string.format(
        '%s triggered Core:Server:RemoveItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.',
        GetInvokingResource(), src, amount, itemName))
end)

-- This event is exploitable and should not be used. It has been deprecated, and will be removed soon. function(itemName, amount, slot, info)
RegisterNetEvent('Core:Server:AddItem', function(itemName, amount)
    local src = source
    print(string.format(
        '%s triggered Core:Server:AddItem by ID %s for %s %s. This event is deprecated due to exploitation, and will be removed soon. Adjust your events accordingly to do this server side with player functions.',
        GetInvokingResource(), src, amount, itemName))
end)

-- Non-Chat Command Calling (ex: bv-adminmenu)

RegisterNetEvent('Core:CallCommand', function(command, args)
    local src = source
    if not Core.Commands.List[command] then return end
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return end
    local hasPerm = Core.Functions.HasPermission(src, 'command.' .. Core.Commands.List[command].name)
    if hasPerm then
        if Core.Commands.List[command].argsrequired and #Core.Commands.List[command].arguments ~= 0 and not args[#Core.Commands.List[command].arguments] then
            TriggerClientEvent('Core:Notify', src, Lang:t('error.missing_args2'), 'error')
        else
            Core.Commands.List[command].callback(src, args)
        end
    else
        TriggerClientEvent('Core:Notify', src, Lang:t('error.no_access'), 'error')
    end
end)

-- Use this for player vehicle spawning
-- Vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
Core.Functions.CreateCallback('Core:Server:SpawnVehicle', function(source, cb, model, coords, warp)
    local veh = Core.Functions.SpawnVehicle(source, model, coords, warp)
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

-- Use this for long distance vehicle spawning
-- vehicle server-side spawning callback (netId)
-- use the netid on the client with the NetworkGetEntityFromNetworkId native
-- convert it to a vehicle via the NetToVeh native
Core.Functions.CreateCallback('Core:Server:CreateVehicle', function(source, cb, model, coords, warp)
    local veh = Core.Functions.CreateAutomobile(source, model, coords, warp)
    cb(NetworkGetNetworkIdFromEntity(veh))
end)

--Core.Functions.CreateCallback('Core:HasItem', function(source, cb, items, amount)
-- https://github.com/Core-framework/bv-inventory/blob/e4ef156d93dd1727234d388c3f25110c350b3bcf/server/main.lua#L2066
--end)
