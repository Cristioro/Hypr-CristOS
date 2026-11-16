#!/usr/bin/env bash
# El servidor es residente. Si no logra arrancar, Mako queda de respaldo.
set -u

owner_pid() {
    busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
        org.freedesktop.DBus GetConnectionUnixProcessID s org.freedesktop.Notifications \
        2>/dev/null | awk '{print $2}'
}

start_fallback() {
    if [ -z "$(owner_pid)" ] && command -v mako >/dev/null 2>&1; then
        # Fuera del cgroup del servicio averiado; systemd no debe matarlo
        # cuando marque cristos-notifications.service como fallido.
        systemd-run --user --collect --unit="cristos-mako-fallback-$$" \
            -- "$(command -v mako)" >/dev/null 2>&1 || return 1
        if [ "${mako_dnd:-off}" = on ]; then
            for _ in {1..20}; do
                makoctl mode -a do-not-disturb >/dev/null 2>&1 && break
                sleep 0.1
            done
        fi
    fi
}

mako_dnd=off
makoctl mode 2>/dev/null | grep -qx 'do-not-disturb' && mako_dnd=on
owner=$(owner_pid)
if [ -n "$owner" ]; then
    comm=$(ps -p "$owner" -o comm= 2>/dev/null | tr -d ' ')
    if [ "$comm" != mako ]; then
        printf 'El servidor de notificaciones ya pertenece a %s (PID %s); no se modifica.\n' "$comm" "$owner" >&2
        exit 1
    fi
    kill "$owner" 2>/dev/null || exit 1
    for _ in {1..30}; do
        [ -z "$(owner_pid)" ] && break
        sleep 0.1
    done
fi

quickshell -n -c cristos-cc &
child=$!
trap 'kill "$child" 2>/dev/null || true; wait "$child" 2>/dev/null || true; exit 0' TERM INT

ready=0
for _ in {1..50}; do
    if [ "$(owner_pid)" = "$child" ]; then ready=1; break; fi
    kill -0 "$child" 2>/dev/null || break
    sleep 0.1
done
if [ "$ready" -ne 1 ]; then
    printf 'CristOS no pudo registrar el servidor de notificaciones; restaurando Mako.\n' >&2
    kill "$child" 2>/dev/null || true
    wait "$child" 2>/dev/null || true
    start_fallback
    exit 1
fi

if [ "$mako_dnd" = on ]; then
    for _ in {1..20}; do
        quickshell ipc -c cristos-cc call notifications toggle >/dev/null 2>&1 && break
        sleep 0.1
    done
fi

wait "$child"
rc=$?
printf 'El servidor CristOS terminó (código %s); restaurando Mako.\n' "$rc" >&2
start_fallback
exit 1
