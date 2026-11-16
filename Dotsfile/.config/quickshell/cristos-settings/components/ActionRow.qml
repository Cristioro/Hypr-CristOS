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
    radius: 12
    color: mouse.containsMouse ? Qt.rgba(theme.foreground.r, theme.foreground.g, theme.foreground.b, 0.07) : "transparent"
    Behavior on color { ColorAnimation { duration: 120 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 10
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
