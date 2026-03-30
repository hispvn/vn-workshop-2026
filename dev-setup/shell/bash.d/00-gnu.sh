#!/usr/bin/env bash
# ============================================================================
# GNU Coreutils on macOS
# ============================================================================
# Install: cp 00-gnu.sh ~/.bash.d/
# Purpose: Use GNU coreutils/findutils/grep/sed/awk instead of macOS BSD
#          variants. Homebrew installs them with a 'g' prefix; this adds
#          the unprefixed versions to PATH.
# Prerequisites: brew install coreutils findutils grep gnu-sed gawk gnu-tar
# Platform: macOS only (guarded)
# ============================================================================

if [[ "$DOTFILES_OS" == "Darwin" ]] && command -v brew &>/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
  for pkg in coreutils findutils grep gnu-sed gawk gnu-tar; do
    gnubin="$BREW_PREFIX/opt/$pkg/libexec/gnubin"
    gnuman="$BREW_PREFIX/opt/$pkg/libexec/gnuman"
    [[ -d "$gnubin" ]] && export PATH="$gnubin:$PATH"
    [[ -d "$gnuman" ]] && export MANPATH="$gnuman:${MANPATH:-}"
  done
  unset BREW_PREFIX gnubin gnuman pkg
fi
