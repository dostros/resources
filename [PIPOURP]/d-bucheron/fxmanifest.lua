-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Dostros'
description 'timber menu by Dostros'
version '1.0.0'

-- What to run
client_scripts {
    'client.lua',"config.lua", 'sell_and_construct.lua'
}

server_scripts {
    'server.lua',
}

dependencies {
    'qb-core',
    'qb-target',
    'PipouUI',
}