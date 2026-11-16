import QtQuick
import QtQuick.Layouts
import "../components"

Flickable {
    id: page
    required property var core
    required property var theme
    required property var confirm

    clip: true
    contentWidth: width
    contentHeight: col.implicitHeight
    boundsBehavior: Flickable.StopAtBounds

    ColumnLayout {
        id: col
        width: page.width
        spacing: 14

        Card {
            theme: page.theme
            title: "Estado"

            Text {
                text: page.core.networkState.length > 0 ? page.core.networkState : "Sin conexión"
                color: page.theme.foreground
                font.family: page.theme.fontFamily
                font.pixelSize: 14
            }
        }

        Card {
            theme: page.theme
            title: "Conexiones"

            ActionRow {
                theme: page.theme
                glyph: "󰖩"
                label: "WiFi"
                onClicked: page.core.runExternal(["network", "wifi"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰂯"
                label: "Bluetooth"
                onClicked: page.core.runExternal(["network", "bluetooth"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰈀"
                label: "Editor de conexiones"
                onClicked: page.core.runExternal(["network", "editor"])
            }
        }

        Item { Layout.preferredHeight: 8 }
    }
}
