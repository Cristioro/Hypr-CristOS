#!/usr/bin/env bash
# Cambia la barra entre estilo completo (una sola barra) y modular (islas).

DIR="$HOME/.config/waybar"
STATE="$DIR/.bar-mode"

mode="${1:-}"
[ -z "$mode" ] && mode="$(cat "$STATE" 2>/dev/null || echo complete)"

case "$mode" in
    complete|modular) ;;
    toggle)
        if [ "$(cat "$STATE" 2>/dev/null || echo complete)" = "complete" ]; then
            mode="modular"
        else
            mode="complete"
        fi
        ;;
    status)
        cat "$STATE" 2>/dev/null || echo "complete"
        exit 0
        ;;
    *)
        echo "uso: $0 [complete|modular|toggle|status]" >&2
        exit 1
        ;;
esac

[ -f "$DIR/style.$mode.css" ] || { echo "Falta $DIR/style.$mode.css" >&2; exit 1; }

cp "$DIR/style.$mode.css" "$DIR/style.css"
echo "$mode" > "$STATE"

if pgrep -x waybar >/dev/null; then
    pkill -SIGUSR2 -x waybar 2>/dev/null
else
    setsid -f waybar >/dev/null 2>&1
fi

if [ "$mode" = "complete" ]; then
    notify-send -a "Waybar" "Barra completa" "Una sola barra de lado a lado" 2>/dev/null || true
else
    notify-send -a "Waybar" "Barra modular" "Bloques separados por módulos" 2>/dev/null || true
fi
