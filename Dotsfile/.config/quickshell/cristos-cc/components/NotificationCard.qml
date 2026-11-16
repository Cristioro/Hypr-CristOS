pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    required property var theme
    required property var entry
    signal dismissed()
    signal actionInvoked(int index)
    implicitHeight: content.implicitHeight + 24
    radius: 16
    color: Qt.rgba(theme.surface.r, theme.surface.g, theme.surface.b, 0.97)
    border.width: 1
    border.color: Qt.rgba(theme.outline.r, theme.outline.g, theme.outline.b, 0.22)

    ColumnLayout {
        id: content
        anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
        anchors.margins: 12
        spacing: 6
        RowLayout {
            Layout.fillWidth: true
            Image {
                readonly property string resolved: root.entry.image
                    ? root.entry.image
                    : (root.entry.icon ? Quickshell.iconPath(root.entry.icon, "application-x-executable") : "")
                source: resolved
                sourceSize.width: 48; sourceSize.height: 48
                Layout.preferredWidth: visible ? 24 : 0; Layout.preferredHeight: 24
                visible: resolved.length > 0
                asynchronous: true
            }
            Text {
                text: root.entry.app || "Aplicación"
                textFormat: Text.PlainText
                color: root.theme.primary; font.family: "Noto Sans"; font.pixelSize: 11; font.bold: true
                elide: Text.ElideRight; Layout.fillWidth: true
            }
            Text { text: root.entry.time || ""; color: root.theme.foregroundMuted; font.family: "Noto Sans"; font.pixelSize: 10 }
            Rectangle {
                implicitWidth: 24; implicitHeight: 24; radius: 8
                color: closeMouse.containsMouse ? root.theme.surfaceHighest : "transparent"
                Text { anchors.centerIn: parent; text: "✕"; color: root.theme.foregroundMuted; font.pixelSize: 12 }
                MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.dismissed() }
            }
        }
        Text {
            text: root.entry.title || ""
            textFormat: Text.PlainText
            color: root.theme.foreground; font.family: "Noto Sans"; font.pixelSize: 13; font.bold: true
            wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight; Layout.fillWidth: true
        }
        Text {
            visible: !!root.entry.body
            text: root.entry.body || ""
            textFormat: Text.PlainText
            color: root.theme.foregroundMuted; font.family: "Noto Sans"; font.pixelSize: 12
            wrapMode: Text.Wrap; maximumLineCount: 4; elide: Text.ElideRight; Layout.fillWidth: true
        }
        Flow {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: root.entry.live && root.entry.notification ? root.entry.notification.actions : []
                delegate: Rectangle {
                    id: button
                    required property var modelData
                    required property int index
                    width: Math.min(actionText.implicitWidth + 20, root.width - 24)
                    height: 28; radius: 9
                    color: actionMouse.containsMouse ? root.theme.surfaceHighest : root.theme.primaryContainer
                    Text {
                        id: actionText
                        anchors.centerIn: parent
                        width: Math.min(implicitWidth, parent.width - 12)
                        text: button.modelData.text || "Abrir"
                        textFormat: Text.PlainText; elide: Text.ElideRight
                        color: root.theme.foregroundPrimaryContainer; font.family: "Noto Sans"; font.pixelSize: 11
                    }
                    MouseArea { id: actionMouse; anchors.fill: parent; hoverEnabled: true; onClicked: root.actionInvoked(button.index) }
                }
            }
        }
    }
}
