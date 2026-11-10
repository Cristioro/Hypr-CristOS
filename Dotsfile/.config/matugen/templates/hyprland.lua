-- /home/kaiserpc/.config/hypr/config/colors.lua
-- NOTA: Este archivo es GENERADO por matugen. NO editar a mano.
-- Ver ~/.config/matugen/templates/hyprland.lua para el template.

local M = {}

-- Paleta generada por matugen
<* for name, value in colors *>
M.{{name}} = "0xff{{value.default.hex_stripped}}"
<* endfor *>

-- Helpers para bordes
M.active_border = { colors = { M.on_primary, M.on_secondary }, angle = 45 }
M.inactive_border = M.on_surface

return M
