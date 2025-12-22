const { createApp, nextTick } = Vue;
createApp({
    data() {
        return {
            devMode: false,
            visible: false,
        };
    },
    mounted() {
        if (this.devMode) {
            this.visible = true; // rendre les éléments visibles
        }
        window.addEventListener("message", this.onMessage);
    },
    methods: {
        onMessage(event) {
            const message = event.data;
            switch (message.action) {
                case "show":
                    this.visible = true;
                    break;
                case "hide":
                    this.visible = false;
                    break;
                default:
                    this.visible = false;
                    return;
            }
        },
    }
}).mount("#app");
