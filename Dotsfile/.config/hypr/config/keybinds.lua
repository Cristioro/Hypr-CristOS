-- /home/kaiserpc/.config/hypr/config/keybinds.lua
local vars = require("config.variables")

local mainMod = vars.mainMod
local terminal = vars.terminal

-- Gestos táctiles (3 dedos horizontal → workspace)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

-- Ratón: mover/redimensionar ventanas
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Redimensionar con teclado (repetible)
local function bindResize(mod, key, x, y)
  hl.bind(mod .. " + " .. key, hl.dsp.window.resize({ x = x, y = y, relative = true }), { repeating = true })
end
bindResize(mainMod .. " + SHIFT", "Left",  -50, 0)
bindResize(mainMod .. " + SHIFT", "Right", 50, 0)
bindResize(mainMod .. " + SHIFT", "Up",    0, -50)
bindResize(mainMod .. " + SHIFT", "Down",  0, 50)

-- Mover ventanas entre splits
hl.bind(mainMod .. " + CTRL + Left",  hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + Up",    hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + Down",  hl.dsp.window.move({ direction = "d" }))

-- Tiling (layout dwindle)
-- Invertir la orientación del split actual (horizontal ↔ vertical).
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"), { repeating = true })
-- Intercambiar la ventana activa con la vecina en esa dirección.
hl.bind(mainMod .. " + ALT + Left",  hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + ALT + Right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + ALT + Up",    hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + ALT + Down",  hl.dsp.window.swap({ direction = "down" }))
-- Pseudotiling: la ventana mantiene su tamaño al abrir otras.
hl.bind(mainMod .. " + U", hl.dsp.window.pseudo())
-- Pin: fija la ventana por encima del resto. Hyprland solo permite fijar
-- ventanas flotantes, así que si está tileada la flotamos primero.
hl.bind(mainMod .. " + ALT + P", function()
  local window = hl.get_active_window()
  if not window then
    return
  end
  if not window.floating then
    hl.dispatch(hl.dsp.window.float({ action = "enable" }))
  end
  hl.dispatch(hl.dsp.window.pin())
end)
-- Preseleccionar la dirección del próximo split (teclas vim).
hl.bind(mainMod .. " + ALT + H", hl.dsp.layout("preselect l"))
hl.bind(mainMod .. " + ALT + J", hl.dsp.layout("preselect d"))
hl.bind(mainMod .. " + ALT + K", hl.dsp.layout("preselect u"))
hl.bind(mainMod .. " + ALT + L", hl.dsp.layout("preselect r"))

-- Mover el workspace activo al otro monitor (intercambia ambos monitores).
hl.bind(mainMod .. " + O", function()
  local workspace = hl.get_active_workspace()
  local monitors = hl.get_monitors()
  if not workspace or not workspace.monitor or #monitors < 2 then
    return
  end
  local current = workspace.monitor.name
  local target
  for _, monitor in ipairs(monitors) do
    if monitor.name ~= current then
      target = monitor.name
      break
    end
  end
  if target then
    hl.dispatch(hl.dsp.workspace.swap_monitors({ monitor1 = current, monitor2 = target }))
  end
end)

-- Foco direccional
hl.bind(mainMod .. " + Left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down",  hl.dsp.focus({ direction = "down" }))

-- Ventanas
hl.bind(mainMod .. " + Q",           hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F",   hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + ALT + F",     hl.dsp.window.fullscreen())

-- Brillo (swayosd OSD)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("swayosd-client --brightness raise"),  { repeating = true, locked = true })

-- Capturas de pantalla (limpias, sin duplicados)
hl.bind("Print",                   hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region"),      { locked = true })
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region-edit"), { locked = true })
hl.bind("SUPER + Print",           hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh full"),        { locked = true })
hl.bind("SUPER + SHIFT + Print",   hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh full-edit"),   { locked = true })

-- Atajos alternativos para teclados 68 keys (sin Print)
hl.bind(mainMod .. " + P",         hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region"),      { locked = true })
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh region"),      { locked = true })
hl.bind(mainMod .. " + SHIFT + P", hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh full"),        { locked = true })
hl.bind(mainMod .. " + CTRL + P",  hl.dsp.exec_cmd("~/.config/hypr/scripts/screenshot.sh full-edit"),   { locked = true })

-- Grabación de pantalla
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("~/.config/hypr/scripts/record.sh full"), { locked = true })

-- Bloqueo de pantalla
hl.bind("XF86PowerOff", hl.dsp.exec_cmd("hyprlock"), { locked = true })
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"), { locked = true })

-- Multimedia (teclas dedicadas + SUPER+SPACE)
hl.bind(mainMod .. " + SPACE",     hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",           hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",          hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",           hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86AudioNext",           hl.dsp.exec_cmd("playerctl next"),       { locked = true })

-- Audio (swayosd OSD)
hl.bind("XF86AudioMicMute",       hl.dsp.exec_cmd("swayosd-client --input-volume mute-toggle"),  { locked = true })
hl.bind("XF86AudioMute",          hl.dsp.exec_cmd("swayosd-client --output-volume mute-toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume",   hl.dsp.exec_cmd("swayosd-client --output-volume lower"),       { repeating = true, locked = true })
hl.bind("XF86AudioRaiseVolume",   hl.dsp.exec_cmd("swayosd-client --output-volume raise"),       { repeating = true, locked = true })

-- Aplicaciones
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd(vars.browser))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))

-- Cafeína (evita idle/suspend)
hl.bind(mainMod .. " + SHIFT + CAPS_LOCK", hl.dsp.exec_cmd("~/.config/hypr/scripts/caffeine.sh toggle"), { locked = true })

-- Cambiar layout teclado (Español ↔ English)
hl.bind(mainMod .. " + ALT + CAPS_LOCK", hl.dsp.exec_cmd([[
  hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .name' | xargs -r -I{} hyprctl switchxkblayout {} next
]]), { locked = true })

-- Launchers / Paneles (Rofi)
hl.bind(mainMod .. " + I", hl.dsp.exec_cmd("~/.config/hypr/scripts/settings-gui.sh"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("~/.config/hypr/scripts/launcher.sh"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("~/.config/rofi/clipboard/launcher.sh"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("~/.config/rofi/clipboard/launcher.sh"))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/rofi/powermenu/powermenu.sh"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("~/.config/rofi/wifi/wifi.sh"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("~/.config/rofi/shortcut/script.sh"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("~/.config/rofi/powermenu/powermenu.sh"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell -c hyprquickpaper"), { locked = true })

-- Recargar Hyprland
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))

-- Workspaces 1-10 (tecla 0 = workspace 10)
for i = 1, 10 do
  local key = (i % 10)
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
