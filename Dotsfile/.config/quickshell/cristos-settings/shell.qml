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
        { glyph: "󰏘", title: "Apariencia", description: "Haz que tu espacio se sienta tuyo." },
        { glyph: "󰍹", title: "Pantalla", description: "Brillo, pantallas y bienestar visual." },
        { glyph: "󰖩", title: "Red y Bluetooth", description: "Tus conexiones, en un solo lugar." },
        { glyph: "󰕾", title: "Audio", description: "Controla el sonido y el micrófono." },
        { glyph: "󰂚", title: "Notificaciones", description: "Decide cuándo quieres recibir avisos." },
        { glyph: "󰘕", title: "Atajos y sistema", description: "Teclado, herramientas e información." },
        { glyph: "󰐥", title: "Sesión y energía", description: "Controla tu sesión de forma segura." }
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
        color: Qt.rgba(0, 0, 0, 0.16)

        MouseArea {
            anchors.fill: parent
            onClicked: Qt.quit()
        }
    }

    // Captura de teclado (Esc cierra / cierra el diálogo).
    Item {
        id: keyHandler
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
        width: Math.max(1, Math.min(1060, root.width - 40))
        height: Math.max(1, Math.min(720, root.height - 40))
        anchors.centerIn: parent
        radius: 24
        color: Qt.rgba(pal.background.r, pal.background.g, pal.background.b, 0.92)
        border.width: 1
        border.color: Qt.rgba(pal.primary.r, pal.primary.g, pal.primary.b, 0.32)
        opacity: 0
        Component.onCompleted: entrance.start()
        NumberAnimation { id: entrance; target: windowRect; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // ------------------------------------------------------ Sidebar
            Rectangle {
                Layout.preferredWidth: root.width < 700 ? 185 : 238
                Layout.fillHeight: true
                color: Qt.rgba(pal.surfaceLow.r, pal.surfaceLow.g, pal.surfaceLow.b, 0.75)
                radius: 24

                // Esquinas derechas rectas (la barra lateral va pegada al contenido).
                Rectangle {
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: 24
                    color: parent.color
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 5

                    RowLayout {
                        spacing: 11
                        Layout.bottomMargin: 17
                        Rectangle {
                            implicitWidth: 38
                            implicitHeight: 38
                            radius: 13
                            color: Qt.rgba(pal.primary.r, pal.primary.g, pal.primary.b, 0.17)
                            Text {
                                anchors.centerIn: parent
                                text: "󰒓"
                                font.family: pal.iconFamily
                                font.pixelSize: 20
                                color: pal.primary
                            }
                        }
                        ColumnLayout {
                            spacing: 1
                            Layout.fillWidth: true
                            Text {
                                text: "CristOS"
                                color: pal.foreground
                                font.family: pal.fontFamily
                                font.pixelSize: 17
                                font.bold: true
                            }
                            Text {
                                text: "AJUSTES"
                                color: pal.foregroundMuted
                                font.family: pal.fontFamily
                                font.pixelSize: 10
                                font.letterSpacing: 1.2
                            }
                        }
                    }

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

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: deviceInfo.implicitHeight + 20
                        radius: 14
                        color: Qt.rgba(pal.foreground.r, pal.foreground.g, pal.foreground.b, 0.04)
                        border.width: 1
                        border.color: Qt.rgba(pal.outline.r, pal.outline.g, pal.outline.b, 0.14)
                        Column {
                            id: deviceInfo
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 2
                            Text {
                                width: parent.width
                                text: core.hostname || "Tu equipo"
                                color: pal.foreground
                                font.family: pal.fontFamily
                                font.pixelSize: 12
                                font.bold: true
                                elide: Text.ElideRight
                            }
                            Text {
                                width: parent.width
                                text: core.kernel || "Hypr-CristOS"
                                color: pal.foregroundMuted
                                font.family: pal.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                            }
                        }
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
                Layout.leftMargin: 30
                Layout.rightMargin: 30
                Layout.topMargin: 26
                Layout.bottomMargin: 24
                spacing: 20

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Text {
                            text: root.pageDefs[root.pageIndex].title
                            color: pal.foreground
                            font.family: pal.fontFamily
                            font.pixelSize: 26
                            font.bold: true
                        }
                        Text {
                            text: root.pageDefs[root.pageIndex].description
                            color: pal.foregroundMuted
                            font.family: pal.fontFamily
                            font.pixelSize: 12
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 18
                        color: closeMouse.containsMouse ? pal.surfaceHigh : Qt.rgba(pal.foreground.r, pal.foreground.g, pal.foreground.b, 0.05)
                        Behavior on color { ColorAnimation { duration: 120 } }

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
        // Devuelve el foco después de procesar la tecla que cerró el diálogo.
        onVisibleChanged: if (!visible) Qt.callLater(() => keyHandler.forceActiveFocus())
    }
}
