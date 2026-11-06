#!/usr/bin/env bash
# Nivel de transparencia para Waybar y Rofi.
# Uso:
#   transparency.sh status
#   transparency.sh waybar <0-95>
#   transparency.sh rofi <0-95>
#   transparency.sh both <0-95>
#   transparency.sh rofi-apply      (re-aplica el nivel con el color actual)
#   transparency.sh apply           (aplica ambos con los valores guardados)
#
# 0 = totalmente opaco, 95 = casi invisible.

set -u

CONF="$HOME/.config/transparency.conf"
WAYBAR_DIR="$HOME/.config/waybar"
ROFI_DIR="$HOME/.config/rofi"

WAYBAR=70
ROFI=15
[ -f "$CONF" ] && source "$CONF"

save() {
    printf 'WAYBAR=%s\nROFI=%s\n' "$WAYBAR" "$ROFI" > "$CONF"
}

apply_waybar() {
    local alpha mode
    alpha=$(awk -v l="$WAYBAR" 'BEGIN { printf "%.2f", (100 - l) / 100 }')
    for f in "$WAYBAR_DIR/style.complete.css" "$WAYBAR_DIR/style.modular.css"; do
        [ -f "$f" ] || continue
        sed -i -E "s|background: alpha\(@background, [0-9.]+\);|background: alpha(@background, $alpha);|" "$f"
    done
    mode=$(cat "$WAYBAR_DIR/.bar-mode" 2>/dev/null || echo complete)
    if [ -f "$WAYBAR_DIR/style.$mode.css" ]; then
        cp "$WAYBAR_DIR/style.$mode.css" "$WAYBAR_DIR/style.css"
    fi
    pkill -SIGUSR2 -x waybar 2>/dev/null || true
}

rofi_targets() {
    cat <<'EOF'
settings/style.rasi
launcher/themes/Rofi-HyprLust.rasi
launcher/themes/card-center.rasi
launcher/themes/fullscreen-grid.rasi
WaybarSelect/themes/Rofi-HyprLust.rasi
WaybarSelect/themes/card-center.rasi
WaybarSelect/themes/fullscreen-grid.rasi
clipboard/clipboard.rasi
clipboard/confirmation.rasi
powermenu/style.rasi
powermenu/confirmation.rasi
shortcut/style.rasi
themeselect/style.rasi
hyprshot/style.rasi
wifi/enable.rasi
wifi/list.rasi
wifi/password.rasi
wifi/ssid.rasi
EOF
}

apply_rofi() {
    local hex r g b alpha rel file
    hex=$(awk -F': ' '/^[[:space:]]*surface:/{gsub(/;/,"",$2); print $2; exit}' "$ROFI_DIR/colors.rasi" 2>/dev/null)
    hex=$(printf '%s' "${hex:-#101418}" | grep -oE '#[0-9a-fA-F]{6}' | head -1)
    [ -n "$hex" ] || hex="#101418"

    r=$((16#${hex:1:2}))
    g=$((16#${hex:3:2}))
    b=$((16#${hex:5:2}))
    alpha=$(awk -v l="$ROFI" 'BEGIN { printf "%.2f", (100 - l) / 100 }')

    while IFS= read -r rel; do
        file="$ROFI_DIR/$rel"
        [ -f "$file" ] || continue
        python3 - "$file" "$r" "$g" "$b" "$alpha" <<'PY'
import re
import sys

path, r, g, b, a = sys.argv[1:]
with open(path, "r", encoding="utf-8") as fh:
    text = fh.read()

text = re.sub(
    r"\n?/\* transparency:managed:start \*/.*?/\* transparency:managed:end \*/\n?",
    "\n",
    text,
    flags=re.S,
)

block = (
    "/* transparency:managed:start */\n"
    "window {\n"
    '    transparency: "real";\n'
    f"    background-color: rgba({r}, {g}, {b}, {a});\n"
    "}\n"
    "/* transparency:managed:end */\n"
)

with open(path, "w", encoding="utf-8") as fh:
    fh.write(text.rstrip("\n") + "\n\n" + block)
PY
    done < <(rofi_targets)
}

case "${1:-apply}" in
    status)
        printf 'WAYBAR=%s\nROFI=%s\n' "$WAYBAR" "$ROFI"
        ;;
    waybar)
        [ $# -ge 2 ] && WAYBAR="$2"
        save
        apply_waybar
        ;;
    rofi)
        [ $# -ge 2 ] && ROFI="$2"
        save
        apply_rofi
        ;;
    both)
        if [ $# -ge 2 ]; then
            WAYBAR="$2"
            ROFI="$2"
        fi
        save
        apply_waybar
        apply_rofi
        ;;
    rofi-apply)
        apply_rofi
        ;;
    apply)
        apply_waybar
        apply_rofi
        ;;
    *)
        echo "uso: $0 [status|waybar N|rofi N|both N|rofi-apply|apply]" >&2
        exit 1
        ;;
esac
