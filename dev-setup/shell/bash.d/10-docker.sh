#!/usr/bin/env bash
# ============================================================================
# Docker Service Launchers
# ============================================================================
# Install: cp 10-docker.sh ~/.bash.d/
# Purpose: One-command ephemeral Docker containers for databases, search
#          engines, message queues, and dev tools. All containers are --rm
#          (auto-removed on stop).
# Prerequisites: docker
# Platform: Cross-platform (Docker abstracts the OS)
# ============================================================================

command -v docker &>/dev/null || return

# Shared helper: runs an ephemeral container with automatic TTY detection.
_docker_service() {
  local name="$1"
  shift
  local tty_flag=""
  [[ -t 0 ]] && tty_flag="-it"
  # shellcheck disable=SC2086
  docker run --name "$name" --rm $tty_flag "$@"
}

# ====================================
# Database Containers
# ====================================

dk-redis() { _docker_service redis -p 6379:6379 redis:latest "$@"; }
dk-mongodb() { _docker_service mongo -p 27017:27017 mongo:latest "$@"; }
dk-mongo() { docker exec -it mongo mongosh "$@"; }

dk-pg() {
  _docker_service pg \
    --platform linux/amd64 \
    -p 15432:5432 \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    postgis/postgis:17-3.5 "$@"
}

dk-mysql() {
  docker run --name mysql --rm \
    -p 3306:3306 \
    -e MYSQL_ROOT_PASSWORD='' -e MYSQL_ALLOW_EMPTY_PASSWORD=yes \
    mysql:8 "$@" &
  trap 'docker stop mysql >/dev/null 2>&1' INT
  wait $!
  trap - INT
}

# ====================================
# Search & Analytics
# ====================================

dk-elastic() {
  _docker_service elastic \
    -p 9200:9200 -p 9300:9300 \
    -e ELASTIC_PASSWORD=elastic \
    docker.elastic.co/elasticsearch/elasticsearch:latest "$@"
}

dk-kibana() {
  _docker_service kibana \
    -p 5601:5601 \
    docker.elastic.co/kibana/kibana:latest "$@"
}

dk-clickhouse() {
  _docker_service clickhouse \
    -p 8123:8123 -p 9000:9000 \
    --ulimit nofile=262144:262144 \
    clickhouse/clickhouse-server:latest "$@"
}

# ====================================
# Message Queues & Infrastructure
# ====================================

dk-rabbit() { _docker_service rabbit -p 15672:15672 -p 5672:5672 rabbitmq:4-management "$@"; }
dk-nginx() { _docker_service nginx -p 8080:8080 nginx:latest "$@"; }

# ====================================
# Object Storage
# ====================================

dk-rustfs() {
  _docker_service rustfs \
    -p 9000:9000 -p 9001:9001 \
    -e RUSTFS_ACCESS_KEY=admin -e RUSTFS_SECRET_KEY=admin \
    rustfs/rustfs:latest "$@"
}

# ====================================
# Authentication & Monitoring
# ====================================

dk-keycloak() {
  _docker_service keycloak \
    -p 9090:8080 \
    -e KEYCLOAK_ADMIN=admin -e KEYCLOAK_ADMIN_PASSWORD=admin \
    quay.io/keycloak/keycloak:latest start-dev "$@"
}

dk-prometheus() { _docker_service prometheus -p 9090:9090 prom/prometheus:latest "$@"; }
dk-grafana() { _docker_service grafana -p 3000:3000 grafana/grafana-enterprise:latest "$@"; }

# ====================================
# Healthcare & FHIR
# ====================================

dk-hapifhir() {
  _docker_service hapifhir \
    -e hapi.fhir.cql_enabled=true \
    -p 8080:8080 \
    hapiproject/hapi:latest "$@"
}

dk-icd11() {
  _docker_service icd11 \
    -p 8888:80 \
    -e acceptLicense=true \
    whoicd/icd-api "$@"
}

# ====================================
# Dev Tools
# ====================================

dk-ubuntu() { _docker_service ubuntu ubuntu:latest "$@"; }

dk-ctop() {
  _docker_service ctop \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    quay.io/vektorlab/ctop:latest "$@"
}

dk-dive() {
  _docker_service dive \
    -v /var/run/docker.sock:/var/run/docker.sock \
    wagoodman/dive:latest "$@"
}

# ====================================
# Maintenance
# ====================================

dk-update() {
  local images
  images="$(docker image ls --format '{{.Repository}}:{{.Tag}}' | grep -v '<none>' | sort -u)"
  if [[ -z "$images" ]]; then
    echo "No local images to update."
    return
  fi
  local count=0 total
  total="$(echo "$images" | wc -l | tr -d ' ')"
  while IFS= read -r image; do
    count=$((count + 1))
    echo "[$count/$total] Pulling $image ..."
    docker pull "$image"
  done <<<"$images"
  echo "Done -- pulled $total images."
}
