# bash_profile

The main shell entry point, sourced by login shells.

**Install:** `cp bash_profile ~/.bash_profile`

## What It Does

In order:

1. **Locale** — Sets `LANG` and `LC_ALL` to `en_US.UTF-8`
2. **OS detection** — Exports `DOTFILES_OS` (`Darwin` or `Linux`) used by all other scripts
3. **Homebrew** — Initializes Homebrew on macOS (Apple Silicon + Intel) and Linux
4. **SSH agent** — Placeholder for your SSH agent config
5. **Core PATH** — Adds `~/.local/bin` and `~/bin` if they exist
6. **Rust** — Sources `~/.cargo/env` if present
7. **Modular scripts** — Sources all `~/.bash.d/*.sh` files in alphabetical order
8. **Local overrides** — Sources `~/.bash_local` for machine-specific settings

## Key Design Decisions

### Why `DOTFILES_OS`?

Setting this once at the top means every downstream script can branch on platform without calling `uname` repeatedly:

```bash
case "$DOTFILES_OS" in
  Darwin) ... ;;
  Linux)  ... ;;
esac
```

### Why `~/.bash_local`?

Sourced last, it's the escape hatch for anything machine-specific: work credentials, project paths, experimental aliases. It's never tracked in version control.

### Login vs non-login shells

- **Login shell** (`bash --login`, new Terminal.app window): sources `~/.bash_profile`
- **Non-login shell** (subshell, `bash` command): sources `~/.bashrc`

Our `bashrc` simply sources `bash_profile`, so you get the same environment either way.
