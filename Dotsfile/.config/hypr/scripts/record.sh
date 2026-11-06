#!/bin/bash
# Grabar pantalla con wf-recorder. Uso: record.sh [full|region]

mode="${1:-full}"
dir="$HOME/Videos/Recordings"
mkdir -p "$dir"

if pgrep -x wf-recorder >/dev/null; then
    pkill -INT -x wf-recorder
    notify-send "Grabación" "Grabación detenida"
    exit 0
fi

out="$dir/rec-$(date +%Y%m%d-%H%M%S).mp4"

if [ "$mode" = "region" ]; then
    geom="$(slurp)" || exit 0
    wf-recorder -g "$geom" -f "$out" &
else
    wf-recorder -f "$out" &
fi

sleep 1
notify-send "Grabación" "Grabando en $out"
