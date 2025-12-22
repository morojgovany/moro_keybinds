local playerBinds = nil

Citizen.CreateThread(function()
    local keyCooldowns = {}
    while true do
        Wait(1)
        for k, v in pairs(Config.Keys) do
            local currentTime = GetGameTimer()
            if not keyCooldowns[k] then keyCooldowns[k] = 0 end

            if currentTime >= keyCooldowns[k] then
                if v.trigger == 'keyUp' then
                    if IsRawKeyReleased(v.hash) then
                        v.callback()
                        if v.wait and v.wait > 0 then
                            keyCooldowns[k] = currentTime + v.wait
                        end
                    end
                elseif v.trigger == 'keyDown' then
                    if IsRawKeyPressed(v.hash) then
                        v.callback()
                        if v.wait and v.wait > 0 then
                            keyCooldowns[k] = currentTime + v.wait
                        end
                    end
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    repeat
        Wait(1000)
    until playerBinds
    while true do
        Wait(1)
        for k, v in pairs(playerBinds) do
            if v.trigger == 'keyUp' then
                if IsRawKeyReleased(v.hash) then
                    v.callback()
                    if v.wait and v.wait > 0 then
                        keyCooldowns[k] = currentTime + v.wait
                    end
                end
            elseif v.trigger == 'keyDown' then
                if IsRawKeyPressed(v.hash) then
                    v.callback()
                    if v.wait and v.wait > 0 then
                        keyCooldowns[k] = currentTime + v.wait
                    end
                end
            end
        end
    end
end)

RegisterNetEvent('moro_keybinds:syncBinds')
AddEventHandler('moro_keybinds:syncBinds', function(binds)
    for k, v in pairs(binds) do
        playerBinds[v.bind_key] = v
    end
    Citizen.CreateThread(function()
        while true do
            Wait(1)
            for k, v in pairs(playerBinds) do
                if v.trigger == 'keyUp' then
                    if IsRawKeyReleased(v.hash) then
                        v.callback()
                        if v.wait and v.wait > 0 then
                            keyCooldowns[k] = currentTime + v.wait
                        end
                    end
                elseif v.trigger == 'keyDown' then
                    if IsRawKeyPressed(v.hash) then
                        v.callback()
                        if v.wait and v.wait > 0 then
                            keyCooldowns[k] = currentTime + v.wait
                        end
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent('moro_keybinds:saveBind')
AddEventHandler('moro_keybinds:saveBind', function(bind)
    playerBinds[bind.bind_key] = bind
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

RegisterNUICallback('moro_keybinds:saveBind', function(data, cb)
    TriggerServerEvent('moro_keybinds:saveBind', data)
    cb('ok')
end)

RegisterNUICallback('moro_keybinds:resetBinds', function(data, cb)
    TriggerServerEvent('moro_keybinds:resetBinds')
    cb('ok')
end)
