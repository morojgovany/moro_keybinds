local playerBinds = {}

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

RegisterNetEvent('moro_keybinds:syncBinds')
AddEventHandler('moro_keybinds:syncBinds', function(binds)
    playerBinds = binds
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

