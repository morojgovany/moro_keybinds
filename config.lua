Config = {}
-- REMEMBER: the hash of the rawkeys uses OS hashes, related to your keyboard layout. So it can be different depending of your players keyboard layout. And it can lead to conflicts with other scripts.
Config.Keys = {
    K = {
        hash = 0x4B,
        callback = function()
            ExecuteCommand('')
        end,
        wait = 1000,
    },
    Y = {
        hash = 0x59,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    J = { -- NOTE: this is a saltychat fix for wagons, adapt the callback to your needs
        hash = 0x4A,
        callback = function()
            local function IsDrivingWagon()
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                if veh == 0 then 
                    return false 
                end
                return true
            end
            local function isOnMount()
                local ped = PlayerPedId()
                return IsPedOnMount(ped)
            end
            if not IsDrivingWagon() and not isOnMount() then
                return
            end
            local saltyDefaultRanges = { 3.5, 8, 15, 32 }
            local currentVoiceRange = exports["saltychat"]:GetVoiceRange()
            local nextIndex = 1

            for i = 1, #saltyDefaultRanges do
                if saltyDefaultRanges[i] == currentVoiceRange then
                    nextIndex = i + 1
                    if nextIndex > #saltyDefaultRanges then
                        nextIndex = 1
                    end
                    break
                end
            end

            TriggerServerEvent("SaltyChat_SetVoiceRange", saltyDefaultRanges[nextIndex])
        end,
        wait = 200,
    },
    NUMPAD_1 = {
        hash = 0x60,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_2 = {
        hash = 0x61,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_3 = {
        hash = 0x62,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_4 = {
        hash = 0x63,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_5 = {
        hash = 0x64,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_6 = {
        hash = 0x65,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_7 = {
        hash = 0x66,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_8 = {
        hash = 0x67,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_9 = {
        hash = 0x68,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
    NUMPAD_0 = {
        hash = 0x69,
        callback = function()
            TriggerEvent('')            
        end,
        wait = 1000,
    },
}
-- list of hash of raw keys https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes