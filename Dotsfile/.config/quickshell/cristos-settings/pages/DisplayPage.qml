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
            title: "Brillo"

            ActionRow {
                theme: page.theme
                glyph: "󰃞"
                label: "Subir 5%"
                onClicked: page.core.run(["display", "brightness-up"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰃟"
                label: "Bajar 5%"
                onClicked: page.core.run(["display", "brightness-down"])
            }
        }

        Card {
            theme: page.theme
            title: "Pantalla"

            ToggleRow {
                theme: page.theme
                glyph: "󰔎"
                label: "Luz nocturna"
                checked: page.core.nightlight === "on"
                onToggled: page.core.run(["display", "nightlight"])
            }

            ToggleRow {
                theme: page.theme
                glyph: "󰈈"
                label: "Cafeína (evitar suspensión)"
                checked: page.core.caffeine === "Activada"
                onToggled: page.core.run(["display", "caffeine"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰍹"
                label: "Resolución y escala (nwg-displays)"
                onClicked: page.core.runExternal(["display", "displays"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰑓"
                label: "Recargar monitores"
                onClicked: page.core.run(["display", "reload"])
            }
        }

        Item { Layout.preferredHeight: 8 }
    }
}
