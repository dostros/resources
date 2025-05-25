fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Dostros'
description 'Admin Menu for QBCore with PipouUI'
version '1.2.0'

ui_page 'html/index.html'

shared_scripts {
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua'
}

client_scripts {
    'client/noclip.lua',
    'client/entity_view.lua',
    'client/blipsnames.lua',
    'client/client.lua',
    'client/events.lua',
    'entityhashes/entity.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}

files {
    'html/index.html',
    'html/index.js',

}



dependency 'PipouUI'
dependency 'qb-core'