Config = {}
-- REMEMBER: the hash of the rawkeys uses OS hashes, related to your keyboard layout. So it can be different depending of your players keyboard layout. And it can lead to conflicts with other scripts.
Config.Keys = {
    K = {
        hash = 0x4B,
        callback = function() -- example of command
            ExecuteCommand('rc')
        end,
        wait = 1000,
        trigger = 'keyUp',
    },
    Y = {
        hash = 0x59,
        callback = function()
            --[[ TriggerServerEvent('') -- example of server event
            TriggerEvent('') -- example of client event ]]
            RequestAnimDict('ai_gestures@gen_female@standing@silent')
            while not HasAnimDictLoaded('ai_gestures@gen_female@standing@silent') do
                Wait(100)
            end
            TaskPlayAnim(PlayerPedId(), 'ai_gestures@gen_female@standing@silent', 'silent_neutral_greet_f_002', 1.0, 1.0, -1, 1, 0, false, false, false, 0, true)
            RemoveAnimDict('ai_gestures@gen_female@standing@silent')
        end,
        wait = 1000,
        trigger = 'keyUp',
    },
}

Config.customizableKeys = {
    NUMPAD_1 = {
        hash = 0x61,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_2 = {
        hash = 0x62,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_3 = {
        hash = 0x63,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_4 = {
        hash = 0x64,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_5 = {
        hash = 0x65,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_6 = {
        hash = 0x66,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_7 = {
        hash = 0x67,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_8 = {
        hash = 0x68,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_9 = {
        hash = 0x69,
        wait = 1000,
        trigger = 'keyUp',
    },
    NUMPAD_0 = {
        hash = 0x60,
        wait = 1000,
        trigger = 'keyUp',
    },
}

Config.actionsToBind = {
    events = {
        'Notification' = 'moro_notifications:TipRight',
    },
    commands = {
        'Reload skin' = 'rc',
    },
}

-- list of hash of raw keys https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes