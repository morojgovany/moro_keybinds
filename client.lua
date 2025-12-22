Citizen.CreateThread(function()
    while true do
        Wait(1)
        for k, v in pairs(Config.Keys) do
            if IsRawKeyReleased(v.hash) then
                v.callback()
                if v.wait and v.wait > 0 then
                    Wait(v.wait)
                end
            end
        end
    end
end)
