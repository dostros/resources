fx_version 'cerulean'
game 'gta5'

author 'Dostros'
description 'HUD personnalisé - Pipou-hud'
version '1.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

client_scripts {
    'client/main.lua'
}

shared_script '@qb-core/shared/locale.lua' -- si tu utilises QBCore
