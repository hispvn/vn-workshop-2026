#!/usr/bin/env bash
# ============================================================================
# Maven Aliases
# ============================================================================
# Install: cp 10-maven.sh ~/.bash.d/
# Purpose: Short aliases for common Maven build commands.
# Prerequisites: mvn (via SDKMAN or system install)
# ============================================================================

if command -v mvn &>/dev/null; then
  alias mci="mvn clean install -DskipTests=true -DuseWarCompression=false"
  alias mi="mvn install -DskipTests=true -DuseWarCompression=false"
  alias mct="mvn clean test -DuseWarCompression=false"
  alias mcp="mvn clean package"
  alias mcf="mvn speedy-spotless:apply"
  alias mcj="mvn clean jetty:run -DuseWarCompression=false"
  alias mcjj="mvn clean jetty:run-war -DuseWarCompression=false"
  alias mj="mvn jetty:run -DuseWarCompression=false"
  alias mjj="mvn jetty:run-war -DuseWarCompression=false"
fi
