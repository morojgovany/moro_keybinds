const { createApp, nextTick } = Vue;
createApp({
    data() {
        return {
            devMode: true, // if set true, the app will load with default data and locales in locales.dev.js, directly in the browser
            visible: false,
            binds: [],
            actions: [],
            locales: {},
            locale: 'en', // change this to change the locale ONLY IN DEVMODE
            translations: {},
            fallbackTranslations: {},
            pendingChanges: false,
        };
    },
    mounted() {
        if (this.devMode) {
            if (window.MoroKeybindsLocales) {
                const locale = window.MoroKeybindsLocale || this.locale;
                this.setLocales(window.MoroKeybindsLocales, locale);
            }
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
        getNestedValue(target, path) {
            return path.split('.').reduce((acc, key) => (acc && acc[key] !== undefined ? acc[key] : undefined), target);
        },
        setLocales(locales, locale) {
            this.locales = locales || {};
            this.locale = locale || this.locale;
            this.translations = this.locales[this.locale] || {};
            this.fallbackTranslations = this.locales.en || {};
        },
        t(path) {
            const value = this.getNestedValue(this.translations, path);
            if (value !== undefined) {
                return value;
            }
            const fallback = this.getNestedValue(this.fallbackTranslations, path);
            return fallback !== undefined ? fallback : path;
        },
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
                    if (message.locales) {
                        this.setLocales(message.locales, message.locale || this.locale);
                    }
                    this.visible = true;
                    this.pendingChanges = false;
                    break;
                case "hide":
                    this.visible = false;
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
        clearBind(bind) {
            bind.selectedAction = '';
            bind.bind_name = '';
            bind.bind_value = '';
            this.pendingChanges = true;
        },
        async resetBinds() {
            this.binds.forEach((bind) => {
                bind.selectedAction = '';
                bind.bind_name = '';
                bind.bind_value = '';
            });
            await fetch(`https://${GetParentResourceName()}/moro_keybinds:resetBinds`, {
                method: 'POST',
            });
            this.pendingChanges = false;
        },
        async saveBinds() {
            const binds = this.binds
                .filter((bind) => bind.selectedAction)
                .map((bind) => ({
                    bind_key: bind.bind_key,
                    bind_name: bind.bind_name,
                    bind_value: bind.bind_value,
                }));
            await fetch(`https://${GetParentResourceName()}/moro_keybinds:saveBinds`, {
                method: 'POST',
                body: JSON.stringify({ binds }),
            });
            this.pendingChanges = false;
        },
        onBindChange(bind) {
            if (!bind.selectedAction) {
                this.clearBind(bind);
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
            this.pendingChanges = true;
        },
    }
}).mount("#app");
