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

local function decodeBindValue(bindValue)
    if type(bindValue) == 'string' then
        local ok, decoded = pcall(json.decode, bindValue)
        if ok and type(decoded) == 'table' then
            return decoded
        end
    end
    return bindValue
end

local function argsMatch(expectedArgs, actualArgs)
    if expectedArgs == nil and actualArgs == nil then
        return true
    end
    if type(expectedArgs) ~= 'table' or type(actualArgs) ~= 'table' then
        return false
    end
    if #expectedArgs ~= #actualArgs then
        return false
    end
    for i = 1, #expectedArgs do
        if expectedArgs[i] ~= actualArgs[i] then
            return false
        end
    end
    return true
end

local function getActionType(bind)
    local bindValue = decodeBindValue(bind.bind_value)
    local clientAction = Config.actionsToBind.clientEvents[bind.bind_name]
    if clientAction and bindValue.event == clientAction.event and argsMatch(clientAction.args, bindValue.args) then
        return 'clientEvent'
    end
    local serverAction = Config.actionsToBind.serverEvents[bind.bind_name]
    if serverAction and bindValue.event == serverAction.event and argsMatch(serverAction.args, bindValue.args) then
        return 'serverEvent'
    end
    local commandAction = Config.actionsToBind.commands[bind.bind_name]
    if commandAction and bindValue.command == commandAction.command and argsMatch(commandAction.args, bindValue.args) then
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

    local bindValue = decodeBindValue(bind.bind_value)
    local callback = nil
    if actionType == 'clientEvent' then
        callback = function()
            local args = {}
            for _, arg in ipairs(bindValue.args or {}) do
                args[#args + 1] = arg
            end
            TriggerEvent(bindValue.event, unpack(args))
        end
    elseif actionType == 'serverEvent' then
        callback = function()
            local args = {}
            for _, arg in ipairs(bindValue.args or {}) do
                args[#args + 1] = arg
            end
            TriggerServerEvent(bindValue.event, unpack(args))
        end
    elseif actionType == 'command' then
        callback = function()
            local args = {}
            for _, arg in ipairs(bindValue.args or {}) do
                args[#args + 1] = arg
            end
            ExecuteCommand(bindValue.command, unpack(args))
        end
    end

    return {
        bind_key = bind.bind_key,
        bind_name = bind.bind_name,
        bind_value = bindValue,
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
    for name, value in pairs(Config.actionsToBind.clientEvents) do
        actions[#actions + 1] = {
            label = name,
            type = 'clientEvent',
            value = value,
        }
    end
    for name, value in pairs(Config.actionsToBind.serverEvents) do
        actions[#actions + 1] = {
            label = name,
            type = 'serverEvent',
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

local function getCustomizableKeyOrder()
    if type(Config.customizableKeysOrder) == 'table' then
        return Config.customizableKeysOrder
    end
    local keys = {}
    for keyName, _ in pairs(Config.customizableKeys) do
        keys[#keys + 1] = keyName
    end
    table.sort(keys)
    return keys
end

local function getBindsForUi()
    local binds = {}
    for _, keyName in ipairs(getCustomizableKeyOrder()) do
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
    for _, v in ipairs(binds) do
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
