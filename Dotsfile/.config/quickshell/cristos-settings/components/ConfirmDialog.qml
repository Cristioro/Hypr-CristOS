import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root
    required property var theme

    property string message: ""
    property var action: null

    visible: false
    color: Qt.rgba(0, 0, 0, 0.55)

    function ask(msg, cb) {
        message = msg;
        action = cb;
        visible = true;
    }

    function reject() {
        visible = false;
        action = null;
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.reject()
    }

    Rectangle {
        width: Math.min(420, root.width - 80)
        implicitHeight: dialogCol.implicitHeight + 40
        anchors.centerIn: parent
        radius: 16
        color: root.theme.surface
        border.width: 1
        border.color: root.theme.outlineVariant

        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }

        ColumnLayout {
            id: dialogCol
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 20
            spacing: 18

            Text {
                text: root.message
                color: root.theme.foreground
                font.family: root.theme.fontFamily
                font.pixelSize: 15
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Item { Layout.fillWidth: true }

                Rectangle {
                    implicitWidth: 88
                    implicitHeight: 36
                    radius: 10
                    color: noMouse.containsMouse ? root.theme.surfaceHighest : root.theme.surfaceHigh

                    Text {
                        anchors.centerIn: parent
                        text: "No"
                        color: root.theme.foreground
                        font.family: root.theme.fontFamily
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: noMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.reject()
                    }
                }

                Rectangle {
                    implicitWidth: 88
                    implicitHeight: 36
                    radius: 10
                    color: yesMouse.containsMouse ? root.theme.primary : root.theme.primaryContainer

                    Text {
                        anchors.centerIn: parent
                        text: "Sí"
                        color: yesMouse.containsMouse ? root.theme.foregroundPrimary : root.theme.foregroundPrimaryContainer
                        font.family: root.theme.fontFamily
                        font.pixelSize: 13
                    }

                    MouseArea {
                        id: yesMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const cb = root.action;
                            root.visible = false;
                            root.action = null;
                            if (cb)
                                cb();
                        }
                    }
                }
            }
        }
    }
}
