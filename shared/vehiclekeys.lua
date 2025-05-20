-- Key System Settings
Shared.PersistentKeys = true -- Whether keys received should be saved after server restart, or not

-- Vehicle lock settings
Shared.LockToggleAnimation = {
    AnimDict = 'anim@mp_player_intmenu@key_fob@',
    Anim = 'fob_click',
    Prop = 'prop_cuff_keys_01',
    PropBone = 57005,
    WaitTime = 500,
}
Shared.LockAnimSound = "keys"
Shared.LockToggleDist = 8.0

-- NPC Vehicle Lock States
Shared.LockNPCDrivingCars = true -- Lock state for NPC cars being driven by NPCs [true = locked, false = unlocked]
Shared.LockNPCParkedCars = true -- Lock state for NPC parked cars [true = locked, false = unlocked]
Shared.UseKeyfob = false -- you can set this true if you dont need ui
-- Lockpick Settings
Shared.RemoveLockpickNormal = 0.5 -- Chance to remove lockpick on fail
Shared.RemoveLockpickAdvanced = 0.2 -- Chance to remove advanced lockpick on fail
-- Carjack Settings
Shared.CarJackEnable = true -- True allows for the ability to car jack peds.
Shared.CarjackingTime = 7500 -- How long it takes to carjack
Shared.DelayBetweenCarjackings = 10000 -- Time before you can carjack again
Shared.CarjackChance = {
    ['2685387236'] = 0.0, -- melee
    ['416676503'] = 0.5, -- handguns
    ['-957766203'] = 0.75, -- SMG
    ['860033945'] = 0.90, -- shotgun
    ['970310034'] = 0.90, -- assault
    ['1159398588'] = 0.99, -- LMG
    ['3082541095'] = 0.99, -- sniper
    ['2725924767'] = 0.99, -- heavy
    ['1548507267'] = 0.0, -- throwable
    ['4257178988'] = 0.0, -- misc
}

-- Hotwire Settings
Shared.HotwireChance = 0.5 -- Chance for successful hotwire or not
Shared.TimeBetweenHotwires = 5000 -- Time in ms between hotwire attempts
Shared.minHotwireTime = 20000 -- Minimum hotwire time in ms
Shared.maxHotwireTime = 40000 --  Maximum hotwire time in ms

-- Police Alert Settings
Shared.AlertCooldown = 10000 -- 10 seconds
Shared.PoliceAlertChance = 0.75 -- Chance of alerting police during the day
Shared.PoliceNightAlertChance = 0.50 -- Chance of alerting police at night (times:01-06)

-- Job Settings
Shared.SharedKeys = { -- Share keys amongst employees. Employees can lock/unlock any job-listed vehicle
    ['police'] = { -- Job name
        requireOnduty = false,
        vehicles = {
	    'police', -- Vehicle model
	    'police2', -- Vehicle model
	}
    },

    ['mechanic'] = {
        requireOnduty = false,
        vehicles = {
            'towtruck',
	}
    }
}

-- These vehicles cannot be jacked
Shared.ImmuneVehicles = {
    'stockade'
}

-- These vehicles will never lock
Shared.NoLockVehicles = {}

-- These weapons cannot be used for carjacking
Shared.NoCarjackWeapons = {
    "WEAPON_UNARMED",
    "WEAPON_Knife",
    "WEAPON_Nightstick",
    "WEAPON_HAMMER",
    "WEAPON_Bat",
    "WEAPON_Crowbar",
    "WEAPON_Golfclub",
    "WEAPON_Bottle",
    "WEAPON_Dagger",
    "WEAPON_Hatchet",
    "WEAPON_KnuckleDuster",
    "WEAPON_Machete",
    "WEAPON_Flashlight",
    "WEAPON_SwitchBlade",
    "WEAPON_Poolcue",
    "WEAPON_Wrench",
    "WEAPON_Battleaxe",
    "WEAPON_Grenade",
    "WEAPON_StickyBomb",
    "WEAPON_ProximityMine",
    "WEAPON_BZGas",
    "WEAPON_Molotov",
    "WEAPON_FireExtinguisher",
    "WEAPON_PetrolCan",
    "WEAPON_Flare",
    "WEAPON_Ball",
    "WEAPON_Snowball",
    "WEAPON_SmokeGrenade",
}