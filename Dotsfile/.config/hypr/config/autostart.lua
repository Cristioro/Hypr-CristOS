-- /home/kaiserpc/.config/hypr/config/autostart.lua
local vars = require("config.variables")

hl.on("hyprland.start", function()
  -- Todo el arranque vive en session-start.sh (idempotente). También lo lanza
  -- la unidad systemd hypr-session.service, de modo que no depende de cuándo
  -- cargue Hyprland el Lua.
  hl.spawn(os.getenv("HOME") .. "/.config/hypr/scripts/session-start.sh")

  -- Night light nativo (reemplaza hyprsunset)
  -- hl.exec_cmd("hyprctl nightlight on")  -- Descomenta si quieres night light automático
end)