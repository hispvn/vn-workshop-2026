# Terminal Tools

Configuration files for the terminal emulator, prompt, and multiplexer.

## Files

| File | Tool | Install Path | Purpose |
|------|------|-------------|---------|
| `starship.toml` | [Starship](https://starship.rs) | `~/.config/starship.toml` | Cross-shell prompt with git, language, and Docker context |
| `tmux.conf` | [tmux](https://github.com/tmux/tmux) | `~/.tmux.conf` | Terminal multiplexer — split panes, persistent sessions |
| `ghostty.conf` | [Ghostty](https://ghostty.org) | `~/.config/ghostty/config` | GPU-accelerated terminal emulator |

## Install

```bash
# Starship prompt
brew install starship
mkdir -p ~/.config
cp starship.toml ~/.config/starship.toml

# tmux
brew install tmux
cp tmux.conf ~/.tmux.conf

# Ghostty — download from https://ghostty.org
mkdir -p ~/.config/ghostty
cp ghostty.conf ~/.config/ghostty/config
```

## Font Dependency

Both Starship and Ghostty expect a **Nerd Font** for icons and symbols. Without one, you'll see placeholder squares instead of git branch icons, language symbols, etc.

### Install a Nerd Font

```bash
# Option 1: Homebrew (recommended)
brew install --cask font-jetbrains-mono-nerd-font

# Option 2: Download manually from https://www.nerdfonts.com/font-downloads
# Pick "JetBrainsMono Nerd Font" (or any Nerd Font you prefer)
```

After installing, set the font in your terminal:

- **Ghostty**: Already configured in `ghostty.conf` (`font-family = "JetBrainsMonoNL Nerd Font Mono"`)
- **iTerm2**: Preferences → Profiles → Text → Font
- **Terminal.app**: Preferences → Profiles → Font → Change
- **VS Code terminal**: Settings → `terminal.integrated.fontFamily` → `"JetBrainsMono Nerd Font"`

### Linux

```bash
# Download and install to local fonts directory
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLO https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
tar xf JetBrainsMono.tar.xz
fc-cache -fv
```

See also: [Starship](starship.md) | [tmux](tmux.md) | [Ghostty](ghostty.md)
