# Shell Configuration

A modular bash setup that loads small, focused scripts from `~/.bash.d/`. Each file handles one concern and guards itself — safe to include even if the tool isn't installed.

## How It Works

```
~/.bash_profile          ← Login shell entry point
  ├── locale, OS detection, Homebrew
  ├── SSH agent, core PATH, Rust
  ├── sources ~/.bash.d/*.sh   ← Modular scripts (alphabetical order)
  └── sources ~/.bash_local    ← Your machine-specific overrides (not tracked)

~/.bashrc                ← Non-login shells → sources .bash_profile
```

The `bash.d/` directory uses a **numbered prefix convention** to control load order:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `00-` | Foundation — PATH, environment | `00-path.sh` |
| `01-` | Aliases | `01-aliases.sh` |
| `02-` | Functions | `02-functions.sh` |
| `05-` | Completions | `05-completion.sh` |
| `10-` | Tool configs (Docker, Maven) | `10-docker.sh` |
| `20-` | Language managers & integrations | `20-nvm.sh` |
| `99-` | Prompt (loaded last) | `99-prompt.sh` |

## File Reference

| File | Purpose | Prerequisites |
|------|---------|---------------|
| `bash_profile` | Login shell entry — locale, OS, Homebrew, PATH | None |
| `bashrc` | Non-login shell redirect | None |
| `bash.d/00-gnu.sh` | GNU coreutils on macOS | `brew install coreutils findutils grep gnu-sed gawk gnu-tar` |
| `bash.d/00-path.sh` | EDITOR, VISUAL, Go/Python/Bun paths | None (guards check) |
| `bash.d/01-aliases.sh` | Short aliases (vim, eza, lazygit) | Optional: nvim, eza, lazygit, lazydocker |
| `bash.d/02-functions.sh` | Utility functions (files, system, network, Docker) | Optional: jq, ffmpeg |
| `bash.d/05-completion.sh` | Bash completion framework + tools | `brew install bash-completion@2` |
| `bash.d/10-docker.sh` | One-command Docker service launchers | docker |
| `bash.d/10-java-docker.sh` | Docker-based Java/Maven builds | docker |
| `bash.d/10-maven.sh` | Maven aliases | mvn |
| `bash.d/20-direnv.sh` | Per-directory env vars | `brew install direnv` |
| `bash.d/20-fzf.sh` | Fuzzy finder keybindings | `brew install fzf` |
| `bash.d/20-java.sh` | SDKMAN + JVM options | [SDKMAN](https://sdkman.io) |
| `bash.d/20-nvm.sh` | Node Version Manager | `brew install nvm` |
| `bash.d/20-uv.sh` | Python uv virtualenv activator | `brew install uv` |
| `bash.d/99-prompt.sh` | Starship prompt init | `brew install starship` + Nerd Font |

## Pick Your Level

### Beginner — Better defaults

Copy these for a nicer shell with minimal effort:

```bash
cp bash_profile ~/.bash_profile
cp bashrc ~/.bashrc
mkdir -p ~/.bash.d
cp bash.d/01-aliases.sh ~/.bash.d/
cp bash.d/99-prompt.sh ~/.bash.d/
```

Then install the prompt: `brew install starship` (and a [Nerd Font](https://www.nerdfonts.com/)).

### Intermediate — Productivity boost

Add these on top of the beginner set:

```bash
cp bash.d/00-path.sh ~/.bash.d/
cp bash.d/02-functions.sh ~/.bash.d/
cp bash.d/05-completion.sh ~/.bash.d/
cp bash.d/20-fzf.sh ~/.bash.d/
```

Install: `brew install fzf bash-completion@2`

### Advanced — Full setup

Copy the entire `bash.d/` directory:

```bash
cp bash.d/*.sh ~/.bash.d/
```

Install tools as needed — each file guards itself, so missing tools won't cause errors.

## Key Patterns

All files use consistent patterns documented in [docs/concepts.md](../docs/concepts.md):

- **Guard pattern**: `command -v tool &>/dev/null || return` — skip if tool missing
- **OS detection**: `$DOTFILES_OS` is set to `Darwin` or `Linux` in `bash_profile`
- **Cross-platform blocks**: `case "$DOTFILES_OS" in Darwin) ... Linux) ... esac`
- **Clean variable scope**: `unset` temporary variables after use
