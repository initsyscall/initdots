# Settings
set fish_greeting " "

# env
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
alias thedarkmod 'cd ~/Games/thedarkmod/ && ./thedarkmod.x64'

# My custom scripts
alias pack 'pypy3 ~/.config/fish/scripts/packer.py'
alias gobuilder 'bash ~/.config/fish/scripts/gobuilder.sh'
alias ync 'lua ~/.config/fish/scripts/yesntcloned.lua'

# Tmux Startup
# if status is-interactive
#     and not set -q TMUX
#     exec tmux -u 
# end

# Startup
if status is-interactive
  clear
end
