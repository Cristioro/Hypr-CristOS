import QtQuick
import QtQuick.Layouts

// Slider compacto para el centro de control: solo pista + knob.
Item {
    id: root
    required property var theme
    property int from: 0
    property int to: 100
    property int step: 1
    property int value: 0
    property bool enabled: true

    signal released(int value)

    Layout.fillWidth: true
    implicitHeight: 26

    property int dragValue: value
    property bool dragging: false
    readonly property int shownValue: dragging ? dragValue : value
    readonly property real ratio: Math.max(0, Math.min(1,
        (shownValue - from) / Math.max(1, to - from)))

    Rectangle {
        id: track
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: 6
        radius: 3
        color: Qt.rgba(root.theme.foreground.r, root.theme.foreground.g,
                       root.theme.foreground.b, root.enabled ? 0.18 : 0.08)

        Rectangle {
            width: track.width * root.ratio
            height: parent.height
            radius: parent.radius
            color: root.enabled ? root.theme.primary : root.theme.outlineVariant
        }
    }

    Rectangle {
        id: knob
        width: 14
        height: 14
        radius: 7
        color: root.enabled ? root.theme.primary : root.theme.outlineVariant
        border.width: 2
        border.color: root.theme.background
        anchors.verticalCenter: track.verticalCenter
        x: Math.max(0, Math.min(track.width - width,
                               track.width * root.ratio - width / 2))
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.enabled
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
        const r = Math.max(0, Math.min(1, x / Math.max(1, track.width)));
        const raw = root.from + r * (root.to - root.from);
        root.dragValue = Math.max(root.from, Math.min(root.to,
                                 Math.round(raw / root.step) * root.step));
    }
}
