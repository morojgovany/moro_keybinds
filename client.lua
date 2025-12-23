local playerBinds = {}
local localesCache = nil

local function loadLocales()
    if localesCache then
        return localesCache
    end

    local resourceName = GetCurrentResourceName()
    local localesRaw = LoadResourceFile(resourceName, 'locales.json')
    if not localesRaw then
        print('moro_keybinds: locales.json not found')
        localesCache = {}
        return localesCache
    end

    local ok, decoded = pcall(json.decode, localesRaw)
    if not ok or type(decoded) ~= 'table' then
        print('moro_keybinds: failed to decode locales.json')
        localesCache = {}
        return localesCache
    end

    localesCache = decoded
    return localesCache
end

local function resolveLocale()
    local locale = Config.Locale or 'en'
    local locales = loadLocales()
    if locales[locale] then
        return locale
    end
    return 'en'
end

local function getActionType(bind)
    if Config.actionsToBind.events[bind.bind_name] == bind.bind_value then
        return 'event'
    end
    if Config.actionsToBind.commands[bind.bind_name] == bind.bind_value then
        return 'command'
    end
    return nil
end

local function buildBind(bind)
    local keyData = Config.customizableKeys[bind.bind_key]
    if not keyData then
        return nil
    end

    local actionType = getActionType(bind)
    if not actionType then
        return nil
    end

    local callback = nil
    if actionType == 'event' then
        callback = function()
            TriggerEvent(bind.bind_value)
        end
    elseif actionType == 'command' then
        callback = function()
            ExecuteCommand(bind.bind_value)
        end
    end

    return {
        bind_key = bind.bind_key,
        bind_name = bind.bind_name,
        bind_value = bind.bind_value,
        hash = keyData.hash,
        wait = keyData.wait,
        trigger = keyData.trigger,
        callback = callback,
    }
end

local function handleBinds(binds, cooldowns)
    local currentTime = GetGameTimer()
    for k, v in pairs(binds) do
        if not cooldowns[k] then
            cooldowns[k] = 0
        end

        if currentTime >= cooldowns[k] then
            if v.trigger == 'keyUp' then
                if IsRawKeyReleased(v.hash) then
                    v.callback()
                    if v.wait and v.wait > 0 then
                        cooldowns[k] = currentTime + v.wait
                    end
                end
            elseif v.trigger == 'keyDown' then
                if IsRawKeyPressed(v.hash) then
                    v.callback()
                    if v.wait and v.wait > 0 then
                        cooldowns[k] = currentTime + v.wait
                    end
                end
            end
        end
    end
end

Citizen.CreateThread(function()
    local keyCooldowns = {}
    while true do
        Wait(1)
        handleBinds(Config.Keys, keyCooldowns)
    end
end)

Citizen.CreateThread(function()
    local keyCooldowns = {}
    while true do
        Wait(1)
        if next(playerBinds) ~= nil then
            handleBinds(playerBinds, keyCooldowns)
        end
    end
end)

local function getActionsForUi()
    local actions = {}
    for name, value in pairs(Config.actionsToBind.events) do
        actions[#actions + 1] = {
            label = name,
            type = 'event',
            value = value,
        }
    end
    for name, value in pairs(Config.actionsToBind.commands) do
        actions[#actions + 1] = {
            label = name,
            type = 'command',
            value = value,
        }
    end
    return actions
end

local function getBindsForUi()
    local binds = {}
    for keyName, _ in pairs(Config.customizableKeys) do
        local bind = playerBinds[keyName]
        binds[#binds + 1] = {
            bind_key = keyName,
            bind_name = bind and bind.bind_name or '',
            bind_value = bind and bind.bind_value or '',
        }
    end
    return binds
end

RegisterNetEvent('moro_keybinds:openMenu')
AddEventHandler('moro_keybinds:openMenu', function()
    local locales = loadLocales()
    local locale = resolveLocale()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'show',
        binds = getBindsForUi(),
        actions = getActionsForUi(),
        locales = locales,
        locale = locale,
    })
end)

RegisterNetEvent('moro_keybinds:syncBinds')
AddEventHandler('moro_keybinds:syncBinds', function(binds)
    playerBinds = {}
    for _, v in pairs(binds) do
        local bind = buildBind(v)
        if bind then
            playerBinds[v.bind_key] = bind
        end
    end
end)

RegisterNetEvent('moro_keybinds:deleteBind')
AddEventHandler('moro_keybinds:deleteBind', function(bind)
    playerBinds[bind.bind_key] = nil
end)

RegisterNetEvent('moro_keybinds:resetBinds')
AddEventHandler('moro_keybinds:resetBinds', function()
    playerBinds = {}
end)

RegisterNUICallback('moro_keybinds:closeMenu', function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'hide' })
    cb('ok')
end)

RegisterNUICallback('moro_keybinds:deleteBind', function(data, cb)
    TriggerServerEvent('moro_keybinds:deleteBind', data)
    cb('ok')
end)

RegisterNUICallback('moro_keybinds:saveBinds', function(data, cb)
    TriggerServerEvent('moro_keybinds:saveBinds', data)
    cb('ok')
end)

RegisterNUICallback('moro_keybinds:resetBinds', function(data, cb)
    TriggerServerEvent('moro_keybinds:resetBinds')
    cb('ok')
end)

RegisterCommand('keybinds', function()
    TriggerEvent('moro_keybinds:openMenu')
end)
