# Only run if completions aren’t already initialized (OMZ usually does it)
if ! typeset -p _comps &>/dev/null; then
  autoload -Uz compinit

  : "${ZSH_COMPDUMP:=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/.zcompdump}"
  
  mkdir -p "${ZSH_COMPDUMP:h}"
  
  # reuse cache if fresh; otherwise compile
  if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
    compinit -d "$ZSH_COMPDUMP"
  else
    compinit -C -d "$ZSH_COMPDUMP"
  fi
fi
