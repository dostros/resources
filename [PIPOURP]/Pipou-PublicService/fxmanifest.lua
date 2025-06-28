-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Dostros'
description 'Pbulic Service Tablet by Dostros'
version '1.0.0'

-- What to run
client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua',
    '@oxmysql/lib/MySQL.lua',
}

ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/**.png',
    'html/**.svg',
}

