#!/usr/bin/env bash
# Centro de control rápido (quickshell).
# Comportamiento toggle: si ya está abierto, lo cierra; si no, lo abre.
set -u

PATTERN='quickshell.*-c[[:space:]]+cristos-cc'

if pgrep -f "$PATTERN" >/dev/null 2>&1; then
    pkill -f "$PATTERN" 2>/dev/null || true
else
    setsid -f quickshell -n -c cristos-cc >/dev/null 2>&1
fi
