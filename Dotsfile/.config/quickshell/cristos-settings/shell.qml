pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "components"
import "pages"

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
    WlrLayershell.namespace: "cristos-settings"

    property int pageIndex: {
        const n = Number(Quickshell.env("CRISTOS_SETTINGS_PAGE"));
        return Number.isFinite(n) ? Math.max(0, Math.min(6, n)) : 0;
    }

    readonly property var pageDefs: [
        { glyph: "󰏘", title: "Apariencia" },
        { glyph: "󰍹", title: "Pantalla" },
        { glyph: "󰖩", title: "Red y Bluetooth" },
        { glyph: "󰕾", title: "Audio" },
        { glyph: "󰂚", title: "Notificaciones" },
        { glyph: "󰘕", title: "Atajos y sistema" },
        { glyph: "󰐥", title: "Sesión y energía" }
    ]

    Theme { id: pal }
    Core { id: core }

    Connections {
        target: core
        function onRequestClose() {
            Qt.quit();
        }
    }

    // Fondo oscurecido; clic fuera = cerrar.
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    // Captura de teclado (Esc cierra / cierra el diálogo).
    Item {
        anchors.fill: parent
        focus: true

        Keys.onEscapePressed: {
            if (confirm.visible)
                confirm.reject();
            else
                Qt.quit();
        }
    }

    Rectangle {
        id: windowRect
        width: Math.min(1040, root.width - 120)
        height: Math.min(700, root.height - 100)
        anchors.centerIn: parent
        radius: 18
        color: pal.background
        border.width: 1
        border.color: pal.outlineVariant

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ------------------------------------------------------ Sidebar
            Rectangle {
                Layout.preferredWidth: 232
                Layout.fillHeight: true
                color: pal.surfaceLow
                radius: 18

                // Esquinas derechas rectas (la barra lateral va pegada al contenido).
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 18
                    color: parent.color
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 4

                    Text {
                        text: "Ajustes"
                        color: pal.foreground
                        font.family: pal.fontFamily
                        font.pixelSize: 22
                        font.bold: true
                    }

                    Text {
                        text: "Hypr-CristOS"
                        color: pal.foregroundMuted
                        font.family: pal.fontFamily
                        font.pixelSize: 12
                    }

                    Item { Layout.preferredHeight: 12 }

                    Repeater {
                        model: root.pageDefs

                        delegate: NavButton {
                            required property var modelData
                            required property int index
                            theme: pal
                            glyph: modelData.glyph
                            label: modelData.title
                            active: root.pageIndex === index
                            onClicked: root.pageIndex = index
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Text {
                        text: core.hostname + "\n" + core.kernel
                        color: pal.foregroundMuted
                        font.family: pal.fontFamily
                        font.pixelSize: 11
                        lineHeight: 1.3
                        wrapMode: Text.WordWrap
                        Layout.fillWidth: true
                    }

                    Text {
                        text: "Esc · cerrar"
                        color: pal.foregroundMuted
                        font.family: pal.fontFamily
                        font.pixelSize: 10
                        Layout.topMargin: 6
                    }
                }
            }

            // ------------------------------------------------------ Contenido
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 26
                spacing: 16

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    Text {
                        text: root.pageDefs[root.pageIndex].title
                        color: pal.foreground
                        font.family: pal.fontFamily
                        font.pixelSize: 24
                        font.bold: true
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 18
                        color: closeMouse.containsMouse ? pal.surfaceHigh : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "✕"
                            color: pal.foregroundMuted
                            font.family: pal.fontFamily
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.quit()
                        }
                    }
                }

                StackLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    currentIndex: root.pageIndex

                    AppearancePage { core: core; theme: pal; confirm: confirm }
                    DisplayPage { core: core; theme: pal; confirm: confirm }
                    NetworkPage { core: core; theme: pal; confirm: confirm }
                    AudioPage { core: core; theme: pal; confirm: confirm }
                    NotificationsPage { core: core; theme: pal; confirm: confirm }
                    SystemPage { core: core; theme: pal; confirm: confirm }
                    SessionPage { core: core; theme: pal; confirm: confirm }
                }
            }
        }
    }

    ConfirmDialog {
        id: confirm
        theme: pal
        anchors.fill: parent
    }
}
