fx_version 'cerulean'
game 'gta5'
lua54 'yes'

local postalFile = "client/postals.json"

shared_scripts {
    'config.lua',
    'shared/locale.lua',
    'locale/en.lua',
    'locale/*.lua',
    'shared/main.lua',
    'shared/items.lua',
    'shared/jobs.lua',
    'shared/vehicles.lua',
    'shared/gangs.lua',
    'shared/weapons.lua',
    'shared/locations.lua',
    'shared/vehiclekeys.lua',
    'shared/postalcodes.lua',
    'shared/weathersync.lua',
    'shared/controls.lua',
}

client_scripts {
    'client/main.lua',
    'client/functions.lua',
    'client/loops.lua',
    'client/events.lua',
    'client/vehiclekeys.lua',
    'client/weathersync.lua',
    'client/modifications.lua',
    'client/emotes.lua',
    'client/deathcam.lua',
    'client/weapons.lua',
    'client/holograms.lua',
    'client/postalcodes.lua',
    'client/dev.lua',
    'client/drawtext.lua',
    'client/tackle.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/functions.lua',
    'server/player.lua',
    'server/events.lua',
    'server/commands.lua',
    'server/exports.lua',
    'server/debug.lua',
    'server/vehiclekeys.lua',
    'server/weathersync.lua',
    'server/weapons.lua',
    'server/dev.lua',
    'server/peds.lua',
    'server/tackle.lua',
}

file(postalFile)
postal_file(postalFile)

dependency 'oxmysql'
