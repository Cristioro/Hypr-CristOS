#!/usr/bin/env bash
# ws-scroll.sh — Cambia de escritorio con la rueda solo sobre los círculos.
#
# Lo ejecuta ws-scroll-daemon.py al detectar un notch de rueda. Aquí se
# comprueba que el cursor esté sobre la zona central (los círculos) antes de
# cambiar, de modo que la rueda sobre el reproductor u otros módulos no cambie
# de escritorio. También se puede llamar a mano para probar:
#     ws-scroll.sh up|down
#
# (Waybar 0.16 pierde la mitad de los eventos de rueda en GTK3, por eso el
# scroll de workspaces se desactiva en config.jsonc y lo gestiona el daemon.)
#
# Uso: ws-scroll.sh up|down
#   up   -> escritorio anterior (m-1)
#   down -> escritorio siguiente (m+1)
#
# Variables opcionales:
#   WS_SCROLL_MARGIN  margen horizontal en px alrededor del centro (def. 110)
#   WS_SCROLL_DEBUG   si no está vacío, registra actividad
#   WS_SCROLL_LOG     ruta del log de depuración
set -u

direction="${1:-}"
case "$direction" in
  up)   target="m-1" ;;
  down) target="m+1" ;;
  *) printf 'uso: %s up|down\n' "${0##*/}" >&2; exit 2 ;;
esac

# Margen horizontal (px) alrededor del centro de la barra.
margin="${WS_SCROLL_MARGIN:-110}"

log() {
  [ -n "${WS_SCROLL_DEBUG:-}" ] || return 0
  printf '%s %s\n' "$(date '+%F %T')" "$*" >>"${WS_SCROLL_LOG:-/tmp/opencode/ws-scroll.log}"
}

log "invocado $direction"

command -v hyprctl >/dev/null 2>&1 || { log "sin hyprctl"; exit 0; }
command -v jq >/dev/null 2>&1 || { log "sin jq"; exit 0; }

# Posición global del cursor.
cursor="$(hyprctl cursorpos -j 2>/dev/null)" || { log "cursorpos falló"; exit 0; }
read -r cx cy < <(printf '%s' "$cursor" | jq -r '"\(.x) \(.y)"' 2>/dev/null) || { log "parse cursor falló"; exit 0; }
case "${cx:-}${cy:-}" in
  ''|*[!0-9-]*) log "cursor inválido: ${cursor:-}"; exit 0 ;;
esac

# Monitor bajo el cursor y geometría de la barra en ese monitor.
monitors="$(hyprctl monitors -j 2>/dev/null)" || { log "monitors falló"; exit 0; }
layers="$(hyprctl layers -j 2>/dev/null)" || { log "layers falló"; exit 0; }

in_zone="$(jq -nr \
  --argjson cx "$cx" --argjson cy "$cy" --argjson margin "$margin" \
  --argjson monitors "$monitors" --argjson layers "$layers" '
  ([ $monitors[] | select($cx >= .x and $cx < (.x + .width)
                        and $cy >= .y and $cy < (.y + .height)) ] | first) as $mon
  | if $mon == null then false
    else
      ([ ($layers[$mon.name].levels // {})[][] | select(.namespace == "waybar") ] | first) as $bar
      | if $bar == null then false
        else
          ($cx - $mon.x) as $lx
          | ($cy - $mon.y) as $ly
          | ((($bar.x + ($bar.w / 2)) - $lx) | if . < 0 then -. else . end) as $dist
          | ($dist <= $margin)
            and ($ly >= $bar.y) and ($ly < ($bar.y + $bar.h))
        end
    end
')"

if [ "$in_zone" != "true" ]; then
  log "ignorado $direction cursor=${cx},${cy}"
  exit 0
fi

log "dispatch $direction ($target) cursor=${cx},${cy}"
hyprctl dispatch "hl.dsp.focus({workspace = \"$target\"})" >/dev/null 2>&1 || true
