#!/usr/bin/env bash
# Compat Omarchy: indicador de grabación de pantalla.
# CristOS graba con wf-recorder; también contempla gpu-screen-recorder.
if pgrep -f '^(gpu-screen-recorder|wf-recorder)' >/dev/null; then
    echo '{"text": "󰻂", "tooltip": "Detener grabación", "class": "active"}'
else
    echo '{"text": ""}'
fi
