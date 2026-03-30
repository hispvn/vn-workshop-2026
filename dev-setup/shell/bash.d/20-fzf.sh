#!/usr/bin/env bash
# ============================================================================
# fzf — Fuzzy Finder Integration
# ============================================================================
# Install: cp 20-fzf.sh ~/.bash.d/
# Purpose: Enable fzf keybindings (Ctrl-R for history, Ctrl-T for files,
#          Alt-C for cd) in bash.
# Prerequisites: brew install fzf
# ============================================================================

if command -v fzf &>/dev/null; then
  eval "$(fzf --bash)"
fi
