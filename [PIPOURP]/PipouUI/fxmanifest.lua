fx_version 'cerulean'
game 'gta5'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/menu.js',
    'html/notify.js',
    'html/progressbar.js',
}

client_script 'pipouui.lua'

exports {
    'CreateMenu',
    'AddButton',
    'OpenMenu'
}