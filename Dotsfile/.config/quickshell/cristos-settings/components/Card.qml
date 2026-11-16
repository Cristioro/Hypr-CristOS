import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string title: ""

    default property alias content: inner.data

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + 34
    radius: 18
    color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.70)
    border.width: 1
    border.color: Qt.rgba(theme.outline.r, theme.outline.g, theme.outline.b, 0.18)

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 17
        spacing: 12

        Text {
            visible: root.title.length > 0
            text: root.title
            color: root.theme.foreground
            font.family: root.theme.fontFamily
            font.pixelSize: 14
            font.bold: true
            Layout.fillWidth: true
        }

        ColumnLayout {
            id: inner
            Layout.fillWidth: true
            spacing: 8
        }
    }
}
