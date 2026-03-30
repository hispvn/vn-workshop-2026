.PHONY: help install lint format test docs docs-serve clean benchmark benchmark-quick

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install         Install dependencies"
	@echo "  lint            Run linter and type checker"
	@echo "  format          Auto-format code"
	@echo "  test            Run tests"
	@echo "  docs            Build documentation site"
	@echo "  docs-serve      Serve documentation locally"
	@echo "  benchmark       Full download speed benchmark (WorldPop, CHIRPS, CDS, traceroute)"
	@echo "  benchmark-quick Quick benchmark (1 iteration, skip CDS and full CHIRPS)"
	@echo "  clean           Clean up temporary files"

install:
	uv sync

lint:
	uv run ruff check .
	uv run ruff format --check .
	uv run mypy src/ examples/
	uv run pyright src/ examples/

format:
	uv run ruff check --fix .
	uv run ruff format .

test:
	uv run pytest

docs:
	uv run mkdocs build

docs-serve:
	uv run mkdocs serve

benchmark:
	uv run python examples/benchmark_download_speeds.py --iterations 3

benchmark-quick:
	uv run python examples/benchmark_download_speeds.py --iterations 1 --skip-cds --skip-chirps-full

clean:
	rm -rf site/ .mypy_cache/ .ruff_cache/ .pyright/ __pycache__/ output/

.DEFAULT_GOAL := help
