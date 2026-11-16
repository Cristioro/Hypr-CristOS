import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string glyph: ""
    property string label: ""
    property bool checked: false

    signal toggled()

    Layout.fillWidth: true
    implicitHeight: 44
    radius: 12
    color: mouse.containsMouse ? Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.07) : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            visible: root.glyph.length > 0
            implicitWidth: 30
            implicitHeight: 30
            radius: 10
            color: Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.12)
            Text {
                anchors.centerIn: parent
                text: root.glyph
                color: root.theme.primary
                font.family: root.theme.iconFamily
                font.pixelSize: 15
            }
        }

        Text {
            text: root.label
            color: root.theme.foreground
            font.family: root.theme.fontFamily
            font.pixelSize: 14
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Rectangle {
            id: track
            implicitWidth: 42
            implicitHeight: 24
            radius: 12
            color: root.checked ? root.theme.primary : root.theme.surfaceHighest
            Behavior on color { ColorAnimation { duration: 120 } }
            border.width: 1
            border.color: root.checked ? root.theme.primary : root.theme.outlineVariant

            Rectangle {
                id: knob
                width: 16
                height: 16
                radius: 8
                y: 3
                x: root.checked ? track.width - width - 4 : 4
                color: root.checked ? root.theme.foregroundPrimary : root.theme.foregroundMuted
                Behavior on x {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
            }
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
