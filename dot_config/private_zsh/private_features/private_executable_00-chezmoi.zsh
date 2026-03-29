# Enable chezmoi completion
if command -v chezmoi >/dev/null; then
    _evalcache chezmoi completion zsh
fi
