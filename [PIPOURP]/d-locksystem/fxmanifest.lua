-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Dostros'
description 'Lock System Menu by Dostros'
version '1.0.0'

-- What to run
client_scripts {
    'client.lua','menu.lua'
}

server_scripts {
    'server.lua',
}

ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/**.png',
    'html/**.svg',
    'stream/**.ytd',
    '**.json',
}

data_file 'DLC_ITYP_REQUEST' 'stream/lockopen.ytd' 
data_file'DLC_ITYP_REQUEST' 'stream/lockclose.ytd'