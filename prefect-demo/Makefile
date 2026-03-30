-include .env
export

PREFECT_API_URL ?= http://localhost:4200/api
PREFECT_SERVER_ANALYTICS_ENABLED ?= false
PREFECT_SERVER_UI_SHOW_PROMOTIONAL_CONTENT ?= false

.DEFAULT_GOAL := help

.PHONY: help sync lint check run run-docker start restart block-register block-create clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' Makefile | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

sync: ## Install dependencies
	uv sync

lint: ## Auto-format, fix lint errors, and type-check
	uv run ruff format .
	uv run ruff check --fix .
	uv run mypy deployments/ packages/
	uv run pyright

check: ## Check formatting, linting, and types (read-only, same as CI)
	uv run ruff format --check .
	uv run ruff check .
	uv run mypy deployments/ packages/
	uv run pyright

run: ## Run basics flow locally (no server needed)
	PREFECT_API_URL= uv run python -c "from deployments.basics.flow import basics_flow; basics_flow()"

run-docker: ## Run parallel flow as a standalone Docker container (needs server running)
	docker build -t parallel -f deployments/parallel/Dockerfile .
	docker run --rm -e PREFECT_API_URL=http://host.docker.internal:4200/api parallel

start: ## Start Prefect stack with Docker (PostgreSQL + Server + deployments)
	docker compose up --build

restart: ## Tear down, rebuild, and start the Docker stack from scratch
	docker compose down -v && docker compose build --no-cache && docker compose up

block-register: ## Register custom block types with Prefect server
	uv run prefect block register -m prefect_dhis2

block-create: ## Create DHIS2 credentials block with default play-server values
	uv run python -c "from prefect_dhis2 import Dhis2Credentials; Dhis2Credentials().save('dhis2', overwrite=True); print('Block dhis2 saved')"

clean: ## Remove build artifacts and caches
	rm -rf __pycache__ .mypy_cache .pytest_cache .ruff_cache
	find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
