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

local function isValidBind(bindName, bindValue)
    if type(bindValue) ~= 'table' then
        return false
    end
    local clientAction = Config.actionsToBind.clientEvents[bindName]
    if clientAction and bindValue.event == clientAction.event and argsMatch(clientAction.args, bindValue.args) then
        return true
    end
    local serverAction = Config.actionsToBind.serverEvents[bindName]
    if serverAction and bindValue.event == serverAction.event and argsMatch(serverAction.args, bindValue.args) then
        return true
    end
    local commandAction = Config.actionsToBind.commands[bindName]
    if commandAction and bindValue.command == commandAction.command and argsMatch(commandAction.args, bindValue.args) then
        return true
    end
    return false
end

Citizen.CreateThread(function()
    jo.database.addTable('moro_keybinds', [[id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    char_id INT NOT NULL DEFAULT 0,
    bind_name VARCHAR(50) NOT NULL DEFAULT '',
    bind_key VARCHAR(50) NOT NULL DEFAULT '',
    bind_value TEXT NOT NULL DEFAULT '',
    UNIQUE KEY unique_char_bind (char_id, bind_key)]])
    
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds')
    for _, v in ipairs(binds) do
        local bindValue = decodeBindValue(v.bind_value)
        if not isValidBind(v.bind_name, bindValue) then
            MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ? AND bind_key = ?', {v.char_id, v.bind_key})
            print('Bind ' .. v.bind_name .. ' => ' .. v.bind_value .. ' from character ' .. jo.framework:getRPName(v.char_id) .. ' deleted, check for possible cheat.')
        end
    end
end)

jo.framework:onCharacterSelected(function(source)
    local _source = source
    local identifiers = jo.framework:getUserIdentifiers(source)
    local charId = identifiers.charid
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds WHERE char_id = ?', {charId})
    for _, bind in ipairs(binds) do
        bind.bind_value = decodeBindValue(bind.bind_value)
    end
    TriggerClientEvent('moro_keybinds:syncBinds', _source, binds)
end)
RegisterNetEvent('moro_keybinds:syncBinds')
AddEventHandler('moro_keybinds:syncBinds', function(payload)
    local _source = source
    local identifiers = jo.framework:getUserIdentifiers(_source)
    local charId = identifiers.charid
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds WHERE char_id = ?', {charId})
    for _, bind in ipairs(binds) do
        bind.bind_value = decodeBindValue(bind.bind_value)
    end
    TriggerClientEvent('moro_keybinds:syncBinds', _source, binds)
end)

RegisterNetEvent('moro_keybinds:saveBinds')
AddEventHandler('moro_keybinds:saveBinds', function(payload)
    local _source = source
    local identifiers = jo.framework:getUserIdentifiers(_source)
    local charId = identifiers.charid

    local binds = payload and payload.binds or {}
    if type(binds) ~= 'table' then
        binds = {}
    end

    local validBinds = {}
    local validKeys = {}
    for _, bind in ipairs(binds) do
        if type(bind) == 'table' then
            if isValidBind(bind.bind_name, bind.bind_value) then
                validKeys[bind.bind_key] = true
                MySQL.update.await('INSERT INTO moro_keybinds (char_id, bind_name, bind_key, bind_value) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE bind_name = VALUES(bind_name), bind_value = VALUES(bind_value)', {charId, bind.bind_name, bind.bind_key, json.encode(bind.bind_value)})
                validBinds[#validBinds + 1] = bind
            else
                print('Tried to bind ' .. tostring(bind.bind_name) .. ' => ' .. tostring(bind.bind_value) .. ' from character ' .. jo.framework:getRPName(charId) .. ', check for possible cheat.')
            end
        end
    end

    if next(validKeys) == nil then
        MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ?', {charId})
    else
        local placeholders = {}
        local values = {charId}
        for keyName, _ in pairs(validKeys) do
            placeholders[#placeholders + 1] = '?'
            values[#values + 1] = keyName
        end
        MySQL.update.await(('DELETE FROM moro_keybinds WHERE char_id = ? AND bind_key NOT IN (%s)'):format(table.concat(placeholders, ',')), values)
    end

    TriggerClientEvent('moro_keybinds:syncBinds', _source, validBinds)
end)

RegisterNetEvent('moro_keybinds:deleteBind')
AddEventHandler('moro_keybinds:deleteBind', function(bind)
    local _source = source
    local identifiers = jo.framework:getUserIdentifiers(_source)
    local charId = identifiers.charid
    MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ? AND bind_key = ?', {charId, bind.bind_key})
    TriggerClientEvent('moro_keybinds:deleteBind', _source, bind)
end)

RegisterNetEvent('moro_keybinds:resetBinds')
AddEventHandler('moro_keybinds:resetBinds', function()
    local _source = source
    local identifiers = jo.framework:getUserIdentifiers(_source)
    local charId = identifiers.charid
    MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ?', {charId})
    TriggerClientEvent('moro_keybinds:resetBinds', _source)
end)
