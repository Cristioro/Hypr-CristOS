#!/bin/bash
# Restaura el último wallpaper elegido con hyprquickpaper y regenera el tema.
# Si no hay ninguno guardado, usa el wallpaper por defecto.

default="$HOME/Pictures/Wallpapers/astralgrave_purple.png"
saved="$(cat "$HOME/.cache/quickshell/hyprquickpaper/.current" 2>/dev/null)"

wall="$saved"
[ -f "$wall" ] || wall="$default"

# Espera a que el daemon de wallpapers esté listo
for _ in $(seq 1 20); do
    awww query >/dev/null 2>&1 && break
    sleep 0.25
done

awww img "$wall" -t grow --transition-duration 1

# Fondo para hyprlock
mkdir -p "$HOME/.cache/rofi"
magick "$wall[0]" "$HOME/.cache/rofi/current_wallpaper.png" 2>/dev/null \
    || convert "$wall[0]" "$HOME/.cache/rofi/current_wallpaper.png" 2>/dev/null

# Tema global
MODE="dark"
SCHEME="scheme-tonal-spot"
[ -f "$HOME/.config/matugen/settings.conf" ] && source "$HOME/.config/matugen/settings.conf"
matugen image "$wall" -m "$MODE" -t "$SCHEME" --prefer saturation >/dev/null 2>&1
