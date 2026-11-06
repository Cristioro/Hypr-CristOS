#!/bin/bash
# Capturas de pantalla: usa hyprshot si está disponible, si no grim/slurp/satty.
# Uso: screenshot.sh region | full | region-edit | full-edit

mode="${1:-region}"

have() { command -v "$1" >/dev/null 2>&1; }

if have hyprshot; then
    case "$mode" in
        region)      hyprshot -m region --freeze --clipboard-only ;;
        full)        hyprshot -m output --freeze --clipboard-only ;;
        region-edit) tmp="$(mktemp --suffix=.png)"; hyprshot -m region --freeze -o "$(dirname "$tmp")" -f "$(basename "$tmp")" && satty --filename "$tmp" --actions-on-enter save-to-clipboard --actions-on-escape exit ;;
        full-edit)   tmp="$(mktemp --suffix=.png)"; hyprshot -m output --freeze -o "$(dirname "$tmp")" -f "$(basename "$tmp")" && satty --filename "$tmp" --actions-on-enter save-to-clipboard --actions-on-escape exit ;;
    esac
    exit 0
fi

case "$mode" in
    region)
        geom="$(slurp)" || exit 0
        grim -g "$geom" - | wl-copy
        ;;
    full)
        grim - | wl-copy
        ;;
    region-edit)
        geom="$(slurp)" || exit 0
        tmp="$(mktemp --suffix=.png)"
        grim -g "$geom" "$tmp" && satty --filename "$tmp" --actions-on-enter save-to-clipboard --actions-on-escape exit
        ;;
    full-edit)
        tmp="$(mktemp --suffix=.png)"
        grim "$tmp" && satty --filename "$tmp" --actions-on-enter save-to-clipboard --actions-on-escape exit
        ;;
esac
