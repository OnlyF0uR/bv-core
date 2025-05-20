local recoils = {
  [453432689] = 0.3, -- PISTOL
  [1593441988] = 0.2, -- COMBAT PISTOL
  [584646201] = 0.15, -- AP PISTOL
  [2578377531] = 0.6, -- PISTOL .50
  [324215364] = 0.25, -- MICRO SMG
  [736523883] = 0.1, -- SMG
  [3220176749] = 0.2, -- ASSAULT RIFLE
  [2210333304] = 0.1, -- CARBINE RIFLE
  [911657153] = 0.1, -- STUN GUN
  [100416529] = 0.5, -- SNIPER RIFLE
  [205991906] = 0.7, -- HEAVY SNIPER
  [3218215474] = 0.2, -- SNS PISTOL
  [3231910285] = 0.2, -- SPECIAL CARBINE
  [3523564046] = 0.5, -- HEAVY PISTOL
  [137902532] = 0.4, -- VINTAGE PISTOL
  [3675956304] = 0.3, -- MACHINE PISTOL
  [3173288789] = 0.35 -- MINI SMG     
}

Citizen.CreateThread(function()
  while true do
      HideHudComponentThisFrame(14)
      Wait(0)
  end
end)

Citizen.CreateThread(function()
  while true do
      local ped = PlayerPedId()
      local weapon = GetSelectedPedWeapon(ped)

      -- Disable melee while aiming (may be not working)
      if IsPedArmed(ped, 6) then
          DisableControlAction(1, 140, true)
          DisableControlAction(1, 141, true)
          DisableControlAction(1, 142, true)

          -- 100416529 WEAPON_SNIPERRIFLE
          -- 205991906 WEAPON_HEAVYSNIPER
          -- if weapon ~= 100416529 and weapon ~= 205991906 then
          --     -- Disable reticle
          --     HideHudComponentThisFrame(14)
          -- end
      end

      -- Disable ammo HUD
      -- DisplayAmmoThisFrame(false)

      -- Pistol
      if weapon == GetHashKey("WEAPON_STUNGUN") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.01)
          end
      end

      if weapon == GetHashKey("WEAPON_FLAREGUN") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.01)
          end
      end

      if weapon == GetHashKey("WEAPON_SNSPISTOL") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.02)
          end
      end

      if weapon == GetHashKey("WEAPON_PISTOL") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.025)
          end
      end

      if weapon == GetHashKey("WEAPON_APPISTOL") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
          end
      end

      if weapon == GetHashKey("WEAPON_COMBATPISTOL") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.03)
          end
      end

      if weapon == GetHashKey("WEAPON_PISTOL50") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.05)
          end
      end

      if weapon == GetHashKey("WEAPON_HEAVYPISTOL") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.045)
          end
      end

      if weapon == GetHashKey("WEAPON_VINTAGEPISTOL") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.025)
          end
      end

      -- SMG

      if weapon == GetHashKey("WEAPON_MICROSMG") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.035)
          end
      end

      if weapon == GetHashKey("WEAPON_SMG") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.045)
          end
      end

      if weapon == GetHashKey("WEAPON_MACHINEPISTOL") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.035)
          end
      end

      if weapon == GetHashKey("WEAPON_MINISMG") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.052)
          end
      end

      -- Rifles
      
      if weapon == GetHashKey("WEAPON_ASSAULTRIFLE") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.07)
          end
      end

      if weapon == GetHashKey("WEAPON_CARBINERIFLE") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.06)
          end
      end

      if weapon == GetHashKey("WEAPON_SPECIALCARBINE") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.06)
          end
      end

     
      -- Sniper

      if weapon == GetHashKey("WEAPON_SNIPERRIFLE") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.2)
          end
      end

      if weapon == GetHashKey("WEAPON_HEAVYSNIPER") then
          if IsPedShooting(ped) then
              ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
          end
      end

      -- Infinite FireExtinguisher
      -- if weapon == GetHashKey("WEAPON_FIREEXTINGUISHER") then
      --     if IsPedShooting(ped) then
      --         SetPedInfiniteAmmo(ped, true, GetHashKey("WEAPON_FIREEXTINGUISHER"))
      --     end
      -- end

      if IsPedShooting(ped) and not IsPedDoingDriveby(ped) then
          if recoils[weapon] and recoils[weapon] ~= 0 then
              tv = 0
              repeat
                  Wait(0)
                  p = GetGameplayCamRelativePitch()
                  if GetFollowPedCamViewMode() ~= 4 then
                      SetGameplayCamRelativePitch(p + 0.1, 0.2)
                  end
                  tv = tv + 0.1
              until tv >= recoils[weapon]
          end
      end

      Wait(5)
  end
end)