-- tools/hypr-sandbox.lua — carga la config Lua de Hyprland con un `hl` falso.
--
-- Objetivo: detectar errores de sintaxis y de carga (por ejemplo, un módulo
-- que haga require("hyprland") y provoque recursión infinita) sin necesidad
-- de una sesión gráfica. Es el test que corre GitHub Actions.
--
-- Uso:
--   lua5.4 tools/hypr-sandbox.lua Dotsfile/.config/hypr
--
-- El stub implementa hl.* y hl.dsp.* como funciones/tablas encadenables que
-- aceptan cualquier argumento y no hacen nada.

local dir = arg[1]
if not dir or dir == "" then
  io.stderr:write("uso: lua hypr-sandbox.lua <directorio-hypr>\n")
  os.exit(2)
end

-- Quita la barra final para componer rutas.
dir = dir:gsub("/$", "")

-- Stub recursivo: cualquier propiedad es una tabla invocable.
local function make_stub()
  local t = {}
  setmetatable(t, {
    __index = function(_, _)
      return make_stub()
    end,
    __call = function(_, ...)
      return make_stub()
    end,
    __tostring = function()
      return "<hl-stub>"
    end,
  })
  return t
end

hl = make_stub()

if os.getenv("HYPR_SANDBOX_VERBOSE") then
  print("hypr-sandbox: cargando " .. dir .. "/hyprland.lua")
end

-- Resolución de módulos: require("config.env") -> <dir>/config/env.lua
package.path = dir .. "/?.lua;" .. package.path

local chunk, err = loadfile(dir .. "/hyprland.lua")
if not chunk then
  io.stderr:write("hypr-sandbox: error de sintaxis: " .. tostring(err) .. "\n")
  os.exit(1)
end

local ok, err2 = pcall(chunk)
if not ok then
  io.stderr:write("hypr-sandbox: error al cargar la config: " .. tostring(err2) .. "\n")
  os.exit(1)
end

print("hypr-sandbox: OK — módulos cargados sin errores")
