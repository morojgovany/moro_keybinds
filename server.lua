jo.framework:onCharacterSelected(function(source)
    local _source = source
    local binds = MySQL.query.await('SELECT * FROM moro_keybinds WHERE char_id = ?', {source})
    if binds[1] then
        TriggerClientEvent('moro_keybinds:syncBinds', _source, binds[1])
    end
end)