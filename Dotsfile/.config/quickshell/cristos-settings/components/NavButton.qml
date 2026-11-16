import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string glyph: ""
    property string label: ""
    property bool active: false

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 42
    radius: 10
    color: root.active ? theme.primaryContainer : (mouse.containsMouse ? theme.surfaceHigh : "transparent")

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Text {
            text: root.glyph
            color: root.active ? root.theme.foregroundPrimaryContainer : root.theme.foregroundMuted
            font.family: root.theme.fontFamily
            font.pixelSize: 15
        }

        Text {
            text: root.label
            color: root.active ? root.theme.foregroundPrimaryContainer : root.theme.foreground
            font.family: root.theme.fontFamily
            font.pixelSize: 14
            elide: Text.ElideRight
            Layout.fillWidth: true
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
