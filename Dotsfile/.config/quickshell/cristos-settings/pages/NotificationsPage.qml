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
            title: "Modo"

            ToggleRow {
                theme: page.theme
                glyph: "󰂚"
                label: "No molestar"
                checked: page.core.dnd === "Sí"
                onToggled: page.core.run(["notifications", "dnd"])
            }
        }

        Card {
            theme: page.theme
            title: "Acciones"

            ActionRow {
                theme: page.theme
                glyph: "󰎟"
                label: "Descartar todas"
                onClicked: page.core.run(["notifications", "dismiss-all"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰃷"
                label: "Restaurar última"
                onClicked: page.core.run(["notifications", "restore"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰑓"
                label: "Reiniciar mako"
                onClicked: page.core.run(["notifications", "restart"])
            }
        }

        Item { Layout.preferredHeight: 8 }
    }
}
