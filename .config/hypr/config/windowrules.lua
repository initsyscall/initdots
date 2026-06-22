-- Picture-in-Picture
hl.window_rule({
  match             = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
  float             = true,
  keep_aspect_ratio = true,
  move              = "73% 72%",
  size              = "25% 25%",
  pin               = true,
})

-- Gaming
local gamingApps = "^(steam_app.*|gamescope)$"
local gamingWorkspace = "name:gaming"

hl.window_rule({ match = { content = "game" }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = gamingApps }, workspace = gamingWorkspace })
hl.window_rule({ match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({
  match     = {
    class = "^(steam)$",
    title = "^(Launching\\.{3})$"
  },
  float     = true,
  center    = true,
  workspace = gamingWorkspace,
})
hl.window_rule({
  match            = {
    class         = gamingApps,
    title         = "^(.+)$",
    initial_title = "negative:^(.*\\\\home\\\\.*)$",
  },
  size             = "monitor_w monitor_h",
  fullscreen_state = 2,
  content          = "game",
})
hl.window_rule({
  match            = {
    class         = "^(steam_app.*)$",
    initial_title = "^$",
  },
  float            = true,
  center           = true,
  fullscreen       = false,
  fullscreen_state = 0,
})

-- Apps
local primaryWorkspace = 1

-- Force any window spawned on Workspace 9 to float, set a clean default size, and center it
hl.window_rule({
  match = { workspace = 9 },
  float = true,
  size = { 900, 650 }, -- Sets a perfect, premium floating dimensions
  center = true        -- Automatically centers the window on your monitor
})

hl.window_rule({ match = { class = "^(.*\\.exe)$" }, workspace = primaryWorkspace, float = true, center = true, fullscreen_state = 0 })
hl.window_rule({ match = { class = "^(vesktop|discord)$" }, workspace = primaryWorkspace })
hl.window_rule({ match = { class = "^(.*[Cc]alculator.*)$" }, float = true, size = "380 616" })
hl.window_rule({ match = { class = "^(org.kde.keditfiletype)$" }, float = true })
hl.window_rule({ match = { class = "^(org.kde.ark)$" }, size = "(monitor_w*0.40) (monitor_h*0.40)" })
hl.window_rule({
  match = {
    class = "^(org.gnome.Nautilus|nautilus)$",
    title =
    "negative:^(Moving.*|Create New.*|Extract.*|Compress.*|Copying.*|Progress.*|Configure.*|Properties.*|Choose\\sApplication.*)$",
  },
  float = true,
  move = {
    "max(0, min(cursor_x - 650, monitor_w - 1320))",
    "max(0, min(cursor_y - 50, monitor_h - 820))"
  },
  size = "800 600",
})
hl.window_rule({
  match = {
    class = "^com.mitchellh.ghostty$",
    title = "^btop$",
  },
  float = true,
  move = {
    "max(0, min(cursor_x - 400, monitor_w - 800))",
    "max(0, min(cursor_y - 300, monitor_h - 600))",
  },
  size = "800 600",
})
hl.window_rule({
  match = { class = "MEGAsync" },
  float = true,
  size = { 500, 650 },
  center = true
})
-- Opacity Overrides
local terminals = "^(kitty|ghostty|[Kk]onsole|Alacritty|gnome-terminal|xfce[0-9]?-terminal)$"

hl.window_rule({ match = { class = "^(firefox|zen)$" }, opacity = "1.0 override" })
hl.window_rule({ match = { class = terminals }, opacity = "1.0 override" }) -- override opacity in favor of terminal settings for opacity
hl.window_rule({
  match = { class = "^(mpv|org.kde.haruna|.*plex.*|org\\.kde\\.gwenview|.*vlc.*)$" },
  opacity =
  "1.0 override"
})

-- Float Utility Windows
local floatApps = {
  { class = "^(kvantummanager|qt[56]ct|nwg-look)$" },
  { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-applet|nm-connection-editor)$" },
  { title = "^(Winetricks.*|Protontricks.*)$" },
}
for _, m in ipairs(floatApps) do hl.window_rule({ match = m, float = true }) end

hl.window_rule({ match = { float = true }, move = "50% 50%" })

-- Float Common Modals
local modalMatches = {
  { title = "^(Open|Authentication Required|Add Folder to Workspace|Choose Files|Save As|Confirm to replace files|File Operation Progress)$" },
  { initial_title = "^(Open File)$" },
  { class = "^([Xx]dg-desktop-portal-gtk)$" },
  { title = "^(File Upload|Choose wallpaper|Library)(.*)$" },
  { class = "^(.*dialog.*)$" },
  { title = "^(.*dialog.*)$" },
  { class = "^(hyprland-share-picker)$" },
}
for _, m in ipairs(modalMatches) do hl.window_rule({ match = m, float = true }) end

-- Fix some dragging issues with XWayland
hl.window_rule({
  name     = "fix-xwayland-drags",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },

  no_focus = true,
})
