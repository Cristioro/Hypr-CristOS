import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string glyph: ""
    property string label: ""
    property string value: ""

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 44
    radius: 10
    color: mouse.containsMouse ? theme.surfaceHigh : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 10
        spacing: 10

        Text {
            visible: root.glyph.length > 0
            text: root.glyph
            color: root.theme.foregroundMuted
            font.family: root.theme.fontFamily
            font.pixelSize: 15
        }

        Text {
            text: root.label
            color: root.theme.foreground
            font.family: root.theme.fontFamily
            font.pixelSize: 14
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            visible: root.value.length > 0
            text: root.value
            color: root.theme.foregroundMuted
            font.family: root.theme.fontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.maximumWidth: 260
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
