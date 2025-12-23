Citizen.CreateThread(function()
    local exists = jo.database.doesTableExist('moro_keybinds')
    if not exists then
        local isTableCreated = jo.database.addTable('moro_keybinds', [[id INT NOT NULL AUTO_INCREMENT,
        char_id INT NOT NULL DEFAULT '',
        bind_name VARCHAR(50) NOT NULL DEFAULT '',
        bind_key VARCHAR(50) NOT NULL DEFAULT '',
        bind_value VARCHAR(50) NOT NULL DEFAULT '',]])
        if not isTableCreated then
            print('Failed to create table moro_keybinds')
            error('Failed to create table moro_keybinds')
        end
    end
    
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds')
    for _, v in pairs(binds) do
        local validEvent = Config.actionsToBind.events[v.bind_name] == v.bind_value
        local validCommand = Config.actionsToBind.commands[v.bind_name] == v.bind_value
        if not validEvent and not validCommand then
            MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ? AND bind_key = ?', {v.char_id, v.bind_key})
            print('Bind ' .. v.bind_name .. ' => ' .. v.bind_value .. ' from character ' .. jo.framework:getRPName(v.char_id) .. ' deleted, check for possible cheat.')
        end
    end
end)

jo.framework:onCharacterSelected(function(source)
    local _source = source
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds WHERE char_id = ?', {source})
    TriggerClientEvent('moro_keybinds:syncBinds', _source, binds)
end)

RegisterNetEvent('moro_keybinds:saveBind')
AddEventHandler('moro_keybinds:saveBind', function(bind)
    local _source = source
    local char_id = jo.framework:getCharacterId(_source)
    if not char_id then
        return
    end
    local validEvent = Config.actionsToBind.events[bind.bind_name] == bind.bind_value
    local validCommand = Config.actionsToBind.commands[bind.bind_name] == bind.bind_value
    if not validEvent and not validCommand then
        print('Tried to bind ' .. bind.bind_name .. ' => ' .. bind.bind_value .. ' from character ' .. jo.framework:getRPName(char_id) .. ', check for possible cheat.')
        return
    end
    MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ? AND bind_key = ?', {char_id, bind.bind_key})
    MySQL.insert.await('INSERT INTO moro_keybinds (char_id, bind_name, bind_key, bind_value) VALUES (?, ?, ?, ?)', {char_id, bind.bind_name, bind.bind_key, bind.bind_value})
    TriggerClientEvent('moro_keybinds:saveBind', _source, bind)
end)

RegisterNetEvent('moro_keybinds:deleteBind')
AddEventHandler('moro_keybinds:deleteBind', function(bind)
    local _source = source
    local char_id = jo.framework:getCharacterId(_source)
    if not char_id then
        return
    end
    MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ? AND bind_key = ?', {char_id, bind.bind_key})
    TriggerClientEvent('moro_keybinds:deleteBind', _source, bind)
end)

RegisterNetEvent('moro_keybinds:resetBinds')
AddEventHandler('moro_keybinds:resetBinds', function()
    local _source = source
    local char_id = jo.framework:getCharacterId(_source)
    if not char_id then
        return
    end
    MySQL.update.await('DELETE FROM moro_keybinds WHERE char_id = ?', {char_id})
    TriggerClientEvent('moro_keybinds:resetBinds', _source)
end)
