pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland

PanelWindow {
    id: root
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "cristos-launcher"
    screen: {
        const monitor = Hyprland.focusedMonitor;
        if (monitor) {
            for (const s of Quickshell.screens)
                if (s.name === monitor.name) return s;
        }
        return null;
    }

    property var palette: ({
        background: "#1a110f", onSurface: "#f1dfdb",
        onSurfaceVariant: "#d8c2bd", primary: "#ffb4a3",
        surfaceHigh: "#322825"
    })
    readonly property color bg: palette.background
    readonly property color foreground: palette.onSurface
    readonly property color muted: palette.onSurfaceVariant
    readonly property color accent: palette.primary
    readonly property string fontName: "CaskaydiaCove Nerd Font Propo"
    property var results: []
    property int selection: 0
    readonly property int columns: Math.max(1, Math.floor(grid.width / grid.cellWidth))

    function refresh() {
        const words = search.text.toLocaleLowerCase().trim().split(/\s+/).filter(w => w.length);
        const apps = DesktopEntries.applications.values.filter(app => {
            if (app.noDisplay || !app.name) return false;
            const text = [app.name, app.genericName, app.comment, app.id,
                          (app.keywords || []).join(" ")].join(" ").toLocaleLowerCase();
            return words.every(word => text.includes(word));
        });
        apps.sort((a, b) => a.name.localeCompare(b.name));
        root.results = apps;
        root.selection = 0;
        grid.positionViewAtBeginning();
    }
    function moveSelection(delta) {
        if (!results.length) return;
        selection = Math.max(0, Math.min(results.length - 1, selection + delta));
        grid.positionViewAtIndex(selection, GridView.Contain);
    }
    function launch(index) {
        if (index < 0 || index >= results.length) return;
        const app = results[index];
        // gio respeta las opciones de la entrada de escritorio, incluida Terminal.
        Quickshell.execDetached(["gtk-launch", app.id]);
        Qt.quit();
    }
    function loadPalette(text) {
        try {
            const p = JSON.parse(text);
            const keys = ["background", "onSurface", "onSurfaceVariant", "primary", "surfaceHigh"];
            if (keys.every(k => typeof p[k] === "string" && /^#[0-9a-fA-F]{6}$/.test(p[k])))
                palette = p;
        } catch (e) {}
    }

    FileView {
        id: colorsFile
        path: Quickshell.shellPath("colors.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.loadPalette(text())
    }
    Connections {
        target: DesktopEntries
        function onApplicationsChanged() { root.refresh(); }
    }
    IpcHandler {
        target: "launcher"
        function close(): void { Qt.quit(); }
    }
    Component.onCompleted: {
        colorsFile.reload();
        refresh();
        search.forceActiveFocus();
    }

    MouseArea { anchors.fill: parent; onClicked: Qt.quit() }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: Math.min(760, parent.width - 32)
        height: Math.min(600, parent.height - 32)
        radius: 24
        color: Qt.rgba(root.bg.r, root.bg.g, root.bg.b, 0.70)
        border.width: 1
        border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.28)
        opacity: 0
        Component.onCompleted: appear.start()
        NumberAnimation { id: appear; target: panel; property: "opacity"; to: 1; duration: 180 }

        MouseArea { anchors.fill: parent; onClicked: search.forceActiveFocus() }
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 16
            RowLayout {
                Layout.fillWidth: true
                Text {
                    text: "Aplicaciones"
                    color: root.foreground
                    font.family: root.fontName
                    font.pixelSize: 21
                    font.bold: true
                    Layout.fillWidth: true
                }
                Text {
                    text: "ESC  cerrar"
                    color: root.muted
                    font.family: root.fontName
                    font.pixelSize: 12
                }
            }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 54
                radius: 16
                color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
                border.width: 1
                border.color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.32)
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12
                    Text { text: "⌕"; color: root.accent; font.pixelSize: 26 }
                    TextInput {
                        id: search
                        Layout.fillWidth: true
                        color: root.foreground
                        font.family: root.fontName
                        font.pixelSize: 16
                        clip: true
                        focus: true
                        selectByMouse: true
                        onTextChanged: root.refresh()
                        Text {
                            visible: !search.text
                            text: "Buscar aplicaciones…"
                            color: root.muted
                            font: search.font
                        }
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) Qt.quit();
                            else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) root.launch(root.selection);
                            else if (event.key === Qt.Key_Right) root.moveSelection(1);
                            else if (event.key === Qt.Key_Left) root.moveSelection(-1);
                            else if (event.key === Qt.Key_Down) root.moveSelection(root.columns);
                            else if (event.key === Qt.Key_Up) root.moveSelection(-root.columns);
                            else return;
                            event.accepted = true;
                        }
                    }
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                GridView {
                    id: grid
                    anchors.fill: parent
                    clip: true
                    cellWidth: 136
                    cellHeight: 112
                    model: root.results
                    delegate: Item {
                        required property var modelData
                        required property int index
                        width: grid.cellWidth
                        height: grid.cellHeight
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 16
                            color: index === root.selection
                                   ? Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.19)
                                   : hover.containsMouse
                                     ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.08)
                                     : "transparent"
                            Column {
                                anchors.centerIn: parent
                                spacing: 8
                                Image {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 48
                                    height: 48
                                    sourceSize.width: 96
                                    sourceSize.height: 96
                                    source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: grid.cellWidth - 16
                                    text: modelData.name
                                    color: root.foreground
                                    font.family: root.fontName
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                }
                            }
                            MouseArea {
                                id: hover
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.launch(index)
                            }
                        }
                    }
                }
                Text {
                    anchors.centerIn: parent
                    visible: root.results.length === 0
                    text: "No se encontraron aplicaciones"
                    color: root.muted
                    font.family: root.fontName
                    font.pixelSize: 15
                }
            }
            Text {
                text: root.results.length + (root.results.length === 1 ? " aplicación" : " aplicaciones")
                color: root.muted
                font.family: root.fontName
                font.pixelSize: 12
            }
        }
    }
}
