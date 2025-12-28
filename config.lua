Config = {}
Config.Locale = 'en'
Config.devMode = false -- set to true if you want to restart the script live
-- REMEMBER: the hash of the rawkeys uses OS hashes, related to your keyboard layout. So it can be different depending of your players keyboard layout. And it can lead to conflicts with other scripts.
-- list of hash of raw keys https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes

-- The keys binded by default for all players
Config.Keys = {
    K = {
        hash = 0x4B, -- The hash of the key
        callback = function() -- example of command executed when the key is pressed
            ExecuteCommand('rc')
            -- Or use events
            --[[ TriggerServerEvent('') -- example of server event
            TriggerEvent('') -- example of client event ]]
        end,
        wait = 1000, -- The wait time in milliseconds before the key can be pressed again
        trigger = 'keyUp', -- The trigger of the key, can be 'keyUp' or 'keyDown'
    },
    Y = {
        hash = 0x59,
        callback = function()
            RequestAnimDict('ai_gestures@gen_female@standing@silent')
            while not HasAnimDictLoaded('ai_gestures@gen_female@standing@silent') do
                Wait(100)
            end
            TaskPlayAnim(PlayerPedId(), 'ai_gestures@gen_female@standing@silent', 'silent_flirty_greet_r_001', 1.0, 1.0, -1, 1, 0, false, false, false, 0, true)
            RemoveAnimDict('ai_gestures@gen_female@standing@silent')
            Wait(5000)
            ClearPedTasks(PlayerPedId())
        end,
        wait = 1000,
        trigger = 'keyUp',
    },
}
-- The customizable keys are the keys that the player can assign to actions, be careful of conflicts with other scripts & remember that depends on the keyboard layout of the player
Config.customizableKeys = {
    ['NUMPAD 1'] = {
        hash = 0x61,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 2'] = {
        hash = 0x62,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 3'] = {
        hash = 0x63,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 4'] = {
        hash = 0x64,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 5'] = {
        hash = 0x65,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 6'] = {
        hash = 0x66,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 7'] = {
        hash = 0x67,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 8'] = {
        hash = 0x68,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 9'] = {
        hash = 0x69,
        wait = 1000,
        trigger = 'keyUp',
    },
    ['NUMPAD 0'] = {
        hash = 0x60,
        wait = 1000,
        trigger = 'keyUp',
    },
}
Config.customizableKeysOrder = {
    'NUMPAD 1',
    'NUMPAD 2',
    'NUMPAD 3',
    'NUMPAD 4',
    'NUMPAD 5',
    'NUMPAD 6',
    'NUMPAD 7',
    'NUMPAD 8',
    'NUMPAD 9',
    'NUMPAD 0',
}

-- The actions to bind are the actions that the player is allowed to bind to the customizable keys
Config.actionsToBind = {
    -- Events that can be binded to the customizable keys (triggered by TriggerEvent)
    clientEvents = {
        ['Notification'] = {
            event = 'moro_notifications:TipRight',
            args = {
                'test',
                5000
            }
        }, -- the key is the label displayed for the player, the event is the eventname:action, the args are the arguments passed to the event
    },

    -- Server events that can be binded to the customizable keys (triggered by TriggerServerEvent)
    serverEvents = {
        ['test'] = {
            event = '',
            args = {}
        }
    },
    -- Commands that can be binded to the customizable keys (triggered by ExecuteCommand)
    -- Remove the / used before the command name in chat
    commands = {
        ['Reload skin'] = 'rc'
    },

}
