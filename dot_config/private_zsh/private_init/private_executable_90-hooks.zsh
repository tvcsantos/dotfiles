# Global flag to track SDKMAN loading
_SDKMAN_LOADED=false

# Pre-execution hook to lazy load SDKMAN
preexec() {
  local cmd="$1"
  
  # Check if command starts with SDKMAN-managed tools
  if [[ "$cmd" =~ ^(ijhttp|mvn|java|gradle|scala|kotlin|sbt|sdk) ]] && [[ "$_SDKMAN_LOADED" != "true" ]]; then
    if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
      source "$HOME/.sdkman/bin/sdkman-init.sh"
      _SDKMAN_LOADED=true
    fi
  fi
}

# --- Lazy bootstrap of SDKMAN when a .sdkmanrc is present ---
autoload -Uz add-zsh-hook

_z_sdkman_bootstrap_autoenv() {
  local dir=${PWD:A}
  # Only act if this directory has a .sdkmanrc
  [[ -f "$dir/.sdkmanrc" ]] || return 0

  # Load SDKMAN once per shell if not yet loaded
  if ! whence -w sdk >/dev/null && [[ "$_SDKMAN_LOADED" != "true" ]]; then
    if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
      source "$SDKMAN_DIR/bin/sdkman-init.sh"
      _SDKMAN_LOADED=true
    fi
  fi

  # Apply the .sdkmanrc now (show standard SDKMAN messages for consistency)
  command -v sdk >/dev/null && sdk env -q >/dev/null 2>&1 || true
}

# Run when changing directories
add-zsh-hook chpwd _z_sdkman_bootstrap_autoenv
# Also run once at shell start (covers starting inside a project dir)
_z_sdkman_bootstrap_autoenv

