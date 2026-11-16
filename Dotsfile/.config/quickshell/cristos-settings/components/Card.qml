import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme
    property string title: ""

    default property alias content: inner.data

    Layout.fillWidth: true
    implicitHeight: layout.implicitHeight + 28
    radius: 14
    color: theme.surface
    border.width: 1
    border.color: theme.outlineVariant

    ColumnLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        Text {
            visible: root.title.length > 0
            text: root.title
            color: root.theme.primary
            font.family: root.theme.fontFamily
            font.pixelSize: 13
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
