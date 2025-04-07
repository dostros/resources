fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Dostros'
description 'Script For helicopter options'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@qb-core/shared/locale.lua',
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua',
	'client/objects.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

dependencies {
    'qb-target',
}