import QtQuick
import Quickshell
import Quickshell.Io

// Puente entre la GUI y settings-core.sh. Toda la lógica vive en el core;
// aquí solo se lee su estado JSON y se lanzan acciones.
Item {
    id: root

    readonly property string script: (Quickshell.env("HOME") || "") + "/.config/hypr/scripts/settings-core.sh"

    property var state: ({
        mode: "dark",
        scheme: "tonal-spot",
        dnd: "No",
        volume: "",
        caffeine: "Desactivada",
        wall: "",
        wallName: "",
        barTheme: "actual",
        barMode: "complete",
        clockLabel: "24 h",
        nightlight: "off",
        transparencyWaybar: 70,
        transparencyRofi: 15,
        networkState: "",
        hostname: "",
        kernel: "",
        barThemes: []
    })

    readonly property string mode: state.mode ?? "dark"
    readonly property string scheme: state.scheme ?? "tonal-spot"
    readonly property string dnd: state.dnd ?? "No"
    readonly property string volume: state.volume ?? ""
    readonly property string caffeine: state.caffeine ?? "Desactivada"
    readonly property string wallName: state.wallName ?? ""
    readonly property string barTheme: state.barTheme ?? "actual"
    readonly property string barMode: state.barMode ?? "complete"
    readonly property string clockLabel: state.clockLabel ?? "24 h"
    readonly property string nightlight: state.nightlight ?? "off"
    readonly property int transparencyWaybar: state.transparencyWaybar ?? 70
    readonly property int transparencyRofi: state.transparencyRofi ?? 15
    readonly property string networkState: state.networkState ?? ""
    readonly property string hostname: state.hostname ?? ""
    readonly property string kernel: state.kernel ?? ""
    readonly property var barThemes: state.barThemes ?? []

    // Se emite cuando hay que cerrar la ventana (p. ej. antes de abrir otra UI).
    signal requestClose()

    function refresh() {
        if (stateProc.running)
            stateProc.running = false;
        stateProc.running = true;
    }

    // Acción normal: se queda abierta y refresca el estado al terminar.
    function run(args) {
        actionProc.command = ["bash", root.script].concat(args);
        if (actionProc.running)
            actionProc.running = false;
        actionProc.running = true;
    }

    // Acción que abre otra interfaz (rofi, foot, pavucontrol, hyprlock…):
    // se lanza desacoplada y cerramos esta ventana para no robar el foco.
    function runExternal(args) {
        Quickshell.execDetached(["bash", root.script].concat(args));
        root.requestClose();
    }

    Process {
        id: stateProc
        command: ["bash", root.script, "json"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const obj = JSON.parse(this.text);
                    if (obj && typeof obj === "object")
                        root.state = obj;
                } catch (e) {
                    console.warn("cristos-settings: estado inválido:", e);
                }
            }
        }
    }

    Process {
        id: actionProc
        command: ["true"]

        onExited: {
            root.refresh();
            delayedRefresh.restart();
        }
    }

    // Refresco periódico suave (volumen, DND, tema… pueden cambiar fuera).
    Timer {
        interval: 4000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    // Las acciones asíncronas (matugen, waybar) tardan un poco en reflejarse.
    Timer {
        id: delayedRefresh
        interval: 1500
        onTriggered: root.refresh()
    }
}
