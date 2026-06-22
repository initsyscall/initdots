# initdots

<img width="1920" height="1080" alt="Screenshot" src="https://github.com/user-attachments/assets/ee3a6c92-806a-4301-bdee-fac901dc18b5" />

Dotfiles for an Arch Linux Hyprland setup with caelestia shell.

## Requirements

Arch Linux (tested on CachyOS) with `paru` (or another AUR helper) and `stow`.

### Core packages

```sh
paru -S --needed \
  hyprland caelestia-dots \
  ghostty \
  fish starship zoxide eza bat \
  tmux \
  cliphist wl-clipboard rofi \
  fastfetch \
  brightnessctl
```

`caelestia-dots` pulls in Hyprland and most runtime deps. The rest are configured
explicitly: fish (shell), ghostty (terminal), tmux, cliphist, rofi, etc.

### Fish plugins

```sh
# tide + zoxide completions (listed in fish_plugins)
fish -c "fisher install ilancosman/tide@v6 icezyclon/zoxide.fish"
```

## Setup

```sh
# Clone into home
git clone https://github.com/initsyscall/initdots ~/initdots

# Symlink everything to $HOME
cd ~/initdots && stow .
```

Restart session or reboot. Everything should work out of the box.

## Components

| Component | Detail |
|-----------|--------|
| Window Manager | Hyprland via caelestia Lua API |
| Shell | caelestia (QML-based Wayland shell) |
| Bar | caelestia bar — workspaces, clock, tray, status |
| Launcher | caelestia — fuzzy search, vim keybinds |
| Lock Screen | caelestia — media controls, weather, clock |
| Terminal | Ghostty with JetBrainsMono Nerd Font |
| Prompt | tide + starship |
| Multiplexer | tmux (prefix C-s) |
| Directory Jump | zoxide |
| Clipboard | cliphist (daemon via wl-paste, rofi picker) |
| File Manager | nautilus |
| Browser | zen-browser |

## Keybindings

### Application launchers

| Binding | Action |
|---------|--------|
| Super + Return | Terminal (ghostty) |
| Super + Space | App launcher |
| Super + E | File manager |
| Super + B | Browser |

### Navigation (vim-style)

| Binding | Action |
|---------|--------|
| Super + H / J / K / L | Focus left / down / up / right |
| Super + arrows | Same (fallback) |

### Window management

| Binding | Action |
|---------|--------|
| Super + Q | Close window |
| Super + V | Toggle float |
| Super + P | Toggle pseudo-tiling |
| Super + Alt + H / J / K / L | Move window left / down / up / right |
| Super + Shift + J | Toggle split layout (dwindle) |

### Workspaces

| Binding | Action |
|---------|--------|
| Super + S | Toggle scratchpad |
| Super + [1-0] | Switch to workspace |
| Super + Shift + [1-0] | Move window to workspace |
| Super + Alt + S | Send window to scratchpad |
| Super + Shift + Print | Move window to scratchpad |
| Super + scroll | Cycle workspaces |

### Mouse

| Binding | Action |
|---------|--------|
| Super + LMB | Drag/move window |
| Super + RMB | Resize window |

### System

| Binding | Action |
|---------|--------|
| Super + Shift + L | Lock screen |
| Super + Escape | Session drawer |
| Super + M | Exit Hyprland |
| Super + Shift + R | Restart caelestia shell |
| Super + W | Cycle wallpaper |
| Print | Full screenshot |
| Super + Shift + S | Region screenshot |

### Utilities

| Binding | Action |
|---------|--------|
| Super + Shift + V | Clipboard history (cliphist + rofi) |
| Super + Period | Emoji picker |

All multimedia keys (volume, brightness, media playback) use standard XF86 keycodes.

## Theme

Colors are defined in `hypr/modules/themeInit.lua` and shared across:
- Hyprland window decorations (borders, active/inactive)
- Ghostty terminal (palette, background, cursor)
- Tmux status bar and pane borders
- Fish shell syntax highlighting

## Project Structure

```
.config/
  caelestia/         Shell, bar, launcher, dashboard config
  fish/              config.fish, aliases, plugins, packer.py
  ghostty/           Terminal config, animated cursor shaders
  hypr/
    hyprland.lua     Entry point — requires modules below
    modules/         Lua modules for each concern
      binds.lua       Keybindings (navigation, apps, window mgmt)
      look_feel.lua   Gaps, borders, shadows, blur, rounding
      animations/     18 animation presets (choose in hyprland.lua)
      autostart.lua   Startup (caelestia shell, cliphist daemon)
      env_variables.lua
      input.lua
      monitor.lua
      themeInit.lua   Color palette (single source of truth)
      win_space.lua   Window rules
    scripts/cliphist.sh
    scheme/           Auto-generated theme (gitignored)
  fastfetch/         System info display
.tmux.conf           Tmux with TPM, vim-tmux-navigator, tmux-cpu
```

## Switching animation presets

Edit `hyprland.lua` and change the require line:

```lua
require("modules.animations.animations-optimized")  -- default
-- require("modules.animations.animations-fast")
-- require("modules.animations.animations-vertical")
-- require("modules.animations.animations-disabled")
```

## License

Apache 2.0
