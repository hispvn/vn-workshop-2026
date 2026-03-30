# Concepts

Patterns and techniques used throughout these configs. Understanding these will help you write your own modular shell setup.

## Guard Patterns

Every script protects itself so it's safe to include even if the required tool isn't installed.

### Tool guard (skip entire file)

```bash
command -v docker &>/dev/null || return
```

The `return` exits the current sourced script without affecting the parent shell. This is the most common pattern — used in `10-docker.sh`, `10-java-docker.sh`, and others.

### Tool guard (wrap a section)

```bash
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash)"
fi
```

Used when the file has multiple independent sections and only some need guarding.

### Directory guard

```bash
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
```

Only modify PATH if the directory actually exists. Keeps `$PATH` clean.

### File guard

```bash
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
```

Only source a file if it exists. Prevents errors on machines where Rust isn't installed.

## Cross-Platform Support

These configs work on both macOS and Linux using a shared `$DOTFILES_OS` variable.

### OS detection (set once in bash_profile)

```bash
DOTFILES_OS="$(uname -s)"
export DOTFILES_OS
# Result: "Darwin" on macOS, "Linux" on Linux
```

### Platform-specific blocks

```bash
case "$DOTFILES_OS" in
  Darwin)
    # macOS-specific code
    ;;
  Linux)
    # Linux-specific code
    ;;
esac
```

Used extensively in `02-functions.sh` for commands that differ between platforms (e.g., `free -h` vs `vm_stat`, clipboard tools, network commands).

### Homebrew path handling

Homebrew installs to different locations depending on the platform and architecture:

```bash
case "$DOTFILES_OS" in
  Darwin)
    # Apple Silicon: /opt/homebrew
    # Intel Mac: /usr/local
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ;;
  Linux)
    # Linuxbrew: /home/linuxbrew/.linuxbrew
    if [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
      eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
    ;;
esac
```

## Modular Loading

The `bash.d/` pattern keeps configurations separate and independently manageable.

### The loader (in bash_profile)

```bash
if [[ -d "$HOME/.bash.d" ]]; then
  for file in "$HOME/.bash.d"/*.sh; do
    [[ -f "$file" && -r "$file" ]] && source "$file"
  done
fi
```

This globs `*.sh` files in alphabetical order, which is why the numeric prefix convention matters:

```
00-gnu.sh          ← Foundation (PATH changes needed by everything)
00-path.sh
01-aliases.sh      ← Use tools set up by 00-*
02-functions.sh
05-completion.sh
10-docker.sh       ← Tool-specific configs
10-java-docker.sh
10-maven.sh
20-direnv.sh       ← Language managers and integrations
20-fzf.sh
20-java.sh
20-nvm.sh
20-uv.sh
99-prompt.sh       ← Prompt last (sees all env changes)
```

### Adding your own

Drop a new `.sh` file in `~/.bash.d/` with an appropriate prefix. It will be picked up automatically on the next shell start.

### Machine-specific overrides

```bash
[[ -f "$HOME/.bash_local" ]] && source "$HOME/.bash_local"
```

`~/.bash_local` is sourced **after** all `bash.d/` scripts. Use it for machine-specific settings, secrets, or overrides you don't want tracked in version control.

## Lazy Loading

Some tools are expensive to initialize. The configs handle this by only loading them when the prerequisite exists.

### SDKMAN (20-java.sh)

```bash
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi
```

Only initializes SDKMAN if the install directory exists and the init script is non-empty (`-s`).

### NVM (20-nvm.sh)

```bash
# Try Homebrew path first, then standalone install
if [[ -s "${HOMEBREW_PREFIX:-}/opt/nvm/nvm.sh" ]]; then
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi
```

Checks two possible install locations — Homebrew-managed and manual install.

## GNU Coreutils on macOS

macOS ships with BSD versions of core tools (`ls`, `grep`, `sed`, etc.) that have different flags than the GNU versions used on Linux. The `00-gnu.sh` script makes GNU versions the default:

```bash
for pkg in coreutils findutils grep gnu-sed gawk gnu-tar; do
  gnubin="$BREW_PREFIX/opt/$pkg/libexec/gnubin"
  [[ -d "$gnubin" ]] && export PATH="$gnubin:$PATH"
done
```

This means scripts written for Linux will work identically on macOS. Homebrew installs GNU tools with a `g` prefix (`gls`, `ggrep`, etc.) — this PATH trick makes the unprefixed names (`ls`, `grep`) point to the GNU versions.

## Variable Hygiene

Temporary variables are cleaned up to avoid polluting the shell environment:

```bash
_py_prefix="$(brew --prefix python@3 2>/dev/null)"
[[ -d "$_py_prefix/libexec/bin" ]] && export PATH="$_py_prefix/libexec/bin:$PATH"
unset _py_prefix
```

Convention: prefix temporary variables with `_` and `unset` them after use.
