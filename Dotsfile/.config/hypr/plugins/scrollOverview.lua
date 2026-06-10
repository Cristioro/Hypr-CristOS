-- .config/hypr/hyprland.lua
if hl.plugin and hl.plugin.scrolloverview then
    hl.plugin.scrolloverview.configure({
        gesture_distance = 300, -- how far is the "max" for the gesture
        scale = 0.6, -- preferred overview scale
        workspace_gap = 50,
        wallpaper = 0, -- 0: global only, 1: per-workspace only, 2: both
        blur = false, -- blur only the main overview wallpaper

        shadow = {
            enabled = false,
            range = 50,
            render_power = 3,
            color = 0xee1a1a1a,
        },
    })
end

hl.bind("SUPER + G", function()
    if hl.plugin and hl.plugin.scrolloverview then
        return hl.plugin.scrolloverview.overview("toggle")
    end
end)