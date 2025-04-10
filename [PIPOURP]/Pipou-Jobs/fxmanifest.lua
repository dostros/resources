fx_version 'cerulean'
games { 'gta5' }

author 'Dostros'
description 'Jobs Menu'
version '1.0.0'

client_scripts {
    'client/*.lua',
    'config.lua',
}

server_scripts {
    'server/*.lua',
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

dependencies {
    'qb-core',
    'qb-target'
}