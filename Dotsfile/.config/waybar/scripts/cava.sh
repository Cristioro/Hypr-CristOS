#!/bin/bash

bars=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)

cava -p /home/cristioro/.config/waybar/scripts/cava/config | while read -r line; do
    output=""
    IFS=';' read -ra values <<< "$line"

    for v in "${values[@]}"; do
        ((v<0)) && v=0
        ((v>7)) && v=7
        output+="${bars[$v]}"
    done

    echo "$output"
done