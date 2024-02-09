fx_version 'bodacious'

game 'gta5'

author 'Fonlogen e Kekko_4316'
description 'Buisness War'

version '1.1.0'

client_scripts {
	'@PolyZone/client.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/ComboZone.lua',
	'client/react.lua',
	'client/cl_main.lua',
	'client/test.js'
}

shared_scripts {
	'config.lua',
}

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'server/sv_main.lua'
}

ui_page 'ui/dist/index.html'

files {
	'ui/dist/*',
	'ui/dist/index.html',
	'ui/dist/**/*',
	'ui/dist/images/*',
	'ui/dist/assets/*',
	'ui/dist/assets/**/*',
}