# Function to recursively clean Maven projects (wrapper or system mvn)
function clean_mvn_projects {
    local dir="$1"
    
    if [[ -f "$dir/mvnw" ]]; then
        echo "Found mvnw in $dir - running './mvnw clean'"
        (cd "$dir" && ./mvnw clean)
        return 0  # Stop recursion once a Maven project is cleaned
    elif [[ -f "$dir/pom.xml" ]]; then
        echo "Found pom.xml in $dir - running 'mvn clean'"
        (cd "$dir" && mvn clean)
        return 0
    fi

    # Recurse into immediate subdirectories only
    find "$dir" -maxdepth 1 -mindepth 1 -type d | while read -r subdir; do
        clean_mvn_projects "$subdir"
    done
}

# Function to recursively clean Gradle projects
function clean_gradle_projects {
    local dir="$1"

    if [[ -f "$dir/gradlew" ]]; then
        echo "Found gradlew in $dir - running './gradlew clean'"
        (cd "$dir" && ./gradlew clean)
        return 0  # Stop recursion once a Gradle project is cleaned
    elif [[ -f "$dir/build.gradle" || -f "$dir/build.gradle.kts" ]]; then
        echo "Found Gradle build file in $dir - running 'gradle clean'"
        (cd "$dir" && gradle clean)
        return 0
    fi

    # Recurse into immediate subdirectories only
    find "$dir" -maxdepth 1 -mindepth 1 -type d | while read -r subdir; do
        clean_gradle_projects "$subdir"
    done
}

# Function to recursively clean Node.js projects
function clean_node_projects {
    local dir="$1"

    # Check if package.json exists in the current directory
    if [[ -f "$dir/package.json" ]]; then
        echo "Found package.json in $dir - cleaning..."

        # Remove node_modules if it exists
        if [[ -d "$dir/node_modules" ]]; then
            echo "  Removing node_modules"
            rm -r "$dir/node_modules"
        fi

        # Optionally remove build artifacts if they exist
        for artifact in dist build; do
            if [[ -d "$dir/$artifact" ]]; then
                echo "  Removing $artifact"
                rm -r "$dir/$artifact"
            fi
        done

        return 0  # Stop recursion once a Node.js project is cleaned
    fi

    # Recursively search immediate subdirectories
    find "$dir" -maxdepth 1 -mindepth 1 -type d | while read -r subdir; do
        clean_node_projects "$subdir"
    done
}

# Nuke developer caches safely, with subcommands
# Usage:
#   nuke [--dry-run] [--force] [targets...]
# Targets:
#   all (default), gradle, maven, npm, android, dotnet, cargo, sonar, openjfx, terraform, ruby, kube, other
# Utilities:
#   list   -> show what each target would remove
#   help   -> show help
#
# Examples:
#   nuke --dry-run maven npm
#   nuke gradle
#   nuke all --force

function nuke() {
  emulate -L zsh
  set -o pipefail

  local DRY=false FORCE=false
  local -a ARGS TARGETS_REQUESTED
  local -A TARGETS

  # Map targets -> space-separated dir globs
  TARGETS=(
    gradle   "$HOME/.gradle/caches $HOME/.gradle/daemon $HOME/.gradle/wrapper"
    maven    "$HOME/.m2/repository $HOME/.m2/wrapper $HOME/.m2/mvnd $HOME/.m2/build-cache"
    npm      "$HOME/.npm/_cacache $HOME/.npm/_logs $HOME/.npm/_locks"
    android  "$HOME/.android/cache"
    dotnet   "$HOME/.nuget/packages $HOME/.nuget/v3-cache $HOME/.nuget/http-cache $HOME/.nuget/plugins-cache $HOME/.local/share/NuGet/v3-cache $HOME/.local/share/NuGet/http-cache $HOME/.local/share/NuGet/plugins-cache"
    cargo    "$HOME/.cargo/registry/cache $HOME/.cargo/registry/index $HOME/.cargo/git"   # avoid nuking ~/.cargo/registry root
    sonar    "$HOME/.sonar/cache"
    openjfx  "$HOME/.openjfx/cache"
    terraform "$HOME/.terraform.d/plugins $HOME/.terraform.d/plugin-cache $HOME/.cdktf/cache"
    ruby     "$HOME/.standard-cache $HOME/.bundle/cache"
    kube     "$HOME/.kube/cache"
    other    "$HOME/.local/share/containers/cache $HOME/.cache/gradle $HOME/.cache/maven $HOME/.cache/npm $HOME/.cache/cargo $HOME/.cache/sonar $HOME/.cache/terraform $HOME/.cache/ruby $HOME/.cache/kube"
  )

  # Parse flags
  for a in "$@"; do
    case "$a" in
      --dry-run) DRY=true ;;
      --force)   FORCE=true ;;
      --)        shift; break ;;
      -*)        echo "Unknown flag: $a" >&2; return 2 ;;
      *)         ARGS+=("$a") ;;
    esac
  done

  # Helpers
  local -a SELECTED
  _print_help() {
    cat <<'EOF'
nuke [--dry-run] [--force] [targets...]

Targets:
  all (default), gradle, maven, npm, android, dotnet, cargo, sonar, openjfx, terraform, ruby, kube, other

Utilities:
  list    Show what each target would remove
  help    Show this help

Flags:
  --dry-run  Preview deletions without removing anything
  --force    Skip confirmation prompt

Examples:
  nuke --dry-run maven npm
  nuke gradle
  nuke all --force
EOF
  }

  _resolve_targets() {
    local t
    if (( ${#ARGS[@]} == 0 )); then
      SELECTED=("all")
    else
      SELECTED=("${ARGS[@]}")
    fi

    # Expand "all" into every real target (skip utilities)
    local -a expanded
    for t in "${SELECTED[@]}"; do
      case "$t" in
        help) _print_help; return 10 ;;
        list)
          echo "Available targets and their cache paths:"
          local k p
          for k in ${(ok)TARGETS}; do
            printf "  %-9s\n" "$k"
            for p in ${(z)TARGETS[$k]}; do
              printf "    - %s\n" "$p"
            done
          done
          return 11
          ;;
        all)
          expanded+=(${(k)TARGETS})
          ;;
        *)
          if [[ -n "${TARGETS[$t]}" ]]; then
            expanded+=("$t")
          else
            echo "Unknown target: $t" >&2
            return 12
          fi
          ;;
      esac
    done
    SELECTED=(${(ou)expanded})  # unique, sorted
    return 0
  }

  _confirm() {
    $FORCE && return 0
    read -q "?Proceed to delete caches for: ${(j:, :)SELECTED}? [y/N] " || { echo; echo "Aborted."; return 1; }
    echo
  }

  _safe_rm() {
    # $@ are candidate paths (may include globs)
    local p real
    for p in "$@"; do
      # Expand globs carefully
      local -a matches
      matches=(${~p}(N))  # (N) = nullglob
      (( ${#matches[@]} )) || continue

      for real in "${matches[@]}"; do
        # Safety guards: only remove inside $HOME
        [[ "$real" == "$HOME" || "$real" == "/" ]] && { echo "SKIP (safety): $real"; continue; }
        [[ "$real" == $HOME/* ]] || { echo "SKIP (outside HOME): $real"; continue; }

        if $DRY; then
          echo "Would remove: $real"
        else
          rm -rf -- "$real" 2>/dev/null && echo "Removed: $real" || echo "Failed:  $real"
        fi
      done
    done
  }

  # Resolve/act on targets
  _resolve_targets; local rc=$?
  case $rc in
    10) return 0 ;;   # help printed
    11) return 0 ;;   # list printed
    12) return 2 ;;   # unknown target
  esac

  # Build path list
  local -a paths
  local t
  for t in "${SELECTED[@]}"; do
    [[ -n "${TARGETS[$t]}" ]] && paths+=(${=TARGETS[$t]})
  done

  if $DRY; then
    echo "🔎 Dry-run: scanning for paths to remove..."
  else
    echo "🔥 Nuking caches for: ${(j:, :)SELECTED}"
  fi

  _confirm || return 1
  _safe_rm "${paths[@]}"
  $DRY && echo "✅ Dry-run complete." || echo "✅ Done."
}