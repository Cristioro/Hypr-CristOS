-- /home/kaiserpc/.config/hypr/config/monitors.lua

-- Configuración automática (plug & play)
-- Toda pantalla nueva toma su modo preferido y se coloca sola, sin depender
-- de que exista una regla por nombre de salida.
local function arrange_monitors()
  hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1.0,
  })
end

arrange_monitors()

-- Al conectar o desconectar una pantalla se reaplica la disposición automática
-- (posición y modo), de modo que las ventanas y workspaces se reparten solos
-- en el monitor que queda disponible. No se reaplica en layout_changed para no
-- pisar los ajustes manuales que hagas desde el centro de control.
hl.on("monitor.added", arrange_monitors)
hl.on("monitor.removed", arrange_monitors)

-- Ejemplo configuración multi-monitor (descomenta y ajusta):
-- hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1.0 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "2560x0", scale = 1.0 })
