-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Dostros'
description 'Garage Menu by Dostros'
version '1.0.0'

-- What to run
client_scripts {
    './client/**.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/server.lua'
}
ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/**.png',
    'html/**.svg',
}