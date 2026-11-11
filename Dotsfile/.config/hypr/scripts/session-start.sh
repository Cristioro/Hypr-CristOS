#!/usr/bin/env bash
# session-start.sh — arranque idempotente de la sesión Hyprland.
#
# Se invoca desde autostart.lua y desde la unidad de systemd
# hypr-session.service. Lanzar dos veces no duplica procesos: cada daemon se
# comprueba con pgrep y la restauración del wallpaper solo ocurre una vez por
# instancia de Hyprland.
set -u

RUNTIME="${XDG_RUNTIME_DIR:-/tmp}"
HOME_DIR="${HOME:?}"

# systemd arranca con un PATH mínimo; añade lo instalado por el usuario.
export PATH="$HOME_DIR/.local/opt/waybar-0.16/usr/bin:$HOME_DIR/.local/bin:$HOME_DIR/.cargo/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Sin entorno de la sesión (systemd, o el evento Lua disparado demasiado
# pronto), deducirlo del socket de Hyprland/Wayland.
detect_env() {
  if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -d "$RUNTIME/hypr" ]; then
    sig="$(find "$RUNTIME/hypr" -maxdepth 2 -name .socket.sock -printf '%T@ %h\n' 2>/dev/null \
      | sort -nr | head -1 | awk '{print $2}' | xargs -r basename)"
    [ -n "$sig" ] && export HYPRLAND_INSTANCE_SIGNATURE="$sig"
  fi
  if [ -z "${WAYLAND_DISPLAY:-}" ]; then
    for w in "$RUNTIME"/wayland-[0-9]*; do
      [ -S "$w" ] && export WAYLAND_DISPLAY="${w##*/}" && break
    done
  fi
}

# Espera a que Hyprland esté realmente listo (máx. ~15 s). Esto es lo que
# hacía fallar el arranque: el evento hyprland.start podía llegar antes de que
# existiera el socket, y la detección se rendía.
detect_env
for _ in $(seq 1 50); do
  [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -n "${WAYLAND_DISPLAY:-}" ] && break
  sleep 0.3
  detect_env
done

# Aislamiento entre escritorios: esta sesión solo debe arrancar bajo Hyprland.
# Si systemd activa la unidad en otra sesión gráfica (Plasma, GNOME...) no
# tocamos nada, para no meter waybar/mako/hypridle en el otro escritorio.
case "${XDG_CURRENT_DESKTOP:-}" in
  *[Hh]yprland*) ;;
  *) [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || exit 0 ;;
esac

# Aislamiento de tema con VistaThemePlasma: Hyprland debe usar el perfil
# Qt/KDE propio, no el de la sesión VistaThemePlasma.
cp -f "$HOME_DIR/.config/kdeglobals.nonvtp" "$HOME_DIR/.config/kdeglobals" 2>/dev/null || true

# Lock: evita ejecuciones simultáneas.
exec 9>"$RUNTIME/hypr-session-start.lock"
flock -n 9 || exit 0

have() { command -v "$1" >/dev/null 2>&1; }

# start_once NOMBRE COMANDO... — no relanza si el proceso ya existe.
start_once() {
  local name="$1"; shift
  pgrep -x "$name" >/dev/null 2>&1 && return 0
  if have setsid; then
    setsid -f "$@" >/dev/null 2>&1 9>&-
  else
    "$@" >/dev/null 2>&1 9>&- &
  fi
  return 0
}

# start_cmd PATRÓN COMANDO... — para procesos cuyo argv no coincide con -x.
start_cmd() {
  local pattern="$1"; shift
  pgrep -f "$pattern" >/dev/null 2>&1 && return 0
  if have setsid; then
    setsid -f "$@" >/dev/null 2>&1 9>&-
  else
    "$@" >/dev/null 2>&1 9>&- &
  fi
  return 0
}

# Marcador por instancia (el wallpaper se restaura una vez por sesión). Si no
# hay firma no creamos uno "unknown" que bloquee el siguiente intento.
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  marker="$RUNTIME/hypr-session-started.$HYPRLAND_INSTANCE_SIGNATURE"
else
  marker=""
fi
first_run=1
if [ -n "$marker" ] && [ -f "$marker" ]; then
  first_run=0
elif [ -n "$marker" ]; then
  : >"$marker"
fi

# Portapapeles
start_cmd 'wl-paste --type text'  wl-paste --type text  --watch cliphist store
start_cmd 'wl-paste --type image' wl-paste --type image --watch cliphist store

# Shell
start_once waybar          waybar
start_once mako            mako
start_once hypridle        hypridle
start_once swayosd-server  swayosd-server
start_once nm-applet       nm-applet --indicator
start_cmd  'ws-scroll-daemon' "$HOME_DIR/.local/bin/ws-scroll-daemon"

# Polkit
systemctl --user start hyprpolkitagent >/dev/null 2>&1 || true

# Entorno DBus
if have dbus-update-activation-environment; then
  dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP >/dev/null 2>&1 || true
fi

# Tema oscuro GTK
if have gsettings; then
  gsettings set org.gnome.desktop.interface color-scheme "prefer-dark" >/dev/null 2>&1 || true
fi

# Wallpaper
start_once awww-daemon awww-daemon

if [ "$first_run" = "1" ]; then
  # Espera a que Hyprland y awww estén listos (máx. ~6 s).
  for _ in $(seq 1 20); do
    hyprctl version >/dev/null 2>&1 && break
    sleep 0.3
  done
  for _ in $(seq 1 20); do
    [ -S "$RUNTIME/${WAYLAND_DISPLAY:-wayland-1}-awww-daemon.sock" ] && break
    sleep 0.3
  done
  if [ -x "$HOME_DIR/.config/hypr/scripts/restore-wallpaper.sh" ]; then
    "$HOME_DIR/.config/hypr/scripts/restore-wallpaper.sh" >/dev/null 2>&1 || true
  fi
fi

# Redundancia: algunas actualizaciones ejecutan `systemctl preset`, que puede
# deshabilitar la unidad. La dejamos habilitada para el próximo login.
systemctl --user enable hypr-session.service >/dev/null 2>&1 || true

exit 0
