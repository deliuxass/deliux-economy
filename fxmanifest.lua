fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author '_deliuxas'
github 'https://github.com/deliuxass'

shared_scripts { 
	'@ox_lib/init.lua',
	'@es_extended/imports.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
}