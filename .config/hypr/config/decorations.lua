-- Look and feel configuration
-- Decoration (rounding, opacity, blur) lives in hyprland-gui.lua (HyprMod-managed)

hl.config({
  general = {
    gaps_in = 3,
    gaps_out = 8,
    border_size = 1,
    extend_border_grab_area = 10,
    resize_on_border = true,
    col = {
      active_border = {
        colors = {
          "rgba(cba6f7ff)", -- soft mauve
          "rgba(f38ba8ff)", -- dusty rose
        },
        angle = 35,
      },

      inactive_border = "rgba(44475a99)"
    },
  },
  group = {
    col = {
      border_active = CACHYLBLUE,
      border_inactive = CACHYGRAY,
      border_locked_active = CACHYDBLUE,
      border_locked_inactive = CACHYGRAY,
    },
    groupbar = {
      col = {
        active = CACHYLGREEN,
        inactive = CACHYGRAY,
        locked_active = CACHYDBLUE,
        locked_inactive = CACHYGRAY,
      },
    },
  },
})
