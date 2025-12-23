const { createApp, nextTick } = Vue;
createApp({
    data() {
        return {
            devMode: true,
            visible: false,
            displayMessage: false,
            message: '',
            binds: [],
            actions: [],
        };
    },
    mounted() {
        if (this.devMode) {
            this.visible = true;
            this.actions = [
                { label: 'Notification', value: 'moro_notifications:TipRight', type: 'event' },
                { label: 'Reload skin', value: 'rc', type: 'command' },
            ];
            this.binds = [
                { bind_key: 'NUMPAD_1', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_2', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_3', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_4', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_5', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_6', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_7', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_8', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_9', bind_name: '', bind_value: '', selectedAction: '' },
                { bind_key: 'NUMPAD_0', bind_name: '', bind_value: '', selectedAction: '' },
            ];
        }
        window.addEventListener("message", this.onMessage);
    },
    computed: {
        usedActions() {
            return new Set(this.binds.filter((bind) => bind.selectedAction).map((bind) => bind.selectedAction));
        },
    },
    methods: {
        actionKey(action) {
            return `${action.type}:${action.value}`;
        },
        normalizeBind(bind) {
            const action = this.actions.find(
                (candidate) =>
                    candidate.label === bind.bind_name && candidate.value === bind.bind_value
            );
            return {
                ...bind,
                selectedAction: action ? this.actionKey(action) : '',
            };
        },
        availableActions(bind) {
            const usedActions = new Set(
                this.binds
                    .filter((entry) => entry.selectedAction && entry.bind_key !== bind.bind_key)
                    .map((entry) => entry.selectedAction)
            );
            return this.actions.filter((action) => {
                const key = this.actionKey(action);
                return !usedActions.has(key) || key === bind.selectedAction;
            });
        },
        onMessage(event) {
            const message = event.data;
            switch (message.action) {
                case "show":
                    this.actions = message.actions || [];
                    this.binds = (message.binds || []).map((bind) => this.normalizeBind(bind));
                    this.visible = true;
                    break;
                case "hide":
                    this.visible = false;
                    break;
                case 'success':
                    this.displayMessage = true;
                    this.message = message.message;
                    setTimeout(() => {
                        this.displayMessage = false;
                        this.message = '';
                    }, 5000);
                    break;
                case 'error':
                    this.displayMessage = true;
                    this.message = message.message;
                    setTimeout(() => {
                        this.displayMessage = false;
                        this.message = '';
                    }, 5000);
                    break;
                default:
                    this.visible = false;
                    return;
            }
        },
        closeMenu() {
            this.visible = false;
            fetch(`https://${GetParentResourceName()}/moro_keybinds:closeMenu`, {
                method: 'POST',
            });
        },
        async deleteBind(bind) {
            bind.selectedAction = '';
            bind.bind_name = '';
            bind.bind_value = '';
            await fetch(`https://${GetParentResourceName()}/moro_keybinds:deleteBind`, {
                method: 'POST',
                body: JSON.stringify(bind),
            }).then(() => {
                this.displayMessage = true;
                this.message = 'Bind deleted';
                setTimeout(() => {
                    this.displayMessage = false;
                    this.message = '';
                }, 5000);
            });
        },
        async saveBind(bind) {
            await fetch(`https://${GetParentResourceName()}/moro_keybinds:saveBind`, {
                method: 'POST',
                body: JSON.stringify(bind),
            }).then(() => {
                this.displayMessage = true;
                this.message = 'Bind saved';
                setTimeout(() => {
                    this.displayMessage = false;
                    this.message = '';
                }, 5000);
            });
        },
        async resetBinds() {
            this.binds.forEach((bind) => {
                bind.selectedAction = '';
                bind.bind_name = '';
                bind.bind_value = '';
            });
            await fetch(`https://${GetParentResourceName()}/moro_keybinds:resetBinds`, {
                method: 'POST',
            }).then(() => {
                this.displayMessage = true;
                this.message = 'Binds reset';
                setTimeout(() => {
                    this.displayMessage = false;
                    this.message = '';
                }, 5000);
            });
        },
        onBindChange(bind) {
            if (!bind.selectedAction) {
                this.deleteBind(bind);
                return;
            }
            const action = this.actions.find(
                (candidate) => this.actionKey(candidate) === bind.selectedAction
            );
            if (!action) {
                return;
            }
            bind.bind_name = action.label;
            bind.bind_value = action.value;
            bind.bind_type = action.type;
            this.saveBind(bind);
        },
    }
}).mount("#app");
