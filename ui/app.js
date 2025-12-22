const { createApp, nextTick } = Vue;
createApp({
    data() {
        return {
            devMode: false,
            visible: false,
            displayMessage: false,
            message: '',
            binds: [],
            bindsEvents: [],
            bindKeys: [],
        };
    },
    mounted() {
        if (this.devMode) {
            this.visible = true;
            this.binds = [

            ]
        }
        window.addEventListener("message", this.onMessage);
    },
    computed: {
        optionList() {
            return this.bindsEvents.filter((bindEvent) => !this.binds.some((bind) => bind.bind_event === bindEvent));
        }
    },
    methods: {
        onMessage(event) {
            const message = event.data;
            switch (message.action) {
                case "show":
                    this.binds = message.binds;
                    this.bindsEvents = message.bindsEvents;
                    this.bindKeys = message.bindKeys;
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
            this.binds = this.binds.filter((b) => b.bind_key !== bind.bind_key);
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
            this.binds = this.binds.filter((b) => b.bind_key !== bind.bind_key);
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
            this.binds = [];
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
    }
}).mount("#app");
