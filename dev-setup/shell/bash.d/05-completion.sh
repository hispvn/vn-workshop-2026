#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091
# ============================================================================
# Bash Completions
# ============================================================================
# Install: cp 05-completion.sh ~/.bash.d/
# Purpose: Load bash-completion framework and tool-specific completions.
# Prerequisites: bash-completion (brew install bash-completion@2)
# ============================================================================

# Load bash-completion framework
case "$DOTFILES_OS" in
  Darwin)
    if [[ -r "$(brew --prefix 2>/dev/null)/etc/profile.d/bash_completion.sh" ]]; then
      source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
    fi
    ;;
  Linux)
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
      source /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
      source /etc/bash_completion
    fi
    ;;
esac

# Rustup completions
if command -v rustup &>/dev/null; then
  eval "$(rustup completions bash)"
fi

# Cargo completions
if command -v rustc &>/dev/null; then
  local_cargo_completion="$(rustc --print sysroot)/etc/bash_completion.d/cargo"
  [[ -r "$local_cargo_completion" ]] && source "$local_cargo_completion"
  unset local_cargo_completion
fi

# GitHub CLI completions
if command -v gh &>/dev/null; then
  eval "$(gh completion -s bash)"
fi
