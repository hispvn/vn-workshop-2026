# Starship

A fast, customizable cross-shell prompt written in Rust.

**Install:** `brew install starship`
**Config:** `cp starship.toml ~/.config/starship.toml`

## What It Shows

- Current directory and git branch/status
- Language versions (Node, Python, Java, etc.) — only when in a project using that language
- Docker context when active
- Green `➜` on success, red `✗` on command failure

## This Config

| Setting | Value | Why |
|---------|-------|-----|
| `add_newline` | `false` | Compact output |
| `command_timeout` | `5000` | Allow slow git repos |
| Git branch symbol | `` | Nerd Font git icon |
| Git staged symbol | `✓` | Clear staged indicator |
| Python symbol | `🐍` | Language context |
| Docker symbol | `🐳` | Container context |

## Customization

Edit `~/.config/starship.toml`. The full config reference is at [starship.rs/config](https://starship.rs/config/).

Common tweaks:

```toml
# Show full path instead of truncated
[directory]
truncation_length = 8

# Disable modules you don't use
[package]
disabled = true

# Change the prompt symbols
[character]
success_symbol = "[❯](bold green)"
```
