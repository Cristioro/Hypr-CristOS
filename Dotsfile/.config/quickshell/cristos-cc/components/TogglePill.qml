import QtQuick
import QtQuick.Layouts

// Pastilla de alternancia (micrófono, luz nocturna, no molestar).
Rectangle {
    id: root
    required property var theme
    property string glyph: ""
    property string label: ""
    property bool active: false

    signal toggled()

    Layout.fillWidth: true
    implicitHeight: 54
    radius: 14
    color: root.active
        ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.20)
        : (mouse.containsMouse ? theme.surfaceHigh : "transparent")
    Behavior on color { ColorAnimation { duration: 120 } }
    border.width: 1
    border.color: root.active
        ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.55)
        : theme.outlineVariant

    Column {
        anchors.centerIn: parent
        spacing: 3
        width: parent.width - 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.glyph
            color: root.active ? root.theme.primary : root.theme.foregroundMuted
            font.family: root.theme.fontFamily
            font.pixelSize: 17
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: root.label
            color: root.active ? root.theme.foreground : root.theme.foregroundMuted
            font.family: "Noto Sans"
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }
}
