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
            title: "Sistema"

            Text {
                text: page.core.hostname + " · " + page.core.kernel
                color: page.theme.foregroundMuted
                font.family: page.theme.fontFamily
                font.pixelSize: 13
            }
        }

        Card {
            theme: page.theme
            title: "Teclado"

            ActionRow {
                theme: page.theme
                glyph: "󰌌"
                label: "Español (Latam)"
                onClicked: page.core.run(["keyboard", "es"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰌌"
                label: "English (US)"
                onClicked: page.core.run(["keyboard", "us"])
            }
        }

        Card {
            theme: page.theme
            title: "Herramientas"

            ActionRow {
                theme: page.theme
                glyph: "󰌌"
                label: "Ver atajos de teclado"
                onClicked: page.core.runExternal(["system", "keybinds"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰋼"
                label: "Información del sistema (fastfetch)"
                onClicked: page.core.runExternal(["system", "fastfetch"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰢮"
                label: "Monitor de recursos (btop)"
                onClicked: page.core.runExternal(["system", "btop"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰚰"
                label: "Actualizar sistema (paru -Syu)"
                onClicked: page.core.runExternal(["system", "update"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰑓"
                label: "Reconstruir miniaturas de wallpapers"
                onClicked: page.core.runExternal(["system", "thumbs"])
            }
        }

        Item { Layout.preferredHeight: 8 }
    }
}
