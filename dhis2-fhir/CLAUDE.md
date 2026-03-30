# Claude Code Guidelines

## Git Commits

- Always run `make lint` before committing (runs ruff, mypy, and pyright)
- Never ignore lint or type errors - fix them properly
- Use conventional commits format: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `perf:`, `test:`
- Never include attribution or Co-Authored-By lines
- Keep commit messages concise and descriptive

## Git Branches

- Use conventional naming: `feat/`, `fix/`, `chore/`, `docs/`, `refactor/` prefixes
- Use kebab-case for branch names (e.g., `feat/add-patient-search`)

## Pull Requests

- Never include attribution lines
- Keep PR descriptions focused on changes and test plan

## Style

- Never use emojis in code, commits, documentation, or any output
- Keep documentation minimal and practical

## Package Management

- Always use `uv` for Python (e.g., `uv sync`, `uv run`, `uv add`)
- Always use `bun` for JavaScript (never npm or node)
- Never use `uv pip` commands

## Feature Development

When adding or updating features:

1. **Lint** - Run `make lint` (ruff, mypy, pyright) before committing
2. **Tests** - Run `make test` (Playwright E2E) and fix any failures
3. **Documentation** - Update docs/ with new features, run `make docs` to verify
4. **Postman** - Update postman/ collection with new API endpoints
5. **Templates** - Use the Edit tool for file changes, never sed via Bash

## Key Make Targets

- `make run` - FastAPI dev server (http://localhost:8000)
- `make seed` - Generate seed patient data
- `make lint` - Ruff + mypy + pyright
- `make test` - Playwright E2E tests
- `make docs` / `make docs-serve` - MkDocs documentation
- `make slides` / `make slides-pdf` - Slidev presentation
- `make docker-sushi` - Compile FSH to FHIR JSON
