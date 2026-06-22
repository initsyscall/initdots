-- ── Mod Key ──────────────────────────────────────────────
local mainMod     = "SUPER" -- Sets "Windows" key as main modifier

-- ── programs ──────────────────────────────────────────────
local terminal    = "ghostty"
local browser     = "zen-browser"
local fileManager = "nautilus"
local menu        = "caelestia shell drawers toggle launcher"

-- ── Launchers ──────────────────────────────────────────────
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd(browser))

-- ── System & Session ───────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.exec_cmd("caelestia shell lock lock"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("caelestia wallpaper -r ~/Pictures/wallpaper"))
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("caelestia shell drawers toggle session"))
hl.bind(mainMod .. " + M",
  hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- ── Screenshot ─────────────────────────────────────────────
hl.bind("Print", hl.dsp.exec_cmd("caelestia screenshot"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("caelestia screenshot -r"))

-- ── Window Management ──────────────────────────────────────
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + J", hl.dsp.layout("togglesplit")) -- dwindle only

-- ── Focus & Navigation ─────────────────────────────────────
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))

-- Arrow keys as secondary fallback
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

-- ── Workspaces ─────────────────────────────────────────────
for i = 1, 10 do
  local key = i % 10 -- 10 maps to key 0
  hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + Print", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- ── Move Window ────────────────────────────────────────────
hl.bind(mainMod .. " + ALT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(mainMod .. " + ALT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(mainMod .. " + ALT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(mainMod .. " + ALT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- ── Mouse ──────────────────────────────────────────────────
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- ── Utilities ──────────────────────────────────────────────
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.exec_cmd("caelestia clipboard"))
hl.bind(mainMod .. " + PERIOD", hl.dsp.exec_cmd("caelestia emoji -p"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("qs -c caelestia kill; sleep .1; caelestia shell -d"))

-- ── Input ──────────────────────────────────────────────────
hl.config({
  input = {
    kb_options = "caps:swapescape"
  }
})

-- ── Multimedia Keys ────────────────────────────────────────
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- ── Media Playback ─────────────────────────────────────────
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("caelestia shell mpris next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("caelestia shell mpris playPause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("caelestia shell mpris playPause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("caelestia shell mpris previous"), { locked = true })
