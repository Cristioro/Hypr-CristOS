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
    implicitHeight: 43
    radius: 13
    color: root.active ? Qt.rgba(theme.primary.r, theme.primary.g, theme.primary.b, 0.18)
                       : (mouse.containsMouse ? Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.07) : "transparent")
    Behavior on color { ColorAnimation { duration: 130 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            implicitWidth: 29
            implicitHeight: 29
            radius: 10
            color: root.active ? Qt.rgba(root.theme.primary.r, root.theme.primary.g, root.theme.primary.b, 0.17) : "transparent"
            Text {
                anchors.centerIn: parent
                text: root.glyph
                color: root.active ? root.theme.primary : root.theme.foregroundMuted
                font.family: root.theme.iconFamily
                font.pixelSize: 16
            }
        }

        Text {
            text: root.label
            color: root.theme.foreground
            font.family: root.theme.fontFamily
            font.pixelSize: 12
            font.bold: root.active
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
