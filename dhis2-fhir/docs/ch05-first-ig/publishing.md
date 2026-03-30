# Publishing Your Implementation Guide

Publishing an IG is a two-stage process: SUSHI compiles your FSH into FHIR JSON artifacts, and the IG Publisher validates those artifacts and generates a complete HTML website. This section explains each stage and shows you how to run them using the Docker-based toolchain provided by this project.

## Stage 1: SUSHI Compilation (FSH to JSON)

When you run SUSHI, it reads every `.fsh` file in your `input/fsh/` directory, parses the FSH syntax, and generates FHIR JSON resources in the `fsh-generated/` directory. These include:

- **StructureDefinitions** for profiles and extensions
- **CodeSystem** and **ValueSet** resources for terminology
- **Example instances** (Patient, Observation, etc.)
- **Logical models** and **concept maps**

To run SUSHI by itself:

```bash
make docker-sushi
```

This executes the following Docker command under the hood:

```bash
docker run --rm -v $(pwd)/ig:/home/publisher/ig ghcr.io/fhir/ig-publisher-localdev sushi .
```

SUSHI will report any errors or warnings in your FSH. Common issues include references to undefined profiles, incorrect cardinality syntax, and missing required fields. Fix any errors before proceeding to the next stage.

After SUSHI completes, inspect the `ig/fsh-generated/resources/` directory to see the generated JSON files. Each profile, extension, value set, and instance will have its own file.

## Stage 2: IG Publisher (Validation + HTML Generation)

The IG Publisher takes the SUSHI-generated artifacts (along with any hand-written resources and narrative pages) and produces a complete, publishable HTML website. During this process it:

1. **Validates** every resource against the FHIR specification and your IG's own profiles
2. **Generates narrative** (human-readable HTML summaries) for each resource
3. **Builds the HTML site** with navigation, artifact listings, and downloadable packages
4. **Produces a QA report** highlighting any validation errors or warnings

To run the full build:

```bash
make docker-build
```

This executes:

```bash
docker run -it --rm -v $(pwd)/ig:/home/publisher/ig ghcr.io/fhir/ig-publisher-localdev
```

The build can take several minutes the first time, as it downloads the FHIR package cache. Subsequent builds are faster.

## Output Directory Structure

After a successful build, the `ig/output/` directory contains the complete HTML site:

```
ig/output/
  index.html                 # IG landing page
  artifacts.html             # List of all defined artifacts
  StructureDefinition-*.html # One page per profile/extension
  ValueSet-*.html            # One page per value set
  CodeSystem-*.html          # One page per code system
  Patient-*.html             # One page per example instance
  qa.html                    # Quality assurance report
  package.tgz               # Downloadable NPM package of the IG
  definitions.json.zip       # Machine-readable definitions
```

Open `index.html` in a browser to browse the generated IG locally. The `qa.html` page is especially useful -- it lists every validation error and warning, helping you identify and fix issues.

## Iterative Development Workflow

A typical development cycle looks like this:

1. Edit `.fsh` files in `input/fsh/`
2. Run `make docker-sushi` to quickly check for FSH compilation errors
3. Fix any errors and repeat step 2
4. Run `make docker-build` to produce the full HTML output
5. Open `ig/output/qa.html` to review validation results
6. Open `ig/output/index.html` to review the rendered IG

For rapid iteration, use SUSHI alone (step 2) to catch syntax errors quickly, and only run the full IG Publisher when you want to see the rendered HTML or validate against the FHIR spec.

## CI/CD with the Auto-IG-Builder

HL7 provides an automated build service called the [Auto-IG-Builder](https://github.com/nicka/auto-ig-builder) that can build your IG whenever you push to a GitHub repository. To use it:

1. Register your repository with the IG build infrastructure
2. Push your code to GitHub
3. The builder automatically compiles your IG and publishes it to `https://build.fhir.org/ig/<org>/<repo>/`

This gives you a continuously updated, publicly accessible version of your IG. It is the standard way that FHIR IGs are shared during development. For production releases, IGs are typically published through the HL7 FHIR IG registry, but the auto-builder is invaluable during active development for sharing work-in-progress with collaborators and reviewers.

## Understanding IG Publisher Output

### The output/ directory in detail

After a successful `make docker-build`, the `ig/output/` directory contains a complete static HTML website. Here is a more detailed look at what it contains:

```
ig/output/
  index.html                          # IG landing page (rendered from input/pagecontent/index.md)
  artifacts.html                      # Auto-generated list of all profiles, extensions, value sets, examples
  toc.html                            # Table of contents for the full IG

  StructureDefinition-*.html          # One HTML page per profile and extension
  ValueSet-*.html                     # One page per ValueSet (expansion + definition)
  CodeSystem-*.html                   # One page per CodeSystem
  Bundle-*.html                       # One page per Bundle example
  Patient-*.html                      # One page per Patient example
  Observation-*.html                  # One page per Observation example
  Measure-*.html                      # One page per Measure definition
  MeasureReport-*.html                # One page per MeasureReport example

  qa.html                             # Quality Assurance report (validation results)
  qa.min.html                         # Minified QA report

  package.tgz                         # NPM package containing all conformance resources
  definitions.json.zip                # Machine-readable definitions bundle
  expansions.json                     # Pre-expanded ValueSets
  full-ig.zip                         # Complete downloadable IG
```

### The QA report (qa.html)

The QA report is the single most important output for IG development. Open it after every full build. It lists:

- **Errors** -- validation failures that must be fixed. For example, an example instance that does not conform to its declared profile, or a required element that is missing.
- **Warnings** -- issues that should be reviewed but may be acceptable. For example, a code that is not in the preferred ValueSet, or a display value that does not match the code system's definition.
- **Information** -- notes about the build, such as which packages were loaded and how many resources were validated.

The report groups issues by resource, so you can quickly find which FSH file needs attention. Each issue includes the FHIR path (e.g., `Patient.identifier[0].system`) and a description of the problem.

## Common IG Publisher Errors and Fixes

### "Unable to find/resolve resource"

```
UNABLE to find/resolve resource reference: StructureDefinition/dhis2-patient
```

This means a profile, extension, or instance references another artifact that the publisher cannot locate. Common causes:
- The referenced artifact has a typo in its `Id` or canonical URL.
- A dependency IG is missing from `sushi-config.yaml`.
- The SUSHI step failed silently and did not generate the expected JSON file -- always check SUSHI output first.

### "Profile reference could not be resolved"

An example instance declares `meta.profile` pointing to a profile URL that does not exist in the build. Verify the profile URL matches the canonical + `/StructureDefinition/` + the profile's `Id`.

### "Code not in ValueSet"

An instance uses a code that is not a member of the bound ValueSet. Either add the code to the ValueSet/CodeSystem, or change the binding strength to `example` if the code list is intentionally open.

### Slow or hanging builds

The first build downloads the FHIR package cache (several hundred megabytes). If the build seems stuck, it may be downloading packages. Subsequent builds reuse the cache and are significantly faster. If the build is consistently slow, check the number of example instances -- each one is validated against all applicable profiles.

## Docker-Based Workflow Detail

This project uses a custom Docker image to provide a reproducible build environment. The `Dockerfile` at the project root:

```dockerfile
FROM ghcr.io/fhir/ig-publisher-localdev

# Pre-download the IG Publisher JAR so builds don't need to fetch it
RUN mkdir -p /home/publisher/.ig-publisher && \
    curl -L -o /home/publisher/.ig-publisher/publisher.jar \
    "https://github.com/HL7/fhir-ig-publisher/releases/latest/download/publisher.jar"

# Pre-install SUSHI globally
RUN npm install -g fsh-sushi

WORKDIR /home/publisher/ig
```

The base image `ghcr.io/fhir/ig-publisher-localdev` provides Java, Node.js, and the FHIR infrastructure. On top of that, our Dockerfile pre-bakes two things:

1. **publisher.jar** -- the IG Publisher is downloaded at image build time rather than at each run. This avoids re-downloading the 200+ MB JAR file on every build and makes builds faster and reproducible.
2. **SUSHI** -- installed globally via npm so it is available as a command.

Build the Docker image once with:

```bash
make docker-build-image
```

This runs `docker build -t dhis2-fhir-ig .` and produces a local image tagged `dhis2-fhir-ig`.

## The Two-Command Workflow

The Makefile provides two commands that correspond to the two stages of IG development:

### `make docker-sushi` -- Quick compile (seconds)

```bash
docker run --rm -v $(pwd)/ig:/home/publisher/ig dhis2-fhir-ig sushi .
```

This runs only SUSHI. It parses your `.fsh` files and generates JSON in `fsh-generated/`. Use this for rapid iteration when you are writing FSH and want quick feedback on syntax errors, unresolved references, or cardinality problems. It completes in seconds.

**When to use:** After every FSH edit. This is your inner development loop.

### `make docker-build` -- Full validation (minutes)

```bash
docker run --rm -v $(pwd)/ig:/home/publisher/ig dhis2-fhir-ig \
  java -jar /home/publisher/.ig-publisher/publisher.jar ig.ini -ig .
```

This runs the full IG Publisher pipeline: SUSHI compilation, then FHIR validation of every resource, then HTML generation. It produces the complete `output/` directory with the rendered IG and QA report. The first run takes several minutes; subsequent runs are faster because of caching.

**When to use:** Before reviewing the rendered IG, before committing, or when you need to check the QA report for validation errors that SUSHI alone does not catch (such as example instances that do not conform to their profiles).

### Summary

| Command | Runs | Speed | Output | Use for |
|---|---|---|---|---|
| `make docker-sushi` | SUSHI only | Seconds | `fsh-generated/` | FSH syntax checking, rapid iteration |
| `make docker-build` | SUSHI + IG Publisher | Minutes | `fsh-generated/` + `output/` | Full validation, HTML rendering, QA report |
