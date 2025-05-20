local crouched = false
local handsup = false
local isPointingKeyPressed = false
local isPointing = false

-- ==========================================
-- Basically legs
local BONES = {
    --[[Pelvis]][11816] = true,          --[[SKEL_L_Thigh]][58271] = true,  --[[SKEL_L_Calf]][63931] = true,
    --[[SKEL_L_Foot]][14201] = true,     --[[SKEL_L_Toe0]][2108] = true,    --[[IK_L_Foot]][65245] = true,
    --[[PH_L_Foot]][57717] = true,       --[[MH_L_Knee]][46078] = true,     --[[SKEL_R_Thigh]][51826] = true,
    --[[SKEL_R_Calf]][36864] = true,     --[[SKEL_R_Foot]][52301] = true,   --[[SKEL_R_Toe0]][20781] = true,
    --[[IK_R_Foot]][35502] = true,       --[[PH_R_Foot]][24806] = true,     --[[MH_R_Knee]][16335] = true,
    --[[RB_L_ThighRoll]][23639] = true,  --[[RB_R_ThighRoll]][6442] = true
}

local function Disarm(ped)
    if IsEntityDead(ped) then
        return false
    end

    local boneCoords
    local hit, bone = GetPedLastDamageBone(ped)

    if hit or hit == 1 then
        if BONES[bone] then
            boneCoords = GetWorldPositionOfEntityBone(ped, GetPedBoneIndex(ped, bone))
            SetPedToRagdoll(PlayerPedId(), 5000, 5000, 0, false, false, false)
            return true
        end
    end

    return false
end

-- ==========================================
local function startPointing(ped)
    RequestAnimDict("anim@mp_point")
    while not HasAnimDictLoaded("anim@mp_point") do
        Citizen.Wait(15)
    end
    SetPedCurrentWeaponVisible(ped, false, true, true, true)
    SetPedConfigFlag(ped, 36, true)
    Citizen.InvokeNative(0x2D537BA194896636, ped, "task_mp_pointing", 0.5, 0, "anim@mp_point", 24)
    RemoveAnimDict("anim@mp_point")
end

local function stopPointing(ped)
    Citizen.InvokeNative(0xD01015C7316AE176, ped, "Stop")
    if not IsPedInjured(ped) then
        ClearPedSecondaryTask(ped)
    end
    if not IsPedInAnyVehicle(ped, true) then
        SetPedCurrentWeaponVisible(ped, true, true, true, true)
    end
    SetPedConfigFlag(ped, 36, false)
    ClearPedSecondaryTask(PlayerPedId())
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)

        local ped = PlayerPedId()

        -- ==========================================
        -- Crouching
        -- ==========================================
        if crouched then
            DisableFirstPersonCamThisFrame()
        end
        if DoesEntityExist(ped) and not IsEntityDead(ped) then
            DisableControlAction(0, 36, true) -- INPUT_DUCK / Left-Ctrl
            if not IsPauseMenuActive() then
                if IsDisabledControlJustPressed(0, 36) and not IsPedInAnyVehicle(ped, true) then
                    RequestAnimSet("move_ped_crouched")
                    while not HasAnimSetLoaded("move_ped_crouched") do
                        Citizen.Wait(50)
                    end
                    if crouched then
                        ResetPedMovementClipset(ped, 0.3)
                        ResetPedStrafeClipset(ped)
                        crouched = false
                    else
                        SetPedMovementClipset(ped, "move_ped_crouched", 0.25)
                        SetPedStrafeClipset(ped, "move_ped_crouched_strafing")
                        crouched = true
                    end
                end
            end
        end

        -- ==========================================
        -- Handsup
        -- ==========================================
        if IsControlJustPressed(1, 83) then --Start holding =
            if not handsup then
                handsup = true
                
                Core.Functions.RequestAnimDict("missminuteman_1ig_2")
                TaskPlayAnim(ped, "missminuteman_1ig_2", "handsup_enter", 8.0, 8.0, -1, 50, 0, false, false, false)

                DisableControlAction(0, 24, true) -- Attack
                DisableControlAction(0, 257, true) -- Attack 2
                DisableControlAction(0, 25, true) -- Aim
                DisableControlAction(0, 263, true) -- Melee Attack 1
    
                DisableControlAction(0, 45, true) -- Reload
                DisableControlAction(0, 37, true) -- Select Weapon
                DisableControlAction(0, 288,  true) -- Disable phone
    
                DisableControlAction(0, 47, true)  -- Disable weapon
                DisableControlAction(0, 264, true) -- Disable melee
                DisableControlAction(0, 257, true) -- Disable melee
                DisableControlAction(0, 140, true) -- Disable melee
                DisableControlAction(0, 141, true) -- Disable melee
                DisableControlAction(0, 142, true) -- Disable melee
                DisableControlAction(0, 143, true) -- Disable melee
            else
                handsup = false
                ClearPedTasks(ped)
            end
        end

        -- ==========================================
        -- Pointing
        -- ==========================================
        if not isPointingKeyPressed then
            if IsControlPressed(0, 29) and not isPointing and IsPedOnFoot(ped) then
                Wait(200)
                if not IsControlPressed(0, 29) then
                    isPointingKeyPressed = true
                    startPointing(ped)
                    isPointing = true
                else
                    isPointingKeyPressed = true
                    while IsControlPressed(0, 29) do
                        Wait(50)
                    end
                end
            elseif (IsControlPressed(0, 29) and isPointing) or (not IsPedOnFoot(ped) and isPointing) then
                isPointingKeyPressed = true
                isPointing = false
                stopPointing(ped)
            end
        end

        if isPointingKeyPressed then
            if not IsControlPressed(0, 29) then
                isPointingKeyPressed = false
            end
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, ped) and not isPointing then
            stopPointing()
        end
        if Citizen.InvokeNative(0x921CE12C489C4C41, ped) then
            if not IsPedOnFoot(ped) then
                stopPointing()
            else
                local camPitch = GetGameplayCamRelativePitch()
                if camPitch < -70.0 then
                    camPitch = -70.0
                elseif camPitch > 42.0 then
                    camPitch = 42.0
                end
                camPitch = (camPitch + 70.0) / 112.0

                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                if camHeading < -180.0 then
                    camHeading = -180.0
                elseif camHeading > 180.0 then
                    camHeading = 180.0
                end
                camHeading = (camHeading + 180.0) / 360.0

                local blocked = false
                local nn = 0

                local coords = GetOffsetFromEntityInWorldCoords(ped, (cosCamHeading * -0.2) -
                    (sinCamHeading * (0.4 * camHeading + 0.3)), (sinCamHeading * -0.2) +
                    (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                
                local ray = Cast_3dRayPointToPoint(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y,
                    coords.z + 0.2, 0.4, 95, ped, 7);

                nn, blocked, coords, coords = GetRaycastResult(ray)

                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Pitch", camPitch)
                Citizen.InvokeNative(0xD5BB4025AE449A4E, ped, "Heading", camHeading * -1.0 + 1.0)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isBlocked", blocked)
                Citizen.InvokeNative(0xB0A6CFD2C69C1088, ped, "isFirstPerson", Citizen.InvokeNative(0xEE778F8C7E1142E2, Citizen.InvokeNative(0x19CAFA3C87F7C2FF)) == 4)
            end
        end

        -- ==========================================
        -- Legshot
        -- ==========================================
        if HasEntityBeenDamagedByAnyPed(ped) then
            Disarm(ped)
        end
        
        ClearEntityLastDamageEntity(ped)
    end
end)