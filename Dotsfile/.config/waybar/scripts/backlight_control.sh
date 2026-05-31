#!/usr/bin/env bash

# Archivo temporal para rastrear el estado del filtro (0 = Apagado, 1 = Encendido)
STATE_FILE="/tmp/hyprsunset_clicked_state"
if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

case "$1" in
    "read")
        # Lee el brillo físico del monitor Acer
        BRIGHTNESS=$(ddcutil getvcp 10 --brief 2>/dev/null | awk '{print $4}')
        # Si ddcutil falla, asume 100 por seguridad
        : "${BRIGHTNESS:=100}"
        
        # Lee el estado guardado del filtro
        SUNSET_STATE=$(cat "$STATE_FILE")
        
        # Cambia el icono en Waybar dependiendo de si el filtro está activo o no
        if [ "$SUNSET_STATE" = "1" ]; then
            echo "{\"text\": \"$BRIGHTNESS%\", \"alt\": \"sunset\"}"
        else
            echo "{\"text\": \"$BRIGHTNESS%\", \"alt\": \"normal\"}"
        fi
        ;;
        
    "up")
        ddcutil setvcp 10 + 5 --noverify --sleep-multiplier 0.05
        pkill -RTMIN+8 waybar
        ;;
        
    "down")
        ddcutil setvcp 10 - 5 --noverify --sleep-multiplier 0.05
        pkill -RTMIN+8 waybar
        ;;
        
    "toggle")
        SUNSET_STATE=$(cat "$STATE_FILE")
        if [ "$SUNSET_STATE" = "0" ]; then
            hyprctl hyprsunset temperature 4000
            echo "1" > "$STATE_FILE"
        else
            hyprctl hyprsunset identity
            echo "0" > "$STATE_FILE"
        fi
        pkill -RTMIN+8 waybar
        ;;
esac