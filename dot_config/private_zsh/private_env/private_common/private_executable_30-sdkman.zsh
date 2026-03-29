if [[ -d "$HOME/.sdkman" ]]; then
    export SDKMAN_DIR="$HOME/.sdkman"
    # SDKMAN is lazy loaded via preexec on shell init

    if [[ -d "$SDKMAN_DIR/candidates/java/current" ]]; then
        export JAVA_HOME="$SDKMAN_DIR/candidates/java/current"
        [[ ":$PATH:" == *":$JAVA_HOME/bin:"* ]] || path=("$JAVA_HOME/bin" $path)
    fi
fi
