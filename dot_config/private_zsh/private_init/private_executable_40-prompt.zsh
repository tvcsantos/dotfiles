# Starship prompt initialization
if command -v starship >/dev/null 2>&1; then
    # eval "$(starship init zsh)"
    _evalcache starship init zsh
fi

# thefuck command correction
if command -v thefuck >/dev/null 2>&1; then
    #eval $(thefuck --alias)
    _evalcache thefuck --alias
fi
