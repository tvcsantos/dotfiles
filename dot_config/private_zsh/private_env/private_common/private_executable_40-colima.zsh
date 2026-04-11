# Use Colima’s Docker on this Mac
if command -v colima >/dev/null 2>&1; then

  # Only set if Colima's socket exists (avoids breaking when it's not running)
  if [ -S "$HOME/.colima/default/docker.sock" ]; then
    export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
  elif [ -S "$XDG_CONFIG_HOME/colima/default/docker.sock" ]; then
    export DOCKER_HOST="unix://${XDG_CONFIG_HOME}/colima/default/docker.sock"
  fi

  # Testcontainers: use the real Docker socket directly, disable Ryuk locally
  # (Change if you prefer Ryuk enabled)
  [ -S /var/run/docker.sock ] && export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
  export TESTCONTAINERS_RYUK_DISABLED=true
fi

# Set the host to the Docker Desktop socket
#export DOCKER_HOST=unix://$HOME/.docker/run/docker.sock

# For some 1.x versions, this extra hint helps Ryuk (the reaper)
#export TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock
