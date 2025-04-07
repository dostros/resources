fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Dostros'
description 'Restaurant Job for QB-Core'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@qb-core/shared/locale.lua',
	--'locales/en.lua',
	--'locales/*.lua'
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua',
	'client/objects.lua',
	'client/transformation.lua',
	'client/sell-customer.lua',
	'client/interactions.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
}

dependencies {
    'qb-target',
}