#!/usr/bin/env bash
# Menú de Bluetooth para el centro de control

DIR="$HOME/.config/rofi/settings"
THEME="$DIR/style.rasi"

menu() {
    local prompt="$1" mesg="${2:-}"
    if [ -n "$mesg" ]; then
        rofi -dmenu -i -p "$prompt" -mesg "$mesg" -theme "$THEME"
    else
        rofi -dmenu -i -p "$prompt" -theme "$THEME"
    fi
}

notify() {
    notify-send "Bluetooth" "$1" 2>/dev/null || true
}

powered=$(bluetoothctl show 2>/dev/null | awk -F': ' '/Powered:/{print $2; exit}')
[ -z "$powered" ] && powered="no"

if [ "$powered" = "yes" ]; then
    toggle="󰂲  Apagar Bluetooth"
else
    toggle="󰂯  Encender Bluetooth"
fi

options=("$toggle" "󰑐  Escanear y conectar")
mapfile -t paired < <(bluetoothctl devices Paired 2>/dev/null | sed 's/^Device //')
declare -A DEVICE_MAC

if [ "${#paired[@]}" -gt 0 ]; then
    options+=("──────── Dispositivos ────────")
fi

for line in "${paired[@]}"; do
    [ -z "$line" ] && continue
    mac="${line%% *}"
    name="${line#* }"
    conn=$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/Connected:/{print $2; exit}')
    if [ "$conn" = "yes" ]; then
        label="󰂱  $name  (conectado)"
    else
        label="󰂯  $name"
    fi
    DEVICE_MAC["$label"]="$mac"
    options+=("$label")
done

choice=$(printf '%s\n' "${options[@]}" | menu "Bluetooth" "Adaptador: $powered")

[ -z "$choice" ] && exit 0

# Dispositivo ya emparejado
if [ -n "${DEVICE_MAC[$choice]:-}" ]; then
    mac="${DEVICE_MAC[$choice]}"
    if [ "$(bluetoothctl info "$mac" 2>/dev/null | awk -F': ' '/Connected:/{print $2; exit}')" = "yes" ]; then
        bluetoothctl disconnect "$mac" >/dev/null 2>&1
        notify "Desconectado"
    else
        if bluetoothctl connect "$mac" >/dev/null 2>&1; then
            notify "Conectado"
        else
            notify "No se pudo conectar"
        fi
    fi
    exit 0
fi

case "$choice" in
    *Apagar*)
        bluetoothctl power off >/dev/null 2>&1
        notify "Bluetooth apagado"
        ;;
    *Encender*)
        bluetoothctl power on >/dev/null 2>&1
        notify "Bluetooth encendido"
        ;;
    *Escanear*)
        notify "Escaneando dispositivos (8s)…"
        timeout 8 bluetoothctl scan on >/dev/null 2>&1
        mapfile -t found < <(bluetoothctl devices 2>/dev/null | sed 's/^Device //')
        if [ "${#found[@]}" -eq 0 ]; then
            notify "No se encontraron dispositivos"
            exit 0
        fi
        sel=$(printf '%s\n' "${found[@]}" | menu "Dispositivos encontrados")
        [ -z "$sel" ] && exit 0
        mac="${sel%% *}"
        name="${sel#* }"
        bluetoothctl pair "$mac" >/dev/null 2>&1
        bluetoothctl trust "$mac" >/dev/null 2>&1
        if bluetoothctl connect "$mac" >/dev/null 2>&1; then
            notify "Conectado a $name"
        else
            notify "No se pudo conectar a $name"
        fi
        ;;
esac
