local suppressedModels = {
	"SHAMAL", -- They spawn on LSIA and try to take off
	"LUXOR", -- They spawn on LSIA and try to take off
	"LUXOR2", -- They spawn on LSIA and try to take off
	"JET", -- They spawn on LSIA and try to take off and land, remove this if you still want em in the skies
	"LAZER", -- They spawn on Zancudo and try to take off
	"TITAN", -- They spawn on Zancudo and try to take off
	"BARRACKS", -- Regularily driving around the Zancudo airport surface
	"BARRACKS2", -- Regularily driving around the Zancudo airport surface
	"CRUSADER", -- Regularily driving around the Zancudo airport surface
	"RHINO", -- Regularily driving around the Zancudo airport surface
	"AIRTUG", -- Regularily spawns on the LSsIA airport surface
	"RIPLEY", -- Regularily spawns on the LSIA airport surface
	"POLICEB", -- Regularily spawns on MRPD
}

Citizen.CreateThread(function()
	while true do
	  Wait(0)

	    -- Remove dispatch vehicles
		for i = 1, 20 do
			EnableDispatchService(i, false)
		end

		local pid = PlayerId()
		SetPlayerWantedLevel(pid, 0, false)
		SetPlayerWantedLevelNow(pid, false)
		SetPlayerWantedLevelNoDrop(pid, 0, false)

		-- Redu locals
	  SetVehicleDensityMultiplierThisFrame(0.1) -- traffic density
	  SetPedDensityMultiplierThisFrame(0.2) -- npc/ai peds density
	  SetRandomVehicleDensityMultiplierThisFrame(0.1) -- random vehicles (car scenarios / cars driving off from a parking spot etc.)
	  SetParkedVehicleDensityMultiplierThisFrame(0.0) -- random parked vehicles (parked car scenarios)
	  SetScenarioPedDensityMultiplierThisFrame(0.0, 0.0) -- npc/ai peds or scenario peds
		
		-- SetGarbageTrucks(false) -- Stop garbage trucks from randomly spawning
		-- SetRandomBoats(false) -- Stop random boats from spawning in the water.
		SetCreateRandomCops(false) -- disable random cops walking/driving around.
		SetCreateRandomCopsNotOnScenarios(false) -- stop random cops (not in a scenario) from spawning.
		SetCreateRandomCopsOnScenarios(false) -- stop random cops (in a scenario) from spawning.

		for _, model in next, suppressedModels do
      SetVehicleModelIsSuppressed(GetHashKey(model), true)
    end

		local ped = PlayerPedId()
		SetPedConfigFlag(ped, 35, false) -- CPED_CONFIG_FLAG_UseHelmet
		SetPedConfigFlag(ped, 149, true) -- _0x1A15670B
		SetPedConfigFlag(ped, 438, true) -- CPED_CONFIG_FLAG_DisableHelmetArmor

		DisablePlayerVehicleRewards(pid)
		SetPlayerHealthRechargeMultiplier(pid, 0.0)

		-- Disable certain things 
		BlockWeaponWheelThisFrame()
    HideHudComponentThisFrame(19)
    HideHudComponentThisFrame(20)
    HideHudComponentThisFrame(17)
    DisableControlAction(0, 37, true) -- Disable Tab

		-- Disable district / vehicle name (bottom right)
		HideHudComponentThisFrame(6)
		HideHudComponentThisFrame(7)
		HideHudComponentThisFrame(8)
		HideHudComponentThisFrame(9)

		-- Modify weapon damage
		N_0x4757f00bc6323cfe(0xA2719263, 0.25) -- weapon_unarmed
    N_0x4757f00bc6323cfe(0x678B81B1, 0.2) -- weapon_nightstick
    N_0x4757f00bc6323cfe(0xDFE37640, 0.3) -- weapon_switchblade
    N_0x4757f00bc6323cfe(0x99B507EA, 0.4) -- weapon_knife
    N_0x4757f00bc6323cfe(0xD8DF3C3C, 0.3) -- weapon_knuckle
    N_0x4757f00bc6323cfe(0xDD5DF8D9, 0.4) -- weapon_machete
    N_0x4757f00bc6323cfe(0x8BB05FD7, 0.1) -- weapon_flashlight
    N_0x4757f00bc6323cfe(0x958A4A8F , 0.28) -- weapon_bat
    N_0x4757f00bc6323cfe(0xF9DCBF2D, 0.3) -- weapon_hatchet
    N_0x4757f00bc6323cfe(0x4E875F73, 0.2) -- weapon_hammer
    N_0x4757f00bc6323cfe(0x19044EE0, 0.2) -- weapon_wrench
    N_0x4757f00bc6323cfe(0x84BD7BFD, 0.2) -- weapon_crowbar
    N_0x4757f00bc6323cfe(1741783703, 0.2) -- VEHICLE_WEAPON_WATER_CANNON
	end
end)

Citizen.CreateThread(function()
	while true do
		Wait(2500)

    -- ==========================================
    -- Idle Cams
    -- ==========================================
    InvalidateIdleCam()
		N_0x9e4cfff989258472() -- Disable the vehicle idle camera

        -- ==========================================
        -- Weapon Drops
        -- ==========================================
		local handle, ped = FindFirstPed()
		local finished = false
	
		repeat
			if not IsEntityDead(ped) then
				SetPedDropsWeaponsWhenDead(ped, false)
			end
			finished, ped = FindNextPed(handle)
		until not finished
	
		EndFindPed(handle)
	end
end)

Citizen.CreateThread(function()
    -- ==========================================
    -- City Sounds
    -- ==========================================
    StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE")

    -- ==========================================
    -- ESC-Menu text entries
    -- ==========================================
	AddTextEntry('FE_THDR_GTAO', 'Galactic')
	AddTextEntry('PM_SCR_MAP', 'GOOGLE MAPS')
	AddTextEntry('PM_SCR_SET', 'INSTELLINGEN')

	-- Fix auto weapon swap
    SetWeaponsNoAutoswap(true)
    SetWeaponsNoAutoreload(true)
end)