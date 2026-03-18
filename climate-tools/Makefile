.PHONY: help install lint format test docs docs-serve clean

help:
	@echo "Usage: make [target]"
	@echo ""
	@echo "Targets:"
	@echo "  install     Install dependencies"
	@echo "  lint        Run linter and type checker"
	@echo "  format      Auto-format code"
	@echo "  test        Run tests"
	@echo "  docs        Build documentation site"
	@echo "  docs-serve  Serve documentation locally"
	@echo "  clean       Clean up temporary files"

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

clean:
	rm -rf site/ .mypy_cache/ .ruff_cache/ .pyright/ __pycache__/

.DEFAULT_GOAL := help
