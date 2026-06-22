-----------------------
---- LOOK AND FEEL ----
-----------------------

local theme = require("modules.themeInit")

local function rgba(hex, alpha)
  return "rgba(" .. hex:sub(2) .. (alpha or "FF") .. ")"
end

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    gaps_in          = 5,
    gaps_out         = 20,

    border_size      = 1,

    col              = {
      active_border   = { colors = { rgba(theme.fnc), rgba(theme.kwd) }, angle = 45 },
      inactive_border = rgba(theme.border, "aa"),
    },

    -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false,

    -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
    allow_tearing    = false,

    layout           = "dwindle",
  },

  decoration = {
    rounding         = 10,
    rounding_power   = 2,

    -- Change transparency of focused and unfocused windows
    active_opacity   = 0.9,
    inactive_opacity = 0.7,

    shadow           = {
      enabled      = true,
      range        = 20,
      render_power = 3,
      color        = ("0xee" .. theme.bg:sub(2)),
    },

    blur             = {
      enabled  = true,
      size     = 8,
      passes   = 2,
      noise    = 0.01,
    },
  },
})

-- Ref https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
-- hl.window_rule({
--     name  = "no-gaps-wtv1",
--     match = { float = false, workspace = "w[tv1]" },
--     border_size = 0,
--     rounding    = 0,
-- })
-- hl.window_rule({
--     name  = "no-gaps-f1",
--     match = { float = false, workspace = "f[1]" },
--     border_size = 0,
--     rounding    = 0,
-- })

-- See https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/ for more
hl.config({
  dwindle = {
    preserve_split = true, -- You probably want this
  },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Master-Layout/ for more
hl.config({
  master = {
    new_status = "master",
  },
})

-- See https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/ for more
hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
  },
})

----------------
----  MISC  ----
----------------

hl.config({
  misc = {
    force_default_wallpaper = 0,     -- Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo   = false, -- If true disables the random hyprland logo / anime girl background. :(
  },
})
