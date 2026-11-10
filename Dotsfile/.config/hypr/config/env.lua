-- /home/kaiserpc/.config/hypr/config/env.lua

hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
-- Variables de tema para Qt.
-- NO fuerces GTK_THEME aquí: en apps libadwaita (Nautilus, GNOME Files,
-- Configuración...) el tema Breeze-Dark de KDE rompe el CSS interno de GTK
-- (avisos "GtkGizmo ... min width -2") y la interfaz sale con tamaños y
-- colores raros. Las apps GTK toman el tema de gsettings (adw-gtk3-dark,
-- que ajusta el hook de matugen) y la paleta de ~/.config/gtk-*/colors.css.
hl.env("QT_QPA_PLATFORMTHEME", "kde")

-- Cursores BreezeX (Hypr-CristOS)
hl.env("XCURSOR_THEME", "BreezeX-Black")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "BreezeX-Black-hyprcursor")
hl.env("HYPRCURSOR_SIZE", "24")
