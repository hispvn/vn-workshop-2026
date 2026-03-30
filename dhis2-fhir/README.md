# DHIS2-FHIR Learning Guide

A step-by-step learning project for FHIR and FSH (FHIR Shorthand), with a
focus on DHIS2-to-FHIR mapping concepts. Includes a 13-chapter guide,
hands-on exercises, a FastAPI web renderer for FHIR resources, and a
Community Health Registry (CHR) service with FHIR REST API.

## Prerequisites

- Python 3.13+
- [uv](https://docs.astral.sh/uv/) (Python package manager)
- Docker (for the FHIR IG Publisher)

## Quick Start

```sh
# Install dependencies
uv sync

# Generate seed patient data (120 patients + immunizations)
make seed

# Run the web renderer
make run
# → http://localhost:8000
```

## FHIR Implementation Guide

The `ig/` directory contains a full FHIR IG built with SUSHI. To compile
and validate:

```sh
# Build the Docker image (SUSHI + IG Publisher)
make docker-build-image

# Compile FSH → JSON only
make docker-sushi

# Full build: SUSHI + validation + HTML output
make docker-build
```

Output lands in `ig/output/`.

## Learning Guide

A 13-chapter guide (mkdocs + Material theme) covering FHIR fundamentals,
FSH, DHIS2 mapping, IPS profiles, FHIR search, and the CHR service.

```sh
# Serve with live reload
make docs-serve

# Or build static HTML
make docs
```

## Development

```sh
# Run linters and type checkers (ruff, mypy, pyright)
make lint

# Run Playwright end-to-end tests
make test

# Run tests with browser visible
make test ARGS="--headed"
```

## Make Targets

Run `make help` for the full list:

| Target               | Description                                       |
| -------------------- | ------------------------------------------------- |
| `run`                | Run the FHIR resource renderer (localhost:8000)   |
| `seed`               | Generate 120 seed patients in `data/`             |
| `lint`               | Run ruff, mypy, and pyright                       |
| `test`               | Run Playwright end-to-end tests                   |
| `docker-build-image` | Build the Docker image (SUSHI + IG Publisher)     |
| `docker-sushi`       | Compile FSH → JSON                                |
| `docker-build`       | Full IG Publisher build (SUSHI + validation + HTML)|
| `ips-examples`       | Regenerate IPS example FSH                        |
| `docs`               | Build documentation (mkdocs)                      |
| `docs-serve`         | Serve documentation with live reload              |
| `clean`              | Clean generated files                             |
| `clean-all`          | Clean everything including input-cache            |

## Project Structure

```
docs/          Documentation source (13 chapters + glossary)
ig/            FHIR Implementation Guide / SUSHI project
  input/fsh/   FSH profiles, extensions, terminology
exercises/     10 hands-on FSH exercises (starter + solution)
src/dhis2_fhir/
  app.py       FastAPI application and HTML routes
  fhir_api.py  FHIR REST API (Patient, Immunization)
  models.py    Pydantic models for FHIR resources
  store.py     JSON file store for user-created resources
  loader.py    Loads SUSHI-generated and user resources
  seed.py      Seed data generator
templates/     Jinja2 HTML templates
data/          Generated seed data (Patient, Immunization)
tests/         Playwright E2E tests
```
