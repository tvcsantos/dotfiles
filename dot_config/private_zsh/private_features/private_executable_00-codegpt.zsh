# Enable codegpt completion (avoid _ alias conflict)
if command -v codegpt >/dev/null; then
    # Generate completion and modify it to use a different function name
    codegpt completion zsh | sed -e 's/^#compdef /#compdef codegpt/' -e 's/^compdef _ /compdef _codegpt_completion codegpt/' -e 's/^_()/_codegpt_completion()/' | source /dev/stdin
fi
