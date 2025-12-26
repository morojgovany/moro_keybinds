Citizen.CreateThread(function()
    jo.database.addTable('moro_keybinds', [[id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    char_id INT NOT NULL DEFAULT 0,
    bind_name VARCHAR(50) NOT NULL DEFAULT '',
    bind_key VARCHAR(50) NOT NULL DEFAULT '',
    bind_value TEXT NOT NULL DEFAULT '']])
    
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds')
    for _, v in pairs(binds) do
        local validClientEvent = Config.actionsToBind.clientEvents[v.bind_name] == v.bind_value
        local validServerEvent = Config.actionsToBind.serverEvents[v.bind_name] == v.bind_value
        local validCommand = Config.actionsToBind.commands[v.bind_name] == v.bind_value
        if not validClientEvent and not validServerEvent and not validCommand then
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
    TriggerClientEvent('moro_keybinds:syncBinds', _source, binds)
end)
RegisterNetEvent('moro_keybinds:syncBinds')
AddEventHandler('moro_keybinds:syncBinds', function(payload)
    local _source = source
    local identifiers = jo.framework:getUserIdentifiers(_source)
    local charId = identifiers.charid
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds WHERE char_id = ?', {charId})
    print(json.encode(binds))
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

    MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ?', {charId})

    local validBinds = {}
    for _, bind in ipairs(binds) do
        if type(bind) == 'table' then
            local validClientEvent = Config.actionsToBind.clientEvents[bind.bind_name] == bind.bind_value.event
            local validServerEvent = Config.actionsToBind.serverEvents[bind.bind_name] == bind.bind_value.event
            local validCommand = Config.actionsToBind.commands[bind.bind_name] == bind.bind_value.command
            if validClientEvent or validServerEvent or validCommand then
                MySQL.insert.await('INSERT INTO moro_keybinds (char_id, bind_name, bind_key, bind_value) VALUES (?, ?, ?, ?)', {charId, bind.bind_name, bind.bind_key, json.encode(bind.bind_value)})
                validBinds[#validBinds + 1] = bind
            else
                print('Tried to bind ' .. tostring(bind.bind_name) .. ' => ' .. tostring(bind.bind_value) .. ' from character ' .. jo.framework:getRPName(charId) .. ', check for possible cheat.')
            end
        end
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
