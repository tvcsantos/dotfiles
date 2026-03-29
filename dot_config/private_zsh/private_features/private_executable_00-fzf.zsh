# Set up fzf key bindings and fuzzy completion
if command -v fzf >/dev/null; then
    #source <(fzf --zsh)
    _evalcache fzf --zsh
fi

if command -v atuin >/dev/null; then
    #eval "$(atuin init zsh)"
    _evalcache atuin init zsh
fi
