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
                label: "Ver historial de notificaciones"
                onClicked: page.core.runExternal(["notifications", "restore"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰑓"
                label: "Reiniciar servidor de notificaciones"
                onClicked: page.core.run(["notifications", "restart"])
            }
        }

        Item { Layout.preferredHeight: 8 }
    }
}
