-- hyprland

local mainMod = "SUPER" -- Sets "Windows" key as main modifier

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
local closeWindowBind = hl.bind(mainMod .. " + C", hl.dsp.window.close())
-- closeWindowBind:set_enabled(false)
hl.bind(
	mainMod .. " + M",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + space", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("~/.config/rofi/powermenu/powermenu.sh"))

--- custom binds ---
--- suspended binds ---
hl.bind(mainMod .. " + F10", hl.dsp.dpms({ action = "off" }))
hl.bind(mainMod .. " + F11", hl.dsp.dpms({ action = "on" }))

-- center floating window
hl.bind(mainMod .. " + ALT + C", hl.dsp.window.center())

-- Wallpaper
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("quickshell -c hyprquickpaper-copy"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("quickshell -p ~/.config/quickshell/qs-wallpaper-picker/Main.qml"))

-- cliphist
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("/home/cristioro/.config/rofi/clipboard/launcher.sh"))

-- hyprshot
hl.bind("Print", hl.dsp.exec_cmd("hyprshot -m region --freeze --clipboard-only"))

--- END custom binds ---

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
	local key = i % 10 -- 10 maps to key 0
	hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- num keyboard
hl.bind(mainMod .. " + KP_End", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + KP_Down", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + KP_Next", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + KP_Left", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + KP_Begin", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + KP_Right", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + KP_Home", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + KP_Up", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + KP_Prior", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + KP_Insert", hl.dsp.focus({ workspace = 10 }))

hl.bind(mainMod .. " + SHIFT + KP_End", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + SHIFT + KP_Down", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + SHIFT + KP_Next", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + SHIFT + KP_Left", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + SHIFT + KP_Begin", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + SHIFT + KP_Right", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + SHIFT + KP_Home", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + SHIFT + KP_Up", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + SHIFT + KP_Insert", hl.dsp.window.move({ workspace = 9 }))

-- Swap Windows
hl.bind(mainMod .. " + SHIFT + left", hl.dsp.window.swap({ direction = "left" }))
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.swap({ direction = "right" }))
hl.bind(mainMod .. " + SHIFT + up", hl.dsp.window.swap({ direction = "up" }))
hl.bind(mainMod .. " + SHIFT + down", hl.dsp.window.swap({ direction = "down" }))

-- Move Windows
hl.bind(mainMod .. " + ALT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + ALT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + ALT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + ALT + down", hl.dsp.window.move({ direction = "down" }))

--- END WORKSPACE ---

-- Example special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + CTRL + S", hl.dsp.window.move({ workspace = "+0" }))

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind(
	"XF86PowerOff",
	hl.dsp.exec_cmd("hyprshutdown -t 'Shutting down...' --post-cmd 'shutdown -P 0'"),
	{ locked = true, repeating = true }
)

hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
