fx_version 'cerulean'
games { 'gta5' }

author 'Dostros'
description 'Admin Menu For PipouRP with PipouUI'
version '1.0.0'

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
    '@oxmysql/lib/MySQL.lua',
}




dependencies {
    'PipouUI','ox_lib','oxmysql'
}