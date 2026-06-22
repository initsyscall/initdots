-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("caelestia shell")
  hl.exec_cmd("wl-paste --watch cliphist store")
end)
