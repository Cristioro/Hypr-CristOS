import QtQuick
import Quickshell
import Quickshell.Io

// Estado y acciones del centro de control rápido.
Item {
    id: root

    readonly property string stateScript: (Quickshell.env("HOME") || "")
        + "/.config/hypr/scripts/control-center-state.sh"

    property int volume: 0
    property bool muted: false
    property int brightness: 0
    property int brightnessMax: 100
    property bool ddcAvailable: true
    property bool micMuted: false
    property bool nightlight: false
    property bool dnd: false
    property bool panelVisible: false

    // Conectividad (red y bluetooth).
    property bool networkConnected: false
    property string networkType: "none"
    property string networkName: ""
    property string networkIp: ""
    property bool btPowered: false
    property int btCount: 0
    property string btNames: ""

    readonly property int brightnessPercent:
        Math.round(brightness * 100 / Math.max(1, brightnessMax))

    readonly property string networkGlyph: {
        if (!networkConnected)
            return "󰖪";
        return networkType === "wifi" ? "󰖩" : "󰈀";
    }

    readonly property string networkSubtitle: {
        if (!networkConnected)
            return "Desconectado";
        if (networkType === "wifi")
            return networkIp.length > 0 ? networkIp : "Conectado";
        return networkIp.length > 0 ? "Ethernet · " + networkIp : "Ethernet";
    }

    readonly property string btSubtitle: {
        if (!btPowered)
            return "Desactivado";
        if (btCount <= 0)
            return "Sin dispositivos";
        return btNames.length > 0 ? btNames : btCount + " conectado(s)";
    }

    signal menuLaunched()

    function refresh() {
        if (stateProc.running)
            return;
        stateProc.running = true;
    }

    function act(cmd) {
        // Evita solapar ddcutil (getvcp del sondeo) con la acción del usuario.
        if (stateProc.running)
            stateProc.running = false;
        actionProc.command = cmd;
        if (actionProc.running)
            actionProc.running = false;
        actionProc.running = true;
    }

    // Abre el menú rofi correspondiente (WiFi de CristOS o Bluetooth).
    function launchMenu(kind) {
        const home = Quickshell.env("HOME") || "";
        const script = kind === "bluetooth"
            ? home + "/.config/rofi/settings/bluetooth.sh"
            : home + "/.config/rofi/wifi/wifi.sh";
        if (stateProc.running)
            stateProc.running = false;
        menuProc.command = ["bash", "-c", "setsid -f " + JSON.stringify(script)
            + " >/dev/null 2>&1"];
        if (menuProc.running)
            menuProc.running = false;
        menuProc.running = true;
    }

    function setVolume(v) {
        root.volume = v;
        root.muted = false;
        act(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", v + "%"]);
    }

    function toggleMute() {
        root.muted = !root.muted;
        act(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function setBrightness(v) {
        if (!root.ddcAvailable)
            return;
        root.brightness = v;
        act(["ddcutil", "setvcp", "10", String(v)]);
    }

    function toggleMic() {
        root.micMuted = !root.micMuted;
        act(["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"]);
    }

    function toggleNightlight() {
        root.nightlight = !root.nightlight;
        act(["bash", "-c",
            "if [ \"$(cat /tmp/hyprsunset_clicked_state 2>/dev/null || echo 0)\" = 1 ]; then " +
            "hyprctl hyprsunset identity >/dev/null 2>&1; echo 0 > /tmp/hyprsunset_clicked_state; " +
            "else hyprctl hyprsunset temperature 4000 >/dev/null 2>&1; echo 1 > /tmp/hyprsunset_clicked_state; fi"]);
    }

    Process {
        id: stateProc
        command: ["bash", root.stateScript]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const s = JSON.parse(this.text);
                    if (!s || typeof s !== "object")
                        return;
                    root.volume = Number(s.volume) || 0;
                    root.muted = !!s.muted;
                    root.brightness = Number(s.brightness) || 0;
                    root.brightnessMax = Number(s.brightnessMax) || 100;
                    root.ddcAvailable = s.ddcAvailable !== false;
                    root.micMuted = !!s.micMuted;
                    root.nightlight = !!s.nightlight;
                    root.networkConnected = !!s.networkConnected;
                    root.networkType = String(s.networkType ?? "none");
                    root.networkName = String(s.networkName ?? "");
                    root.networkIp = String(s.networkIp ?? "");
                    root.btPowered = !!s.btPowered;
                    root.btCount = Number(s.btCount) || 0;
                    root.btNames = String(s.btNames ?? "");
                } catch (e) {
                    console.warn("cristos-cc: estado inválido:", e);
                }
            }
        }
    }

    Process {
        id: actionProc
        command: ["true"]
        onExited: root.refresh()
    }

    Process {
        id: menuProc
        command: ["true"]
        onExited: root.menuLaunched()
    }

    // Refresco suave mientras el panel está abierto (el proceso muere al cerrar).
    Timer {
        interval: 4000
        running: root.panelVisible
        repeat: true
        onTriggered: {
            if (!actionProc.running && !menuProc.running)
                root.refresh();
        }
    }

    onPanelVisibleChanged: if (panelVisible) refresh()
}
