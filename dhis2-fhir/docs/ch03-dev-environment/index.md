# Development Environment

This project is designed so that you need minimal software installed on your machine. All FHIR-specific tooling runs inside a Docker container, keeping your local environment clean and ensuring everyone works with the same tool versions.

## Prerequisites

You need two things installed locally:

- **Docker** -- Runs the FHIR tooling container
- **A text editor** -- VS Code is recommended, with the [FSH language extension](https://marketplace.visualstudio.com/items?itemName=MITRE-Health.vscode-language-fsh) for syntax highlighting

Optionally, install **mdbook** if you want to build and serve this documentation locally:

```bash
# macOS
brew install mdbook

# Or via cargo
cargo install mdbook
```

## The Docker Container

All FHIR compilation and publishing runs through the `ghcr.io/fhir/ig-publisher-localdev` Docker image. This image bundles:

- **SUSHI** -- The FSH compiler that turns `.fsh` files into FHIR JSON
- **IG Publisher** -- The tool that builds a complete, browsable Implementation Guide
- **Java** -- Required by the IG Publisher (already included in the image)
- **Node.js** -- Required by SUSHI (already included in the image)

You do not need to install SUSHI, Java, or Node.js on your machine. The Makefile handles pulling the Docker image and running commands inside it.

## The Makefile

The project includes a Makefile that orchestrates common tasks:

```bash
# Compile FSH files with SUSHI
make sushi

# Build the full Implementation Guide
make ig

# Build and serve the mdbook documentation
make book

# Run SUSHI and then build the IG
make all
```

Each `make` target runs the appropriate Docker command with the correct volume mounts and arguments. You can inspect the Makefile to see exactly what commands are being run.

## Workflow

A typical development workflow looks like this:

1. Edit `.fsh` files in `ig/input/fsh/`
2. Run `make sushi` to compile and check for errors
3. Fix any issues reported by SUSHI
4. Run `make ig` to build the full IG and review it in a browser
5. Edit documentation in `book/` and run `make book` to preview

The fast feedback loop of editing FSH and running SUSHI is one of the key advantages of this setup. SUSHI compilation typically takes just a few seconds.
