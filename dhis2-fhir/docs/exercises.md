# Hands-on Exercises

Ten progressive FSH exercises that reinforce the concepts from the learning guide. Each exercise has an **instructions** file, a **starter** template, and a **solution** you can check your work against.

## Getting started

Each exercise lives in `exercises/NN-topic/` with three files:

```
exercises/01-profiles/
  instructions.md   ← read this first
  starter.fsh       ← your starting point
  solution.fsh      ← reference solution
```

**Workflow:**

1. Read `instructions.md` for the requirements
2. Edit `starter.fsh` to complete the exercise
3. Compile with SUSHI to check your work (see below)
4. Compare with `solution.fsh` when done

## Building exercises with SUSHI

To compile and validate your FSH, copy your exercise file into the IG and run SUSHI:

```sh
# Copy your work into the IG
cp exercises/01-profiles/starter.fsh ig/input/fsh/

# Compile with SUSHI (via Docker)
make docker-sushi

# Check for errors in the output
# 0 Errors = your FSH is valid
```

SUSHI will report errors if your FSH has syntax issues or constraint violations. Fix them and re-run until you get `0 Errors`.

## Exercises

### 01 — Profiles

Create a `DHIS2Patient` profile that constrains the FHIR Patient resource for use with DHIS2 Tracked Entity Instances. Learn cardinality (`1..1`, `1..*`) and Must Support flags.

**Concepts:** Profile, Parent, cardinality, MS flag

---

### 02 — Extensions

Create a FHIR extension that captures the DHIS2 Organisation Unit associated with a patient, then apply it to a Patient profile.

**Concepts:** Extension, value[x], applying extensions to profiles

---

### 03 — Value Sets and Code Systems

Create a FHIR CodeSystem representing DHIS2 data element value types, a ValueSet that includes all codes, and bind the ValueSet to a profile element.

**Concepts:** CodeSystem, ValueSet, binding strength (required, extensible)

---

### 04 — Instances

Create example instances of a DHIS2 Patient with realistic data that conform to a DHIS2Patient profile.

**Concepts:** Instance, InstanceOf, Usage (#example), populating fields

---

### 05 — Logical Models

Model a DHIS2 Tracked Entity Instance (TEI) as a FHIR Logical Model using FSH.

**Concepts:** Logical model, custom elements, non-FHIR data structures

---

### 06 — Mappings

Create a formal mapping from the DHIS2 Tracked Entity Instance logical model to the FHIR Patient resource.

**Concepts:** Mapping, source/target, element correspondence

---

### 07 — RuleSets

Create reusable RuleSets that capture common DHIS2 metadata patterns, then apply them to multiple profiles.

**Concepts:** RuleSet, parameterized rules, DRY principle, insert

---

### 08 — Aliases

Define aliases for commonly used DHIS2 and FHIR URIs and use them in profiles and instances.

**Concepts:** Alias, URI shorthand, readability

---

### 09 — Invariants

Create FHIRPath invariants that enforce DHIS2-specific validation rules and apply them to a Patient profile.

**Concepts:** Invariant, FHIRPath expressions, obeys, severity

---

### 10 — Slicing

Slice the `Patient.identifier` element to distinguish between a DHIS2 UID and a national ID.

**Concepts:** Slicing, discriminator, contains, pattern matching
