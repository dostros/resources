fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Dostros'
description 'Provides governement tools, evidence, job and more functionality for players to use as a government worker'
version '1.0.0'

shared_scripts {
	'config.lua',
	'@qb-core/shared/locale.lua',
	'locales/en.lua',
	'locales/*.lua'
}

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/main.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

-- ui_page 'html/index.html'

-- files {
-- 	'html/index.html',
-- 	'html/vue.min.js',
-- 	'html/script.js',
-- 	'html/tablet-frame.png',
-- 	'html/fingerprint.png',
-- 	'html/main.css',
-- 	'html/vcr-ocd.ttf'
-- }
