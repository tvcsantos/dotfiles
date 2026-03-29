if command -v fnm >/dev/null; then
    #eval "$(fnm env --use-on-cd --shell zsh)"
    _evalcache fnm env --use-on-cd --shell zsh
fi
