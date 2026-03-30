# Exercise 09: Invariants

## Objective

Create FHIRPath invariants that enforce DHIS2-specific validation rules and apply them to a Patient profile.

## Background

Invariants in FHIR are validation rules expressed in FHIRPath (a path-based expression language for FHIR resources). They allow you to enforce constraints that go beyond simple cardinality, such as format requirements, conditional presence rules, and cross-element consistency checks.

In FSH, you define an invariant with a name, severity, human-readable description, and a FHIRPath expression. You then apply it to a specific element in a profile using the `obeys` keyword.

## Requirements

1. Create an invariant named `dhis2-uid-format`:
   - Severity: `error`
   - Description: "DHIS2 UID must be exactly 11 alphanumeric characters"
   - FHIRPath expression: `matches('^[a-zA-Z][a-zA-Z0-9]{10}$')`
   - Note: DHIS2 UIDs start with a letter followed by 10 alphanumeric characters

2. Create an invariant named `dhis2-identifier-has-system`:
   - Severity: `error`
   - Description: "Every identifier must have a system"
   - FHIRPath expression: `system.exists()`

3. Create a profile named `DHIS2PatientWithInvariants` that:
   - Constrains Patient
   - Applies `dhis2-uid-format` to a DHIS2 UID identifier value
   - Applies `dhis2-identifier-has-system` to `identifier`

## Instructions

1. Open `starter.fsh`
2. Define the invariants and apply them to the profile
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
Invariant: invariant-name
Description: "Human-readable description"
Severity: #error | #warning
Expression: "FHIRPath expression"

Profile: ProfileName
Parent: ParentResource
* element obeys invariant-name
```
