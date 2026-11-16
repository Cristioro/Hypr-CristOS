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
            title: "Salida"

            SliderRow {
                theme: page.theme
                label: "Volumen"
                from: 0
                to: 100
                step: 5
                value: Math.round((parseFloat(page.core.volume) || 0) * 100)
                onReleased: (v) => page.core.run(["audio", "set", String(v)])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰝝"
                label: "Subir 5%"
                onClicked: page.core.run(["audio", "up"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰝞"
                label: "Bajar 5%"
                onClicked: page.core.run(["audio", "down"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰖁"
                label: "Silenciar salida"
                onClicked: page.core.run(["audio", "mute"])
            }
        }

        Card {
            theme: page.theme
            title: "Micrófono"

            ActionRow {
                theme: page.theme
                glyph: "󰍬"
                label: "Silenciar micrófono"
                onClicked: page.core.run(["audio", "mic-mute"])
            }
        }

        Card {
            theme: page.theme
            title: "Mezclador"

            ActionRow {
                theme: page.theme
                glyph: "󰕾"
                label: "Abrir pavucontrol"
                onClicked: page.core.runExternal(["audio", "mixer"])
            }
        }

        Item { Layout.preferredHeight: 8 }
    }
}
