# Observation

The Observation resource captures measurements, assessments, and findings about a patient. It is one of the most frequently used resources in FHIR, covering everything from simple vital signs (body weight, temperature) to complex laboratory results, survey answers, and clinical assessments.

Use an Observation when you need to record a discrete data point about a patient -- something that was measured, observed, or reported at a specific point in time.

## Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `status` | code | 1..1 | `registered` \| `preliminary` \| `final` \| `amended` \| `cancelled` (required) |
| `category` | CodeableConcept[] | 0..* | Classification: vital-signs, laboratory, social-history, etc. |
| `code` | CodeableConcept | 1..1 | What was observed (e.g., a LOINC code for body weight) |
| `subject` | Reference(Patient) | 0..1 | Who the observation is about |
| `encounter` | Reference(Encounter) | 0..1 | The encounter during which this was observed |
| `effective[x]` | dateTime \| Period | 0..1 | When the observation applies |
| `value[x]` | Quantity \| CodeableConcept \| string \| boolean \| integer \| ... | 0..1 | The result value |
| `interpretation` | CodeableConcept[] | 0..* | High, low, normal, abnormal, etc. |
| `referenceRange` | BackboneElement[] | 0..* | Expected range for the value |
| `component` | BackboneElement[] | 0..* | Sub-observations (e.g., systolic + diastolic in blood pressure) |

## The value[x] Choice Type

The `[x]` notation means this element can take different data types. The actual JSON key changes depending on the type: `valueQuantity`, `valueCodeableConcept`, `valueString`, `valueBoolean`, and so on. A body weight uses `valueQuantity`; an answer like "Yes/No" might use `valueCodeableConcept`.

## Example: Body Weight

```json
{
  "resourceType": "Observation",
  "id": "obs-weight-001",
  "status": "final",
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/observation-category",
          "code": "vital-signs",
          "display": "Vital Signs"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "29463-7",
        "display": "Body weight"
      }
    ]
  },
  "subject": {
    "reference": "Patient/mw-patient-5428"
  },
  "effectiveDateTime": "2024-06-10T09:15:00+02:00",
  "valueQuantity": {
    "value": 62.5,
    "unit": "kg",
    "system": "http://unitsofmeasure.org",
    "code": "kg"
  }
}
```

This is a straightforward single-value observation. The `code` identifies what was measured (LOINC 29463-7 = body weight), `subject` links to the patient, and `valueQuantity` carries the result with proper units.

## Example: Blood Pressure (Multi-Component)

Blood pressure is a classic multi-component observation. Instead of `value[x]` on the root, each component carries its own code and value:

```json
{
  "resourceType": "Observation",
  "id": "obs-bp-001",
  "status": "final",
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/observation-category",
          "code": "vital-signs",
          "display": "Vital Signs"
        }
      ]
    }
  ],
  "code": {
    "coding": [
      {
        "system": "http://loinc.org",
        "code": "85354-9",
        "display": "Blood pressure panel"
      }
    ]
  },
  "subject": {
    "reference": "Patient/mw-patient-5428"
  },
  "effectiveDateTime": "2024-06-10T09:15:00+02:00",
  "component": [
    {
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "8480-6",
            "display": "Systolic blood pressure"
          }
        ]
      },
      "valueQuantity": {
        "value": 120,
        "unit": "mmHg",
        "system": "http://unitsofmeasure.org",
        "code": "mm[Hg]"
      }
    },
    {
      "code": {
        "coding": [
          {
            "system": "http://loinc.org",
            "code": "8462-4",
            "display": "Diastolic blood pressure"
          }
        ]
      },
      "valueQuantity": {
        "value": 80,
        "unit": "mmHg",
        "system": "http://unitsofmeasure.org",
        "code": "mm[Hg]"
      }
    }
  ]
}
```

The parent observation has code "Blood pressure panel" but no `value[x]`. The actual readings live in `component`, each with its own `code` and `valueQuantity`.

## Common Patterns and Gotchas

**Status is required.** Every Observation must have a `status`. Use `final` for completed results, `preliminary` for partial results, and `amended` if a previous final result was corrected.

**Category matters for searching.** Setting `category` to `vital-signs` or `laboratory` allows clients to efficiently filter observations by type. Omitting it makes discovery harder.

**Don't confuse component with hasMember.** Use `component` when sub-values are always reported together (blood pressure). Use `hasMember` (a reference to other Observations) when the parts can exist independently (a lab panel with separate results).

**effective[x] precision.** Use `effectiveDateTime` for a point-in-time measurement. Use `effectivePeriod` when the observation covers a time range (e.g., a 24-hour urine collection).

## Relationship to DHIS2

Observations map to DHIS2 **data values** -- both aggregate data elements and tracker data values captured during program stage events. A DHIS2 data element (e.g., "Weight at visit") with its value becomes an Observation where the data element maps to `code` and the recorded value maps to `value[x]`. The event date corresponds to `effectiveDateTime`, and the tracked entity instance is the `subject`.
