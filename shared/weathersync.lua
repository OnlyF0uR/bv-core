Shared                                   = Shared or {}

Shared.WeatherSync                       = {}
Shared.WeatherSync.DynamicWeather        = true -- Set this to false if you don't want the weather to change automatically every 10 minutes.

-- On server start
Shared.WeatherSync.StartWeather          = 'EXTRASUNNY' -- Default weather                       default: 'EXTRASUNNY'
Shared.WeatherSync.BaseTime              = 8            -- Time                                             default: 8
Shared.WeatherSync.TimeOffset            = 0            -- Time offset                                      default: 0
Shared.WeatherSync.FreezeTime            = false        -- freeze time                                  default: false
Shared.WeatherSync.Blackout              = false        -- Set blackout                                 default: false
Shared.WeatherSync.BlackoutVehicle       = false        -- Set blackout affects vehicles                default: false
Shared.WeatherSync.NewWeatherTimer       = 10           -- Time (in minutes) between each weather change   default: 10
Shared.WeatherSync.Disabled              = false        -- Set weather disabled                         default: false
Shared.WeatherSync.RealTimeSync          = false        -- Activate realtime synchronization            default: false

Shared.WeatherSync.AvailableWeatherTypes = {            -- DON'T TOUCH EXCEPT IF YOU KNOW WHAT YOU ARE DOING
  'EXTRASUNNY',
  'CLEAR',
  'NEUTRAL',
  'SMOG',
  'FOGGY',
  'OVERCAST',
  'CLOUDS',
  'CLEARING',
  'RAIN',
  'THUNDER',
  'SNOW',
  'BLIZZARD',
  'SNOWLIGHT',
  'XMAS',
  'HALLOWEEN',
}
