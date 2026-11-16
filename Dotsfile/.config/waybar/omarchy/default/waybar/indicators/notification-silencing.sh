#!/usr/bin/env bash
# Compat Omarchy: indicador de notificaciones silenciadas.
if makoctl mode 2>/dev/null | grep -q 'do-not-disturb'; then
    echo '{"text": "󰂛", "tooltip": "Notificaciones silenciadas", "class": "active"}'
else
    echo '{"text": ""}'
fi
