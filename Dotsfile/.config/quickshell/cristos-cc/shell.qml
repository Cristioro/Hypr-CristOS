pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "components"

// Centro de control rápido: volumen, brillo y toggles del sistema.
// Se abre desde la barra (icono de controles) o con control-center.sh.
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
    WlrLayershell.namespace: "cristos-cc"

    Theme { id: pal }
    Core { id: core }

    Connections {
        target: core
        function onMenuLaunched() {
            Qt.quit();
        }
    }

    readonly property color glassFill: Qt.rgba(pal.background.r, pal.background.g,
                                               pal.background.b, 0.40)
    readonly property color glassBorder: Qt.rgba(pal.primary.r, pal.primary.g,
                                                 pal.primary.b, 0.30)
    readonly property color accentSoft: Qt.rgba(pal.primary.r, pal.primary.g,
                                                pal.primary.b, 0.22)

    // Clic fuera del panel = cerrar.
    MouseArea {
        anchors.fill: parent
        onClicked: Qt.quit()
    }

    // Esc = cerrar.
    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: Qt.quit()
    }

    Rectangle {
        id: panel
        width: 356
        implicitHeight: content.implicitHeight + 36
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 52
        anchors.rightMargin: 12
        radius: 22
        color: root.glassFill
        border.width: 1
        border.color: root.glassBorder

        // Brillo de vidrio en la parte superior.
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            gradient: Gradient {
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(pal.foreground.r, pal.foreground.g,
                                   pal.foreground.b, 0.10)
                }
                GradientStop {
                    position: 0.55
                    color: Qt.rgba(pal.foreground.r, pal.foreground.g,
                                   pal.foreground.b, 0.0)
                }
            }
        }

        // Evita que los clics del panel lleguen al fondo.
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // ------------------------------------------------------ Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "Centro de control"
                    color: pal.foreground
                    font.family: pal.fontFamily
                    font.pixelSize: 16
                    font.bold: true
                    Layout.fillWidth: true
                }

                Rectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 15
                    color: closeMouse.containsMouse ? root.accentSoft : "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: "✕"
                        color: pal.foregroundMuted
                        font.family: pal.fontFamily
                        font.pixelSize: 14
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

            // ----------------------------------------------------- Volumen
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        radius: 15
                        color: muteMouse.containsMouse ? root.accentSoft : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: core.muted ? "󰖁" : "󰕾"
                            color: core.muted ? pal.error : pal.foreground
                            font.family: pal.fontFamily
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: muteMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: core.toggleMute()
                        }
                    }

                    Text {
                        text: "Volumen"
                        color: pal.foregroundMuted
                        font.family: pal.fontFamily
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }

                    Text {
                        text: core.muted ? "Silenciado" : core.volume + "%"
                        color: core.muted ? pal.error : pal.foreground
                        font.family: pal.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                GlassSlider {
                    theme: pal
                    from: 0
                    to: 100
                    step: 1
                    value: core.volume
                    onReleased: (v) => core.setVolume(v)
                }
            }

            // ------------------------------------------------------ Brillo
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: "󰃠"
                        color: pal.foreground
                        font.family: pal.fontFamily
                        font.pixelSize: 17
                        Layout.leftMargin: 7
                    }

                    Text {
                        text: "Brillo"
                        color: pal.foregroundMuted
                        font.family: pal.fontFamily
                        font.pixelSize: 13
                        Layout.fillWidth: true
                    }

                    Text {
                        text: core.ddcAvailable ? core.brightnessPercent + "%" : "No disponible"
                        color: core.ddcAvailable ? pal.foreground : pal.foregroundMuted
                        font.family: pal.fontFamily
                        font.pixelSize: 13
                        font.bold: true
                    }
                }

                GlassSlider {
                    theme: pal
                    from: 0
                    to: 100
                    step: 1
                    value: core.brightnessPercent
                    enabled: core.ddcAvailable
                    onReleased: (v) => core.setBrightness(Math.round(v * core.brightnessMax / 100))
                }
            }

            // ------------------------------------------------ Conectividad
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                InfoRow {
                    theme: pal
                    glyph: core.networkGlyph
                    title: "Red"
                    subtitle: core.networkSubtitle
                    active: core.networkConnected
                    onClicked: core.launchMenu("wifi")
                }

                InfoRow {
                    theme: pal
                    glyph: core.btPowered ? (core.btCount > 0 ? "󰂱" : "󰂯") : "󰂲"
                    title: "Bluetooth"
                    subtitle: core.btSubtitle
                    active: core.btPowered
                    onClicked: core.launchMenu("bluetooth")
                }
            }

            // --------------------------------------------------- Separador
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 2
                Layout.bottomMargin: 2
                implicitHeight: 1
                color: Qt.rgba(pal.outlineVariant.r, pal.outlineVariant.g,
                               pal.outlineVariant.b, 0.6)
            }

            // ----------------------------------------------------- Toggles
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                TogglePill {
                    theme: pal
                    glyph: core.micMuted ? "󰍭" : "󰍬"
                    label: "Micrófono"
                    active: core.micMuted
                    onToggled: core.toggleMic()
                }

                TogglePill {
                    theme: pal
                    glyph: "󰖔"
                    label: "Luz nocturna"
                    active: core.nightlight
                    onToggled: core.toggleNightlight()
                }

                TogglePill {
                    theme: pal
                    glyph: "󰂛"
                    label: "No molestar"
                    active: core.dnd
                    onToggled: core.toggleDnd()
                }
            }
        }
    }
}
