# bash.d Scripts

Each file in `bash.d/` is a self-contained module. They're sourced alphabetically by the loader in `bash_profile`.

## Foundation (00-*)

### 00-gnu.sh — GNU Coreutils on macOS

Adds GNU versions of `ls`, `grep`, `sed`, `awk`, etc. to your PATH so they behave like Linux. Without this, macOS uses BSD variants with different flags.

**Prerequisites:** `brew install coreutils findutils grep gnu-sed gawk gnu-tar`

### 00-path.sh — PATH, EDITOR, VISUAL

Sets your default editor (prefers `nvim`, falls back to `vi`) and adds language-specific paths for Go, Python (Homebrew), and Bun. All guarded.

## Aliases & Functions (01-02)

### 01-aliases.sh — Core Aliases

| Alias | Expands to | Requires |
|-------|-----------|----------|
| `v` | `vim` (or `nvim`) | — |
| `vim` | `nvim` | nvim |
| `ls` | `eza` | eza |
| `lg` | `lazygit` | lazygit |
| `ldo` | `lazydocker` | lazydocker |
| `of` | `open .` | macOS |
| `ot` | `open -a Ghostty` | macOS + Ghostty |

### 02-functions.sh — Utility Functions

Organized by category:

| Function | What it does |
|----------|-------------|
| **File ops** | |
| `dir-make-cd <dir>` | Create directory and cd into it |
| `file-find-large` | Show 10 largest files in current directory |
| `file-extract <file>` | Extract any archive format |
| `file-backup <file>` | Create timestamped backup |
| **System info** | |
| `sys-meminfo` | Memory usage (cross-platform) |
| `sys-diskinfo` | Disk usage |
| `sys-top-cpu` | Top CPU-consuming processes |
| `sys-top-mem` | Top memory-consuming processes |
| `sys-battery` | Battery percentage (cross-platform) |
| `sys-weather [city]` | Weather via wttr.in |
| **Network** | |
| `net-public-ip` | Your public IP |
| `net-local-ip` | Your local IP (cross-platform) |
| `net-speedtest` | Network speed test (macOS 12+) |
| `port-list` | All listening ports |
| `port-of <port>` | What process uses this port |
| `port-kill <port>` | Kill process on a port |
| `http-serve [-p port]` | Simple HTTP server |
| `ssh-copy-key` | Copy SSH public key to clipboard |
| **Docker** | |
| `docker-update` | Pull all local images |
| `docker-cleanup` | Remove stopped containers |
| `docker-prune` | Remove dangling images |
| `docker-ps` | List running containers (clean format) |
| **Dev tools** | |
| `script-create <name>` | Create executable bash script |
| `json-format [file]` | Pretty-print JSON (requires jq) |
| `qr-generate <text>` | Generate QR code in terminal |
| `term-colors` | Display color palette |
| `task-watch <cmd>` | Run command every 5 seconds |
| **Media** | |
| `media-to-gif <video>` | Convert video to GIF (requires ffmpeg) |
| `media-extract-audio <video>` | Extract audio to MP3 (requires ffmpeg) |

## Completions (05-*)

### 05-completion.sh — Bash Completions

Loads the bash-completion framework and adds completions for Rust (rustup, cargo) and GitHub CLI.

**Prerequisites:** `brew install bash-completion@2`

## Tool Configs (10-*)

### 10-docker.sh — Docker Service Launchers

One-command ephemeral containers. All use `--rm` (auto-cleaned on stop).

| Function | Service | Port(s) |
|----------|---------|---------|
| `dk-pg` | PostGIS 17 | 15432 |
| `dk-mysql` | MySQL 8 | 3306 |
| `dk-redis` | Redis | 6379 |
| `dk-mongodb` | MongoDB | 27017 |
| `dk-elastic` | Elasticsearch | 9200, 9300 |
| `dk-kibana` | Kibana | 5601 |
| `dk-clickhouse` | ClickHouse | 8123, 9000 |
| `dk-rabbit` | RabbitMQ | 5672, 15672 |
| `dk-nginx` | nginx | 8080 |
| `dk-rustfs` | RustFS (S3-compatible) | 9000, 9001 |
| `dk-keycloak` | Keycloak | 9090 |
| `dk-prometheus` | Prometheus | 9090 |
| `dk-grafana` | Grafana | 3000 |
| `dk-hapifhir` | HAPI FHIR | 8080 |
| `dk-icd11` | ICD-11 API | 8888 |
| `dk-ubuntu` | Ubuntu shell | — |
| `dk-ctop` | Container top | — |
| `dk-dive` | Image layer explorer | — |
| `dk-update` | Pull all local images | — |

### 10-java-docker.sh — Docker Java/Maven Wrappers

Build Java projects without a local JDK. Mounts your project and Maven cache:

| Function | Image | Use |
|----------|-------|-----|
| `dk-java17` / `dk-java21` / `dk-java25` | Eclipse Temurin | Run Java |
| `dk-mvn17` / `dk-mvn21` / `dk-mvn25` | Eclipse Temurin + Maven | Run Maven |
| `dk-java` / `dk-mvn` | Java 21 (current LTS) | Defaults |

### 10-maven.sh — Maven Aliases

| Alias | Command |
|-------|---------|
| `mci` | `mvn clean install -DskipTests` |
| `mi` | `mvn install -DskipTests` |
| `mct` | `mvn clean test` |
| `mcp` | `mvn clean package` |
| `mcf` | `mvn speedy-spotless:apply` |
| `mcj` | `mvn clean jetty:run` |
| `mj` | `mvn jetty:run` |

## Language Managers & Integrations (20-*)

### 20-direnv.sh

Auto-loads `.envrc` files when you `cd` into a directory. Great for per-project environment variables.

### 20-fzf.sh

Enables fzf keybindings: **Ctrl-R** (history search), **Ctrl-T** (file picker), **Alt-C** (cd to directory).

### 20-java.sh

Initializes [SDKMAN](https://sdkman.io) for managing Java versions. Sets `JAVA_OPTS` and `MAVEN_OPTS` to 2GB heap.

### 20-nvm.sh

Initializes [NVM](https://github.com/nvm-sh/nvm) for managing Node.js versions. Checks both Homebrew and manual install paths.

### 20-uv.sh

Provides `uv-shell` and `uv-deactivate` for activating [uv](https://docs.astral.sh/uv/)-managed Python virtual environments. Walks up directories to find the project root.

## Prompt (99-*)

### 99-prompt.sh

Initializes [Starship](https://starship.rs) prompt. Loaded last so it sees all environment changes from earlier scripts. Requires a Nerd Font for icons.
