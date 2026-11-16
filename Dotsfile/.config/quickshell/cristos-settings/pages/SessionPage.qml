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
            title: "Acciones"

            ActionRow {
                theme: page.theme
                glyph: "󰌾"
                label: "Bloquear pantalla"
                onClicked: page.core.runExternal(["session", "lock"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰒲"
                label: "Suspender"
                onClicked: page.confirm.ask("¿Suspender el equipo?", () => page.core.runExternal(["session", "suspend"]))
            }

            ActionRow {
                theme: page.theme
                glyph: "󰍃"
                label: "Cerrar sesión"
                onClicked: page.confirm.ask("¿Cerrar la sesión de Hyprland?", () => page.core.runExternal(["session", "logout"]))
            }

            ActionRow {
                theme: page.theme
                glyph: "󰜉"
                label: "Reiniciar"
                onClicked: page.confirm.ask("¿Reiniciar el equipo?", () => page.core.runExternal(["session", "reboot"]))
            }

            ActionRow {
                theme: page.theme
                glyph: "󰐥"
                label: "Apagar"
                onClicked: page.confirm.ask("¿Apagar el equipo?", () => page.core.runExternal(["session", "poweroff"]))
            }
        }

        Item { Layout.preferredHeight: 8 }
    }
}
