DOCKER_IMAGE := fhir-ig
IG_DIR := ig

.PHONY: help setup sushi build clean clean-all

help:              ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

setup:             ## Build the Docker image (one-time setup)
	docker build -t $(DOCKER_IMAGE) .

sushi:             ## Compile FSH to FHIR JSON
	docker run --rm -v $$(pwd)/$(IG_DIR):/home/publisher/ig $(DOCKER_IMAGE) sushi .

build:             ## Build the full IG (SUSHI + validation + HTML)
	docker run --rm -v $$(pwd)/$(IG_DIR):/home/publisher/ig $(DOCKER_IMAGE) \
	  java -Xmx4g -jar /home/publisher/.ig-publisher/publisher.jar ig.ini -ig .

clean:             ## Clean generated files
	rm -rf $(IG_DIR)/fsh-generated $(IG_DIR)/output $(IG_DIR)/temp $(IG_DIR)/template

clean-all: clean   ## Clean everything including input-cache
	rm -rf $(IG_DIR)/input-cache
