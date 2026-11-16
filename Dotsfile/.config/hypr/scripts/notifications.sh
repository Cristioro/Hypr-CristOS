#!/usr/bin/env bash
# Puente común para la barra, los ajustes y el centro de control.
set -u
QS_CONFIG=cristos-cc

ipc() {
    quickshell ipc -c "$QS_CONFIG" call notifications "$@" 2>/dev/null
}

fallback_status() {
    if makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; then
        printf 'on\n'
    else
        printf 'off\n'
    fi
}

case "${1:-status}" in
    status)
        ipc status || fallback_status
        ;;
    toggle)
        if ! ipc toggle; then
            makoctl mode -t do-not-disturb >/dev/null 2>&1 || exit 1
            fallback_status
        fi
        ;;
    clear)
        ipc clear || makoctl dismiss -a
        ;;
    controls|notifications)
        if [ "$1" = controls ]; then method=toggleControls; else method=toggleNotifications; fi
        if ! ipc "$method" >/dev/null; then
            systemctl --user start cristos-notifications.service >/dev/null 2>&1 || true
            for _ in {1..25}; do
                if ipc "$method" >/dev/null; then exit 0; fi
                sleep 0.2
            done
            notify-send -a "CristOS" "Centro de control no disponible" "Revisa el servicio cristos-notifications."
            exit 1
        fi
        ;;
    show)
        ipc openNotifications >/dev/null || "$0" notifications
        ;;
    json)
        state=$(ipc json) || state='{"dnd":false,"count":0,"unread":0}'
        printf '%s\n' "$state"
        ;;
    waybar)
        state=$(ipc json) || {
            [ "$(fallback_status)" = on ] && dnd=true || dnd=false
            state="{\"dnd\":$dnd,\"count\":0,\"unread\":0}"
        }
        jq -cn --argjson s "$state" '
            {text: (if $s.dnd then "󰂛" elif $s.unread > 0 then "󰂚 " + ($s.unread|tostring) else "󰂚" end),
             tooltip: (if $s.dnd then "No molestar activado\n" else "" end)
                    + (($s.count|tostring) + " notificaciones · clic para ver"),
             class: (if $s.dnd then "dnd" elif $s.unread > 0 then "unread" else "idle" end)}'
        ;;
    *)
        printf 'Uso: %s {status|toggle|clear|controls|notifications|show|json|waybar}\n' "${0##*/}" >&2
        exit 2
        ;;
esac
