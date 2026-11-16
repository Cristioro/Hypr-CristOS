import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    readonly property string fontFamily: "CaskaydiaCove Nerd Font Propo"

    // Paleta completa por defecto (tema oscuro). Solo se reemplaza por otra
    // paleta COMPLETA y válida; nunca se mezcla a medias. Así, mientras
    // matugen reescribe colors.json, se conservan los últimos colores buenos
    // y el texto jamás queda negro sobre un fondo oscuro.
    readonly property var defaultPalette: ({
        background: "#1a110f",
        surfaceLow: "#231917",
        surface: "#271d1b",
        surfaceHigh: "#322825",
        surfaceHighest: "#3d3230",
        onSurface: "#f1dfdb",
        onSurfaceVariant: "#d8c2bd",
        primary: "#ffb4a3",
        onPrimary: "#561f12",
        primaryContainer: "#733426",
        onPrimaryContainer: "#ffdad2",
        secondaryContainer: "#5d3f39",
        onSecondaryContainer: "#ffdad2",
        outline: "#a08c88",
        outlineVariant: "#534340",
        error: "#ffb4ab",
        onError: "#690005"
    })

    readonly property var paletteKeys: [
        "background", "surfaceLow", "surface", "surfaceHigh", "surfaceHighest",
        "onSurface", "onSurfaceVariant", "primary", "onPrimary",
        "primaryContainer", "onPrimaryContainer", "secondaryContainer",
        "onSecondaryContainer", "outline", "outlineVariant", "error", "onError"
    ]

    property var palette: defaultPalette

    // Nota: las propiedades NO pueden llamarse "onSurface", "onPrimary", etc.
    // QML las interpreta como signal handlers (colisionan con las propiedades
    // surface/primary/...) y las deja en negro. Por eso usamos "foreground*".
    readonly property color background: palette["background"]
    readonly property color surfaceLow: palette["surfaceLow"]
    readonly property color surface: palette["surface"]
    readonly property color surfaceHigh: palette["surfaceHigh"]
    readonly property color surfaceHighest: palette["surfaceHighest"]
    readonly property color foreground: palette["onSurface"]
    readonly property color foregroundMuted: palette["onSurfaceVariant"]
    readonly property color primary: palette["primary"]
    readonly property color foregroundPrimary: palette["onPrimary"]
    readonly property color primaryContainer: palette["primaryContainer"]
    readonly property color foregroundPrimaryContainer: palette["onPrimaryContainer"]
    readonly property color secondaryContainer: palette["secondaryContainer"]
    readonly property color foregroundSecondaryContainer: palette["onSecondaryContainer"]
    readonly property color outline: palette["outline"]
    readonly property color outlineVariant: palette["outlineVariant"]
    readonly property color error: palette["error"]
    readonly property color foregroundError: palette["onError"]

    function applyText(raw) {
        if (!raw || raw.trim().length === 0)
            return;

        let obj;
        try {
            obj = JSON.parse(raw);
        } catch (e) {
            // Archivo a medio escribir: se mantiene la paleta anterior.
            return;
        }

        if (!obj || typeof obj !== "object")
            return;

        // Solo se acepta si TODAS las claves existen y son colores válidos.
        for (let i = 0; i < paletteKeys.length; i++) {
            const v = obj[paletteKeys[i]];
            if (typeof v !== "string" || !/^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(v))
                return;
        }

        root.palette = obj;
    }

    FileView {
        id: colorsFile
        path: Quickshell.shellPath("colors.json")
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.applyText(text())
        Component.onCompleted: reload()
    }
}
