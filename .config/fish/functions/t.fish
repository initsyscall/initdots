function t
    set -l exclude node_modules .git .cache dist build target venv ~/go

    set -l prune_args
    for item in $exclude
        if test (count $prune_args) -gt 0
            set -a prune_args -o
        end

        if string match -q "*/*" -- "$item"
            set -a prune_args -path "$item"
        else
            set -a prune_args -name "$item"
        end
    end

    set -l dir (command find ~ -mindepth 1 \( $prune_args \) -prune -o -type d -print 2>/dev/null | fzf --height 40% --reverse --border --select-1 --exit-0 -q "$argv")

    if test -n "$dir"
        builtin cd "$dir"
    end
end

