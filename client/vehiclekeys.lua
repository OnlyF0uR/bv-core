-----------------------
----   Variables   ----
-----------------------
local KeysList = {}
local isTakingKeys = false
local isCarjacking = false
local canCarjack = true
local AlertSend = false
local lastPickedVehicle = nil
local IsHotwiring = false
local trunkclose = true
local looped = false

local function robKeyLoop()
    if looped == false then
        looped = true
        while true do
            local sleep = 1000
            if LocalPlayer.state.isLoggedIn then
                sleep = 100

                local ped = PlayerPedId()
                local entering = GetVehiclePedIsTryingToEnter(ped)
                local carIsImmune = false
                if entering ~= 0 and not isBlacklistedVehicle(entering) then
                    sleep = 2000
                    local plate = Core.Functions.GetPlate(entering)

                    local driver = GetPedInVehicleSeat(entering, -1)
                    for _, veh in ipairs(Shared.ImmuneVehicles) do
                        if GetEntityModel(entering) == joaat(veh) then
                            carIsImmune = true
                        end
                    end
                    -- Driven vehicle logic
                    if driver ~= 0 and not IsPedAPlayer(driver) and not HasKeys(plate) and not carIsImmune then
                        if IsEntityDead(driver) then
                            if not isTakingKeys then
                                isTakingKeys = true

                                TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering),
                                    1)
                                Core.Functions.Progressbar('steal_keys', Lang:t('progress.takekeys'), 2500, false, false,
                                    {
                                        disableMovement = false,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true
                                    }, {}, {}, {}, function() -- Done
                                        TriggerServerEvent('core:server:AcquireVehicleKeys', plate)
                                        isTakingKeys = false
                                    end, function()
                                        isTakingKeys = false
                                    end)
                            end
                        elseif Shared.LockNPCDrivingCars then
                            TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 2)
                        else
                            TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(entering), 1)
                            TriggerServerEvent('core:server:AcquireVehicleKeys', plate)

                            --Make passengers flee
                            local pedsInVehicle = GetPedsInVehicle(entering)
                            for _, pedInVehicle in pairs(pedsInVehicle) do
                                if pedInVehicle ~= GetPedInVehicleSeat(entering, -1) then
                                    MakePedFlee(pedInVehicle)
                                end
                            end
                        end
                        -- Parked car logic
                    elseif driver == 0 and entering ~= lastPickedVehicle and not HasKeys(plate) and not isTakingKeys then
                        Core.Functions.TriggerCallback('core:server:checkPlayerOwned', function(playerOwned)
                            if not playerOwned then
                                if Shared.LockNPCParkedCars then
                                    TriggerServerEvent('core:server:setVehLockState',
                                        NetworkGetNetworkIdFromEntity(entering), 2)
                                else
                                    TriggerServerEvent('core:server:setVehLockState',
                                        NetworkGetNetworkIdFromEntity(entering), 1)
                                end
                            end
                        end, plate)
                    end
                end

                -- Hotwiring while in vehicle, also keeps engine off for vehicles you don't own keys to
                if IsPedInAnyVehicle(ped, false) and not IsHotwiring then
                    sleep = 1000
                    local vehicle = GetVehiclePedIsIn(ped)
                    local plate = Core.Functions.GetPlate(vehicle)

                    if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() and not HasKeys(plate) and not isBlacklistedVehicle(vehicle) and not AreKeysJobShared(vehicle) then
                        sleep = 0

                        local vehiclePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, 1.0, 0.5)
                        DrawText3D(vehiclePos.x, vehiclePos.y, vehiclePos.z, Lang:t('info.skeys'))
                        SetVehicleEngineOn(vehicle, false, false, true)

                        if IsControlJustPressed(0, 74) then
                            Hotwire(vehicle, plate)
                        end
                    end
                end

                if Shared.CarJackEnable and canCarjack then
                    local playerid = PlayerId()
                    local aiming, target = GetEntityPlayerIsFreeAimingAt(playerid)
                    if aiming and (target ~= nil and target ~= 0) then
                        if DoesEntityExist(target) and IsPedInAnyVehicle(target, false) and not IsEntityDead(target) and not IsPedAPlayer(target) then
                            local targetveh = GetVehiclePedIsIn(target)
                            for _, veh in ipairs(Shared.ImmuneVehicles) do
                                if GetEntityModel(targetveh) == joaat(veh) then
                                    carIsImmune = true
                                end
                            end
                            if GetPedInVehicleSeat(targetveh, -1) == target and not IsBlacklistedWeapon() then
                                local pos = GetEntityCoords(ped, true)
                                local targetpos = GetEntityCoords(target, true)
                                if #(pos - targetpos) < 5.0 and not carIsImmune then
                                    CarjackVehicle(target)
                                end
                            end
                        end
                    end
                end
                if entering == 0 and not IsPedInAnyVehicle(ped, false) and GetSelectedPedWeapon(ped) == `WEAPON_UNARMED` then
                    looped = false
                    break
                end
            end
            Wait(sleep)
        end
    end
end

function isBlacklistedVehicle(vehicle)
    local isBlacklisted = false
    for _, v in ipairs(Shared.NoLockVehicles) do
        if joaat(v) == GetEntityModel(vehicle) then
            isBlacklisted = true
            break;
        end
    end
    if Entity(vehicle).state.ignoreLocks or GetVehicleClass(vehicle) == 13 then isBlacklisted = true end
    return isBlacklisted
end

function addNoLockVehicles(model)
    Shared.NoLockVehicles[#Shared.NoLockVehicles + 1] = model
end

exports('addNoLockVehicles', addNoLockVehicles)

function removeNoLockVehicles(model)
    for k, v in pairs(Shared.NoLockVehicles) do
        if v == model then
            Shared.NoLockVehicles[k] = nil
        end
    end
end

exports('removeNoLockVehicles', removeNoLockVehicles)

-----------------------
---- Client Events ----
-----------------------
RegisterKeyMapping('togglelocks', Lang:t('info.tlock'), 'keyboard', 'L')
RegisterCommand('togglelocks', function()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        ToggleVehicleLocks(GetVehicle())
    else
        if Shared.UseKeyfob then
            openmenu()
        else
            ToggleVehicleLocks(GetVehicle())
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() and Core.Functions.GetPlayerData() ~= {} then
        GetKeys()
    end
end)

-- Handles state right when the player selects their character and location.
AddEventHandler('Core:Client:OnPlayerLoaded', function()
    GetKeys()
end)

-- Resets state on logout, in case of character change.
AddEventHandler('Core:Client:OnPlayerUnload', function()
    KeysList = {}
end)

RegisterNetEvent('core:client:AddKeys', function(plate)
    KeysList[plate] = true
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped)
        local vehicleplate = Core.Functions.GetPlate(vehicle)
        if plate == vehicleplate then
            SetVehicleEngineOn(vehicle, false, false, false)
        end
    end
end)

RegisterNetEvent('core:client:RemoveKeys', function(plate)
    KeysList[plate] = nil
end)

RegisterNetEvent('core:client:ToggleEngine', function()
    local EngineOn = GetIsVehicleEngineRunning(GetVehiclePedIsIn(PlayerPedId()))
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), true)
    if HasKeys(Core.Functions.GetPlate(vehicle)) then
        if EngineOn then
            SetVehicleEngineOn(vehicle, false, false, true)
        else
            SetVehicleEngineOn(vehicle, true, false, true)
        end
    end
end)

RegisterNetEvent('core:client:GiveKeys', function(id)
    local targetVehicle = GetVehicle()
    if targetVehicle then
        local targetPlate = Core.Functions.GetPlate(targetVehicle)
        if HasKeys(targetPlate) then
            if id and type(id) == 'number' then -- Give keys to specific ID
                GiveKeys(id, targetPlate)
            else
                if IsPedSittingInVehicle(PlayerPedId(), targetVehicle) then -- Give keys to everyone in vehicle
                    local otherOccupants = GetOtherPlayersInVehicle(targetVehicle)
                    for p = 1, #otherOccupants do
                        TriggerServerEvent('core:server:GiveVehicleKeys',
                            GetPlayerServerId(NetworkGetPlayerIndexFromPed(otherOccupants[p])), targetPlate)
                    end
                else -- Give keys to closest player
                    GiveKeys(GetPlayerServerId(Core.Functions.GetClosestPlayer()), targetPlate)
                end
            end
        else
            Core.Functions.Notify(Lang:t('notify.ydhk'), 'error')
        end
    end
end)

RegisterNetEvent('Core:Client:VehicleInfo', function(data)
    if data.event == 'Entering' then
        robKeyLoop()
    end
end)

RegisterNetEvent('core-weapons:client:DrawWeapon', function()
    Wait(2000)
    robKeyLoop()
end)

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = Core.Functions.GetClosestVehicle()

    if vehicle == nil or vehicle == 0 then return end
    if HasKeys(Core.Functions.GetPlate(vehicle)) then return end
    if #(pos - GetEntityCoords(vehicle)) > 2.5 then return end
    if GetVehicleDoorLockStatus(vehicle) <= 0 then return end

    local difficulty = isAdvanced and 'easy' or 'medium' -- Easy for advanced lockpick, medium by default
    local success = exports['bv-minigames']:Skillbar(difficulty)

    local chance = math.random()
    if success then
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        lastPickedVehicle = vehicle

        if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
            TriggerServerEvent('core:server:AcquireVehicleKeys', Core.Functions.GetPlate(vehicle))
        else
            Core.Functions.Notify(Lang:t('carlocks.lockpick'), 'success')
            TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(vehicle), 1)
        end
    else
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        AttemptPoliceAlert('steal')
    end

    if isAdvanced then
        if chance <= Shared.RemoveLockpickAdvanced then
            TriggerServerEvent('core:server:breakLockpick', 'advancedlockpick')
        end
    else
        if chance <= Shared.RemoveLockpickNormal then
            TriggerServerEvent('core:server:breakLockpick', 'lockpick')
        end
    end
end)
-- Backwards Compatibility ONLY -- Remove at some point --
RegisterNetEvent('core:client:SetVehicleOwner', function(plate)
    TriggerServerEvent('core:server:AcquireVehicleKeys', plate)
end)
-- Backwards Compatibility ONLY -- Remove at some point --

-----------------------
----   Functions   ----
-----------------------
function ToggleEngine(veh)
    if veh then
        local EngineOn = GetIsVehicleEngineRunning(veh)
        if not isBlacklistedVehicle(veh) then
            if HasKeys(Core.Functions.GetPlate(veh)) or AreKeysJobShared(veh) then
                if EngineOn then
                    SetVehicleEngineOn(veh, false, false, true)
                else
                    SetVehicleEngineOn(veh, true, true, true)
                end
            end
        end
    end
end

function ToggleVehicleLocks(veh)
    if veh then
        if not isBlacklistedVehicle(veh) then
            if HasKeys(Core.Functions.GetPlate(veh)) or AreKeysJobShared(veh) then
                local ped = PlayerPedId()
                local vehLockStatus, curVeh = GetVehicleDoorLockStatus(veh), GetVehiclePedIsIn(ped, false)
                local object = 0

                if curVeh == 0 then
                    if Shared.LockToggleAnimation.Prop then
                        object = CreateObject(joaat(Shared.LockToggleAnimation.Prop), 0, 0, 0, true, true, true)
                        while not DoesEntityExist(object) do Wait(1) end
                        AttachEntityToEntity(object, ped, GetPedBoneIndex(ped, Shared.LockToggleAnimation.PropBone),
                            0.1, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
                    end

                    Core.Functions.RequestAnimDict(Shared.LockToggleAnimation.AnimDict)
                    TaskPlayAnim(ped, Shared.LockToggleAnimation.AnimDict, Shared.LockToggleAnimation.Anim, 8.0, -8.0, -1,
                        52, 0, false, false, false)
                end

                Citizen.CreateThread(function()
                    if curVeh == 0 then Wait(Shared.LockToggleAnimation.WaitTime) end
                    if IsEntityPlayingAnim(ped, Shared.LockToggleAnimation.AnimDict, Shared.LockToggleAnimation.Anim, 3) then
                        StopAnimTask(ped, Shared.LockToggleAnimation.AnimDict, Shared.LockToggleAnimation.Anim, 8.0)
                    end

                    if object ~= 0 and DoesEntityExist(object) then
                        DeleteObject(object)
                        object = 0
                    end
                end)

                NetworkRequestControlOfEntity(veh)
                if vehLockStatus == 1 then
                    TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 2)
                    Core.Functions.Notify(Lang:t('carlocks.locked'), 'primary')
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'lock', 1.0)
                else
                    TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
                    Core.Functions.Notify(Lang:t('carlocks.unlocked'), 'success')
                    TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'unlock', 1.0)
                end

                SetVehicleLights(veh, 2)
                Wait(250)
                SetVehicleLights(veh, 1)
                Wait(200)
                SetVehicleLights(veh, 0)
                Wait(300)
                ClearPedTasks(ped)
            else
                Core.Functions.Notify(Lang:t('notify.ydhk'), 'error')
            end
        else
            TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
        end
    end
end

function GiveKeys(id, plate)
    local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(id))))
    if distance < 1.5 and distance > 0.0 then
        TriggerServerEvent('core:server:GiveVehicleKeys', id, plate)
    else
        Core.Functions.Notify(Lang:t('notify.nonear'), 'error')
    end
end

function GetKeys()
    Core.Functions.TriggerCallback('core:server:GetVehicleKeys', function(keysList)
        KeysList = keysList
    end)
end

function HasKeys(plate)
    return KeysList[plate]
end

exports('HasKeys', HasKeys)

-- If in vehicle returns that, otherwise tries 3 different raycasts to get the vehicle they are facing.
-- Raycasts picture: https://i.imgur.com/FRED0kV.png

function GetVehicle()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local vehicle = GetVehiclePedIsIn(PlayerPedId())
    while vehicle == 0 do
        vehicle = Core.Functions.GetClosestVehicle()
        if #(pos - GetEntityCoords(vehicle)) > Shared.LockToggleDist then
            return
        end
    end
    if not IsEntityAVehicle(vehicle) then vehicle = nil end
    return vehicle
end

function AreKeysJobShared(veh)
    local vehName = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    local vehPlate = Core.Functions.GetPlate(veh)
    if not vehName or not vehPlate then return false end

    local pData = Core.Functions.GetPlayerData()
    if not pData or not pData.job then return false end

    local jobName = Core.Functions.GetPlayerData().job.name
    local onDuty = Core.Functions.GetPlayerData().job.onduty
    for job, v in pairs(Shared.SharedKeys) do
        if job == jobName then
            if Shared.SharedKeys[job].requireOnduty and not onDuty then return false end
            for _, vehicle in pairs(v.vehicles) do
                if string.upper(vehicle) == string.upper(vehName) then
                    if not HasKeys(vehPlate) then
                        TriggerServerEvent('core:server:AcquireVehicleKeys', vehPlate)
                    end
                    return true
                end
            end
        end
    end
    return false
end

function ToggleVehicleTrunk(veh)
    if veh then
        if not isBlacklistedVehicle(veh) then
            if HasKeys(Core.Functions.GetPlate(veh)) or AreKeysJobShared(veh) then
                local ped = PlayerPedId()
                local boot = GetEntityBoneIndexByName(GetVehiclePedIsIn(PlayerPedId(), false), 'boot')
                Core.Functions.RequestAnimDict('anim@mp_player_intmenu@key_fob@')
                TaskPlayAnim(ped, 'anim@mp_player_intmenu@key_fob@', 'fob_click', 3.0, 3.0, -1, 49, 0, false, false,
                    false)
                TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 5, 'lock', 0.3)
                NetworkRequestControlOfEntity(veh)
                if boot ~= -1 or DoesEntityExist(veh) then
                    if trunkclose == true then
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleDoorOpen(veh, 5)
                        trunkclose = false
                        ClearPedTasks(ped)
                    else
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleLights(veh, 2)
                        Wait(150)
                        SetVehicleLights(veh, 0)
                        Wait(150)
                        SetVehicleDoorShut(veh, 5)
                        trunkclose = true
                        ClearPedTasks(ped)
                    end
                end
            else
                Core.Functions.Notify(Lang:t('notify.ydhk'), 'error')
            end
        else
            TriggerServerEvent('core:server:setVehLockState', NetworkGetNetworkIdFromEntity(veh), 1)
        end
    end
end

function GetOtherPlayersInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if IsPedAPlayer(pedInSeat) and pedInSeat ~= PlayerPedId() then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

function GetPedsInVehicle(vehicle)
    local otherPeds = {}
    for seat = -1, GetVehicleModelNumberOfSeats(GetEntityModel(vehicle)) - 2 do
        local pedInSeat = GetPedInVehicleSeat(vehicle, seat)
        if not IsPedAPlayer(pedInSeat) and pedInSeat ~= 0 then
            otherPeds[#otherPeds + 1] = pedInSeat
        end
    end
    return otherPeds
end

function IsBlacklistedWeapon()
    local weapon = GetSelectedPedWeapon(PlayerPedId())
    if weapon ~= nil then
        for _, v in pairs(Shared.NoCarjackWeapons) do
            if weapon == joaat(v) then
                return true
            end
        end
    end
    return false
end

function Hotwire(vehicle, plate)
    local hotwireTime = math.random(Shared.minHotwireTime, Shared.maxHotwireTime)
    local ped = PlayerPedId()
    IsHotwiring = true

    SetVehicleAlarm(vehicle, true)
    SetVehicleAlarmTimeLeft(vehicle, hotwireTime)
    Core.Functions.Progressbar('hotwire_vehicle', Lang:t('progress.hskeys'), hotwireTime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {
        animDict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        anim = 'machinic_loop_mechandplayer',
        flags = 16
    }, {}, {}, function() -- Done
        StopAnimTask(ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1.0)
        TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
        if (math.random() <= Shared.HotwireChance) then
            TriggerServerEvent('core:server:AcquireVehicleKeys', plate)
        else
            Core.Functions.Notify(Lang:t('carlocks.lockpick_failed'), 'error')
        end
        Wait(Shared.TimeBetweenHotwires)
        IsHotwiring = false
    end, function() -- Cancel
        StopAnimTask(ped, 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', 'machinic_loop_mechandplayer', 1.0)
        IsHotwiring = false
    end)
    SetTimeout(10000, function()
        AttemptPoliceAlert('steal')
    end)
    IsHotwiring = false
end

function CarjackVehicle(target)
    if not Shared.CarJackEnable then return end
    isCarjacking = true
    canCarjack = false
    Core.Functions.RequestAnimDict('mp_am_hold_up')
    local vehicle = GetVehiclePedIsUsing(target)
    local occupants = GetPedsInVehicle(vehicle)
    for p = 1, #occupants do
        local ped = occupants[p]
        CreateThread(function()
            TaskPlayAnim(ped, 'mp_am_hold_up', 'holdup_victim_20s', 8.0, -8.0, -1, 49, 0, false, false, false)
            PlayPain(ped, 6, 0)
            FreezeEntityPosition(vehicle, true)
            SetVehicleUndriveable(vehicle, true)
        end)
        Wait(math.random(200, 500))
    end
    -- Cancel progress bar if: Ped dies during robbery, car gets too far away
    CreateThread(function()
        while isCarjacking do
            local distance = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(target))
            if IsPedDeadOrDying(target) or distance > 7.5 then
                TriggerEvent('progressbar:client:cancel')
                FreezeEntityPosition(vehicle, false)
                SetVehicleUndriveable(vehicle, false)
            end
            Wait(100)
        end
    end)
    Core.Functions.Progressbar('rob_keys', Lang:t('progress.acjack'), Shared.CarjackingTime, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, nil, nil, function()
        local hasWeapon, weaponHash = GetCurrentPedWeapon(PlayerPedId(), true)
        if hasWeapon and isCarjacking then
            local carjackChance
            if Shared.CarjackChance[tostring(GetWeapontypeGroup(weaponHash))] then
                carjackChance = Shared.CarjackChance[tostring(GetWeapontypeGroup(weaponHash))]
            else
                carjackChance = 0.5
            end
            if math.random() <= carjackChance then
                local plate = Core.Functions.GetPlate(vehicle)
                for p = 1, #occupants do
                    local ped = occupants[p]
                    CreateThread(function()
                        FreezeEntityPosition(vehicle, false)
                        SetVehicleUndriveable(vehicle, false)
                        TaskLeaveVehicle(ped, vehicle, 0)
                        PlayPain(ped, 6, 0)
                        Wait(1250)
                        ClearPedTasksImmediately(ped)
                        PlayPain(ped, math.random(7, 8), 0)
                        MakePedFlee(ped)
                    end)
                end
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
                TriggerServerEvent('core:server:AcquireVehicleKeys', plate)
            else
                Core.Functions.Notify(Lang:t('notify.cjackfail'), 'error')
                FreezeEntityPosition(vehicle, false)
                SetVehicleUndriveable(vehicle, false)
                MakePedFlee(target)
                TriggerServerEvent('hud:server:GainStress', math.random(1, 4))
            end
            isCarjacking = false
            Wait(2000)
            AttemptPoliceAlert('carjack')
            Wait(Shared.DelayBetweenCarjackings)
            canCarjack = true
        end
    end, function()
        MakePedFlee(target)
        isCarjacking = false
        Wait(Shared.DelayBetweenCarjackings)
        canCarjack = true
    end)
end

function AttemptPoliceAlert(type)
    if not AlertSend then
        local chance = Shared.PoliceAlertChance
        if GetClockHours() >= 1 and GetClockHours() <= 6 then
            chance = Shared.PoliceNightAlertChance
        end
        if math.random() <= chance then
            TriggerServerEvent('police:server:policeAlert', Lang:t('info.palert') .. type)
        end
        AlertSend = true
        SetTimeout(Shared.AlertCooldown, function()
            AlertSend = false
        end)
    end
end

function MakePedFlee(ped)
    SetPedFleeAttributes(ped, 0, 0)
    TaskReactAndFleePed(ped, PlayerPedId())
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    if GetConvar('bv_locale', 'en') == 'en' then
        SetTextFont(4)
    else
        SetTextFont(1)
    end
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end
