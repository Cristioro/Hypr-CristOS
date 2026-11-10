#!/usr/bin/env bash
# Cafeína (caffeine): mantiene la pantalla encendida y evita el bloqueo/suspensión.
#
# Implementa un inhibidor de logind (idle + sleep) en modo "block", que es lo que
# hypridle consulta: mientras esté activo, hypridle no dispara sus timeouts
# (lock a los 4 min ni suspend a los 30 min).
#
# Uso:
#   caffeine.sh toggle   (por defecto) alterna activar/desactivar
#   caffeine.sh on       activa
#   caffeine.sh off      desactiva
#   caffeine.sh status   imprime "Activada" / "Desactivada"

PID_FILE="${XDG_RUNTIME_DIR:-/tmp}/hypr-caffeine.pid"

is_active() {
    [ -f "$PID_FILE" ] || return 1
    local pid
    pid="$(cat "$PID_FILE" 2>/dev/null)"
    [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null
}

start() {
    # setsid -> nueva sesión/grupo de procesos para poder terminarlos juntos.
    setsid systemd-inhibit --what=idle:sleep --why=Cafeina --mode=block sleep infinity \
        > /dev/null 2>&1 &
    echo $! > "$PID_FILE"
    sleep 1
    notify-send -a "Caffeine" "Cafeína activada" "Bloqueando apagado de pantalla y suspensión"
}

stop() {
    local pid
    if [ -f "$PID_FILE" ]; then
        pid="$(cat "$PID_FILE" 2>/dev/null)"
        if [ -n "$pid" ]; then
            kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null
        fi
        rm -f "$PID_FILE"
    fi
    # Limpieza por si quedara algún inhibidor huérfano de una sesión anterior.
    pkill -f "systemd-inhibit.*--why=Cafeina" 2>/dev/null
    notify-send -a "Caffeine" "Cafeína desactivada" "La pantalla puede apagarse y el equipo suspender"
}

case "${1:-toggle}" in
    status)
        if is_active; then echo "Activada"; else echo "Desactivada"; fi
        ;;
    on) start ;;
    off) stop ;;
    toggle)
        if is_active; then stop; else start; fi
        ;;
    *)
        echo "uso: $0 [toggle|on|off|status]" >&2
        exit 1
        ;;
esac
