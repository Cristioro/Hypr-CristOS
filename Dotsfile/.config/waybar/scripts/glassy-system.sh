#!/usr/bin/env bash
# Acciones e indicadores independientes de Omarchy para el tema glassy.
set -u

case "${1:-}" in
  btop)
    address=$(hyprctl clients -j 2>/dev/null |
      jq -r '[.[] | select((.class // "" | ascii_downcase) == "btop") | .address][0] // empty')
    if [[ "$address" =~ ^0x[[:xdigit:]]+$ ]]; then
      result=$(hyprctl dispatch "hl.dsp.focus({ window = \"address:$address\" })" 2>/dev/null || true)
      [ "$result" = "ok" ] && exit 0
    fi
    if command -v foot >/dev/null 2>&1 && command -v btop >/dev/null 2>&1; then
      setsid -f foot -a btop -e btop
    else
      notify-send -a "Barra" "No se pudo abrir btop" "Instala foot y btop."
    fi
    ;;
  updates)
    command -v checkupdates >/dev/null 2>&1 || exit 0
    updates=$(checkupdates 2>/dev/null) || exit 0
    [ -n "$updates" ] || exit 0
    count=$(printf '%s\n' "$updates" | wc -l)
    printf '%s actualizaciones de repositorio disponibles\n' "$count"
    ;;
  update-open)
    if command -v foot >/dev/null 2>&1 && command -v paru >/dev/null 2>&1; then
      setsid -f foot -a cristos-update -e bash -c 'paru -Syu; printf "\nPulsa Enter para cerrar…"; read -r'
    else
      notify-send -a "Barra" "No se pudo abrir el actualizador" "Instala foot y paru."
    fi
    ;;
  idle-status)
    if "$HOME/.config/hypr/scripts/caffeine.sh" status 2>/dev/null | grep -qi '^Activada'; then
      printf '%s\n' '{"text":"󱫖","tooltip":"Cafeína activada (inactividad desactivada)","class":"active"}'
    else
      printf '%s\n' '{"text":""}'
    fi
    ;;
  dnd-status)
    if [ "$("$HOME/.config/hypr/scripts/notifications.sh" status)" = on ]; then
      printf '%s\n' '{"text":"󰂛","tooltip":"Notificaciones silenciadas","class":"active"}'
    else
      printf '%s\n' '{"text":""}'
    fi
    ;;
  recording-status)
    if pgrep -x wf-recorder >/dev/null; then
      printf '%s\n' '{"text":"󰻂","tooltip":"Detener grabación","class":"active"}'
    else
      printf '%s\n' '{"text":""}'
    fi
    ;;
  *)
    printf 'Uso: %s {btop|updates|update-open|idle-status|dnd-status|recording-status}\n' "${0##*/}" >&2
    exit 2
    ;;
esac
