#!/usr/bin/env bash
# shellcheck disable=SC1091
# ============================================================================
# Node Version Manager (NVM)
# ============================================================================
# Install: cp 20-nvm.sh ~/.bash.d/
# Purpose: Initialize NVM for managing multiple Node.js versions.
# Prerequisites: brew install nvm  OR  https://github.com/nvm-sh/nvm#installing
# ============================================================================

export NVM_DIR="$HOME/.nvm"

# Load NVM -- try Homebrew path first, then standalone install
if [[ -s "${HOMEBREW_PREFIX:-}/opt/nvm/nvm.sh" ]]; then
  source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
  source "$NVM_DIR/nvm.sh"
fi

# Load NVM bash completion
if [[ -s "${HOMEBREW_PREFIX:-}/opt/nvm/etc/bash_completion.d/nvm" ]]; then
  source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
elif [[ -s "$NVM_DIR/bash_completion" ]]; then
  source "$NVM_DIR/bash_completion"
fi
