#!/usr/bin/env bash
# ============================================================================
# Docker Java/Maven Wrappers
# ============================================================================
# Install: cp 10-java-docker.sh ~/.bash.d/
# Purpose: Ephemeral Docker containers for Java/Maven builds — no local JDK
#          required. Persists Maven cache across runs.
# Prerequisites: docker
# Platform: Cross-platform
# ============================================================================

command -v docker &>/dev/null || return

# Common docker run boilerplate for Java/Maven containers.
# Mounts PWD as /workspace, persists Maven cache, runs as host user.
_docker_java() {
  local image="$1"
  shift

  local tty_flag=""
  [[ -t 0 ]] && tty_flag="-it"

  # shellcheck disable=SC2086
  docker run --rm $tty_flag \
    -v "$PWD":/workspace -w /workspace \
    -v "$HOME/.m2":/var/maven/.m2 \
    -e MAVEN_CONFIG=/var/maven/.m2 \
    -e HOME=/var/maven \
    -e MAVEN_OPTS="-Duser.home=/var/maven ${MAVEN_OPTS:--Xmx2048m}" \
    -e JAVA_OPTS="${JAVA_OPTS:--Xmx2048m}" \
    -u "$(id -u):$(id -g)" \
    "$image" "$@"
}

# All wrappers use maven:3-eclipse-temurin-* images (contain both Java and Maven)

# Java
dk-java17() { _docker_java maven:3-eclipse-temurin-17 java "$@"; }
dk-java21() { _docker_java maven:3-eclipse-temurin-21 java "$@"; }
dk-java25() { _docker_java maven:3-eclipse-temurin-25 java "$@"; }

# Maven
dk-mvn17() { _docker_java maven:3-eclipse-temurin-17 mvn "$@"; }
dk-mvn21() { _docker_java maven:3-eclipse-temurin-21 mvn "$@"; }
dk-mvn25() { _docker_java maven:3-eclipse-temurin-25 mvn "$@"; }

# Defaults use current LTS (Java 21)
dk-java() { dk-java21 "$@"; }
dk-mvn() { dk-mvn21 "$@"; }
