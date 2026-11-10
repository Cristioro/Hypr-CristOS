-- /home/kaiserpc/.config/hypr/config/monitors.lua

-- Configuración automática (plug & play)
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = 1.0,
})

-- Ejemplo configuración multi-monitor (descomenta y ajusta):
-- hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1.0 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "2560x0", scale = 1.0 })