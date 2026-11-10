-- /home/kaiserpc/.config/hypr/config/autostart.lua
local vars = require("config.variables")

hl.on("hyprland.start", function()
  -- Portapapeles
  hl.spawn("wl-paste --type text --watch cliphist store")
  hl.spawn("wl-paste --type image --watch cliphist store")

  -- Shell (Waybar + notificaciones + idle)
  hl.spawn("waybar")
  hl.spawn("mako")
  hl.spawn("hypridle")
  hl.spawn("swayosd-server")
  hl.spawn("nm-applet --indicator")

  -- Rueda del ratón sobre los círculos de Waybar → cambiar workspace
  hl.spawn(os.getenv("HOME") .. "/.local/bin/ws-scroll-daemon")

  -- Polkit agent (systemd user service)
  hl.exec_cmd("systemctl --user start hyprpolkitagent")

  -- Entorno DBus
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")

  -- Tema oscuro global (GTK)
  hl.exec_cmd('gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"')

  -- Wallpaper daemon + restauración (el script espera a awww-daemon internamente)
  hl.spawn("awww-daemon")
  hl.spawn("~/.config/hypr/scripts/restore-wallpaper.sh")

  -- Night light nativo (reemplaza hyprsunset)
  -- hl.exec_cmd("hyprctl nightlight on")  -- Descomenta si quieres night light automático
end)