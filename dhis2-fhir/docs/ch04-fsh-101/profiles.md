# Profiles

A **profile** constrains an existing FHIR resource to fit a specific use case. When you say "our system requires a patient to always have a name and a birth date," you express that requirement as a profile. Profiles are the most common artifact you will author in FSH and the foundation of any Implementation Guide.

Profiles do not invent new resources. They narrow the rules of an existing resource -- making optional elements required, fixing values, restricting data types, or flagging elements as Must Support. Validators and systems can then enforce these rules automatically.

## Syntax reference

```fsh
Profile:     <name>
Parent:      <base-resource-or-profile>
Id:          <machine-readable-id>
Title:       "<human-readable title>"
Description: "<what this profile is for>"

// Rules
* <path> <cardinality>          // e.g. * name 1..*
* <path> MS                     // Must Support flag
* <path> = <fixed-value>        // Fix a value
* <path> from <ValueSet> (strength)  // Bind terminology
```

Key rule types:

| Rule | Meaning |
|------|---------|
| `1..1` | Exactly one (required, single) |
| `1..*` | At least one (required, repeating) |
| `0..1` | Optional, at most one |
| `0..*` | Optional, repeating (the default for many elements) |
| `0..0` | Prohibited -- the element must not appear |
| `MS` | Must Support |

### Understanding Must Support

The `MS` flag is one of the most misunderstood concepts in FHIR. It is **independent of cardinality** -- it does not make an element required or optional. Instead, it declares an **implementation obligation**:

- **Senders** must be capable of populating the element when the data is available.
- **Receivers** must be able to meaningfully process and store the element -- they cannot silently ignore or drop it.

This distinction matters in practice:

| Declaration | Meaning |
|------------|---------|
| `* name 1..1 MS` | Required **and** must support -- the element must always be present, and systems must handle it |
| `* address 0..1 MS` | Optional **but** must support -- the element may be absent, but if present, systems must handle it |
| `* photo 0..*` | Optional, no MS -- systems may ignore this element entirely |
| `* gender 1..1` | Required but no MS -- must be present, but no explicit implementation obligation (less common) |

The exact meaning of "support" can vary between Implementation Guides. Some IGs like US Core define very specific behaviors (e.g., "must be able to search by this element"). As an IG author, you should document what MS means in your context.

> **Rule of thumb:** Mark an element as MS when you want to tell implementers: "this element is important to our use case -- your system must be able to work with it."

## Example 1: Simple Patient profile

This profile requires that every Patient has at least one name and a birth date.

```fsh
Profile:     SimplePatient
Parent:      Patient
Id:          simple-patient
Title:       "Simple Patient"
Description: "A Patient that must have a name and birth date."

* name 1..* MS
* birthDate 1..1 MS
```

Here `name` is both required (`1..*`) and Must Support -- every Patient must have at least one name, and systems must be able to store and return it. If we had written `* address 0..* MS`, address would be optional but systems would still need to handle it when present.

## Example 2: DHIS2 Patient profile

A more realistic profile for patients originating from DHIS2 Tracker. It requires an identifier (to carry the DHIS2 UID), constrains gender, and marks several elements as Must Support.

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"
Description: "Patient profile for individuals tracked in DHIS2."

* identifier 1..* MS
* identifier.system 1..1
* identifier.value 1..1
* name 1..* MS
* name.family 1..1
* name.given 1..* MS
* gender 1..1 MS
* birthDate 1..1 MS
* address MS
```

This profile guarantees that every DHIS2 Patient carries at least one identifier with both a `system` and `value`, has a structured name with family and given parts, and includes gender and birth date.

## Generated output

When you run `sushi .`, the profile above produces a `StructureDefinition` JSON resource. Here is a simplified excerpt:

```json
{
  "resourceType": "StructureDefinition",
  "id": "dhis2-patient",
  "url": "http://example.org/fhir/StructureDefinition/dhis2-patient",
  "name": "DHIS2Patient",
  "title": "DHIS2 Patient",
  "status": "active",
  "kind": "resource",
  "type": "Patient",
  "baseDefinition": "http://hl7.org/fhir/StructureDefinition/Patient",
  "derivation": "constraint",
  "differential": {
    "element": [
      {
        "id": "Patient.identifier",
        "path": "Patient.identifier",
        "min": 1,
        "mustSupport": true
      },
      {
        "id": "Patient.identifier.system",
        "path": "Patient.identifier.system",
        "min": 1
      },
      {
        "id": "Patient.identifier.value",
        "path": "Patient.identifier.value",
        "min": 1
      },
      {
        "id": "Patient.name",
        "path": "Patient.name",
        "min": 1,
        "mustSupport": true
      },
      {
        "id": "Patient.gender",
        "path": "Patient.gender",
        "min": 1,
        "mustSupport": true
      },
      {
        "id": "Patient.birthDate",
        "path": "Patient.birthDate",
        "min": 1,
        "mustSupport": true
      }
    ]
  }
}
```

Notice how FSH's two-line cardinality rule `* identifier 1..* MS` expands into a full `element` entry with `min`, `max`, and `mustSupport` fields. This is why FSH exists -- it compresses verbose JSON into readable, authorable shorthand.

## Key takeaways

- **Parent** determines which base resource or profile you are constraining.
- **Cardinality** rules tighten (never loosen) what the base allows.
- **MS** is an implementation obligation (systems must handle the element), not a cardinality constraint. An element can be optional (`0..1`) and still be Must Support.
- A profile with no rules is technically valid but not useful.

## Exercise

Open `exercises/ch04-profiles/` and complete the exercise. You will create a profile for an `Encounter` resource that requires a subject reference, a period, and a status. Compare your solution with the provided answer when finished.
