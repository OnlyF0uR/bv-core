Shared = Shared or {}

local StringCharset = {}
local NumberCharset = {}

Shared.StarterItems = {
    ['phone'] = { amount = 1, item = 'phone' },
    ['id_card'] = { amount = 1, item = 'id_card' },
    ['driver_license'] = { amount = 1, item = 'driver_license' },
}

for i = 48, 57 do NumberCharset[#NumberCharset + 1] = string.char(i) end
for i = 65, 90 do StringCharset[#StringCharset + 1] = string.char(i) end
for i = 97, 122 do StringCharset[#StringCharset + 1] = string.char(i) end

function Shared.RandomStr(length)
    if length <= 0 then return '' end
    return Shared.RandomStr(length - 1) .. StringCharset[math.random(1, #StringCharset)]
end

function Shared.RandomInt(length)
    if length <= 0 then return '' end
    return Shared.RandomInt(length - 1) .. NumberCharset[math.random(1, #NumberCharset)]
end

function Shared.SplitStr(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        result[#result + 1] = string.sub(str, from, delim_from - 1)
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    result[#result + 1] = string.sub(str, from)
    return result
end

function Shared.Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function Shared.FirstToUpper(value)
    if not value then return nil end
    return (value:gsub("^%l", string.upper))
end

function Shared.Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / (power)
end

function Shared.ChangeVehicleExtra(vehicle, extra, enable)
    if DoesExtraExist(vehicle, extra) then
        if enable then
            SetVehicleExtra(vehicle, extra, false)
            if not IsVehicleExtraTurnedOn(vehicle, extra) then
                Shared.ChangeVehicleExtra(vehicle, extra, enable)
            end
        else
            SetVehicleExtra(vehicle, extra, true)
            if IsVehicleExtraTurnedOn(vehicle, extra) then
                Shared.ChangeVehicleExtra(vehicle, extra, enable)
            end
        end
    end
end

function Shared.IsFunction(value)
    if type(value) == 'table' then
        return value.__cfx_functionReference ~= nil and type(value.__cfx_functionReference) == "string"
    end

    return type(value) == 'function'
end

function Shared.SetDefaultVehicleExtras(vehicle, config)
    -- Clear Extras
    for i = 1, 20 do
        if DoesExtraExist(vehicle, i) then
            SetVehicleExtra(vehicle, i, 1)
        end
    end

    for id, enabled in pairs(config) do
        if type(enabled) ~= 'boolean' then
            enabled = true
        end

        Shared.ChangeVehicleExtra(vehicle, tonumber(id), enabled)
    end
end

Shared.MaleNoGloves = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [18] = true,
    [26] = true,
    [52] = true,
    [53] = true,
    [54] = true,
    [55] = true,
    [56] = true,
    [57] = true,
    [58] = true,
    [59] = true,
    [60] = true,
    [61] = true,
    [62] = true,
    [112] = true,
    [113] = true,
    [114] = true,
    [118] = true,
    [125] = true,
    [132] = true
}

Shared.FemaleNoGloves = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = true,
    [14] = true,
    [15] = true,
    [19] = true,
    [59] = true,
    [60] = true,
    [61] = true,
    [62] = true,
    [63] = true,
    [64] = true,
    [65] = true,
    [66] = true,
    [67] = true,
    [68] = true,
    [69] = true,
    [70] = true,
    [71] = true,
    [129] = true,
    [130] = true,
    [131] = true,
    [135] = true,
    [142] = true,
    [149] = true,
    [153] = true,
    [157] = true,
    [161] = true,
    [165] = true
}

-- ===========================================
-- Accurate epoch-based millisecond timer
function Shared.GetTimeInMilliseconds()
    -- GetGameTimer() returns milliseconds since game start in FiveM
    return GetGameTimer()
end

-- ===========================================
-- Pad with leading "0" if number is less than 10
local function leading0(number)
    return number < 10 and "0" or ""
end

-- Format milliseconds into MM:SS.mmm string
function Shared.FormatMilliseconds(ms)
    local mins = math.floor(ms / 1000 / 60)
    local secs = math.floor((ms / 1000) % 60)
    local huns = math.floor(ms % 1000)

    return string.format("%s%d:%s%d.%s%d",
        leading0(mins), mins,
        leading0(secs), secs,
        leading0(huns), huns
    )
end

-- ===========================================
-- Calculate 2D Euclidean distance between two vector2 tables
local function getdist(a, b)
    return math.sqrt((a.x - b.x)^2 + (a.y - b.y)^2)
end

-- Check if vector3 `c` is approximately between `a` and `b`
function Shared.IsBetween(aJson, bJson, cJson)
    local a = json.decode(aJson)
    local b = json.decode(bJson)
    local c = json.decode(cJson)

    local sum = getdist(a, c) + getdist(c, b)
    local dist = getdist(a, b)

    -- Margin to tolerate tick inaccuracies or float imprecision
    return math.abs(dist - sum) < 0.1
end

-- ===========================================
-- Generate pseudo-random float between min and max
function Shared.RandomBetween(min, max)
    return math.random() * (max - min) + min
end
