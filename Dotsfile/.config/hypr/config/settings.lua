-- /home/kaiserpc/.config/hypr/config/settings.lua
local colors = require("config.colors")

hl.config({
  general = {
    border_size = 2,
    gaps_in = 4,
    gaps_out = 6,
    float_gaps = 6,
    resize_on_border = true,
    extend_border_grab_area = 30,
    col = {
      active_border = colors.active_border,
      inactive_border = colors.inactive_border,
    },
  },

  decoration = {
    rounding = 12,
    active_opacity = 1.0,
    inactive_opacity = 1.0,
    blur = {
      enabled = true,
      size = 8,
      passes = 2,
      new_optimizations = true,
    },
    shadow = { enabled = false },
  },

  input = {
    kb_layout = "latam,us",
    kb_options = "grp:alt_shift_toggle",
    accel_profile = "flat",
    touchpad = {
      natural_scroll = true,
      disable_while_typing = false,
    },
  },

  misc = {
    focus_on_activate = false,
    font_family = "JetBrains Mono",
    disable_hyprland_logo = true,
    disable_splash_rendering = true,
  },
})

-- Curvas de animación
-- Spring elástico para entradas: rebote marcado (damping bajo = más bounce)
hl.curve("springBounce", { type = "spring", mass = 1, stiffness = 260, damping = 9 })
-- Spring rápido para salidas/movimientos: ágil, con micro-rebote al asentarse
hl.curve("springSnap", { type = "spring", mass = 1, stiffness = 420, damping = 26 })
-- Spring para cambios de workspace: rebote breve y discreto
hl.curve("springSmooth", { type = "spring", mass = 1, stiffness = 260, damping = 18 })
-- Fade suave y uniforme
hl.curve("fadeSoft", { type = "bezier", points = { {0.33, 0}, {0.68, 1} } })

-- Animaciones globales
hl.animation({ leaf = "windowsIn",    enabled = true, speed = 4, spring = "springBounce", style = "popin 70%" })
hl.animation({ leaf = "windowsOut",   enabled = true, speed = 3, spring = "springSnap",   style = "popin 80%" })
hl.animation({ leaf = "windowsMove",  enabled = true, speed = 4, spring = "springSnap",   style = "slide" })
hl.animation({ leaf = "layers",       enabled = true, speed = 3, bezier = "fadeSoft",     style = "fade" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 3, bezier = "fadeSoft",     style = "fade" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 3, bezier = "fadeSoft",     style = "fade" })
hl.animation({ leaf = "fade",         enabled = true, speed = 3, bezier = "fadeSoft" })
hl.animation({ leaf = "workspaces",   enabled = true, speed = 5, spring = "springSmooth", style = "slidefade" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 3, bezier = "fadeSoft", style = "fade" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 3, bezier = "fadeSoft", style = "fade" })

-- Layer rules para blur
hl.layer_rule({
  name = "waybar-blur",
  match = { namespace = "waybar" },
  blur = true,
  ignore_alpha = 0.2,
})

hl.layer_rule({
  name = "rofi-blur",
  match = { namespace = "rofi" },
  blur = true,
  ignore_alpha = 0.1,
})

hl.layer_rule({
  name = "swayosd-blur",
  match = { namespace = "swayosd" },
  blur = true,
  ignore_alpha = 0.05,
})

-- Centro de control rápido (quickshell)
hl.layer_rule({
  name = "cristos-cc-blur",
  match = { namespace = "cristos-cc" },
  blur = true,
  ignore_alpha = 0.05,
})

hl.layer_rule({
  name = "cristos-cc-toast-blur",
  match = { namespace = "cristos-cc-toast" },
  blur = true,
  ignore_alpha = 0.05,
})

hl.layer_rule({
  name = "cristos-launcher-blur",
  match = { namespace = "cristos-launcher" },
  blur = true,
  ignore_alpha = 0.05,
})

-- Solo la ventana de ajustes tiene blur; el velo exterior queda nítido.
hl.layer_rule({
  name = "cristos-settings-blur",
  match = { namespace = "cristos-settings" },
  blur = true,
  ignore_alpha = 0.2,
})
