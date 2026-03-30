#!/usr/bin/env bash
# ============================================================================
# PATH, EDITOR, and Environment Variables
# ============================================================================
# Install: cp 00-path.sh ~/.bash.d/
# Purpose: Set default editor, add language-specific paths (Go, Python, Bun).
# Prerequisites: None (guards check for each tool)
# ============================================================================

# Editor
if command -v nvim &>/dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vi"
fi

export VISUAL="$EDITOR"

# Go
if command -v go &>/dev/null; then
  export GOPATH="$HOME/go"
  [[ -d "$GOPATH/bin" ]] && export PATH="$GOPATH/bin:$PATH"
fi

# Python (Homebrew)
if [[ "$DOTFILES_OS" == "Darwin" ]] && command -v brew &>/dev/null; then
  _py_prefix="$(brew --prefix python@3 2>/dev/null)"
  [[ -d "$_py_prefix/libexec/bin" ]] && export PATH="$_py_prefix/libexec/bin:$PATH"
  unset _py_prefix
fi

# Bun
[[ -d "$HOME/.bun/bin" ]] && export PATH="$HOME/.bun/bin:$PATH"

# Add your own project-specific exports here, e.g.:
# [[ -d "$HOME/.myproject" ]] && export MYPROJECT_HOME="$HOME/.myproject"
