fx_version "adamant"
game 'rdr3'
rdr3_warning "I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships."
lua54 'yes'
name "moro_keybinds"
startup_message "moro_keybinds loaded successfully!"
author "Morojgovany"
description "Ultra simple key binding script for redm"

client_script {
    'client.lua',
    'config.lua',
}

server_script {
    'server.lua',
	'@oxmysql/lib/MySQL.lua',
}

files {
    'ui/*',
    'ui/assets/*',
    'ui/vendor/*',
    'ui/fonts/*',
    'ui/img/*',
}

ui_page 'ui/index.html'
