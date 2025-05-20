Core = {}
Core.PlayerData = {}
Core.Config = Config
Core.Shared = Shared
Core.ClientCallbacks = {}
Core.ServerCallbacks = {}

-- Get the full Core object (default behavior):
-- local Core = GetCoreObject()

-- Get only specific parts of Core:
-- local Core = GetCoreObject({'Players', 'Config'})

local function GetCoreObject(filters)
    if not filters then return Core end
    local results = {}
    for i = 1, #filters do
        local key = filters[i]
        if Core[key] then
            results[key] = Core[key]
        end
    end
    return results
end
exports('GetCoreObject', GetCoreObject)

local function GetSharedItems()
    return Shared.Items
end
exports('GetSharedItems', GetSharedItems)

local function GetSharedVehicles()
    return Shared.Vehicles
end
exports('GetSharedVehicles', GetSharedVehicles)

local function GetSharedWeapons()
    return Shared.Weapons
end
exports('GetSharedWeapons', GetSharedWeapons)

local function GetSharedJobs()
    return Shared.Jobs
end
exports('GetSharedJobs', GetSharedJobs)

local function GetSharedGangs()
    return Shared.Gangs
end
exports('GetSharedGangs', GetSharedGangs)
