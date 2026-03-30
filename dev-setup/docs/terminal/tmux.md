# tmux

Terminal multiplexer — run multiple terminal sessions in one window with split panes and persistent sessions.

**Install:** `brew install tmux`
**Config:** `cp tmux.conf ~/.tmux.conf`

## Quick Start

```bash
tmux              # Start new session
tmux attach       # Reconnect to existing session
tmux ls           # List sessions
```

## Key Bindings

All tmux commands start with the **prefix key**: `Ctrl-b`

| Keys | Action |
|------|--------|
| `Ctrl-b h` | Split pane horizontally (custom) |
| `Ctrl-b v` | Split pane vertically (custom) |
| `Ctrl-b x` | Close current pane |
| `Ctrl-b r` | Reload config (custom) |
| `Ctrl-b c` | New window |
| `Ctrl-b n` / `p` | Next / previous window |
| `Ctrl-b d` | Detach from session |
| `Ctrl-b [` | Enter scroll mode (q to exit) |

Mouse support is enabled — click to select panes, scroll to browse history.

## This Config

- Mouse enabled
- 256-color terminal
- Status bar: session name, time, user, hostname
- Split with `h`/`v` (instead of `"` and `%`) — opens in current path
- Auto-rename disabled — windows keep the name you set
- Bells silenced
