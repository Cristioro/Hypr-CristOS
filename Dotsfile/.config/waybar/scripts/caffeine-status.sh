#!/usr/bin/env bash
# caffeine-status.sh — estado de la cafeína para el módulo custom/caffeine de Waybar.
set -u

status="$("$HOME/.config/hypr/scripts/caffeine.sh" status 2>/dev/null || echo "Desactivada")"

if [ "$status" = "Activada" ]; then
  printf '{"text":"󰈈","tooltip":"Cafeína activa — clic para desactivar","class":"active"}\n'
else
  printf '{"text":"󰈉","tooltip":"Cafeína desactivada — clic para activar","class":"inactive"}\n'
fi
