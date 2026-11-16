import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    required property var theme
    property string current: "dark"
    signal selected(string value)
    spacing: 10

    Repeater {
        model: [
            { key: "dark", label: "Oscuro", bg: "#181c23", fg: "#eef1f7", panel: "#353c48" },
            { key: "light", label: "Claro", bg: "#e9edf4", fg: "#222b37", panel: "#c7d0dc" }
        ]
        delegate: Rectangle {
            id: choice
            required property var modelData
            readonly property bool active: root.current === modelData.key
            Layout.fillWidth: true
            Layout.preferredHeight: 68
            radius: 13
            color: mouse.containsMouse ? root.theme.surfaceHighest : root.theme.surfaceHigh
            border.width: 1
            border.color: active ? root.theme.primary : root.theme.outlineVariant
            Behavior on color { ColorAnimation { duration: 120 } }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10
                Rectangle {
                    implicitWidth: 54
                    implicitHeight: 42
                    radius: 8
                    color: choice.modelData.bg
                    Rectangle { x: 5; y: 5; width: 12; height: 32; radius: 4; color: choice.modelData.panel }
                    Rectangle { x: 22; y: 9; width: 24; height: 4; radius: 2; color: choice.modelData.fg; opacity: 0.85 }
                    Rectangle { x: 22; y: 18; width: 20; height: 3; radius: 2; color: choice.modelData.fg; opacity: 0.35 }
                    Rectangle { x: 22; y: 25; width: 16; height: 3; radius: 2; color: choice.modelData.fg; opacity: 0.25 }
                }
                Text {
                    text: choice.modelData.label
                    color: root.theme.foreground
                    font.family: root.theme.fontFamily
                    font.pixelSize: 13
                    font.bold: choice.active
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
                Text {
                    visible: choice.active
                    text: "✓"
                    color: root.theme.primary
                    font.pixelSize: 15
                }
            }
            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.selected(choice.modelData.key)
            }
        }
    }
}
