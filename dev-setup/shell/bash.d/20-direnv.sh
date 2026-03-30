#!/usr/bin/env bash
# ============================================================================
# direnv — Per-directory Environment Variables
# ============================================================================
# Install: cp 20-direnv.sh ~/.bash.d/
# Purpose: Automatically load/unload environment variables when entering or
#          leaving directories with a .envrc file.
# Prerequisites: brew install direnv
# ============================================================================

if command -v direnv &>/dev/null; then
  eval "$(direnv hook bash)"
fi
