#!/usr/bin/env bash
# Centro de control gráfico (quickshell).
# Comportamiento toggle: si ya está abierto, lo cierra; si no, lo abre.
set -u

PATTERN='quickshell.*-c[[:space:]]+cristos-settings'

if pgrep -f "$PATTERN" >/dev/null 2>&1; then
    pkill -f "$PATTERN" 2>/dev/null || true
else
    setsid -f quickshell -n -c cristos-settings >/dev/null 2>&1
fi
