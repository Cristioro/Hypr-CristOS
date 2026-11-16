import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property var theme
    property var options: []
    property string current: ""

    signal selected(string value)

    spacing: 6

    Repeater {
        model: root.options

        delegate: Rectangle {
            id: chip
            required property string modelData
            readonly property bool active: modelData === root.current

            implicitWidth: chipText.implicitWidth + 26
            implicitHeight: 34
            radius: 9
            color: chip.active ? root.theme.primaryContainer : (mouse.containsMouse ? root.theme.surfaceHighest : root.theme.surfaceHigh)
            border.width: 1
            border.color: chip.active ? root.theme.primary : "transparent"
            Behavior on color { ColorAnimation { duration: 120 } }

            Text {
                id: chipText
                anchors.centerIn: parent
                text: chip.modelData
                color: chip.active ? root.theme.foregroundPrimaryContainer : root.theme.foreground
                font.family: root.theme.fontFamily
                font.pixelSize: 13
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selected(chip.modelData)
            }
        }
    }
}
