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
            title: "Tu fondo"

            ActionRow {
                theme: page.theme
                glyph: "󰸉"
                label: "Cambiar fondo de pantalla"
                value: page.core.wallName
                onClicked: page.core.runExternal(["wallpaper", "picker"])
            }
        }

        Card {
            theme: page.theme
            title: "Colores y estilo"

            RowLayout {
                Layout.fillWidth: true
                spacing: 12

                Text {
                    text: "Paleta actual"
                    color: page.theme.foregroundMuted
                    font.family: page.theme.fontFamily
                    font.pixelSize: 12
                    Layout.fillWidth: true
                }

                Row {
                    spacing: 5
                    Repeater {
                        model: [page.theme.primary, page.theme.primaryContainer, page.theme.secondaryContainer,
                                page.theme.surfaceHighest, page.theme.foreground]
                        delegate: Rectangle {
                            required property var modelData
                            width: 18
                            height: 18
                            radius: 9
                            color: modelData
                            border.width: 1
                            border.color: page.theme.outlineVariant
                        }
                    }
                }
            }

            Text {
                text: "Modo"
                color: page.theme.foregroundMuted
                font.family: page.theme.fontFamily
                font.pixelSize: 12
            }

            ModePreview {
                Layout.fillWidth: true
                theme: page.theme
                current: page.core.mode
                onSelected: (v) => page.core.run(["theme", "mode", v])
            }

            Text {
                text: "Esquema de color"
                color: page.theme.foregroundMuted
                font.family: page.theme.fontFamily
                font.pixelSize: 12
                Layout.topMargin: 4
            }

            ChipFlow {
                theme: page.theme
                options: ["tonal-spot", "vibrant", "expressive", "fidelity", "content",
                          "neutral", "monochrome", "rainbow", "fruit-salad", "smart"]
                current: page.core.scheme
                onSelected: (v) => page.core.run(["theme", "scheme", v])
            }
        }

        Card {
            theme: page.theme
            title: "Barra"

            Text {
                text: "Tema de barra"
                color: page.theme.foregroundMuted
                font.family: page.theme.fontFamily
                font.pixelSize: 12
            }

            BarThemeChoices {
                theme: page.theme
                options: page.core.barThemes
                current: page.core.barTheme
                onSelected: (v) => page.core.run(["bar", "theme", v])
            }

            ToggleRow {
                theme: page.theme
                glyph: "󰍜"
                label: "Barra modular (islas)"
                checked: page.core.barMode === "modular"
                onToggled: page.core.run(["bar", "mode"])
            }
        }

        Card {
            theme: page.theme
            title: "Reloj"

            ChipFlow {
                theme: page.theme
                options: ["24 h", "24 h con segundos", "12 h", "12 h con segundos", "Fecha y hora", "Solo fecha"]
                current: page.core.clockLabel
                onSelected: (v) => page.core.run(["clock", "preset", page.clockPreset(v)])
            }
        }

        Card {
            theme: page.theme
            title: "Transparencia"

            SliderRow {
                theme: page.theme
                label: "Barra"
                from: 0
                to: 85
                step: 5
                value: page.core.transparencyWaybar
                onReleased: (v) => page.core.run(["transparency", "waybar", String(v)])
            }

            SliderRow {
                theme: page.theme
                label: "Rofi"
                from: 0
                to: 85
                step: 5
                value: page.core.transparencyRofi
                onReleased: (v) => page.core.run(["transparency", "rofi", String(v)])
            }
        }

        Card {
            theme: page.theme
            title: "Acciones"

            ActionRow {
                theme: page.theme
                glyph: "󰑓"
                label: "Regenerar tema desde el wallpaper"
                onClicked: page.core.run(["theme", "regenerate"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰒓"
                label: "Reiniciar Waybar"
                onClicked: page.core.run(["bar", "reload"])
            }

            ActionRow {
                theme: page.theme
                glyph: "󰑓"
                label: "Recargar Hyprland"
                onClicked: page.core.run(["reload"])
            }
        }

        Item { Layout.preferredHeight: 8 }
    }

    function clockPreset(label) {
        switch (label) {
        case "24 h": return "24h";
        case "24 h con segundos": return "24h-seg";
        case "12 h": return "12h";
        case "12 h con segundos": return "12h-seg";
        case "Fecha y hora": return "fecha-hora";
        case "Solo fecha": return "fecha";
        default: return "24h";
        }
    }
}
