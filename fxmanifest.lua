fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Kakarot (QB-Core), OnlyF0uR'
description 'Core resource for the framework, adapted from QB-Core'
version '1.0.0'

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
    'client/holograms.lua'
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
}

dependency 'oxmysql'
