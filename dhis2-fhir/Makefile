DOCKER_IMAGE := dhis2-fhir-ig
IG_DIR := ig

.PHONY: help docker-build-image docker-sushi docker-build docs docs-serve run seed test lint slides slides-pdf clean clean-all

help:              ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-18s %s\n", $$1, $$2}'

docker-build-image: ## Build the Docker image (includes SUSHI + IG Publisher)
	docker build -t $(DOCKER_IMAGE) .

docker-sushi:      ## Run SUSHI only (compile FSH → JSON)
	docker run --rm -v $$(pwd)/$(IG_DIR):/home/publisher/ig $(DOCKER_IMAGE) sushi .

docker-build:      ## Run full IG Publisher (SUSHI + validation + HTML)
	docker run --rm -v $$(pwd)/$(IG_DIR):/home/publisher/ig $(DOCKER_IMAGE) \
	  java -Xmx4g -jar /home/publisher/.ig-publisher/publisher.jar ig.ini -ig .

run:               ## Run the FHIR resource renderer (http://localhost:8000)
	uv run fastapi dev src/dhis2_fhir/app.py

seed:              ## Generate 100 seed patients in data/
	uv run python -m dhis2_fhir.seed

ips-examples:      ## Regenerate IPS example FSH (55 patients + immunizations)
	python3 $(IG_DIR)/input/fsh/ips/gen_examples.py

lint:              ## Run linters and type checkers
	@echo ">>> Running linter"
	@uv run ruff format .
	@uv run ruff check . --fix
	@echo ">>> Running type checker"
	@uv run mypy --explicit-package-bases src tests
	@uv run pyright

test:              ## Run Playwright end-to-end tests (add --headed to watch in browser)
	uv run pytest tests/ -v $(ARGS)

slides:            ## Run presentation (Slidev)
	cd presentation && bun run dev

slides-pdf:        ## Export presentation to PDF
	cd presentation && bunx slidev export --output slides.pdf

docs:              ## Build documentation (mkdocs)
	uv run mkdocs build

docs-serve:        ## Serve documentation with live reload
	uv run mkdocs serve --open

clean:             ## Clean generated files
	rm -rf $(IG_DIR)/fsh-generated $(IG_DIR)/output $(IG_DIR)/temp $(IG_DIR)/template
	rm -rf site

clean-all: clean   ## Clean everything including input-cache
	rm -rf $(IG_DIR)/input-cache
