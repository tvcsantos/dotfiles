_get_aws_profiles() {
  grep '^\[profile' ~/.aws/config 2>/dev/null | sed 's/\[profile \(.*\)\]/\1/' | sort
}

_has_profile() {
  grep -q "^\[profile $1\]" ~/.aws/config 2>/dev/null
}

_has_default_profile() {
  grep -q '^\[default\]' ~/.aws/config 2>/dev/null
}

_list_sso_sessions() {
  grep '^\[sso-session' ~/.aws/config 2>/dev/null | sed 's/\[sso-session \(.*\)\]/\1/' | sort -u
}

local ax_history_dir="${XDG_STATE_HOME:=$HOME/.local/state}"
local ax_history_file="$ax_history_dir/ax/last_profile"

_switch_to_profile() {
  local profile="$1"
  if [[ -z "$profile" ]]; then
    echo "Profile name cannot be empty"
    return 1
  fi
  local current_profile=$AWS_PROFILE
  if [[ -z "$current_profile" ]]; then
    current_profile="default"
  fi
  export AWS_PROFILE="$profile"
  if [[ "$current_profile" == "$profile" ]]; then
    echo "Switched to AWS profile \"$AWS_PROFILE\""
    return 0
  fi
  # Create directory if it doesn't exist
  mkdir -p "$(dirname "$ax_history_file")"
  # Store both current and last profile
  {
    echo "$profile"
    echo "$current_profile"
  } > "$ax_history_file"
  echo "Switched to AWS profile \"$AWS_PROFILE\""
}

_load_history() {
  if [[ -f "$ax_history_file" ]]; then
    local current_profile=$(head -n 1 "$ax_history_file")
    if [[ -n "$current_profile" ]]; then
      # if the profile still valid
      if _has_profile "$current_profile" || _has_default_profile; then
        export AWS_PROFILE="$current_profile"
      else
        rm "$ax_history_file"
      fi
    fi
  fi
}

_load_history

# AWS Profile selector with fuzzy search
ax() {
  # Check for multiple arguments
  if [[ $# -gt 1 ]]; then
    echo "Usage: ax [PROFILE|-|login]"
    echo "  ax              - List profiles with fuzzy search"
    echo "  ax -            - Switch to last used profile"
    echo "  ax PROFILE      - Switch to specified profile"
    echo "  ax login        - List SSO sessions and login"
    return 1
  fi
  
  # Login to SSO session
  if [[ $1 == "login" ]]; then
    local sessions
    sessions=$(_list_sso_sessions)
    
    if [[ -z "$sessions" ]]; then
      echo "No SSO sessions found in ~/.aws/config"
      return 1
    fi
    
    local selected_session
    selected_session=$(echo "$sessions" | fzf)
    
    if [[ -z "$selected_session" ]]; then
      return 1
    fi
    
    echo "Logging in to SSO session: $selected_session"
    aws sso login --sso-session "$selected_session"
    return $?
  fi
  
  # Switch to last used profile
  if [[ $1 == "-" ]]; then
    if [[ ! -f "$ax_history_file" ]]; then
      echo "No previous profile in history"
      return 1
    fi
    local last_profile=$(tail -n 1 "$ax_history_file")
    if [[ -z "$last_profile" ]]; then
      echo "No previous profile in history"
      return 1
    fi
    _switch_to_profile "$last_profile"
    return 0
  fi
  
  # Switch to profile provided as argument
  if [[ -n "$1" ]]; then
    local profile_arg="$1"
    # Validate that the argument is not a flag
    if [[ "$profile_arg" == -* ]]; then
      echo "Unknown option: $profile_arg"
      echo "Usage: ax [PROFILE|-]"
      return 1
    fi
    if ! _has_profile "$profile_arg" && ! ([[ "$profile_arg" == "default" ]] && _has_default_profile); then
      echo "AWS profile \"$profile_arg\" not found"
      return 1
    fi
    _switch_to_profile "$profile_arg"
    return 0
  fi
  
  # List available profiles with fuzzy search
  local profiles
  profiles=$(_get_aws_profiles)
  
  # Also include 'default' profile if it exists
  if _has_default_profile; then
    profiles=$(echo -e "default\n$profiles")
  fi
  
  if [[ -z "$profiles" ]]; then
    echo "No AWS profiles found in ~/.aws/config"
    return 1
  fi

  local selected_profile
  selected_profile=$(echo "$profiles" | fzf)
  
  if [[ -z "$selected_profile" ]]; then
    return 1
  fi
  
  _switch_to_profile "$selected_profile"
  return 0
}
