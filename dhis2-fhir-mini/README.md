# dhis2-fhir-mini

Minimal FHIR Implementation Guide starter project using [FSH (FHIR Shorthand)](https://build.fhir.org/ig/HL7/fhir-shorthand/).

## Prerequisites

- Docker
- [uv](https://docs.astral.sh/uv/) (Python package manager)

## Quick start

```bash
# One-time: build the Docker image
make setup

# Generate example patients (Faker + Jinja2)
make generate

# Compile FSH to FHIR JSON
make sushi

# Full IG build (validation + HTML site)
make build
```

## Project structure

```
Makefile              # All build targets
Dockerfile            # SUSHI + IG Publisher image
generate.py           # Faker/Jinja2 example generator
templates/
  examples.fsh.j2     # Jinja2 template for FSH examples
ig/
  sushi-config.yaml   # IG metadata
  ig.ini              # IG Publisher config
  input/
    fsh/
      patient.fsh     # Patient profile
      examples.fsh    # Generated examples (do not edit)
    pagecontent/
      index.md        # IG landing page
```

## Make targets

| Target     | Description                          |
|------------|--------------------------------------|
| `setup`    | Build the Docker image (one-time)    |
| `generate` | Generate FSH examples from Faker     |
| `sushi`    | Compile FSH to FHIR JSON             |
| `build`    | Full IG build (SUSHI + validation)   |
| `clean`    | Clean generated files                |
| `clean-all`| Clean everything including cache     |
