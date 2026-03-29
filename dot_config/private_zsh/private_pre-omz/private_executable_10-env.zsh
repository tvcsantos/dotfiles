# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Oh My Zsh cache under XDG cache
export ZSH_CACHE_DIR="${XDG_CACHE_HOME}/zsh"
export ZSH_COMPDUMP="${ZSH_CACHE_DIR}/.zcompdump"
export ZSH_EVALCACHE_DIR="$ZSH_CACHE_DIR/evalcache"
mkdir -p "$ZSH_CACHE_DIR" "$ZSH_EVALCACHE_DIR"

export HISTFILE="$XDG_STATE_HOME/zsh/history"
export HISTSIZE=50000
export SAVEHIST=50000
mkdir -p "${HISTFILE:h}"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

############### For zsh-nvm plugin to enabled lazy loading ###############

export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true

##########################################################################

# Disable completion security checks for speed
ZSH_DISABLE_COMPFIX=true
