-- /home/kaiserpc/.config/hypr/hyprland.lua
require("config.variables")
require("config.env")
require("config.autostart")
require("config.monitors")
require("config.settings")
require("config.keybinds")

-- Overrides opcionales por máquina: config/hosts/<hostname>.lua
-- Ejemplo en config/hosts/example.lua (monitores, layout, escala...).
local ok_host, hostname = pcall(function()
  local f = io.popen("hostname -s")
  local h = f:read("*l")
  f:close()
  return h
end)
if ok_host and hostname and hostname ~= "" then
  pcall(require, "config.hosts." .. hostname)
end