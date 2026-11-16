import QtQuick
import QtQuick.Layouts

Item {
    id: root
    required property var theme
    property string label: ""
    property int from: 0
    property int to: 100
    property int step: 5
    property int value: 0

    signal released(int value)

    Layout.fillWidth: true
    implicitHeight: 58

    property int dragValue: value
    property bool dragging: false
    readonly property int shownValue: dragging ? dragValue : value

    Text {
        text: root.label
        color: root.theme.foreground
        font.family: root.theme.fontFamily
        font.pixelSize: 14
        anchors.left: parent.left
        anchors.top: parent.top
    }

    Text {
        text: root.shownValue + "%"
        color: root.theme.foregroundMuted
        font.family: root.theme.fontFamily
        font.pixelSize: 13
        anchors.right: parent.right
        anchors.top: parent.top
    }

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 8
        height: 5
        radius: 3
        color: root.theme.outlineVariant

        Rectangle {
            width: track.width * (root.shownValue - root.from) / Math.max(1, root.to - root.from)
            height: parent.height
            radius: parent.radius
            color: root.theme.primary
        }
    }

    Rectangle {
        id: knob
        width: 16
        height: 16
        radius: 8
        color: root.theme.primary
        border.width: 2
        border.color: root.theme.background
        anchors.bottom: track.bottom
        anchors.bottomMargin: -5
        x: Math.max(0, Math.min(track.width - width,
                               track.width * (root.shownValue - root.from) / Math.max(1, root.to - root.from) - width / 2))
    }

    MouseArea {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 34
        cursorShape: Qt.PointingHandCursor

        onPressed: (mouse) => {
            root.dragging = true;
            root.updateFromMouse(mouse.x);
        }
        onPositionChanged: (mouse) => {
            if (root.dragging)
                root.updateFromMouse(mouse.x);
        }
        onReleased: {
            root.dragging = false;
            root.released(root.dragValue);
        }
    }

    function updateFromMouse(x) {
        const ratio = Math.max(0, Math.min(1, x / Math.max(1, track.width)));
        const raw = root.from + ratio * (root.to - root.from);
        const snapped = Math.round(raw / root.step) * root.step;
        root.dragValue = Math.max(root.from, Math.min(root.to, snapped));
    }
}
