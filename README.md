# Dotfiles

A comprehensive chezmoi-based dotfiles repository for managing shell configuration, development tools, and system preferences across macOS and Linux.

## Overview

This repository uses [chezmoi](https://www.chezmoi.io/) to manage dotfiles and configuration files, enabling reproducible development environments across multiple machines. It includes configurations for:

- **Shell**: ZSH with Oh My Zsh
- **Prompt**: Starship
- **Package Management**: Homebrew (macOS)
- **Development Tools**: Kubernetes, SDKMAN, Node (fnm), Python (pyenv), Ruby (rbenv), Go (goenv), Rust (cargo)
- **CLI Enhancements**: fzf, atuin, ax
- **Git**: Multi-profile git configuration (personal/work)

## Quick Start

### Prerequisites

- [chezmoi](https://www.chezmoi.io/install/)
- Git
- macOS or Linux

### Installation

1. **Clone and apply**:

   ```bash
   chezmoi init --apply tvcsantos/dotfiles
   ```

   Or manually:

   ```bash
   chezmoi init https://github.com/tvcsantos/dotfiles.git
   chezmoi apply
   ```

2. **Follow on-screen prompts** for environment setup (Homebrew, Oh My Zsh, tools, packages)

3. **Restart your shell** to load the new configuration:

   ```bash
   exec zsh
   ```

## What Gets Installed

### System Setup (First-Time)

- ✅ Homebrew (macOS)
- ✅ Oh My Zsh
- ✅ Development tools and CLIs
- ✅ Homebrew packages (via Brewfile)

### Configuration Files

- **ZSH**: Complete shell configuration with modular initialization
- **Git**: Personal and work-specific git configurations
- **Starship**: Fast, customizable prompt

### Development Environment Managers

- **fnm**: Fast Node Manager
- **pyenv**: Python version manager
- **rbenv**: Ruby version manager
- **goenv**: Go version manager
- **SDKMAN**: Java and JVM tools manager
- **Cargo**: Rust package manager

### Shell Features & Integrations

- **fzf**: Fuzzy finder for shell commands
- **atuin**: Magical shell history
- **ax**: CLI shortcuts
- **Kubernetes**: kubectl configuration
- **CodeGPT**: AI-powered terminal assistance

## Repository Structure

```text
.
├── Brewfile                          # Homebrew packages (macOS)
├── dot_gitconfig*.tmpl               # Git configurations (templated)
├── dot_zshenv                        # ZSH environment variables
├── run_once_*.sh.tmpl                # First-time setup scripts
│
└── dot_config/
    ├── starship.toml                 # Starship prompt configuration
    └── zsh/
        ├── dot_zprofile              # ZSH login shell initialization
        ├── dot_zshenv                # ZSH environment setup
        ├── dot_zshrc                 # ZSH interactive shell configuration
        │
        ├── env/
        │   ├── common/               # Universal environment setup
        │   ├── interactive/          # Interactive shell setup
        │   ├── login/                # Login shell setup
        │   └── platform/             # Platform-specific (darwin/linux)
        │
        ├── features/                 # Optional tool integrations
        │   ├── *-cargo.zsh
        │   ├── *-chezmoi.zsh
        │   ├── *-fnm.zsh
        │   ├── *-pyenv.zsh
        │   ├── *-rbenv.zsh
        │   ├── *-fzf.zsh
        │   ├── *-atuin.zsh
        │   └── ...
        │
        ├── init/                     # Core initialization
        │   ├── 00-paths.zsh
        │   ├── 10-env.zsh
        │   ├── 20-completions.zsh
        │   ├── 30-keys.zsh
        │   ├── 40-prompt.zsh
        │   └── 90-hooks.zsh
        │
        ├── platform/                 # Platform-specific settings
        │   ├── aliases.zsh
        │   ├── tools.zsh
        │   └── darwin.zsh / linux.zsh
        │
        └── pre-omz/                  # Setup before Oh My Zsh loads
            ├── 00-paths.zsh
            ├── 10-env.zsh
            └── 20-plugin-config.zsh
```

## Customization

### Using Templates

Configuration files use chezmoi's templating system (`.tmpl` extension) to support:

- **Multi-environment setup**: Different configurations for work vs. personal
- **Platform-specific configs**: Separate Darwin (macOS) and Linux setups
- **Dynamic values**: Using chezmoi variables and functions

#### Available Template Variables

Common variables can be set during initialization:

- Git name, email, SSH keys
- Personal vs. work configuration preferences
- Host-specific settings

View and edit templates:

```bash
chezmoi edit-config
```

### Modifying Configurations

1. **Edit locally**:

   ```bash
   chezmoi edit ~/.zshrc
   ```

2. **Review changes**:

   ```bash
   chezmoi diff
   ```

3. **Apply changes**:

   ```bash
   chezmoi apply
   ```

4. **Update the repository**:

   ```bash
   chezmoi cd
   git add .
   git commit -m "Update: ..."
   git push
   ```

### Adding New Files

```bash
chezmoi add ~/.config/newapp/config.toml
```

## Features

### Shell Initialization Order

The ZSH configuration follows a strict loading order:

1. **Pre-Oh My Zsh** (`pre-omz/`): Path and environment setup
2. **Oh My Zsh**: Loaded with plugins
3. **Init** (`init/`): Core initialization (paths, env, completions, keys, prompt, hooks)
4. **Environment** (`env/`): Common and platform-specific setup
5. **Features** (`features/`): Tool integrations (loaded if tools are installed)
6. **Platform** (`platform/`): Platform-specific settings and aliases

### Platform Support

- **macOS (Darwin)**: Full support with Homebrew integration
- **Linux**: Supported with platform-specific configurations

To use Linux-specific setups, ensure the appropriate files in `platform/` are active.

## Usage Examples

### Update dotfiles on a machine

```bash
chezmoi update
```

### Check what would change

```bash
chezmoi diff
```

### Pull the latest and apply immediately

```bash
chezmoi update --apply
```

### Manage a new application config

```bash
chezmoi add ~/.config/myapp/settings.json
cd ~/.local/share/chezmoi
git add dot_config/myapp/settings.json.tmpl
git commit -m "feat: add myapp configuration"
git push
```

## Project Structure Philosophy

- **Modular organization**: Features and environments are separated by directory
- **Numbered prefixes**: Control initialization order (00-*, 10-*, 20-*, etc.)
- **Platform abstraction**: Shared configs with platform-specific overrides
- **Templating**: Support for multiple machines and configurations
- **Automation**: Run-once scripts for reproducible setup

## Troubleshooting

### Changes not appearing after `chezmoi apply`

The shell may be caching configurations. Restart your shell:

```bash
exec zsh
```

### Template variables undefined

Ensure you've run chezmoi initialization with proper values:

```bash
chezmoi init --configure
```

### Check current state

View what chezmoi thinks should be applied:

```bash
chezmoi diff
```

See all templates and their rendered values:

```bash
chezmoi execute-template --init --promptString smartcard=false '{{ .smartcard }}'
```

## Updating and Maintenance

### Pull latest updates

```bash
chezmoi update
```

### Check for differences

```bash
chezmoi diff
```

### Review all templateable values

```bash
chezmoi data
```

## Additional Resources

- [chezmoi Documentation](https://www.chezmoi.io/)
- [chezmoi Quick Start](https://www.chezmoi.io/quick-start/)
- [Oh My Zsh](https://ohmyz.sh/)
- [Starship Prompt](https://starship.rs/)

## License

MIT License - see [LICENSE](LICENSE) for details.
