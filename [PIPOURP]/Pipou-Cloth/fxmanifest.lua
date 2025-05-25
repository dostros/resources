fx_version 'cerulean'
game 'gta5'

author 'Dostros'
description 'Pipou-cloth - gestion de tenues & preview'
version '1.0.0'

-- Fichiers partagés (config éventuel)
shared_script 'config.lua'

-- Scripts client/serveur
client_script 'client/main.lua'
server_script 'server/main.lua'

-- Déclaration de l’UI NUI
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    -- Ajoute ici toute ressource liée (images, fonts, icônes… si besoin)
}
