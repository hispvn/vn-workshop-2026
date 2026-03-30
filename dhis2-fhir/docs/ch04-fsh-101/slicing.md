# Slicing

**Slicing** subdivides a repeating element into named portions, each with its own constraints. Consider `Patient.identifier`: the base resource says a patient can have zero or more identifiers, but it does not distinguish between a national ID, a DHIS2 UID, and a hospital MRN. Slicing lets you say "there must be exactly one identifier that is a DHIS2 UID, and optionally one that is a national ID," with separate rules for each.

Slicing is one of the most powerful -- and most complex -- features in FHIR profiling. This section breaks it down step by step.

## The three parts of slicing

Every slicing setup involves three components:

1. **Discriminator** -- how the validator tells slices apart (what to look at)
2. **Slicing rules** -- what happens with items that do not match any slice
3. **Slice definitions** -- the individual slices and their constraints

## Discriminator types

The discriminator tells validators which element to examine when sorting items into slices.

| Type | Meaning | Example use |
|------|---------|-------------|
| `value` | Match on the exact value of an element | Slice by `identifier.system` value |
| `pattern` | Match on a pattern (partial match) | Slice by `identifier.type.coding.code` |
| `type` | Match on the data type (for polymorphic elements) | Slice `value[x]` by type |
| `profile` | Match on which profile the element conforms to | Slice `entry.resource` by profile |

## Slicing rules

| Rule | Meaning |
|------|---------|
| `open` | Additional items beyond the defined slices are allowed. |
| `closed` | Only items matching a defined slice are allowed. |
| `openAtEnd` | Additional items are allowed but must appear after the defined slices. |

## Syntax reference

```fsh
// Set up the discriminator
* <element> ^slicing.discriminator.type = #<type>
* <element> ^slicing.discriminator.path = "<path>"
* <element> ^slicing.rules = #<open|closed|openAtEnd>

// Define slices
* <element> contains
    <sliceName1> <cardinality> and
    <sliceName2> <cardinality>

// Constrain each slice
* <element>[<sliceName1>].<child> = <value>
```

## Example 1: Slice Patient.identifier by system value

The most common pattern: distinguish identifiers by their `system` URI.

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"
Description: "Patient with sliced identifiers for DHIS2 UID and national ID."

* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open

* identifier contains
    dhis2Uid 1..1 MS and
    nationalId 0..1 MS

* identifier[dhis2Uid].system = "https://dhis2.org/tracked-entity-instance"
* identifier[dhis2Uid].value 1..1

* identifier[nationalId].system = "https://example.org/national-id"
* identifier[nationalId].value 1..1
```

This profile says:

- There must be exactly one identifier where `system` equals the DHIS2 TEI URI.
- There may optionally be one identifier where `system` equals the national ID URI.
- Other identifiers with different systems are allowed (because slicing rules are `#open`).

## Example 2: Slice by type pattern

Sometimes you discriminate by a CodeableConcept pattern rather than an exact value. This is common for `identifier.type`.

```fsh
Profile:     DHIS2PatientByType
Parent:      Patient
Id:          dhis2-patient-by-type
Title:       "DHIS2 Patient (Type Pattern)"
Description: "Patient with identifiers sliced by type pattern."

* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open

* identifier contains
    dhis2Uid 1..1 and
    nationalId 0..1

* identifier[dhis2Uid].type = http://terminology.hl7.org/CodeSystem/v2-0203#RI "Resource identifier"
* identifier[dhis2Uid].system = "https://dhis2.org/tracked-entity-instance"
* identifier[dhis2Uid].value 1..1

* identifier[nationalId].type = http://terminology.hl7.org/CodeSystem/v2-0203#NI "National unique individual identifier"
* identifier[nationalId].system = "https://example.org/national-id"
* identifier[nationalId].value 1..1
```

With `#pattern` discrimination, the validator checks whether the `type` element contains at least the specified coding. The element may include additional codings.

## Example 3: Slice Observation.component

Slicing applies to any repeating element, not just identifiers. Here, we slice `Observation.component` to require systolic and diastolic blood pressure readings.

```fsh
Profile:     BloodPressureObservation
Parent:      Observation
Id:          blood-pressure-observation
Title:       "Blood Pressure Observation"
Description: "Blood pressure with systolic and diastolic components."

* status MS
* code = http://loinc.org#85354-9 "Blood pressure panel"

* component ^slicing.discriminator.type = #pattern
* component ^slicing.discriminator.path = "code"
* component ^slicing.rules = #closed

* component contains
    systolic 1..1 MS and
    diastolic 1..1 MS

* component[systolic].code = http://loinc.org#8480-6 "Systolic blood pressure"
* component[systolic].value[x] only Quantity
* component[systolic].valueQuantity.unit = "mmHg"
* component[systolic].valueQuantity.system = "http://unitsofmeasure.org"
* component[systolic].valueQuantity.code = #mm[Hg]

* component[diastolic].code = http://loinc.org#8462-4 "Diastolic blood pressure"
* component[diastolic].value[x] only Quantity
* component[diastolic].valueQuantity.unit = "mmHg"
* component[diastolic].valueQuantity.system = "http://unitsofmeasure.org"
* component[diastolic].valueQuantity.code = #mm[Hg]
```

Note `#closed` slicing rules here: no components other than systolic and diastolic are permitted.

## Generated output

The slicing setup for identifier produces differential elements like this (simplified):

```json
{
  "id": "Patient.identifier",
  "path": "Patient.identifier",
  "slicing": {
    "discriminator": [
      {
        "type": "value",
        "path": "system"
      }
    ],
    "rules": "open"
  }
},
{
  "id": "Patient.identifier:dhis2Uid",
  "path": "Patient.identifier",
  "sliceName": "dhis2Uid",
  "min": 1,
  "max": "1",
  "mustSupport": true
},
{
  "id": "Patient.identifier:dhis2Uid.system",
  "path": "Patient.identifier.system",
  "fixedUri": "https://dhis2.org/tracked-entity-instance"
}
```

The `sliceName` field is what distinguishes slices in the JSON output. The discriminator configuration tells validators how to assign incoming data to the correct slice.

## Common mistakes

- **Forgetting the discriminator**: Without it, validators cannot determine which slice an element belongs to.
- **Using `#closed` too aggressively**: This rejects any items beyond your defined slices, which can break interoperability if senders include extra data.
- **Wrong discriminator type**: Use `#value` for exact match on simple types, `#pattern` for CodeableConcept matching. Mixing them up causes validation failures.

## Key takeaways

- Slicing is how you impose structure on repeating elements.
- The discriminator, slicing rules, and slice definitions form a complete slicing setup.
- `#value` discrimination with `system` is the bread-and-butter pattern for identifiers.
- `#pattern` discrimination with `code` is standard for Observation components and categories.
- Always think about whether `#open` or `#closed` is appropriate for your use case.

## Exercise

Open `exercises/ch04-slicing/` and complete the exercise. You will slice `Observation.category` to require a DHIS2-specific category alongside the standard observation category, using pattern discrimination.
