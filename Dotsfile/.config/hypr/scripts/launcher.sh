#!/usr/bin/env bash
# Abrir o cerrar únicamente el lanzador CristOS.
set -u
if quickshell ipc -c cristos-launcher call launcher close >/dev/null 2>&1; then
  exit 0
fi
if ! command -v quickshell >/dev/null 2>&1; then
  exec rofi -show drun
fi
exec quickshell -n -c cristos-launcher
