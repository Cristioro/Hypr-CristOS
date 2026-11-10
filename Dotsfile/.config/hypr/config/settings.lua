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

-- Curva de animación (bezier suave, sin overshoot extremo)
hl.curve("myBezier", { type = "bezier", points = { {0.25, 0.1}, {0.25, 1.0} } })

-- Animaciones globales
hl.animation({ leaf = "windows",       enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 5, bezier = "myBezier", style = "popin 80%" })
hl.animation({ leaf = "layers",        enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "fade",          enabled = true, speed = 5, bezier = "myBezier" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5, bezier = "myBezier", style = "slide" })
hl.animation({ leaf = "specialWorkspaceIn",  enabled = true, speed = 5, bezier = "myBezier", style = "fade" })
hl.animation({ leaf = "specialWorkspaceOut", enabled = true, speed = 5, bezier = "myBezier", style = "fade" })

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