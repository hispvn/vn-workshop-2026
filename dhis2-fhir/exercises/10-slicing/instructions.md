# Exercise 10: Slicing

## Objective

Slice the `Patient.identifier` element to distinguish between a DHIS2 UID and a national ID.

## Background

Slicing is a FHIR profiling mechanism that subdivides a repeating element (like `identifier`, which is `0..*`) into named "slices," each with its own constraints. This lets you say "this patient must have one identifier that is a DHIS2 UID and may have another that is a national ID" -- rather than just "the patient must have at least one identifier."

Slicing requires three things:
1. A **discriminator** that tells validators how to distinguish slices (typically by pattern on a sub-element like `type`)
2. **Slicing rules** (`open`, `closed`, or `openAtEnd`) that control whether additional unsliced values are allowed
3. **Slice definitions** with their own cardinality and constraints

## Requirements

Create a profile named `DHIS2PatientSliced` that:

1. Slices `identifier` using discriminator type `#pattern` on path `type`
2. Sets slicing rules to `#open`
3. Defines two slices:
   - `dhis2uid` (1..1, Must Support):
     - `system` fixed to `http://dhis2.org/fhir/id/tracked-entity`
     - `type` set to `$V2-0203#RI "Resource identifier"`
   - `national` (0..1, Must Support):
     - `type` set to `$V2-0203#NI "National unique individual identifier"`

## Instructions

1. Open `starter.fsh`
2. Set up the slicing discriminator and define both slices
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
* element ^slicing.discriminator.type = #pattern
* element ^slicing.discriminator.path = "subElement"
* element ^slicing.rules = #open
* element contains
    sliceName1 cardinality flags and
    sliceName2 cardinality flags
* element[sliceName1].subElement = "value"
```
