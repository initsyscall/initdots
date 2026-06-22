-- Input configuration

hl.config({
  input = {
    accel_profile = "flat",
  },
})

-- cursors
hl.env("HYPRCURSOR_THEME", "MyCursor")
hl.env("HYPRCURSOR_SIZE", "14")

--touchpad
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = 3, direction = "down", action = "close" })
hl.gesture({ fingers = 3, direction = "up", action = "fullscreen" })
hl.gesture({ fingers = 3, direction = "left", action = "float" })
