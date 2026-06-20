# initdots

<img width="1920" height="1080" alt="Screenshot" src="https://github.com/user-attachments/assets/ee3a6c92-806a-4301-bdee-fac901dc18b5" />

Dotfiles for an Arch Linux Hyprland setup with caelestia shell.

## Report Card

| Component | Detail |
|-----------|--------|
| Operating System | Cachy OS |
| Window Manager | Hyprland (Lua config via caelestia) |
| Shell | caelestia (QML-based Wayland shell) |
| Bar | caelestia bar with workspaces, clock, tray, status icons |
| Launcher | caelestia app launcher with fuzzy search, vim keybinds |
| Drawers | Dashboard, session control, notifications, OSD |
| Lock Screen | caelestia lock with media controls, weather, clock |
| Theme | nightSyscall (dark) + Material You color generation |
| Terminal | Ghostty with JetBrainsMono Nerd Font |
| Shell Prompt | tide + starship |
| Directory Jump | zoxide (cd replacement) |
| Multiplexer | tmux with vim-tmux-navigator, tmux-cpu |
| System Info | fastfetch |
| Compositor | Hyprland blur, animations, rounded corners |
| Screenshot | caelestia screenshot utility |
| Clipboard | cliphist with rofi picker |
| Wallpaper | caelestia wallpaper management |

## Requirements

- Arch Linux / Arch Based Distro
- Hyprland
- caelestia (install via paru: `paru -S caelestia-dots`)
- stow

## Setup

```sh
# Install dependencies
paru -S hyprland caelestia-dots

# Clone the repo into your home directory
git clone https://github.com/initsyscall/initdots ~/initdots

# Stow everything
cd ~/initdots && stow .
```

Restart your session or reboot. The dotfiles are designed to work out of the box after installing hyprland and caelestia via paru.

## Keybindings

| Binding | Action |
|---------|--------|
| Super + Return | Open terminal (ghostty) |
| Super + Space | Open launcher |
| Super + E | Open file manager (nautilus) |
| Super + B | Open browser (zen-browser) |
| Super + Q | Close focused window |
| Super + L | Lock screen |
| Super + V | Toggle window float |
| Super + W | Cycle wallpaper |
| Super + S | Toggle scratchpad |
| Super + [1-0] | Switch to workspace |
| Super + Shift + [1-0] | Move window to workspace |
| Print | Full screenshot |
| Super + Shift + S | Region screenshot |
| Super + Shift + V | Clipboard history |

All window navigation (focus, move, resize) uses vim-style keybindings.

## Theme

The nightSyscall color scheme is defined in `hypr/modules/themeInit.lua` and applied across:
- Hyprland window decorations
- Ghostty terminal colors
- Tmux status bar
- Fish shell syntax highlighting

## Project Structure

```
.config/
  caelestia/       Shell and bar configuration
  fish/            Fish shell config, plugins, aliases
  ghostty/         Terminal emulator config
  hypr/            WM modules, keybinds, theme, scripts
  fastfetch/       System info display
.tmux.conf         Tmux config with custom theme and bindings
```

## License

Apache 2.0
