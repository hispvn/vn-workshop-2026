# Dev Setup — Reference Configs

A curated collection of shell and terminal configurations for workshop participants. Browse, pick what you need, and copy it to your home directory.

**No installer. No magic. Just files you can read and copy.**

## What's Here

| Directory | Contents | Start here |
|-----------|----------|------------|
| [`shell/`](shell/index.md) | Modular bash config (`bash_profile` + `bash.d/*.sh`) | [Shell Overview](shell/index.md) |
| [`terminal/`](terminal/index.md) | Starship prompt, tmux, Ghostty configs | [Terminal Overview](terminal/index.md) |

## Quick Start

```bash
# 1. Pick a level (see Shell Overview for details)
#    Beginner: aliases + prompt
#    Intermediate: + functions, completions, fzf
#    Advanced: full bash.d/ set

# 2. Copy what you want
mkdir -p ~/.bash.d
cp shell/bash.d/01-aliases.sh ~/.bash.d/
cp shell/bash.d/99-prompt.sh ~/.bash.d/

# 3. Reload
source ~/.bash_profile
```

## Key Features

- **Modular** — Each `bash.d/` file handles one tool. Add or remove files freely.
- **Safe** — Every script guards with `command -v`. Missing tools are silently skipped.
- **Cross-platform** — Works on macOS and Linux via `$DOTFILES_OS` guards.
- **No dependencies** — The base setup needs nothing installed. Tools are optional.

## Learn More

- [Getting Started](getting-started.md) — Decision guide and setup instructions
- [Concepts](concepts.md) — Guard patterns, cross-platform support, lazy loading
