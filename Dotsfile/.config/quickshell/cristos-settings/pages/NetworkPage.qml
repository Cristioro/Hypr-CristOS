import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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
    ScrollBar.vertical: SlimScrollBar { theme: page.theme }

    ColumnLayout {
        id: col
        width: page.width
        spacing: 14

        Card {
            theme: page.theme
            title: "Estado"

            Text {
                text: page.networkLabel(page.core.networkState)
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

    function networkLabel(state) {
        const code = parseInt(state, 10);
        if (code === 100) return "Conectado";
        if (code === 70) return "Desconectando";
        if (code >= 40 && code < 100) return "Conectando";
        if (code === 30) return "Desconectado";
        if (code === 20) return "No disponible";
        if (code === 10) return "No gestionado";
        return state ? state : "Sin información";
    }
}
