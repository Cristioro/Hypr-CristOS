#!/usr/bin/env bash
# Compat Omarchy: indicador de idle/cafeína para módulos de Waybar.
# Omarchy muestra el icono cuando el bloqueo por inactividad está desactivado;
# aquí el equivalente es la Cafeína de CristOS.
if "$HOME/.config/hypr/scripts/caffeine.sh" status 2>/dev/null | grep -qi '^Activada'; then
    echo '{"text": "󱫖", "tooltip": "Cafeína activada (idle desactivado)", "class": "active"}'
else
    echo '{"text": ""}'
fi
