# Exercise 01: Profiles

## Objective

Create a DHIS2Patient profile that constrains the FHIR Patient resource for use with DHIS2 Tracked Entity Instances.

## Requirements

Your profile must:

1. Be named `DHIS2Patient` and use `Patient` as its parent resource
2. Set the Id to `dhis2-patient`
3. Include a Title and Description
4. Constrain the following elements:
   - `identifier` -- cardinality `1..*` (at least one identifier is required)
   - `name` -- cardinality `1..*` (at least one name is required)
   - `birthDate` -- cardinality `1..1` (birth date is mandatory)
   - `gender` -- cardinality `1..1` (gender is mandatory)
5. Add `MS` (Must Support) flags to all four constrained elements

## What is Must Support?

The `MS` flag indicates that systems claiming conformance to this profile must be able to populate and/or process these elements. It does not mean the element is required (that is controlled by cardinality), but it signals that the element is important for interoperability.

## Instructions

1. Open `starter.fsh` in your editor
2. Replace each `// TODO` comment with the correct FSH syntax
3. Verify your work by comparing with `solution.fsh`
4. (Optional) Copy your file into the IG's `input/fsh/` directory and run `make docker-sushi` to compile it

## FSH Syntax Reference

```fsh
Profile: ProfileName
Parent: ParentResource
Id: profile-id
Title: "Human-Readable Title"
Description: "A description of the profile."
* element cardinality flags
```

Cardinality examples:
- `* identifier 1..*` -- at least one, no upper limit
- `* birthDate 1..1` -- exactly one
- `* deceased[x] 0..0` -- prohibited (removed from the profile)

Flag examples:
- `MS` -- Must Support
- `?!` -- Is Modifier
- `SU` -- Summary
