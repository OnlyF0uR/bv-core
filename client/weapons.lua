-- Variables
local PlayerData = Core.Functions.GetPlayerData()
local CurrentWeaponData, CanShoot, MultiplierAmount, currentWeapon = {}, true, 0, nil

-- Handlers

AddEventHandler('Core:Client:OnPlayerLoaded', function()
    PlayerData = Core.Functions.GetPlayerData()
    Core.Functions.TriggerCallback('core-weapons:server:GetConfig', function(RepairPoints)
        for k, data in pairs(RepairPoints) do
            Config.WeaponRepairPoints[k].IsRepairing = data.IsRepairing
            Config.WeaponRepairPoints[k].RepairingData = data.RepairingData
        end
    end)
end)

RegisterNetEvent('Core:Client:OnPlayerUnload', function()
    for k in pairs(Config.WeaponRepairPoints) do
        Config.WeaponRepairPoints[k].IsRepairing = false
        Config.WeaponRepairPoints[k].RepairingData = {}
    end
end)

-- Functions

local function DrawText3Ds(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    AddTextComponentSubstringPlayerName(text)
    SetDrawOrigin(x, y, z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

-- Events

RegisterNetEvent('core-weapons:client:SyncRepairShops', function(NewData, key)
    Config.WeaponRepairPoints[key].IsRepairing = NewData.IsRepairing
    Config.WeaponRepairPoints[key].RepairingData = NewData.RepairingData
end)

RegisterNetEvent('core-weapons:client:EquipTint', function(weapon, tint)
    local player = PlayerPedId()
    SetPedWeaponTintIndex(player, weapon, tint)
end)

RegisterNetEvent('core-weapons:client:SetCurrentWeapon', function(data, bool)
    if data ~= false then
        CurrentWeaponData = data
    else
        CurrentWeaponData = {}
    end
    CanShoot = bool
end)

RegisterNetEvent('core-weapons:client:SetWeaponQuality', function(amount)
    if CurrentWeaponData and next(CurrentWeaponData) then
        TriggerServerEvent('core-weapons:server:SetWeaponQuality', CurrentWeaponData, amount)
    end
end)

RegisterNetEvent('core-weapons:client:AddAmmo', function(ammoType, amount, itemData)
    local ped = PlayerPedId()
    local weapon = GetSelectedPedWeapon(ped)

    if not CurrentWeaponData then
        Core.Functions.Notify(Lang:t('error.no_weapon'), 'error')
        return
    end

    if Core.Shared.Weapons[weapon]['name'] == 'weapon_unarmed' then
        Core.Functions.Notify(Lang:t('error.no_weapon_in_hand'), 'error')
        return
    end

    if Core.Shared.Weapons[weapon]['ammotype'] ~= ammoType:upper() then
        Core.Functions.Notify(Lang:t('error.wrong_ammo'), 'error')
        return
    end

    local total = GetAmmoInPedWeapon(ped, weapon)
    local _, maxAmmo = GetMaxAmmo(ped, weapon)

    if total >= maxAmmo then
        Core.Functions.Notify(Lang:t('error.max_ammo'), 'error')
        return
    end

    Core.Functions.Progressbar('taking_bullets', Lang:t('info.loading_bullets'), Config.ReloadTime, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        weapon = GetSelectedPedWeapon(ped) -- Get weapon at time of completion

        if Core.Shared.Weapons[weapon]?.ammotype ~= ammoType then
            return Core.Functions.Notify(Lang:t('error.wrong_ammo'), 'error')
        end

        AddAmmoToPed(ped, weapon, amount)
        TaskReloadWeapon(ped, false)
        TriggerServerEvent('core-weapons:server:UpdateWeaponAmmo', CurrentWeaponData, total + amount)
        TriggerServerEvent('core-weapons:server:removeWeaponAmmoItem', itemData)
        TriggerEvent('qb-inventory:client:ItemBox', Core.Shared.Items[itemData.name], 'remove')
        TriggerEvent('Core:Notify', Lang:t('success.reloaded'), 'success')
    end, function()
        Core.Functions.Notify(Lang:t('error.canceled'), 'error')
    end)
end)

RegisterNetEvent('core-weapons:client:UseWeapon', function(weaponData, shootbool)
    local ped = PlayerPedId()
    local weaponName = tostring(weaponData.name)
    local weaponHash = joaat(weaponData.name)
    if currentWeapon == weaponName then
        TriggerEvent('core-weapons:client:DrawWeapon', nil)
        SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
        RemoveAllPedWeapons(ped, true)
        TriggerEvent('core-weapons:client:SetCurrentWeapon', nil, shootbool)
        currentWeapon = nil
    elseif weaponName == 'weapon_stickybomb' or weaponName == 'weapon_pipebomb' or weaponName == 'weapon_smokegrenade' or weaponName == 'weapon_flare' or weaponName == 'weapon_proxmine' or weaponName == 'weapon_ball' or weaponName == 'weapon_molotov' or weaponName == 'weapon_grenade' or weaponName == 'weapon_bzgas' then
        TriggerEvent('core-weapons:client:DrawWeapon', weaponName)
        GiveWeaponToPed(ped, weaponHash, 1, false, false)
        SetPedAmmo(ped, weaponHash, 1)
        SetCurrentPedWeapon(ped, weaponHash, true)
        TriggerEvent('core-weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    elseif weaponName == 'weapon_snowball' then
        TriggerEvent('core-weapons:client:DrawWeapon', weaponName)
        GiveWeaponToPed(ped, weaponHash, 10, false, false)
        SetPedAmmo(ped, weaponHash, 10)
        SetCurrentPedWeapon(ped, weaponHash, true)
        TriggerServerEvent('qb-inventory:server:snowball', 'remove')
        TriggerEvent('core-weapons:client:SetCurrentWeapon', weaponData, shootbool)
        currentWeapon = weaponName
    else
        TriggerEvent('core-weapons:client:DrawWeapon', weaponName)
        TriggerEvent('core-weapons:client:SetCurrentWeapon', weaponData, shootbool)
        local ammo = tonumber(weaponData.info.ammo) or 0

        if weaponName == 'weapon_petrolcan' or weaponName == 'weapon_fireextinguisher' then
            ammo = 4000
        end

        GiveWeaponToPed(ped, weaponHash, ammo, false, false)
        SetPedAmmo(ped, weaponHash, ammo)
        SetCurrentPedWeapon(ped, weaponHash, true)

        if weaponData.info.attachments then
            for _, attachment in pairs(weaponData.info.attachments) do
                GiveWeaponComponentToPed(ped, weaponHash, joaat(attachment.component))
            end
        end

        if weaponData.info.tint then
            SetPedWeaponTintIndex(ped, weaponHash, weaponData.info.tint)
        end

        currentWeapon = weaponName
    end
end)

RegisterNetEvent('core-weapons:client:CheckWeapon', function(weaponName)
    if currentWeapon ~= weaponName:lower() then return end
    local ped = PlayerPedId()
    TriggerEvent('core-weapons:ResetHolster')
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
    RemoveAllPedWeapons(ped, true)
    currentWeapon = nil
end)

-- Threads

CreateThread(function()
    SetWeaponsNoAutoswap(true)
end)

CreateThread(function()
    while true do
        local ped = PlayerPedId()
        if IsPedArmed(ped, 7) == 1 and (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
            local weapon = GetSelectedPedWeapon(ped)
            local ammo = GetAmmoInPedWeapon(ped, weapon)
            TriggerServerEvent('core-weapons:server:UpdateWeaponAmmo', CurrentWeaponData, tonumber(ammo))
            if MultiplierAmount > 0 then
                TriggerServerEvent('core-weapons:server:UpdateWeaponQuality', CurrentWeaponData, MultiplierAmount)
                MultiplierAmount = 0
            end
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local ped = PlayerPedId()
            if CurrentWeaponData and next(CurrentWeaponData) then
                if IsPedShooting(ped) or IsControlJustPressed(0, 24) then
                    local weapon = GetSelectedPedWeapon(ped)
                    if CanShoot then
                        if weapon and weapon ~= 0 and Core.Shared.Weapons[weapon] then
                            Core.Functions.TriggerCallback('prison:server:checkThrowable', function(result)
                                if result or GetAmmoInPedWeapon(ped, weapon) <= 0 then return end
                                MultiplierAmount += 1
                            end, weapon)
                            Wait(200)
                        end
                    else
                        if weapon ~= `WEAPON_UNARMED` then
                            TriggerEvent('core-weapons:client:CheckWeapon', Core.Shared.Weapons[weapon]['name'])
                            Core.Functions.Notify(Lang:t('error.weapon_broken'), 'error')
                            MultiplierAmount = 0
                        end
                    end
                end
            end
        end
        Wait(0)
    end
end)

CreateThread(function()
    while true do
        if LocalPlayer.state.isLoggedIn then
            local inRange = false
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            for k, data in pairs(Config.WeaponRepairPoints) do
                local distance = #(pos - data.coords)
                if distance < 10 then
                    inRange = true
                    if distance < 1 then
                        if data.IsRepairing then
                            if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                                DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.repairshop_not_usable'))
                            else
                                if not data.RepairingData.Ready then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.weapon_will_repair'))
                                else
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.take_weapon_back'))
                                end
                            end
                        else
                            if CurrentWeaponData and next(CurrentWeaponData) then
                                if not data.RepairingData.Ready then
                                    local WeaponData = Core.Shared.Weapons[GetHashKey(CurrentWeaponData.name)]
                                    local WeaponClass = (Core.Shared.SplitStr(WeaponData.ammotype, '_')[2]):lower()
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.repair_weapon_price', { value = Config.WeaponRepairCosts[WeaponClass] }))
                                    if IsControlJustPressed(0, 38) then
                                        Core.Functions.TriggerCallback('core-weapons:server:RepairWeapon', function(HasMoney)
                                            if HasMoney then
                                                CurrentWeaponData = {}
                                            end
                                        end, k, CurrentWeaponData)
                                    end
                                else
                                    if data.RepairingData.CitizenId ~= PlayerData.citizenid then
                                        DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.repairshop_not_usable'))
                                    else
                                        DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.take_weapon_back'))
                                        if IsControlJustPressed(0, 38) then
                                            TriggerServerEvent('core-weapons:server:TakeBackWeapon', k, data)
                                        end
                                    end
                                end
                            else
                                if data.RepairingData.CitizenId == nil then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('error.no_weapon_in_hand'))
                                elseif data.RepairingData.CitizenId == PlayerData.citizenid then
                                    DrawText3Ds(data.coords.x, data.coords.y, data.coords.z, Lang:t('info.take_weapon_back'))
                                    if IsControlJustPressed(0, 38) then
                                        TriggerServerEvent('core-weapons:server:TakeBackWeapon', k, data)
                                    end
                                end
                            end
                        end
                    end
                end
            end
            if not inRange then
                Wait(1000)
            end
        end
        Wait(0)
    end
end)

local recoils = {
  -- Handguns
  [`weapon_pistol`] = 0.3,
  [`weapon_pistol_mk2`] = 0.5,
  [`weapon_combatpistol`] = 0.2,
  [`weapon_appistol`] = 0.3,
  [`weapon_stungun`] = 0.1,
  [`weapon_pistol50`] = 0.6,
  [`weapon_snspistol`] = 0.2,
  [`weapon_heavypistol`] = 0.5,
  [`weapon_vintagepistol`] = 0.4,
  [`weapon_flaregun`] = 0.9,
  [`weapon_marksmanpistol`] = 0.9,
  [`weapon_revolver`] = 0.6,
  [`weapon_revolver_mk2`] = 0.6,
  [`weapon_doubleaction`] = 0.3,
  [`weapon_snspistol_mk2`] = 0.3,
  [`weapon_raypistol`] = 0.3,
  [`weapon_ceramicpistol`] = 0.3,
  [`weapon_navyrevolver`] = 0.3,
  [`weapon_gadgetpistol`] = 0.3,
  [`weapon_pistolxm3`] = 0.4,

  -- Submachine Guns
  [`weapon_microsmg`] = 0.5,
  [`weapon_smg`] = 0.4,
  [`weapon_smg_mk2`] = 0.1,
  [`weapon_assaultsmg`] = 0.1,
  [`weapon_combatpdw`] = 0.2,
  [`weapon_machinepistol`] = 0.3,
  [`weapon_minismg`] = 0.1,
  [`weapon_raycarbine`] = 0.3,
  [`weapon_tecpistol`] = 0.3,

  -- Shotguns
  [`weapon_pumpshotgun`] = 0.4,
  [`weapon_sawnoffshotgun`] = 0.7,
  [`weapon_assaultshotgun`] = 0.4,
  [`weapon_bullpupshotgun`] = 0.2,
  [`weapon_musket`] = 0.7,
  [`weapon_heavyshotgun`] = 0.2,
  [`weapon_dbshotgun`] = 0.7,
  [`weapon_autoshotgun`] = 0.2,
  [`weapon_pumpshotgun_mk2`] = 0.4,
  [`weapon_combatshotgun`] = 0.0,

  -- Assault Rifles
  [`weapon_assaultrifle`] = 0.5,
  [`weapon_assaultrifle_mk2`] = 0.2,
  [`weapon_carbinerifle`] = 0.3,
  [`weapon_carbinerifle_mk2`] = 0.1,
  [`weapon_advancedrifle`] = 0.1,
  [`weapon_specialcarbine`] = 0.2,
  [`weapon_bullpuprifle`] = 0.2,
  [`weapon_compactrifle`] = 0.3,
  [`weapon_specialcarbine_mk2`] = 0.2,
  [`weapon_bullpuprifle_mk2`] = 0.2,
  [`weapon_militaryrifle`] = 0.0,
  [`weapon_heavyrifle`] = 0.3,
  [`weapon_tacticalrifle`] = 0.2,

  -- Light Machine Guns
  [`weapon_mg`] = 0.1,
  [`weapon_combatmg`] = 0.1,
  [`weapon_gusenberg`] = 0.1,
  [`weapon_combatmg_mk2`] = 0.1,

  -- Sniper Rifles
  [`weapon_sniperrifle`] = 0.5,
  [`weapon_heavysniper`] = 0.7,
  [`weapon_marksmanrifle`] = 0.3,
  [`weapon_remotesniper`] = 1.2,
  [`weapon_heavysniper_mk2`] = 0.6,
  [`weapon_marksmanrifle_mk2`] = 0.3,
  [`weapon_precisionrifle`] = 0.3,

  -- Heavy Weapons
  [`weapon_rpg`] = 0.0,
  [`weapon_grenadelauncher`] = 1.0,
  [`weapon_grenadelauncher_smoke`] = 1.0,
  [`weapon_minigun`] = 0.1,
  [`weapon_firework`] = 0.3,
  [`weapon_railgun`] = 2.4,
  [`weapon_hominglauncher`] = 0.0,
  [`weapon_compactlauncher`] = 0.5,
  [`weapon_rayminigun`] = 0.3,
}

AddEventHandler('CEventGunShot', function(entities, eventEntity, args)
  local ped = PlayerPedId()
  if eventEntity ~= ped then return end
  if IsPedDoingDriveby(ped) then return end
  local _, weap = GetCurrentPedWeapon(ped, false)
  if recoils[weap] and recoils[weap] ~= 0 then
      local tv = 0
      if GetFollowPedCamViewMode() ~= 4 then
          repeat
              Wait(0)
              local p = GetGameplayCamRelativePitch()
              SetGameplayCamRelativePitch(p + 0.1, 0.2)
              tv += 0.1
          until tv >= recoils[weap]
      else
          repeat
              Wait(0)
              local p = GetGameplayCamRelativePitch()
              if recoils[weap] > 0.1 then
                  SetGameplayCamRelativePitch(p + 0.6, 1.2)
                  tv += 0.6
              else
                  SetGameplayCamRelativePitch(p + 0.016, 0.333)
                  tv += 0.1
              end
          until tv >= recoils[weap]
      end
  end
end)

local weapons = {
  'WEAPON_KNIFE',
  'WEAPON_NIGHTSTICK',
  'WEAPON_BREAD',
  'WEAPON_FLASHLIGHT',
  'WEAPON_HAMMER',
  'WEAPON_BAT',
  'WEAPON_GOLFCLUB',
  'WEAPON_CROWBAR',
  'WEAPON_BOTTLE',
  'WEAPON_DAGGER',
  'WEAPON_HATCHET',
  'WEAPON_MACHETE',
  'WEAPON_SWITCHBLADE',
  'WEAPON_BATTLEAXE',
  'WEAPON_POOLCUE',
  'WEAPON_WRENCH',
  'WEAPON_PISTOL',
  'WEAPON_PISTOL_MK2',
  'WEAPON_COMBATPISTOL',
  'WEAPON_APPISTOL',
  'WEAPON_PISTOL50',
  'WEAPON_REVOLVER',
  'WEAPON_SNSPISTOL',
  'WEAPON_HEAVYPISTOL',
  'WEAPON_VINTAGEPISTOL',
  'WEAPON_MICROSMG',
  'WEAPON_SMG',
  'WEAPON_ASSAULTSMG',
  'WEAPON_MINISMG',
  'WEAPON_MACHINEPISTOL',
  'WEAPON_COMBATPDW',
  'WEAPON_PUMPSHOTGUN',
  'WEAPON_SAWNOFFSHOTGUN',
  'WEAPON_ASSAULTSHOTGUN',
  'WEAPON_BULLPUPSHOTGUN',
  'WEAPON_HEAVYSHOTGUN',
  'WEAPON_ASSAULTRIFLE',
  'WEAPON_CARBINERIFLE',
  'WEAPON_ADVANCEDRIFLE',
  'WEAPON_SPECIALCARBINE',
  'WEAPON_BULLPUPRIFLE',
  'WEAPON_COMPACTRIFLE',
  'WEAPON_MG',
  'WEAPON_COMBATMG',
  'WEAPON_GUSENBERG',
  'WEAPON_SNIPERRIFLE',
  'WEAPON_HEAVYSNIPER',
  'WEAPON_MARKSMANRIFLE',
  'WEAPON_GRENADELAUNCHER',
  'WEAPON_RPG',
  'WEAPON_STINGER',
  'WEAPON_MINIGUN',
  'WEAPON_GRENADE',
  'WEAPON_STICKYBOMB',
  'WEAPON_SMOKEGRENADE',
  'WEAPON_BZGAS',
  'WEAPON_MOLOTOV',
  'WEAPON_DIGISCANNER',
  'WEAPON_FIREWORK',
  'WEAPON_MUSKET',
  'WEAPON_STUNGUN',
  'WEAPON_HOMINGLAUNCHER',
  'WEAPON_PROXMINE',
  'WEAPON_FLAREGUN',
  'WEAPON_MARKSMANPISTOL',
  'WEAPON_RAILGUN',
  'WEAPON_DBSHOTGUN',
  'WEAPON_AUTOSHOTGUN',
  'WEAPON_COMPACTLAUNCHER',
  'WEAPON_PIPEBOMB',
  'WEAPON_DOUBLEACTION',
  'WEAPON_SNOWBALL',
  'WEAPON_PISTOLXM3',
  'WEAPON_CANDYCANE',
  'WEAPON_CERAMICPISTOL',
  'WEAPON_NAVYREVOLVER',
  'WEAPON_GADGETPISTOL',
  'WEAPON_PISTOLXM3',
  'WEAPON_TECPISTOL',
  'WEAPON_HEAVYRIFLE',
  'WEAPON_MILITARYRIFLE',
  'WEAPON_TACTICALRIFLE',
  'WEAPON_SWEEPERSHOTGUN',
  'WEAPON_ASSAULTRIFLE_MK2',
  'WEAPON_BULLPUPRIFLE_MK2',
  'WEAPON_CARBINERIFLE_MK2',
  'WEAPON_COMBATMG_MK2',
  'WEAPON_HEAVYSNIPER_MK2',
  'WEAPON_KNUCKLE',
  'WEAPON_MARKSMANRIFLE_MK2',
  'WEAPON_PRECISIONRIFLE',
  'WEAPON_PETROLCAN',
  'WEAPON_PUMPSHOTGUN_MK2',
  'WEAPON_RAYCARBINE',
  'WEAPON_RAYMINIGUN',
  'WEAPON_RAYPISTOL',
  'WEAPON_REVOLVER_MK2',
  'WEAPON_SMG_MK2',
  'WEAPON_SNSPISTOL_MK2',
  'WEAPON_SPECIALCARBINE_MK2',
  'WEAPON_STONE_HATCHET'
}

local holstered = true
local canFire = true
local currWeap = `WEAPON_UNARMED`
local currHolster = nil
local currHolsterTexture = nil
local wearingHolster = nil

local function loadAnimDict(dict)
  if HasAnimDictLoaded(dict) then return end
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
      Wait(10)
  end
end

local function checkWeapon(newWeap)
  for i = 1, #weapons do
      if joaat(weapons[i]) == newWeap then
          return true
      end
  end
  return false
end

local function isWeaponHolsterable(weap)
  for i = 1, #Config.WeapDraw.weapons do
      if joaat(Config.WeapDraw.weapons[i]) == weap then
          return true
      end
  end
  return false
end

RegisterNetEvent('core-weapons:ResetHolster', function()
  holstered = true
  canFire = true
  currWeap = `WEAPON_UNARMED`
  currHolster = nil
  currHolsterTexture = nil
  wearingHolster = nil
end)

RegisterNetEvent('core-weapons:client:DrawWeapon', function()
  if GetResourceState('qb-inventory') == 'missing' then return end
  local sleep
  local weaponCheck = 0
  while true do
      local ped = PlayerPedId()
      sleep = 250
      if DoesEntityExist(ped) and not IsEntityDead(ped) and not IsPedInParachuteFreeFall(ped) and not IsPedFalling(ped) and (GetPedParachuteState(ped) == -1 or GetPedParachuteState(ped) == 0) then
          sleep = 0
          if currWeap ~= GetSelectedPedWeapon(ped) then
              local pos = GetEntityCoords(ped, true)
              local rot = GetEntityHeading(ped)

              local newWeap = GetSelectedPedWeapon(ped)
              SetCurrentPedWeapon(ped, currWeap, true)
              loadAnimDict('reaction@intimidation@1h')
              loadAnimDict('reaction@intimidation@cop@unarmed')
              loadAnimDict('rcmjosh4')
              loadAnimDict('weapons@pistol@')

              local holsterVariant = GetPedDrawableVariation(ped, 8)
              wearingHolster = false
              for i = 1, #Config.WeapDraw.variants, 1 do
                  if holsterVariant == Config.WeapDraw.variants[i] then
                      wearingHolster = true
                  end
              end
              if checkWeapon(newWeap) then
                  if holstered then
                      if wearingHolster then
                          --TaskPlayAnim(ped, 'rcmjosh4', 'josh_leadout_cop2', 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
                          canFire = false
                          CeaseFire()
                          currHolster = GetPedDrawableVariation(ped, 7)
                          currHolsterTexture = GetPedTextureVariation(ped, 7)
                          TaskPlayAnimAdvanced(ped, 'rcmjosh4', 'josh_leadout_cop2', pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(300)
                          SetCurrentPedWeapon(ped, newWeap, true)

                          if isWeaponHolsterable(newWeap) then
                              SetPedComponentVariation(ped, 7, currHolster == 8 and 2 or currHolster == 1 and 3 or currHolster == 6 and 5, currHolsterTexture, 2)
                          end
                          currWeap = newWeap
                          Wait(300)
                          ClearPedTasks(ped)
                          holstered = false
                          canFire = true
                      else
                          canFire = false
                          CeaseFire()
                          TaskPlayAnimAdvanced(ped, 'reaction@intimidation@1h', 'intro', pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(1000)
                          SetCurrentPedWeapon(ped, newWeap, true)
                          currWeap = newWeap
                          Wait(1400)
                          ClearPedTasks(ped)
                          holstered = false
                          canFire = true
                      end
                  elseif newWeap ~= currWeap and checkWeapon(currWeap) then
                      if wearingHolster then
                          canFire = false
                          CeaseFire()

                          TaskPlayAnimAdvanced(ped, 'reaction@intimidation@cop@unarmed', 'intro', pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(500)

                          if isWeaponHolsterable(currWeap) then
                              SetPedComponentVariation(ped, 7, currHolster, currHolsterTexture, 2)
                          end

                          SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                          currHolster = GetPedDrawableVariation(ped, 7)
                          currHolsterTexture = GetPedTextureVariation(ped, 7)

                          TaskPlayAnimAdvanced(ped, 'rcmjosh4', 'josh_leadout_cop2', pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(300)
                          SetCurrentPedWeapon(ped, newWeap, true)

                          if isWeaponHolsterable(newWeap) then
                              SetPedComponentVariation(ped, 7, currHolster == 8 and 2 or currHolster == 1 and 3 or currHolster == 6 and 5, currHolsterTexture, 2)
                          end

                          Wait(500)
                          currWeap = newWeap
                          ClearPedTasks(ped)
                          holstered = false
                          canFire = true
                      else
                          canFire = false
                          CeaseFire()
                          TaskPlayAnimAdvanced(ped, 'reaction@intimidation@1h', 'outro', pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(1600)
                          SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                          TaskPlayAnimAdvanced(ped, 'reaction@intimidation@1h', 'intro', pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(1000)
                          SetCurrentPedWeapon(ped, newWeap, true)
                          currWeap = newWeap
                          Wait(1400)
                          ClearPedTasks(ped)
                          holstered = false
                          canFire = true
                      end
                  else
                      if wearingHolster then
                          SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                          currHolster = GetPedDrawableVariation(ped, 7)
                          currHolsterTexture = GetPedTextureVariation(ped, 7)
                          TaskPlayAnimAdvanced(ped, 'rcmjosh4', 'josh_leadout_cop2', pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(300)
                          SetCurrentPedWeapon(ped, newWeap, true)

                          if isWeaponHolsterable(newWeap) then
                              SetPedComponentVariation(ped, 7, currHolster == 8 and 2 or currHolster == 1 and 3 or currHolster == 6 and 5, currHolsterTexture, 2)
                          end

                          currWeap = newWeap
                          Wait(300)
                          ClearPedTasks(ped)
                          holstered = false
                          canFire = true
                      else
                          SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                          TaskPlayAnimAdvanced(ped, 'reaction@intimidation@1h', 'intro', pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(1000)
                          SetCurrentPedWeapon(ped, newWeap, true)
                          currWeap = newWeap
                          Wait(1400)
                          ClearPedTasks(ped)
                          holstered = false
                          canFire = true
                      end
                  end
              else
                  if not holstered and checkWeapon(currWeap) then
                      if wearingHolster then
                          canFire = false
                          CeaseFire()
                          TaskPlayAnimAdvanced(ped, 'reaction@intimidation@cop@unarmed', 'intro', pos.x, pos.y, pos.z, 0, 0, rot, 3.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(500)

                          if isWeaponHolsterable(currWeap) then
                              SetPedComponentVariation(ped, 7, currHolster, currHolsterTexture, 2)
                          end

                          SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                          ClearPedTasks(ped)
                          SetCurrentPedWeapon(ped, newWeap, true)
                          holstered = true
                          canFire = true
                          currWeap = newWeap
                      else
                          canFire = false
                          CeaseFire()
                          TaskPlayAnimAdvanced(ped, 'reaction@intimidation@1h', 'outro', pos.x, pos.y, pos.z, 0, 0, rot, 8.0, 3.0, -1, 50, 0, 0, 0)
                          Wait(1400)
                          SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
                          ClearPedTasks(ped)
                          SetCurrentPedWeapon(ped, newWeap, true)
                          holstered = true
                          canFire = true
                          currWeap = newWeap
                      end
                  else
                      SetCurrentPedWeapon(ped, newWeap, true)
                      holstered = false
                      canFire = true
                      currWeap = newWeap
                  end
              end
          end
      end
      Wait(sleep)
      if currWeap == nil or currWeap == `WEAPON_UNARMED` then
          weaponCheck += 1
          if weaponCheck == 2 then
              break
          end
      end
  end
end)

function CeaseFire()
  CreateThread(function()
      if GetResourceState('qb-inventory') == 'missing' then return end
      while not canFire do
          DisableControlAction(0, 25, true)
          DisablePlayerFiring(PlayerId(), true)
          Wait(0)
      end
  end)
end