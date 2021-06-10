fx_version 'adamant'
game 'gta5'
description 'Everyday find a target car to sell to an honest man'
Author 'Heramy'
version '0.9'

client_scripts {
  '@es_extended/locale.lua',
	'locales/en.lua',
  'locales/fr.lua',
  'client/client.lua',
  'config.lua',
  'functions/functions.lua'
}

server_scripts {
  '@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
  '@es_extended/locale.lua',
	'locales/en.lua',
  'locales/fr.lua',
  'server/server.lua',
  'config.lua',
  'functions/functions.lua'
}

dependencies {
  'es_extended',
}