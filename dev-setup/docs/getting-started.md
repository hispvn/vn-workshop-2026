# Getting Started

This is a reference collection of shell and terminal configurations. Browse what's here, pick what you want, and copy it into your home directory.

**There is no installer.** You are in full control of what goes where.

## Quick Start

### 1. Look around

```
dev-setup/
├── shell/           # Bash config (modular)
│   ├── bash_profile # Main entry point
│   ├── bashrc
│   └── bash.d/      # One file per concern
├── terminal/        # Starship, tmux, Ghostty
└── docs/            # You are here
```

### 2. Pick what you need

**Just want a nicer prompt?**
```bash
brew install starship
brew install --cask font-jetbrains-mono-nerd-font
cp terminal/starship.toml ~/.config/starship.toml
cp shell/bash.d/99-prompt.sh ~/.bash.d/
```

**Want useful aliases and functions?**
```bash
mkdir -p ~/.bash.d
cp shell/bash.d/01-aliases.sh ~/.bash.d/
cp shell/bash.d/02-functions.sh ~/.bash.d/
```

**Want the full modular shell setup?**
```bash
cp shell/bash_profile ~/.bash_profile
cp shell/bashrc ~/.bashrc
mkdir -p ~/.bash.d
cp shell/bash.d/*.sh ~/.bash.d/
```

**Want a terminal config?**
```bash
# Pick one or more:
cp terminal/tmux.conf ~/.tmux.conf
mkdir -p ~/.config/ghostty && cp terminal/ghostty.conf ~/.config/ghostty/config
```

### 3. Reload

```bash
source ~/.bash_profile
```

## Decision Guide

| I want to... | Copy these |
|--------------|------------|
| Get a pretty prompt | `99-prompt.sh` + `starship.toml` |
| Have short aliases (vim, ls, git) | `01-aliases.sh` |
| Use GNU tools on macOS | `00-gnu.sh` |
| Get fuzzy history search (Ctrl-R) | `20-fzf.sh` |
| Spin up Docker databases quickly | `10-docker.sh` |
| Manage Java versions | `20-java.sh` |
| Manage Node versions | `20-nvm.sh` |
| Manage Python virtualenvs | `20-uv.sh` |
| Split my terminal into panes | `tmux.conf` |
| Use tab completion everywhere | `05-completion.sh` |
| Auto-load .env files per directory | `20-direnv.sh` |
| Build Java in Docker (no local JDK) | `10-java-docker.sh` |

## Existing Config?

If you already have a `~/.bash_profile` or `~/.bashrc`:

1. **Back up first**: `cp ~/.bash_profile ~/.bash_profile.backup`
2. **Option A** — Replace it with ours and put your customizations in `~/.bash_local` (sourced automatically at the end of `bash_profile`)
3. **Option B** — Keep yours and just copy individual `bash.d/` files, then add this to the bottom of your existing `.bash_profile`:

```bash
if [[ -d "$HOME/.bash.d" ]]; then
  for file in "$HOME/.bash.d"/*.sh; do
    [[ -f "$file" && -r "$file" ]] && source "$file"
  done
fi
```

## Troubleshooting

**Icons show as squares?**
→ Install a Nerd Font. See [Terminal Overview](terminal/index.md#font-dependency).

**Command not found errors?**
→ Every `bash.d/` script guards its tools with `command -v`. If a tool isn't installed, the script silently skips. Install the tool listed in the file's header.

**Want to override something?**
→ Create `~/.bash_local` — it's sourced last and takes precedence.
