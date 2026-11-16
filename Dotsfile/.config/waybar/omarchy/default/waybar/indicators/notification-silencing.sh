#!/usr/bin/env bash
# Compat Omarchy: indicador de notificaciones silenciadas.
if [ "$("$HOME/.config/hypr/scripts/notifications.sh" status 2>/dev/null)" = on ]; then
    echo '{"text": "󰂛", "tooltip": "Notificaciones silenciadas", "class": "active"}'
else
    echo '{"text": ""}'
fi
