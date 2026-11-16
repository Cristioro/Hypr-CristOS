pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "components"

// Residente durante la sesión: cerrar el panel nunca cierra el servidor.
ShellRoot {
    id: shell
    property bool panelOpen: false
    property string tab: "controls"
    property bool dnd: false
    property var history: []
    property int unread: 0
    property var toastEntry: null
    readonly property var focusedScreen: {
        const monitor = Hyprland.focusedMonitor;
        if (monitor)
            for (const s of Quickshell.screens)
                if (s.name === monitor.name) return s;
        return null;
    }
    readonly property var groupedHistory: {
        const groups = [];
        for (const entry of history) {
            let group = groups.find(g => g.name === entry.app);
            if (!group) { group = { name: entry.app, entries: [] }; groups.push(group); }
            group.entries.push(entry);
        }
        let items = [];
        for (const group of groups) items = items.concat(group.entries);
        return items;
    }

    Theme { id: pal }
    Core { id: core; panelVisible: shell.panelOpen && shell.tab === "controls" }
    Connections {
        target: core
        function onMenuLaunched() { shell.panelOpen = false; }
    }

    function openTab(which) {
        tab = which;
        panelOpen = true;
        toastEntry = null;
        toastTimer.stop();
        if (which === "notifications") unread = 0;
        Qt.callLater(() => keys.forceActiveFocus());
    }
    function toggleTab(which) {
        if (panelOpen && tab === which) panelOpen = false;
        else openTab(which);
    }
    function remove(id) {
        const entry = history.find(e => e.id === id);
        history = history.filter(e => e.id !== id);
        if (toastEntry && toastEntry.id === id) toastEntry = null;
        if (entry && entry.live && entry.notification) entry.notification.dismiss();
        unread = Math.min(unread, history.length);
    }
    function clear() {
        const old = history;
        history = [];
        unread = 0;
        toastEntry = null;
        for (const e of old)
            if (e.live && e.notification) e.notification.dismiss();
    }
    function action(id, index) {
        const e = history.find(item => item.id === id);
        if (e && e.live && e.notification && e.notification.actions[index])
            e.notification.actions[index].invoke();
    }
    function refreshEntry(notification) {
        let updated = null;
        history = history.map(e => {
            if (e.notification !== notification) return e;
            updated = Object.assign({}, e, {
                app: notification.appName || "Aplicación",
                icon: notification.appIcon || notification.desktopEntry || "",
                image: notification.image || "",
                title: notification.summary || "Notificación",
                body: notification.body || ""
            });
            return updated;
        });
        if (updated && toastEntry && toastEntry.id === updated.id) toastEntry = updated;
    }
    function setDnd(value) {
        dnd = value;
        if (value) { toastEntry = null; toastTimer.stop(); }
    }

    IpcHandler {
        target: "notifications"
        function status(): string { return shell.dnd ? "on" : "off"; }
        function toggle(): string { shell.setDnd(!shell.dnd); return shell.dnd ? "on" : "off"; }
        function clear(): void { shell.clear(); }
        function dismiss(id: int): void { shell.remove(id); }
        function openNotifications(): void { shell.openTab("notifications"); }
        function controls(): void { shell.openTab("controls"); }
        function toggleControls(): void { shell.toggleTab("controls"); }
        function toggleNotifications(): void { shell.toggleTab("notifications"); }
        function json(): string {
            return JSON.stringify({dnd: shell.dnd, count: shell.history.length, unread: shell.unread});
        }
    }

    NotificationServer {
        id: server
        bodySupported: true
        bodyMarkupSupported: false
        actionsSupported: true
        persistenceSupported: true
        keepOnReload: false
        onNotification: notification => {
            notification.tracked = true;
            const replacing = shell.history.some(e => e.id === notification.id);
            const entry = {
                id: notification.id,
                app: notification.appName || "Aplicación",
                icon: notification.appIcon || notification.desktopEntry || "",
                image: notification.image || "",
                title: notification.summary || "Notificación",
                body: notification.body || "",
                time: Qt.formatTime(new Date(), "HH:mm"),
                live: true,
                notification: notification
            };
            shell.history = [entry].concat(shell.history.filter(e => e.id !== entry.id));
            if (shell.history.length > 100) {
                const excess = shell.history.slice(100);
                shell.history = shell.history.slice(0, 100);
                for (const old of excess)
                    if (old.live && old.notification) old.notification.dismiss();
            }
            notification.closed.connect(() => {
                shell.history = shell.history.map(e =>
                    e.notification === notification ? Object.assign({}, e, {live: false, notification: null}) : e);
            });
            notification.summaryChanged.connect(() => shell.refreshEntry(notification));
            notification.bodyChanged.connect(() => shell.refreshEntry(notification));
            notification.appNameChanged.connect(() => shell.refreshEntry(notification));
            notification.appIconChanged.connect(() => shell.refreshEntry(notification));
            notification.actionsChanged.connect(() => shell.refreshEntry(notification));
            if (!replacing && !(shell.panelOpen && shell.tab === "notifications"))
                shell.unread = Math.min(100, shell.unread + 1);
            if (!shell.dnd && !(shell.panelOpen && shell.tab === "notifications")) {
                shell.toastEntry = entry;
                toastTimer.restart();
            }
        }
    }
    Timer {
        id: toastTimer
        interval: 5000
        onTriggered: shell.toastEntry = null
    }

    PanelWindow {
        id: overlay
        visible: shell.panelOpen
        screen: shell.focusedScreen
        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
        WlrLayershell.namespace: "cristos-cc"
        MouseArea { anchors.fill: parent; onClicked: shell.panelOpen = false }
        Item {
            id: keys
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: shell.panelOpen = false
        }

        Rectangle {
            id: panel
            width: Math.min(430, parent.width - 24)
            height: Math.min(shell.tab === "controls" ? 510 : 690, parent.height - 68)
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 52
            anchors.rightMargin: 12
            radius: 22
            color: Qt.rgba(pal.background.r, pal.background.g, pal.background.b, 0.91)
            border.width: 1
            border.color: Qt.rgba(pal.primary.r, pal.primary.g, pal.primary.b, 0.30)
            MouseArea { anchors.fill: parent; onClicked: {} }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 14
                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text {
                            text: shell.tab === "controls" ? "Centro de control" : "Notificaciones"
                            color: pal.foreground; font.family: "Noto Sans"; font.pixelSize: 19; font.bold: true
                        }
                        Text {
                            text: shell.tab === "controls" ? "Tu espacio, a tu manera" : "Actividad de esta sesión"
                            color: pal.foregroundMuted; font.family: "Noto Sans"; font.pixelSize: 11
                        }
                    }
                    Rectangle {
                        implicitWidth: 34; implicitHeight: 34; radius: 12
                        color: closeMouse.containsMouse ? pal.surfaceHigh : "transparent"
                        Text { anchors.centerIn: parent; text: "✕"; color: pal.foregroundMuted; font.pixelSize: 15 }
                        MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: shell.panelOpen = false }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true; implicitHeight: 42; radius: 14
                    color: Qt.rgba(pal.foreground.r, pal.foreground.g, pal.foreground.b, 0.07)
                    RowLayout {
                        anchors.fill: parent; anchors.margins: 4; spacing: 4
                        Repeater {
                            model: [{id: "controls", label: "Controles"}, {id: "notifications", label: "Notificaciones"}]
                            delegate: Rectangle {
                                id: tabButton
                                required property var modelData
                                Layout.fillWidth: true; Layout.fillHeight: true; radius: 11
                                color: shell.tab === modelData.id ? pal.primaryContainer : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: tabButton.modelData.label + (tabButton.modelData.id === "notifications" && shell.unread ? " · " + shell.unread : "")
                                    color: shell.tab === tabButton.modelData.id ? pal.foregroundPrimaryContainer : pal.foregroundMuted
                                    font.family: "Noto Sans"; font.pixelSize: 12; font.bold: shell.tab === tabButton.modelData.id
                                }
                                MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: shell.openTab(tabButton.modelData.id) }
                            }
                        }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Flickable {
                        anchors.fill: parent
                        visible: shell.tab === "controls"
                        clip: true
                        contentWidth: width
                        contentHeight: controls.implicitHeight
                        boundsBehavior: Flickable.StopAtBounds
                        ColumnLayout {
                            id: controls
                            width: parent.width
                            spacing: 12
                            RowLayout {
                                Layout.fillWidth: true; spacing: 10
                                InfoRow {
                                    theme: pal; glyph: core.networkGlyph; title: "Red"
                                    subtitle: core.networkConnected ? (core.networkName || core.networkSubtitle) : "Desconectado"
                                    active: core.networkConnected
                                    onClicked: core.launchMenu("wifi")
                                }
                                InfoRow {
                                    theme: pal; glyph: core.btPowered ? "󰂯" : "󰂲"
                                    title: "Bluetooth"; subtitle: core.btSubtitle; active: core.btPowered
                                    onClicked: core.launchMenu("bluetooth")
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: sliders.implicitHeight + 28
                                radius: 16
                                color: Qt.rgba(pal.surface.r, pal.surface.g, pal.surface.b, 0.75)
                                ColumnLayout {
                                    id: sliders
                                    anchors.fill: parent; anchors.margins: 14; spacing: 4
                                    RowLayout {
                                        Layout.fillWidth: true
                                        Text { text: core.muted ? "󰖁" : "󰕾"; font.family: pal.fontFamily; font.pixelSize: 18; color: core.muted ? pal.error : pal.primary }
                                        Text { text: "Volumen"; font.family: "Noto Sans"; font.pixelSize: 13; color: pal.foreground; Layout.fillWidth: true }
                                        Text { text: core.muted ? "Silenciado" : core.volume + "%"; font.family: "Noto Sans"; font.pixelSize: 12; color: pal.foregroundMuted }
                                        Rectangle {
                                            implicitWidth: 30; implicitHeight: 26; radius: 9; color: muteMouse.containsMouse ? pal.surfaceHigh : "transparent"
                                            Text { anchors.centerIn: parent; text: "󰝟"; font.family: pal.fontFamily; font.pixelSize: 16; color: pal.foregroundMuted }
                                            MouseArea { id: muteMouse; anchors.fill: parent; hoverEnabled: true; onClicked: core.toggleMute() }
                                        }
                                    }
                                    GlassSlider { theme: pal; value: core.volume; onReleased: v => core.setVolume(v) }
                                    RowLayout {
                                        Layout.fillWidth: true; Layout.topMargin: 8
                                        Text { text: "󰃠"; font.family: pal.fontFamily; font.pixelSize: 18; color: pal.primary }
                                        Text { text: "Brillo"; font.family: "Noto Sans"; font.pixelSize: 13; color: pal.foreground; Layout.fillWidth: true }
                                        Text { text: core.ddcAvailable ? core.brightnessPercent + "%" : "No disponible"; font.family: "Noto Sans"; font.pixelSize: 12; color: pal.foregroundMuted }
                                    }
                                    GlassSlider {
                                        theme: pal; value: core.brightnessPercent; enabled: core.ddcAvailable
                                        onReleased: v => core.setBrightness(Math.round(v * core.brightnessMax / 100))
                                    }
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true; spacing: 8
                                TogglePill { theme: pal; glyph: core.micMuted ? "󰍭" : "󰍬"; label: "Micrófono"; active: core.micMuted; onToggled: core.toggleMic() }
                                TogglePill { theme: pal; glyph: "󰖔"; label: "Luz nocturna"; active: core.nightlight; onToggled: core.toggleNightlight() }
                                TogglePill { theme: pal; glyph: "󰂛"; label: "No molestar"; active: shell.dnd; onToggled: shell.setDnd(!shell.dnd) }
                            }
                            Rectangle {
                                Layout.fillWidth: true; implicitHeight: 48; radius: 14
                                color: settingsMouse.containsMouse ? pal.surfaceHigh : Qt.rgba(pal.foreground.r, pal.foreground.g, pal.foreground.b, 0.05)
                                RowLayout {
                                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                                    Text { text: "󰒓"; font.family: pal.fontFamily; font.pixelSize: 17; color: pal.primary }
                                    Text { text: "Todos los ajustes"; font.family: "Noto Sans"; font.pixelSize: 13; color: pal.foreground; Layout.fillWidth: true }
                                    Text { text: "Super + I  ›"; font.family: "Noto Sans"; font.pixelSize: 11; color: pal.foregroundMuted }
                                }
                                MouseArea {
                                    id: settingsMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        shell.panelOpen = false;
                                        Quickshell.execDetached(["bash", Quickshell.env("HOME") + "/.config/hypr/scripts/settings-gui.sh"]);
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        anchors.fill: parent
                        visible: shell.tab === "notifications"
                        spacing: 10
                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: shell.history.length + (shell.history.length === 1 ? " notificación" : " notificaciones")
                                color: pal.foregroundMuted; font.family: "Noto Sans"; font.pixelSize: 12; Layout.fillWidth: true
                            }
                            Text {
                                text: shell.dnd ? "No molestar activo" : "Avisos activos"
                                color: shell.dnd ? pal.primary : pal.foregroundMuted; font.family: "Noto Sans"; font.pixelSize: 11
                            }
                            Rectangle {
                                implicitWidth: 68; implicitHeight: 30; radius: 10
                                color: clearMouse.containsMouse ? pal.surfaceHigh : "transparent"
                                Text { anchors.centerIn: parent; text: "Limpiar"; color: pal.foregroundMuted; font.family: "Noto Sans"; font.pixelSize: 11 }
                                MouseArea { id: clearMouse; anchors.fill: parent; enabled: shell.history.length > 0; hoverEnabled: true; onClicked: shell.clear() }
                            }
                        }
                        Item {
                            Layout.fillWidth: true; Layout.fillHeight: true
                            ListView {
                                anchors.fill: parent
                                clip: true
                                spacing: 8
                                model: shell.groupedHistory
                                section.property: "app"
                                section.delegate: Text {
                                    required property string section
                                    width: ListView.view.width
                                    height: 26
                                    text: section
                                    color: pal.foregroundMuted; font.family: "Noto Sans"; font.pixelSize: 11; font.bold: true
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                                delegate: NotificationCard {
                                    required property var modelData
                                    width: ListView.view.width
                                    entry: modelData
                                    theme: pal
                                    onDismissed: shell.remove(modelData.id)
                                    onActionInvoked: index => shell.action(modelData.id, index)
                                }
                                ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
                            }
                            Column {
                                anchors.centerIn: parent
                                visible: shell.history.length === 0
                                spacing: 8
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "󰂚"; font.family: pal.fontFamily; font.pixelSize: 32; color: pal.primary }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Todo al día"; font.family: "Noto Sans"; font.bold: true; font.pixelSize: 15; color: pal.foreground }
                                Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Tus notificaciones aparecerán aquí"; font.family: "Noto Sans"; font.pixelSize: 11; color: pal.foregroundMuted }
                            }
                        }
                    }
                }
            }
        }
    }

    PanelWindow {
        id: toastWindow
        visible: shell.toastEntry !== null
        screen: shell.focusedScreen
        anchors.top: true
        anchors.right: true
        margins.top: 52
        margins.right: 12
        implicitWidth: Math.min(390, screen ? screen.width - 24 : 390)
        implicitHeight: toastCard.implicitHeight + 8
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
        WlrLayershell.namespace: "cristos-cc-toast"
        NotificationCard {
            id: toastCard
            width: parent.width
            entry: shell.toastEntry || ({id: 0, app: "", icon: "", image: "", title: "", body: "", time: "", live: false})
            theme: pal
            onDismissed: { shell.toastEntry = null; toastTimer.stop(); }
            onActionInvoked: index => { shell.action(toastCard.entry.id, index); shell.toastEntry = null; }
        }
    }
}
