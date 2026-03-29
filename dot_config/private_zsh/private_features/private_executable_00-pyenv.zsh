export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"

# Lazy load pyenv for faster startup
if command -v pyenv >/dev/null; then
    _evalcache pyenv init - zsh --no-rehash
    _evalcache pyenv virtualenv-init - --no-rehash
fi
