local TimerEnabled = false

local function TryTackle()
  if not TimerEnabled then
    t, distance = Core.Game.GetClosestPlayer()
    if (distance ~= -1 and distance < 2) then
      -- local maxheading = (GetEntityHeading(PlayerPedId()) + 15.0)
      -- local minheading = (GetEntityHeading(PlayerPedId()) - 15.0)
      -- local theading = (GetEntityHeading(t))

      TriggerServerEvent('core-adapters:server:SendTackle', GetPlayerServerId(t))
    end

    if not IsPedRagdoll(PlayerPedId()) then
      local lPed = PlayerPedId()
      RequestAnimDict("swimming@first_person@diving")
      while not HasAnimDictLoaded("swimming@first_person@diving") do
        Citizen.Wait(1)
      end

      if IsEntityPlayingAnim(lPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 3) then
        ClearPedSecondaryTask(lPed)
      else
        TaskPlayAnim(lPed, "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
        seccount = 3
        while seccount > 0 do
          Citizen.Wait(100)
          seccount = seccount - 1
        end
        ClearPedSecondaryTask(lPed)
        SetPedToRagdoll(PlayerPedId(), 150, 150, 0, 0, 0, 0)
      end
    end

    TimerEnabled = true
    Citizen.Wait(4500)
    TimerEnabled = false
  end
end

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5)

    if IsControlPressed(0, 61) and IsControlPressed(0, 47) then
      Citizen.Wait(10)
      local closestPlayer, _distance = Core.Game.GetClosestPlayer()

      local playerPed = PlayerPedId()
      if not IsPedInAnyVehicle(playerPed) and not IsPedRagdoll(playerPed) and not IsPedInAnyVehicle(GetPlayerPed(closestPlayer)) then
        TryTackle()
      end
    end
  end
end)

RegisterNetEvent('core-adapters:client:GetTackled', function()
  SetPedToRagdoll(PlayerPedId(), math.random(8500), math.random(8500), 0, 0, 0, 0)

  TimerEnabled = true
  Citizen.Wait(1500)
  TimerEnabled = false
end)
