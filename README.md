# Moro_Keybinds

## *Simple key binding script for redm*
It binds unused redm keys to events, commands or any callback function.

## Description
- Assign actions to default keys for all players
- Allow players to bind actions to customizable keys
- Trigger commands, client events or server events (list in config)
- Security checks to prevent players from binding forbidden events or commands to keys (on every restart & bind save)
- Auto creates table in database if not exists
- Persistent bind data (saved in database)
- Pass arguments to commands or events
- Use dev mode to restart the script live
- Use the command `keybinds` to open the ui (can be changed in config)

## *Installation*
- Put the folder in your resources folder
- Add `ensure moro_keybinds` to your server.cfg

## *Config*
- Open `config.lua` and add your keybinds callbacks
- Use as many keybinds as you want but use carefully it can conflict with other scripts
- You can add a wait time after the callback to prevent spam
- Config.Keys are the keys that are binded by default for all players
- Config.customizableKeys are the keys that the player can assign to actions, be careful of conflicts with other scripts & remember that depends on the keyboard layout of the player
- Change the command `keybinds` to open the ui in the config
- Change the locale in the config
- Assign any action to any key in the config
- List authorized actions in the config

## *Translations*
- Open `locales.json` and add your translations
- You can add as many languages as you want
*Translations were IA generated, please review and correct any errors*

### **:warning: Note: the hash of the rawkeys uses OS hashes, related to your keyboard layout. So it can be different depending of your players keyboard layout.**
