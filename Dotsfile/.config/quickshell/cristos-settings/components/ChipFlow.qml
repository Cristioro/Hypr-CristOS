import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    property var options: []
    property string current: ""

    signal selected(string value)

    Layout.fillWidth: true
    implicitHeight: flow.implicitHeight

    Flow {
        id: flow
        width: parent.width
        spacing: 8

        Repeater {
            model: root.options

            delegate: Rectangle {
                id: chip
                required property string modelData
                readonly property bool active: modelData === root.current

                width: chipText.implicitWidth + 24
                height: 32
                radius: 16
                color: chip.active ? root.theme.primaryContainer : root.theme.surfaceHigh
                border.width: 1
                border.color: chip.active ? root.theme.primary : root.theme.outlineVariant

                Text {
                    id: chipText
                    anchors.centerIn: parent
                    text: chip.modelData
                    color: chip.active ? root.theme.foregroundPrimaryContainer : root.theme.foreground
                    font.family: root.theme.fontFamily
                    font.pixelSize: 12
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected(chip.modelData)
                }
            }
        }
    }
}
