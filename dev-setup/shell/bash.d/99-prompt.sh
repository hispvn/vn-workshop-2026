#!/usr/bin/env bash
# ============================================================================
# Starship Prompt
# ============================================================================
# Install: cp 99-prompt.sh ~/.bash.d/
# Purpose: Initialize the Starship cross-shell prompt. Loaded last (99-)
#          so it can see all environment changes from earlier scripts.
# Prerequisites: brew install starship
#                Also needs a Nerd Font — see terminal/README.md
# ============================================================================

if command -v starship &>/dev/null; then
  eval "$(starship init bash)"
fi
