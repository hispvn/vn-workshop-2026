#!/usr/bin/env bash
# ============================================================================
# Utility Functions
# ============================================================================
# Install: cp 02-functions.sh ~/.bash.d/
# Purpose: Reusable shell functions for file ops, system info, networking,
#          Docker, and development tasks. Cross-platform where noted.
# Prerequisites: Optional — jq, ffmpeg, xclip/xsel (Linux clipboard)
# ============================================================================

# ====================================
# File & Directory Operations
# ====================================

# Create and navigate to a directory
dir-make-cd() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: dir-make-cd <directory-name>"
    return 1
  fi
  mkdir -p "$1" && cd "$1" || return
}

# Find large files in the current directory
file-find-large() {
  du -ah . | sort -rh | head -n 10
}

# Extract compressed files (supports most common formats)
file-extract() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: file-extract <file>"
    return 1
  fi
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "Unsupported file type: $1" ;;
  esac
}

# Create timestamped backup of file(s)
file-backup() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: file-backup <file> [file2 ...]"
    return 1
  fi
  local timestamp
  timestamp=$(date +%Y%m%d_%H%M%S)
  for file in "$@"; do
    cp -r "$file" "${file}.${timestamp}.bak"
    echo "Backed up: ${file} -> ${file}.${timestamp}.bak"
  done
}

# ====================================
# System Information
# ====================================

# Show current memory usage (cross-platform)
sys-meminfo() {
  case "$DOTFILES_OS" in
    Darwin)
      vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f Mi\n", "$1:", $2 * $size / 1048576);'
      ;;
    Linux)
      free -h
      ;;
  esac
}

# Check disk usage in human-readable format
sys-diskinfo() {
  df -h
}

# Show top processes consuming CPU
sys-top-cpu() {
  ps -Aceo pid,ppid,comm,%mem,%cpu -r | head -n 6
}

# Show top processes consuming memory
sys-top-mem() {
  ps -Aceo pid,ppid,comm,%mem,%cpu -m | head -n 6
}

# Show battery status (cross-platform)
sys-battery() {
  case "$DOTFILES_OS" in
    Darwin)
      pmset -g batt | grep -Eo "\d+%" | head -1
      ;;
    Linux)
      if [[ -d /sys/class/power_supply/BAT0 ]]; then
        cat /sys/class/power_supply/BAT0/capacity
      else
        echo "No battery found"
      fi
      ;;
  esac
}

# Get weather for location
sys-weather() {
  local location="${1:-}"
  curl -s "wttr.in/${location}?format=3"
}

# ====================================
# Network & Port Management
# ====================================

# Get your public IP address
net-public-ip() {
  curl -s https://api.ipify.org
}

# Get your local IP address (cross-platform)
net-local-ip() {
  case "$DOTFILES_OS" in
    Darwin)
      ipconfig getifaddr en0 || ipconfig getifaddr en1
      ;;
    Linux)
      hostname -I | awk '{print $1}'
      ;;
  esac
}

# Test network speed (macOS-only, guarded)
net-speedtest() {
  if command -v networkQuality &>/dev/null; then
    networkQuality
  else
    echo "networkQuality not available (macOS 12+ only)"
    return 1
  fi
}

# Show all listening ports
port-list() {
  case "$DOTFILES_OS" in
    Darwin)
      sudo lsof -i -P -n | grep LISTEN
      ;;
    Linux)
      ss -tlnp
      ;;
  esac
}

# Find what process is using a specific port
port-of() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: port-of <port>"
    return 1
  fi
  lsof -ti :"$1"
}

# Kill process(es) using specific port(s)
port-kill() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: port-kill <port> [port2 ...]"
    return 1
  fi
  for p in "$@"; do
    lsof -ti ":$p" | xargs -r kill
  done
}

# Start a simple HTTP server in current directory
http-serve() {
  local port=8000 bind="" dir=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -p | --port)
        port="$2"
        shift 2
        ;;
      -b | --bind)
        bind="$2"
        shift 2
        ;;
      -d | --dir)
        dir="$2"
        shift 2
        ;;
      -h | --help)
        echo "Usage: http-serve [-p port] [-b address] [-d directory]"
        echo "  -p, --port  Port to serve on (default: 8000)"
        echo "  -b, --bind  Address to bind to (default: all interfaces)"
        echo "  -d, --dir   Directory to serve (default: current directory)"
        return 0
        ;;
      *)
        port="$1"
        shift
        ;;
    esac
  done
  local args=("$port")
  [[ -n "$bind" ]] && args+=(-b "$bind")
  [[ -n "$dir" ]] && args+=(-d "$dir")
  echo "Serving at http://${bind:-0.0.0.0}:$port"
  python3 -m http.server "${args[@]}"
}

# Copy SSH public key to clipboard (cross-platform)
# Tries key files first, falls back to the SSH agent
ssh-copy-key() {
  local pubkey=""
  if [[ -f ~/.ssh/id_ed25519.pub ]]; then
    pubkey=$(cat ~/.ssh/id_ed25519.pub)
  elif [[ -f ~/.ssh/id_rsa.pub ]]; then
    pubkey=$(cat ~/.ssh/id_rsa.pub)
  else
    pubkey=$(ssh-add -L 2>/dev/null | head -n 1)
  fi

  if [[ -z "$pubkey" ]]; then
    echo "No SSH public key found (no key files and no agent keys)"
    return 1
  fi

  case "$DOTFILES_OS" in
    Darwin) echo "$pubkey" | pbcopy ;;
    Linux)
      if command -v xclip &>/dev/null; then
        echo "$pubkey" | xclip -selection clipboard
      elif command -v xsel &>/dev/null; then
        echo "$pubkey" | xsel --clipboard
      else
        echo "Install xclip or xsel to copy to clipboard"
        echo "$pubkey"
        return
      fi
      ;;
  esac
  echo "SSH public key copied to clipboard"
}

# ====================================
# Docker Utilities
# ====================================

# Update all Docker images
docker-update() {
  docker images | grep -v ^REPO | sed 's/ \+/:/g' | cut -d: -f1,2 | xargs -L1 docker pull
}

# Remove all stopped containers
docker-cleanup() {
  docker container prune -f
}

# Remove all dangling images
docker-prune() {
  docker image prune -f
}

# List all running containers
docker-ps() {
  docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
}

# ====================================
# Development Tools
# ====================================

# Create executable bash script with shebang
script-create() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: script-create <script-name>"
    return 1
  fi
  echo '#!/usr/bin/env bash' >"$1"
  chmod +x "$1"
  echo "Created executable script: $1"
}

# Pretty print JSON (requires jq)
json-format() {
  if ! command -v jq &>/dev/null; then
    echo "jq is not installed"
    return 1
  fi
  if [[ $# -eq 0 ]]; then
    jq '.'
  else
    jq '.' "$1"
  fi
}

# Generate QR code from URL/text
qr-generate() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: qr-generate <text-or-url>"
    return 1
  fi
  curl -s "qrenco.de/$1"
}

# Display terminal color palette
term-colors() {
  for i in {0..255}; do
    printf "\x1b[38;5;%sm%3d " "$i" "$i"
    if (((i + 1) % 16 == 0)); then
      echo
    fi
  done
  echo
}

# Repeatedly run a command every N seconds (default 5)
task-watch() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: task-watch <command>"
    return 1
  fi
  while true; do
    "$@"
    sleep 5
  done
}

# ====================================
# Media Utilities
# ====================================

# Convert video to GIF
media-to-gif() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: media-to-gif <input-video>"
    return 1
  fi
  if ! command -v ffmpeg &>/dev/null; then
    echo "ffmpeg is not installed"
    return 1
  fi
  ffmpeg -i "$1" -vf "fps=10,scale=480:-1:flags=lanczos" -loop 0 "${1%.*}.gif"
  echo "GIF created: ${1%.*}.gif"
}

# Extract audio from video file
media-extract-audio() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: media-extract-audio <video-file>"
    return 1
  fi
  if ! command -v ffmpeg &>/dev/null; then
    echo "ffmpeg is not installed"
    return 1
  fi
  local output="${1%.*}.mp3"
  ffmpeg -i "$1" -vn -acodec libmp3lame -q:a 2 "$output"
  echo "Audio extracted: $output"
}
