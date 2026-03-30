#!/usr/bin/env bash
# ============================================================================
# Core Aliases
# ============================================================================
# Install: cp 01-aliases.sh ~/.bash.d/
# Purpose: Short aliases for common tools. All guarded with `command -v`
#          so they only activate when the tool is installed.
# Prerequisites: Optional — nvim, eza, lazygit, lazydocker
# ============================================================================

# Editor
command -v nvim &>/dev/null && alias vim="nvim"
alias v="vim"

# File listing
command -v eza &>/dev/null && alias ls="eza"

# Git TUI
command -v lazygit &>/dev/null && alias lg="lazygit"

# Docker TUI
command -v lazydocker &>/dev/null && alias ldo="lazydocker"

# macOS-specific
if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  alias of="open ."
  alias ot="open -a Ghostty"
fi
