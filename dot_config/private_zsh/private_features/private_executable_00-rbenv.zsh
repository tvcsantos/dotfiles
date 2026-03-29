export PATH="$HOME/.rbenv/bin:$PATH"
# Lazy load rbenv for faster startup
if command -v rbenv >/dev/null; then
    _evalcache rbenv init - zsh --no-rehash
fi
