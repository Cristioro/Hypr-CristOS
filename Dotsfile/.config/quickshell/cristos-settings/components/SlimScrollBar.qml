import QtQuick
import QtQuick.Controls

ScrollBar {
    id: bar
    required property var theme
    policy: ScrollBar.AsNeeded
    implicitWidth: 6
    visible: size < 1
    contentItem: Rectangle {
        implicitWidth: 6
        radius: 3
        color: Qt.rgba(bar.theme.primary.r, bar.theme.primary.g, bar.theme.primary.b,
                       bar.pressed ? 0.65 : 0.35)
    }
    background: Item {}
}
