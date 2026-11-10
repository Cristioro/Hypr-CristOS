#!/bin/bash
# Ejecutado por hyprquickpaper con la ruta del wallpaper seleccionado ($1)

[ -z "$1" ] && exit 1

# Quickshell escapa los espacios con "\ "
wall="$1"
wall="${wall//\\ / }"
wall="${wall/#\~/$HOME}"

# Wallpaper
if command -v awww >/dev/null 2>&1; then
    awww img "$wall" -t grow --transition-duration 1
fi

# Cache para hyprlock (fondo de la pantalla de bloqueo)
mkdir -p "$HOME/.cache/rofi"
magick "${wall}[0]" "$HOME/.cache/rofi/current_wallpaper.png" 2>/dev/null \
    || convert "${wall}[0]" "$HOME/.cache/rofi/current_wallpaper.png" 2>/dev/null

# Regenerar tema global (hyprland, waybar, kitty, rofi, btop, cava...)
MODE="dark"
SCHEME="scheme-tonal-spot"
[ -f "$HOME/.config/matugen/settings.conf" ] && source "$HOME/.config/matugen/settings.conf"
if matugen image "$wall" -m "$MODE" -t "$SCHEME" --prefer saturation >>"$HOME/.cache/matugen.log" 2>&1; then
    color=$(grep -m1 '^    primary:' "$HOME/.config/rofi/colors.rasi" | awk '{print $2}')
    notify-send -a "Matugen" "Tema actualizado" "Color primario: ${color:-ok}"
else
    notify-send -a "Matugen" -u critical "Matugen falló" "Revisa ~/.cache/matugen.log"
fi

exit 0
