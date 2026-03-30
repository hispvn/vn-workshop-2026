# FSH 101

This is the hands-on core of the guide. Each section introduces one FSH (FHIR Shorthand) concept, explains its purpose, walks through its syntax, and provides worked examples that progress from simple to DHIS2-specific scenarios.

## What you will learn

By the end of this chapter you will be able to author:

- **Profiles** that constrain FHIR resources for DHIS2 use cases
- **Extensions** that add custom data elements not present in base FHIR
- **Value Sets and Code Systems** that define controlled terminology
- **Instances** that represent concrete example data
- **Logical Models** that describe non-FHIR data structures like DHIS2 tracker objects
- **Mappings** that document relationships between logical models and FHIR resources
- **RuleSets** that eliminate repetition through reusable rule groups
- **Aliases** that keep your FSH readable with shorthand URIs
- **Invariants** that enforce validation constraints via FHIRPath
- **Slicing** that subdivides repeating elements for precise data capture

## How each section is structured

Every section in this chapter follows the same pattern:

1. **Explanation** -- what the concept is and why it matters
2. **Syntax reference** -- the FSH grammar for the feature
3. **Worked examples** -- multiple FSH code blocks, progressing from simple to complex, using DHIS2-themed examples wherever possible
4. **Generated output** -- the JSON FHIR resource that SUSHI produces (where helpful)
5. **Exercise prompt** -- a pointer to the corresponding exercise in the `exercises/` directory

## Running the examples

All examples in this chapter compile with [SUSHI](https://fshschool.org/docs/sushi/). To try them yourself, place the FSH code in a `.fsh` file inside the `input/fsh/` directory of your project and run:

```bash
sushi .
```

The generated JSON output will appear in the `fsh-generated/` directory. If you have not yet set up your development environment, refer back to the [Development Environment](../ch03-dev-environment/index.md) chapter.

## Exercises

Each section ends with a prompt that directs you to a matching exercise file in the `exercises/` directory. The exercises reinforce the concepts by asking you to write FSH from scratch. Solutions are provided alongside the exercises so you can check your work after attempting the problem on your own.

Let's get started with Profiles.
