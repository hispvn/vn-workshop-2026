# Encounter

The Encounter resource represents an interaction between a patient and a healthcare provider. This can be anything from a brief outpatient visit, to an emergency department stay, to a multi-day hospital admission. Encounters provide temporal context for clinical data -- they answer the question "when and where did this care happen?"

Use an Encounter when you need to group clinical activities (observations, procedures, diagnoses) that occurred during a specific healthcare interaction.

## Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `status` | code | 1..1 | `planned` \| `arrived` \| `triaged` \| `in-progress` \| `onleave` \| `finished` \| `cancelled` (required) |
| `class` | Coding | 1..1 | Classification: AMB (ambulatory), IMP (inpatient), EMER (emergency), HH (home health) |
| `type` | CodeableConcept[] | 0..* | Specific type of encounter (consultation, follow-up, immunization visit) |
| `subject` | Reference(Patient) | 0..1 | The patient present at the encounter |
| `participant` | BackboneElement[] | 0..* | Practitioners involved in the encounter |
| `period` | Period | 0..1 | Start and end time of the encounter |
| `reasonCode` | CodeableConcept[] | 0..* | Coded reason for the encounter |
| `reasonReference` | Reference[] | 0..* | Reference to a Condition or other resource explaining the reason |
| `diagnosis` | BackboneElement[] | 0..* | Diagnoses relevant to this encounter |
| `location` | BackboneElement[] | 0..* | Locations where the encounter took place |
| `serviceProvider` | Reference(Organization) | 0..1 | The organization responsible for the encounter |
| `episodeOfCare` | Reference(EpisodeOfCare)[] | 0..* | Episodes this encounter belongs to |
| `partOf` | Reference(Encounter) | 0..1 | Parent encounter (for nested encounters) |

## Encounter Status Lifecycle

Encounters follow a defined status flow. A typical outpatient visit progresses through:

1. `planned` -- Appointment is scheduled
2. `arrived` -- Patient checks in
3. `in-progress` -- Consultation is underway
4. `finished` -- Visit is complete

Not every encounter goes through all states. A walk-in visit might start at `arrived` or even `in-progress`. The status represents the current state of the encounter, not a history.

## Complete JSON Example

```json
{
  "resourceType": "Encounter",
  "id": "enc-anc-visit-03",
  "status": "finished",
  "class": {
    "system": "http://terminology.hl7.org/CodeSystem/v3-ActCode",
    "code": "AMB",
    "display": "ambulatory"
  },
  "type": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "424441002",
          "display": "Prenatal initial visit"
        }
      ],
      "text": "ANC Visit"
    }
  ],
  "subject": {
    "reference": "Patient/mw-patient-5428",
    "display": "Grace Banda"
  },
  "period": {
    "start": "2024-06-10T08:30:00+02:00",
    "end": "2024-06-10T09:45:00+02:00"
  },
  "reasonCode": [
    {
      "coding": [
        {
          "system": "http://snomed.info/sct",
          "code": "77386006",
          "display": "Pregnancy"
        }
      ]
    }
  ],
  "location": [
    {
      "location": {
        "reference": "Location/area-25-health-centre",
        "display": "Area 25 Health Centre"
      }
    }
  ],
  "serviceProvider": {
    "reference": "Organization/lilongwe-dho",
    "display": "Lilongwe District Health Office"
  }
}
```

This example models an antenatal care (ANC) outpatient visit. The `class` is AMB (ambulatory), the `period` captures the visit window, and `reasonCode` explains why the patient came in. The `location` and `serviceProvider` record where the encounter happened and which organization was responsible.

## Common Patterns and Gotchas

**Class is required in R4.** Even though it looks like a simple coding, `class` is mandatory and must come from the ActCode value set. Use `AMB` for outpatient visits, `IMP` for inpatient stays, and `EMER` for emergency encounters.

**Period vs. status.** The `period` records the actual wall-clock time span. Do not confuse this with status transitions. A `finished` encounter should have both `period.start` and `period.end` populated.

**Nested encounters.** Hospital admissions often contain nested encounters (e.g., a transfer between wards). Use the `partOf` reference to model this hierarchy.

**Linking clinical data.** Observations, Procedures, and Conditions can reference the Encounter they occurred during via their `encounter` element. This is how you associate clinical data with a specific visit.

**Don't overuse Encounter.** Not every interaction needs an Encounter. If you are recording standalone measurements outside the context of a visit, the Observation can exist without an encounter reference.

## Relationship to DHIS2

Encounters map to DHIS2 **Events** within a tracker program. Each event represents a single interaction -- a clinic visit, a data collection point -- that occurred on a specific date at a specific organisation unit. The event date maps to `period`, the organisation unit maps to `location` and `serviceProvider`, and the program stage type informs the encounter `type`. Data values captured during that event become Observation resources that reference this Encounter.
