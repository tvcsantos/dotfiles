# Zsh Config – Modular & Shareable

This is a structured, modular **Zsh** configuration designed to be:

- **Shareable** across multiple machines.
- **Easy to maintain** by splitting concerns into small files.
- **Safe** for both scripts and interactive shells.
- **Extensible** for per-OS and per-host customization.

---

## 📂 Folder Structure

```text
.config/zsh/
├─ env/                                   # Environment variables (split by context)
│  ├─ common/                             # Script-safe vars for ALL shells
│  ├─ interactive/                        # Vars for interactive terminals only
│  ├─ login/                              # Vars for GUI/login shells (IntelliJ, VS Code…)
│  ├─ platform/                           # OS + host-specific vars
│  │  ├─ darwin.zsh                       # macOS-wide env
│  │  ├─ linux.zsh                        # Linux-wide env
│  │  └─ host-<hostname>.zsh              # Machine-specific env (any OS)
│  └─ secrets/                            # Git-ignored secrets
│     ├─ common.zsh                       # Common secrets for all shells
│     ├─ interactive.zsh                  # Interactive-only secrets
│     ├─ login.zsh                        # GUI-only secrets
│     ├─ host-<hostname>-common.zsh       # Host-specific secrets for all shells
│     ├─ host-<hostname>-interactive.zsh  # Host-specific secrets for interactive shells
│     └─ host-<hostname>-login.zsh        # Host-specific secrets for login shells
├─ features/                              # Alphabetically ordered tool inits (fzf, rbenv, nvm…)
├─ init/                                  # Runs AFTER OMZ (alphabetically ordered boot)
│  ├─ 00-paths.zsh                        # Final PATH adjustments
│  ├─ 10-env.zsh                          # Post-OMZ env vars (prompt vars, LC_ALL, etc.)
│  ├─ 20-completions.zsh                  # Custom completion functions
│  ├─ 30-keys.zsh                         # Keybindings and bindkey settings
│  ├─ 40-prompt.zsh                       # Prompt init (starship, pure, powerlevel10k…)
│  └─ 90-hooks.zsh                        # preexec/precmd/chpwd hooks
├─ platform/                              # Zsh UX tweaks (aliases, functions, shortcuts)
│  ├─ darwin.zsh                          # macOS-specific shell behavior tweaks
│  ├─ linux.zsh                           # Linux-specific shell behavior tweaks
│  ├─ host-<hostname>.zsh                 # Host-specific shell behavior tweaks
│  ├─ aliases.zsh                         # Global aliases (ls → exa, etc.)
│  └─ tools.zsh                           # Tool command shortcuts and wrappers
└─ pre-omz/                               # Runs BEFORE oh-my-zsh.sh (alphabetically ordered)
   ├─ 00-paths.zsh                        # OMZ path setup
   ├─ 10-env.zsh                          # OMZ env vars (ZSH_THEME, zstyle…)
   └─ 20-plugin-config.zsh                # Plugin-specific vars
```

---

## 📜 Load Order

### 1. `.zshenv` – All Shells (script-safe)

- Minim (alphabetically ordered):
  - `env/common/` (all `.zsh` files)
  - `env/platform/<os>.zsh` (macOS or Linux)
  - `env/platform/host-<hostname>.zsh` (machine-specific)
  - `env/secrets/common.zsh` (shared secrets)
  - `env/platform/host-<hostname>.zsh`

### 2. `.zprofile` – Login Shells (GUI apps)

The following are loaded in order:

- `env/login/` (all `.zsh` files)
- `env/secrets/login.zsh` (login-specific secrets)
- `env/secrets/login-host-<hostname>.zsh` (host-specific login secrets)

### 3. `.zshrc` – Interactive Shells

The following are loaded in order:

- `env/interactive/` (all `.zsh` files, alphabetically)
- `pre-omz/` (alphabetically ordered, before OMZ)
- Oh My Zsh itself
- `init/` (alphabetically ordered, after OMZ)
- `features/` (alphabetically ordered tool inits)
- `platform/aliases.zsh` & `platform/tools.zsh` (global UX tweaks)
- `platform/<os>.zsh` (macOS or Linux-specific tweaks)
- `platform/host-<hostname>.zsh` (machine-specific tweaks)
- `env/secrets/interactive.zsh` (interactive-only secrets)rm/host-\<hostname>.zsh` (UX tweaks)
- `env/secrets/interactive.zsh`

---

Secrets are in `env/secrets/` and **git-ignored**:

- **`common.zsh`** → Loaded by `.zshenv` (available to all shells: scripts, GUI apps, terminals).
- **`login.zsh`** → Loaded by `.zprofile` (GUI apps like IntelliJ, VS Code).
- **`interactive.zsh`** → Loaded by `.zshrc` (interactive terminals only).

Only put secrets in `common.zsh` if they must be available to non-interactive scripts. Otherwise, use `login.zsh` or `interactive.zsh` for better isolation

- `interactive.zsh`: for terminal-only use.
- Do **not** put secrets in `common/` unless they must be available to scripts.

---

## 🌐 Platform & Host Specifics

### `env/platform/*.zsh`

These files contain **environment variables** that differ:

- `darwin.zsh` → macOS-specific vars.
- `linux.zsh` → Alphabetically Ordered Post-OMZ Initialization

Files load in numeric order:

- **00-paths.zsh** → final `$PATH` adjustments (after OMZ potentially modifies it).
- **10-env.zsh** → post-OMZ env vars like `FZF_DEFAULT_OPTS`, `LESS`, `PAGER`

## 🎛 `init/` – Ordered Post-OMZ Initialization

- **00-paths.zsh** → final `$PATH` adjustments (after OMZ potentially modifies it).
- **10-env.zsh** → post-OMZ env vars like `FZF_DEFAULT_OPTS`, `LESS`, `PAGER`.
- **15-tool-config.zsh** → settings for tools (fzf colors, direnv config, bat theme).
- **20-completions.zsh** → load custom completions with `autoload -Uz compinit`.
- **30-keys.zsh** → `bindkey` mappings (history search, vi-mode tweaks).
- **40-prompt.zsh** → init prompt (e.g., `eval "$(starship init zsh)"`).
- **90-hooks.zsh** → Zsh hooks like `preexec`, `precmd`, `chpwd`.

---

## ⚙ `platform/` – Zsh UX Tweaks (Non-Env)

These are **shell behavior changes**, not environment variables:

- **darwin.zsh** → macOS-only shell aliases or behaviors (e.g., use `pbcopy`/`pbpaste`).
- **linux.zsh** → Linux-only shell aliases or behaviors (e.g., `xclip` for clipboard).
- **host-\<hostname\>.zsh** → per-machine tweaks (debug aliases, special tooling).
- **aliases.zsh** → command aliases for all platforms (`ll`, `gs` for git status).
- **tools.zsh** → helper functions/wrappers for CLI tools.

Example `platform/aliases.zsh`:

```zsh
alias ll='ls -lah'
alias gs='git status'
alias k='kubectl'
```

Example `platform/tools.zsh`:

```zsh
# Git wrapper to always show graph
glog() {
  git log --oneline --graph --decorate --all "$@"
}

# Restart docker-compose project
drestart() {
  docker compose down && docker compose up -d
}
```

---

## 🛠 Tips

- Keep files **small** and named logically.
- Use `(N)` nullglob in loops so missing dirs don't error.
- Guard single-file loads with `[[ -r file ]] && source file`.
- Keep `.zshenv` minimal to avoid slowing down scripts.
