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
                id: choice
                required property string modelData
                readonly property bool active: modelData === root.current
                width: Math.max(92, Math.min(114, flow.width))
                height: 64
                radius: 12
                color: mouse.containsMouse ? root.theme.surfaceHighest : root.theme.surfaceHigh
                border.width: 1
                border.color: active ? root.theme.primary : root.theme.outlineVariant
                Behavior on color { ColorAnimation { duration: 120 } }
                Column {
                    anchors.fill: parent
                    anchors.margins: 9
                    spacing: 7
                    Rectangle {
                        width: parent.width
                        height: 13
                        radius: 5
                        color: Qt.rgba(root.theme.background.r, root.theme.background.g, root.theme.background.b, 0.75)
                        Row {
                            anchors.centerIn: parent
                            spacing: 4
                            Rectangle { width: 22; height: 4; radius: 2; color: root.theme.foregroundMuted; opacity: 0.7 }
                            Rectangle { width: 15; height: 4; radius: 2; color: root.theme.primary }
                            Rectangle { width: 22; height: 4; radius: 2; color: root.theme.foregroundMuted; opacity: 0.7 }
                        }
                    }
                    Text {
                        width: parent.width
                        text: choice.modelData
                        color: choice.active ? root.theme.primary : root.theme.foreground
                        font.family: root.theme.fontFamily
                        font.pixelSize: 11
                        font.bold: choice.active
                        elide: Text.ElideRight
                    }
                }
                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.selected(choice.modelData)
                }
            }
        }
    }
}
