-- config/hosts/example.lua — overrides opcionales por máquina.
--
-- Copia este archivo como <hostname>.lua (el nombre que devuelve `hostname -s`)
-- y descomenta solo lo que necesites. Se carga automáticamente al final de
-- hyprland.lua; si no existe el archivo, no pasa nada.

-- Monitor principal / multi-monitor
-- hl.monitor({ output = "DP-1", mode = "2560x1440@144", position = "0x0", scale = 1.0 })
-- hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60", position = "2560x0", scale = 1.0 })

-- Layout de teclado específico de esta máquina
-- hl.config({ input = { kb_layout = "latam,us", kb_options = "grp:alt_shift_toggle" } })

-- Escala / opacidad / gaps propios del equipo
-- hl.config({ general = { gaps_in = 2, gaps_out = 4 } })
