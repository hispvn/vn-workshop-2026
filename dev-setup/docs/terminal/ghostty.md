# Ghostty

A fast GPU-accelerated terminal emulator.

**Install:** Download from [ghostty.org](https://ghostty.org)
**Config:** `mkdir -p ~/.config/ghostty && cp ghostty.conf ~/.config/ghostty/config`

## This Config

| Setting | Value | Why |
|---------|-------|-----|
| `font-family` | JetBrainsMonoNL Nerd Font Mono | Nerd Font for Starship icons |
| `font-size` | 14 | Readable default |
| `theme` | GitHub Dark Default | Dark theme |
| `background-opacity` | 0.9 | Slight transparency |
| `cursor-style` | block, no blink | Less distracting |
| `window-width/height` | 155x45 | Comfortable default size |

## Key Bindings

| Keys | Action |
|------|--------|
| `Cmd+Left` / `Cmd+Right` | Previous / next tab |
| `Shift+Cmd+Left` / `Shift+Cmd+Right` | Move tab left / right |

## Customization

Edit `~/.config/ghostty/config`. See all options with:

```bash
ghostty +list-themes     # Browse available themes
ghostty +show-config     # Show current config with defaults
```

Common tweaks:

```
# Try a different theme
theme = Catppuccin Mocha

# Adjust font size
font-size = 13

# Full opacity
background-opacity = 1.0
```
