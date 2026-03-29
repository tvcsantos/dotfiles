export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/shims:$GOENV_ROOT/bin:$PATH"
# Lazy load goenv for faster startup
if command -v goenv >/dev/null; then
    _evalcache goenv init - --no-rehash
fi
