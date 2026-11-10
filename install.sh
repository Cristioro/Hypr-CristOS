#!/usr/bin/env bash
# install.sh — instala estos dotfiles en la máquina actual.
#
# Uso:
#   ./install.sh --dry-run   # muestra lo que hará, sin tocar nada
#   ./install.sh             # backup + copia + hook + recarga de Hyprland
#   ./install.sh --force     # sin backup (úsalo solo si sabes lo que haces)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$ROOT/Dotsfile"
DRY=0
FORCE=0

for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY=1 ;;
    -f|--force)   FORCE=1 ;;
    -h|--help)    sed -n '2,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "install: opción desconocida: $arg" >&2; exit 2 ;;
  esac
done

run() {
  if (( DRY )); then
    printf '[dry] %s\n' "$*"
  else
    "$@"
  fi
}

info() { printf '\n== %s\n' "$*"; }

[ -d "$SRC/.config" ] || { echo "install: no encuentro $SRC/.config" >&2; exit 1; }

info "1/7 Backup de configuraciones que se van a reemplazar"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.config/backup-install-$STAMP"

if (( FORCE )); then
  echo "   --force: se omite el backup"
elif (( DRY )); then
  echo "   [dry] se haría backup en $BACKUP (solo rutas que colisionan)"
else
  mkdir -p "$BACKUP"
  mapfile -t tops < <(find "$SRC/.config" -mindepth 1 -maxdepth 1 -printf '%f\n')
  for name in "${tops[@]}"; do
    [ -e "$HOME/.config/$name" ] || continue
    cp -a "$HOME/.config/$name" "$BACKUP/"
    echo "   backup: ~/.config/$name"
  done
  [ -e "$HOME/.local/bin" ] && cp -a "$HOME/.local/bin" "$BACKUP/local-bin"
fi

info "2/7 Instalando configuraciones"
run rsync -a "$SRC/.config/" "$HOME/.config/"

if [ -d "$SRC/.local" ]; then
  run mkdir -p "$HOME/.local"
  run rsync -a "$SRC/.local/" "$HOME/.local/"
fi

info "3/7 Permisos de ejecución"
if (( DRY )); then
  echo "   [dry] chmod +x en scripts y binarios"
else
  find "$HOME/.config/hypr/scripts" "$HOME/.config/waybar/scripts" \
       "$HOME/.config/hypr/hyprlock" -type f \( -name '*.sh' -o -name '*.py' \) \
       -exec chmod +x {} + 2>/dev/null || true
  [ -f "$HOME/.local/bin/ws-scroll-daemon" ] && chmod +x "$HOME/.local/bin/ws-scroll-daemon"
fi

info "4/7 Directorios de caché"
run mkdir -p "$HOME/.cache/quickshell/hyprquickpaper" "$HOME/.cache/rofi"

info "5/7 Hook de git (protección de Wallpapers y scripts)"
run git -C "$ROOT" config core.hooksPath scripts/hooks
if (( ! DRY )); then
  chmod +x "$ROOT/scripts/hooks/pre-commit"
fi

info "6/7 Servicio de arranque de la sesión"
if (( DRY )); then
  echo "   [dry] systemctl --user daemon-reload && systemctl --user enable --now hypr-session.service"
else
  if command -v systemctl >/dev/null 2>&1; then
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now hypr-session.service 2>/dev/null || true
    echo "   ✓ hypr-session.service activo"
  else
    echo "   (sin systemd; arranca ~/.config/hypr/scripts/session-start.sh a mano)"
  fi
fi

info "7/7 Recargando Hyprland"
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && command -v hyprctl >/dev/null 2>&1; then
  if (( DRY )); then
    echo "   [dry] hyprctl reload && hyprctl configerrors"
  else
    hyprctl reload >/dev/null 2>&1 || true
    sleep 1
    errores="$(hyprctl configerrors 2>/dev/null || true)"
    if [ -n "$errores" ] && ! grep -q '^$' <<<"$errores"; then
      echo "   ⚠ hyprctl reportó errores:" >&2
      printf '%s\n' "$errores" >&2
    else
      echo "   ✓ Hyprland recargado sin errores"
    fi
  fi
else
  echo "   (no estás en una sesión Hyprland; recarga a mano después)"
fi

echo
if (( DRY )); then
  echo "install: dry-run completado."
else
  echo "install: listo. Backup en: $BACKUP"
fi
