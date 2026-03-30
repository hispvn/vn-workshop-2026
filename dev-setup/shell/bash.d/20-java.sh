#!/usr/bin/env bash
# shellcheck disable=SC1091
# ============================================================================
# SDKMAN / Java / Maven Setup
# ============================================================================
# Install: cp 20-java.sh ~/.bash.d/
# Purpose: Initialize SDKMAN (Java version manager), set JVM defaults.
# Prerequisites: curl -s "https://get.sdkman.io" | bash
# ============================================================================

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  source "$SDKMAN_DIR/bin/sdkman-init.sh"
fi

# JVM options
export JAVA_OPTS="-Xmx2048m -Xms2048m"
export MAVEN_OPTS="$JAVA_OPTS"

# JBang
[[ -d "$HOME/.jbang/bin" ]] && export PATH="$HOME/.jbang/bin:$PATH"
