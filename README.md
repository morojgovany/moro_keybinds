Simple RedM key binding script. It lets you bind keys to actions (commands, client/server events, or callbacks) with security checks and persistent storage.

## Features
- Default key binds for all players.
- Per-player customizable binds via UI.
- Supported actions:
  - commands (ExecuteCommand)
  - client events (TriggerEvent)
  - server events (TriggerServerEvent)
  - local callbacks defined in `config.lua`
  - exports from other resources
- Security: disallows non-whitelisted binds and cleans them on restart.
- Database persistence (table auto-created if missing).
- Per-key anti-spam delay.
- Dev mode for live restarts.
- Configurable UI open command.
- Multi-language support via `locales.json`.

## Installation
1. Put the folder in `resources/`.
2. Add the resource to your `server.cfg`:
   ```cfg
   ensure moro_keybinds
   ```

## Configuration (config.lua)
Open `config.lua` and adjust the sections below.

### General settings
- `Config.openCommand`: command to open the UI (default `keybinds`).
- `Config.Locale`: default locale (e.g. `en`, `fr`).
- `Config.devMode`: `true` to allow live restarts.

### Default keys (all players)
`Config.Keys` defines keys that are always active for everyone.
Each entry contains:
- `hash`: key hash (Windows Virtual Key Code).
- `callback`: function executed on press.
- `wait`: delay (ms) before it can be pressed again.
- `trigger`: `keyUp` or `keyDown`.

Example:
```lua
Config.Keys = {
  K = {
    hash = 0x4B,
    callback = function()
      ExecuteCommand('rc')
    end,
    wait = 1000,
    trigger = 'keyUp',
  },
}
```

### Customizable keys (per player)
`Config.customizableKeys` lists keys players can assign in the UI.
- Use `hash`, `wait`, `trigger` as above.
- Display order is defined by:
  - `Config.customizableKeys`
  - `Config.customizableKeysOrder`

### Whitelisted actions
`Config.actionsToBind` defines what players are allowed to bind.
- `clientEvents`: triggered via `TriggerEvent`.
- `serverEvents`: triggered via `TriggerServerEvent`.
- `commands`: executed via `ExecuteCommand` (no `/`).

Example:
```lua
Config.actionsToBind = {
  clientEvents = {
    ['Notification'] = {
      event = 'moro_notifications:TipRight',
      args = {'test', 5000}
    },
  },
  serverEvents = {
    ['test'] = {
      event = '',
      args = {}
    }
  },
  commands = {
    ['Reload skin'] = 'rc'
  },
}
```

## Translations (locales.json)
- Add/edit languages in `locales.json`.
- Set `Config.Locale` accordingly.

## Important notes
- Key hashes use Windows Virtual Key Codes: results depend on the player’s keyboard layout.
- If you add customizable binds, check for conflicts with other scripts.

Useful link for hashes: https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes