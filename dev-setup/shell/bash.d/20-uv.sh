#!/usr/bin/env bash
# ============================================================================
# Python uv-shell — Virtual Environment Activator
# ============================================================================
# Install: cp 20-uv.sh ~/.bash.d/
# Purpose: Activate a project's uv-managed .venv in the current shell.
#          Walks up directories to find pyproject.toml or .venv.
# Prerequisites: brew install uv  OR  curl -LsSf https://astral.sh/uv/install.sh | sh
# ============================================================================

uv-shell() {
  local want_sync=1
  local stay=0
  local print_only=0
  local proj=""
  local arg

  for arg in "$@"; do
    case "$arg" in
      --project)
        shift
        proj="${1:-}"
        if [[ -z "$proj" ]]; then
          echo "uv-shell: --project requires a path" >&2
          return 2
        fi
        ;;
      --project=*)
        proj="${arg#*=}"
        ;;
      --no-sync) want_sync=0 ;;
      --stay) stay=1 ;;
      --print) print_only=1 ;;
      -h | --help)
        cat <<'EOF'
uv-shell -- activate a uv-managed virtualenv in the current shell

Usage:
  uv-shell [--project DIR] [--no-sync] [--stay] [--print] [--help]

Options:
  --project DIR  Use this directory as the starting point
  --no-sync      Do not create the venv automatically (skip uv sync)
  --stay         Do not cd into the project root
  --print        Print the resolved project root and venv path, then exit
  -h, --help     Show this help
EOF
        return 0
        ;;
      *)
        if [[ -z "$proj" && -d "$arg" ]]; then proj="$arg"; fi
        ;;
    esac
  done

  if ! command -v uv >/dev/null 2>&1; then
    echo "uv-shell: 'uv' not found on PATH" >&2
    return 127
  fi

  local start_dir
  if [[ -n "$proj" ]]; then
    start_dir="$(cd "$proj" 2>/dev/null && pwd -P)" || {
      echo "uv-shell: cannot access '$proj'" >&2
      return 2
    }
  else
    start_dir="$(pwd -P)"
  fi

  local dir="$start_dir"
  while :; do
    if [[ -f "$dir/pyproject.toml" || -d "$dir/.venv" ]]; then
      break
    fi
    if [[ "$dir" == "/" ]]; then
      echo "uv-shell: no project root found from '$start_dir'" >&2
      return 2
    fi
    dir="$(dirname "$dir")"
  done
  local proj_root="$dir"
  local venv_dir="$proj_root/.venv"
  local act="$venv_dir/bin/activate"

  if ((print_only)); then
    printf "project_root=%s\nvenv=%s\n" "$proj_root" "$venv_dir"
    return 0
  fi

  if [[ ! -d "$venv_dir" ]]; then
    if ((want_sync)); then
      echo "uv-shell: creating venv with 'uv sync' in $proj_root ..."
      (cd "$proj_root" && uv sync) || {
        echo "uv-shell: 'uv sync' failed" >&2
        return 1
      }
    else
      echo "uv-shell: venv missing and --no-sync specified" >&2
      return 1
    fi
  fi

  if [[ ! -f "$act" ]]; then
    echo "uv-shell: activate script not found: $act" >&2
    return 1
  fi

  if ((!stay)); then
    cd "$proj_root" || {
      echo "uv-shell: failed to cd '$proj_root'" >&2
      return 1
    }
  fi

  # shellcheck disable=SC1090
  . "$act" || {
    echo "uv-shell: activation failed" >&2
    return 1
  }

  if [[ -n "$VIRTUAL_ENV" ]]; then
    local proj_name
    proj_name="$(basename "$proj_root")"
    PS1="(uv:${proj_name}) ${PS1}"
  fi

  echo "Activated: $(python -V) -- $(which python)"
}

uv-deactivate() {
  if type deactivate >/dev/null 2>&1; then deactivate; else echo "uv-deactivate: no active venv"; fi
}
