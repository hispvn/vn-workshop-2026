# SUSHI Configuration

Every SUSHI project requires a `sushi-config.yaml` file at the root of the IG directory. This file tells SUSHI and the IG Publisher how to identify, build, and render your Implementation Guide. Below is a walkthrough of each field, followed by the complete annotated configuration used in this project.

## Configuration Fields

### id

A globally unique identifier for your IG, using reverse-domain notation. This becomes part of every generated artifact's URL and must be stable once published.

### canonical

The base URL for all resources defined in the IG. Every profile, extension, and value set will have a URL that starts with this value. It does not need to resolve to a real server, but by convention it should be a URL your organization controls.

### name

A computable name for the IG, written in PascalCase with no spaces. Tools and registries use this to refer to your IG programmatically.

### title

A human-readable title displayed on the IG's landing page and in the IG registry.

### description

A short summary of the IG's purpose. This appears in metadata listings and the IG registry.

### status

The publication status of the IG. Common values are `draft`, `active`, `retired`, and `unknown`. Use `draft` while developing.

### version

The semantic version of the IG (e.g., `0.1.0`). Increment this each time you publish a new release.

### fhirVersion

The version of the FHIR specification your IG targets. For FHIR R4, this is `4.0.1`.

### publisher

The organization or individual responsible for the IG. Includes `name` and optionally `url` and `email`.

### dependencies

A map of other IGs your project depends on. Each entry specifies the IG's package ID and version. SUSHI will download these packages and make their profiles and extensions available to your FSH code.

### menu

Defines the navigation bar for the generated HTML site. Each key is a label and each value is a relative URL to a page.

### pages

Allows you to specify which pages to include and their order. Useful for adding custom narrative pages beyond the auto-generated ones.

### instanceOptions

Controls how SUSHI handles instances. The `manualSliceOrdering` option, when set to `true`, preserves the order of sliced elements exactly as you write them in FSH.

## Complete Annotated Example

Below is the `sushi-config.yaml` used in this project:

```yaml
# Unique package identifier (reverse-domain style)
id: dhis2.fhir.learning

# Base URL for all conformance resources in this IG
canonical: http://dhis2.org/fhir/learning

# Computable name (PascalCase, no spaces)
name: DHIS2FHIRLearningIG

# Human-readable title shown on the IG landing page
title: DHIS2-FHIR Learning Implementation Guide

# Short description for registries and metadata
description: A learning Implementation Guide for DHIS2-to-FHIR mapping concepts

# Publication status: draft | active | retired | unknown
status: draft

# Semantic version of this IG
version: 0.1.0

# Target FHIR version (R4)
fhirVersion: 4.0.1

# Copyright information
copyrightYear: 2024+
releaseLabel: ci-build
license: CC0-1.0

# Jurisdiction (ISO 3166 country code)
jurisdiction: urn:iso:std:iso:3166#NO "Norway"

# Publisher information
publisher:
  name: DHIS2-FHIR Learning
  url: http://dhis2.org/fhir/learning

# Navigation menu for the HTML site
menu:
  Home: index.html
  Artifacts: artifacts.html

# Instance generation options
instanceOptions:
  manualSliceOrdering: true
```

### Adding dependencies

If your IG depends on another IG (for example, IHE profiles or a national base IG), add a `dependencies` block:

```yaml
dependencies:
  hl7.fhir.uv.ips: 1.1.0
  hl7.fhir.us.core: 6.1.0
```

SUSHI will download these packages automatically and make their profiles available for use as parent profiles in your FSH files.

### Adding pages

To include custom narrative pages (Markdown files in `input/pagecontent/`), list them under `pages`:

```yaml
pages:
  index.md:
    title: Home
  mapping-overview.md:
    title: Mapping Overview
  examples.md:
    title: Examples
```

Each file referenced here should exist in `input/pagecontent/` and will be rendered as an HTML page in the output.

## Validating Your IG

After running SUSHI, always check the terminal output for errors and warnings. SUSHI reports three severity levels:

- **Errors** (red) -- these must be fixed. SUSHI will not generate output for artifacts with errors. Common causes include referencing a profile or extension that does not exist, invalid cardinality syntax, or missing required fields.
- **Warnings** (yellow) -- these should be investigated but do not block generation. Warnings often indicate that SUSHI made an assumption on your behalf, such as inferring a missing `Id` from the resource name, or that a binding strength seems unusual.
- **Info** (blue) -- informational messages, typically safe to ignore. These report things like how many profiles, extensions, and instances were generated.

A clean SUSHI run looks something like this:

```
╔═══════════════════════════════════════════════════╗
║               SUSHI FHIR v3.x.x                  ║
╠═══════════════════════════════════════════════════╣
║    0 Errors    0 Warnings    12 Info              ║
╚═══════════════════════════════════════════════════╝
```

If you see errors, SUSHI prints the file name, line number, and a description of the problem. Fix them and re-run.

### Understanding the fsh-generated/ directory

After a successful SUSHI run, the `fsh-generated/` directory appears inside your IG root. This directory is fully managed by SUSHI -- you should never edit files in it manually, since they will be overwritten on the next run.

```
ig/fsh-generated/
  resources/
    StructureDefinition-dhis2-patient.json       # One file per profile
    StructureDefinition-dhis2-org-unit.json       # One file per extension
    ValueSet-dhis2-program-type-vs.json           # One file per ValueSet
    CodeSystem-dhis2-program-type-cs.json         # One file per CodeSystem
    Patient-PatientExample.json                   # One file per example instance
    Bundle-BundleANCVisitTransaction.json         # Bundle examples
    ...
  includes/
    fsh-link-references.md                        # Auto-generated link targets
```

Key points:

- File names follow the pattern `<ResourceType>-<id>.json`.
- The `resources/` subdirectory contains every artifact SUSHI generated from your FSH.
- The `includes/` subdirectory contains Markdown fragments used by the IG Publisher during HTML rendering.
- You can inspect the generated JSON to verify that your FSH produced the intended structure. This is especially useful for debugging complex slicing or extension definitions.

## Common Errors and Troubleshooting

### Missing dependencies

```
Error: Cannot find package hl7.fhir.uv.ips#1.1.0
```

This means your `sushi-config.yaml` references a dependency that SUSHI cannot download. Check that the package ID and version are correct. SUSHI downloads packages from the FHIR package registry at `packages.fhir.org`. If you are behind a corporate proxy or firewall, you may need to configure your network settings. You can also pre-install packages into the `~/.fhir/packages/` cache manually.

### Invalid canonical URLs

```
Warning: Canonical URL should not end with a trailing slash
```

The `canonical` value in `sushi-config.yaml` should not end with `/`. A trailing slash can cause mismatches when other tools construct URLs by appending path segments. For example, use `http://dhis2.org/fhir/learning` rather than `http://dhis2.org/fhir/learning/`.

Also ensure your canonical URL is a valid absolute URI. Relative URLs and URLs with spaces will cause errors.

### Undefined profile or extension references

```
Error: Could not find definition for DHIS2PatientProfile
```

This usually means you have a typo in a `Parent:`, `InstanceOf:`, or `extension contains` reference. FSH names are case-sensitive. Double-check that the name matches the `Profile:`, `Extension:`, or `Resource:` declaration exactly.

### Circular references

Circular references occur when Profile A has a parent of Profile B, and Profile B has a parent of Profile A (or longer chains). SUSHI will report an error like:

```
Error: Circular dependency detected involving ProfileA
```

Review your `Parent:` declarations to break the cycle. In most cases, one of the profiles should inherit from a base FHIR resource type instead.

### Cardinality and slicing errors

```
Error: Cannot constrain cardinality from 0..* to 2..1
```

Cardinality constraints must narrow (not widen) the parent's cardinality, and the minimum must not exceed the maximum. Common mistakes include writing `2..1` instead of `1..2`, or trying to set `0..*` on an element the parent already constrains to `1..1`.
