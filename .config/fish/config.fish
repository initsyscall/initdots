# Settings
set fish_greeting " "

# env
## Nebulua
set -gx LUA_PATH "$HOME/.local/share/lua/?.lua;;"
## Starship
starship init fish | source

# Alias
alias q 'exit'
alias cat 'bat'
alias ls 'eza'
alias ll 'eza -ll'
alias la 'eza -la'
alias rf 'source ~/.config/fish/config.fish'
alias pysv 'python -m http.server'
alias pack 'pypy3 ~/.config/fish/scripts/packer.py'
alias minecraft '~/.1_devSyscall/1_initsyscall/3_resources/exe/PolyMC-Linux-7.0-x86_64.AppImage & disown'

# Tmux Startup
# if status is-interactive
#     and not set -q TMUX
#     exec tmux -u 
# end

# Startup
if status is-interactive
  clear
end
