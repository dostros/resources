-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Dostros'
description 'Immo Menu by Dostros'
version '1.0.0'

-- What to run
client_scripts {
    './client/**.lua',
    'config.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/**.lua'
}
ui_page 'html/index.html'

files {
    'html/*.html',
    'html/*.js',
    'html/*.css',
    'html/**.png',
    'html/**.svg',
    'stream/**/*.ytyp'

}

data_file 'DLC_ITYP_REQUEST' 'stream/**/*.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/envi_shell_02_empty.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/envi_shell_01_empty.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/envi_shell_03_empty.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/free_shells.ytyp'
dependency '/assetpacks'