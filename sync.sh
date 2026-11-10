#!/usr/bin/env bash
# sync.sh — copia la configuración viva (~/.config) al repo, solo lo funcional.
#
# La fuente de verdad es tu ~/.config. Este script evita desincronizaciones
# como las que rompieron la config en noviembre: copia únicamente la whitelist
# de archivos de configuración y NUNCA toca Wallpapers/ ni archivos personales.
#
# Uso:
#   ./sync.sh             # aplica los cambios al repo
#   ./sync.sh --dry-run   # muestra qué cambiaría, sin escribir nada
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY=0

case "${1:-}" in
  "") ;;
  -n|--dry-run) DRY=1 ;;
  -h|--help|*) sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac

info() { printf '%s\n' "$*"; }
warn() { printf 'sync: %s\n' "$*" >&2; }

# Directorios espejo (rsync --delete solo dentro de estas rutas).
DIRS=(
  ".config/hypr/config"
  ".config/hypr/scripts"
  ".config/waybar/scripts"
)

# Archivos individuales.
FILES=(
  ".config/hypr/hyprland.lua"
  ".config/hypr/hyprland.conf"
  ".config/hypr/hypridle.conf"
  ".config/hypr/hyprlock.conf"
  ".config/hypr/hyprlock/nowplaying.sh"
  ".config/hypr/hyprlock/fallback_album_art.jpg"
  ".config/waybar/config.jsonc"
  ".config/waybar/style.css"
  ".config/waybar/style.complete.css"
  ".config/waybar/style.modular.css"
  ".config/quickshell/hyprquickpaper/commands.sh"
  ".config/gtk-3.0/gtk.css"
  ".config/gtk-4.0/gtk.css"
  ".config/matugen/config.toml"
  ".config/matugen/templates/hyprland.lua"
  ".config/systemd/user/hypr-session.service"
  ".local/bin/ws-scroll-daemon"
)

changed=0

sync_dir() {
  local rel="$1" src="$HOME/$1" dst="$ROOT/Dotsfile/$1"
  if [ ! -d "$src" ]; then
    warn "falta $src, se omite"
    return 0
  fi
  local opts=(-a --delete --itemize-changes --exclude='__pycache__' --exclude='*.pyc')
  (( DRY )) || opts+=()
  if (( DRY )); then
    info "── dir: $rel (dry-run)"
    rsync "${opts[@]}" --dry-run "$src/" "$dst/" | sed 's/^/   /'
  else
    local out
    out="$(rsync "${opts[@]}" "$src/" "$dst/")"
    if [ -n "$out" ]; then
      info "── dir: $rel (actualizado)"
      printf '%s\n' "$out" | sed 's/^/   /'
      changed=1
    fi
  fi
}

sync_file() {
  local rel="$1" src="$HOME/$1" dst="$ROOT/Dotsfile/$1"
  if [ ! -f "$src" ]; then
    warn "falta $src, se omite"
    return 0
  fi
  if cmp -s "$src" "$dst"; then
    return 0
  fi
  changed=1
  if (( DRY )); then
    info "── file: $rel (dry-run)"
    diff -u "$dst" "$src" | sed 's/^/   /' || true
  else
    mkdir -p "$(dirname "$dst")"
    cp -a "$src" "$dst"
    info "── file: $rel (actualizado)"
  fi
}

for rel in "${DIRS[@]}"; do sync_dir "$rel"; done
for rel in "${FILES[@]}"; do sync_file "$rel"; done

echo
if (( DRY )); then
  echo "sync: dry-run completado (nada escrito)."
else
  if (( changed )); then
    echo "sync: listo. Revisa con 'git diff' y commitea."
  else
    echo "sync: repo ya estaba al día."
  fi
fi
