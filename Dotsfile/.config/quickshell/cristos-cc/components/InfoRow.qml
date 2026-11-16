import QtQuick
import QtQuick.Layouts

// Fila informativa y clicable del centro de control (Red, Bluetooth).
// Muestra el estado actual y, al pulsar, abre el menú rofi de gestión.
Rectangle {
    id: root
    required property var theme
    property string glyph: ""
    property string title: ""
    property string subtitle: ""
    property bool active: true

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 54
    radius: 14
    color: mouse.containsMouse
        ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.12)
        : "transparent"
    border.width: 1
    border.color: Qt.rgba(theme.outlineVariant.r, theme.outlineVariant.g,
                          theme.outlineVariant.b, 0.55)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Text {
            text: root.glyph
            color: root.active ? root.theme.foreground : root.theme.foregroundMuted
            font.family: root.theme.fontFamily
            font.pixelSize: 18
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                text: root.title
                color: root.theme.foreground
                font.family: root.theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                text: root.subtitle
                color: root.theme.foregroundMuted
                font.family: root.theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Text {
            text: "›"
            color: root.theme.foregroundMuted
            font.family: root.theme.fontFamily
            font.pixelSize: 16
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
