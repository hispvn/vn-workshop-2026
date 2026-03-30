# EpisodeOfCare

The EpisodeOfCare resource represents an ongoing association between a patient and a healthcare organization for a specific condition or purpose. Unlike an Encounter, which models a single visit, an EpisodeOfCare spans an entire care journey -- from the moment a patient is enrolled in a program until they are discharged or the care period ends.

Use an EpisodeOfCare when you need to represent a patient's enrollment in a care program over time, grouping multiple encounters and activities under a single umbrella.

## Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `status` | code | 1..1 | `planned` \| `waitlist` \| `active` \| `onhold` \| `finished` \| `cancelled` (required) |
| `type` | CodeableConcept[] | 0..* | The type of care or program (e.g., antenatal care, TB treatment) |
| `patient` | Reference(Patient) | 1..1 | The patient enrolled in this episode |
| `managingOrganization` | Reference(Organization) | 0..1 | Organization managing this episode |
| `period` | Period | 0..1 | Start and end dates of the episode |
| `diagnosis` | BackboneElement[] | 0..* | Diagnoses relevant to this episode |
| `team` | Reference(CareTeam)[] | 0..* | Care team assigned to this episode |
| `referralRequest` | Reference(ServiceRequest)[] | 0..* | Referrals that initiated this episode |

## EpisodeOfCare vs. Encounter

This distinction is crucial:

- **EpisodeOfCare** is the overarching enrollment -- "Grace is enrolled in the ANC program from January to September 2024."
- **Encounter** is a single visit within that episode -- "Grace came for her third ANC visit on June 10."

An Encounter references the EpisodeOfCare it belongs to via its `episodeOfCare` element. One EpisodeOfCare typically contains multiple Encounters.

## Complete JSON Example

```json
{
  "resourceType": "EpisodeOfCare",
  "id": "eoc-anc-enrollment-5428",
  "status": "active",
  "type": [
    {
      "coding": [
        {
          "system": "http://dhis2.org/program",
          "code": "ANC",
          "display": "Antenatal Care Program"
        }
      ],
      "text": "Antenatal Care"
    }
  ],
  "patient": {
    "reference": "Patient/mw-patient-5428",
    "display": "Grace Banda"
  },
  "managingOrganization": {
    "reference": "Organization/area-25-health-centre",
    "display": "Area 25 Health Centre"
  },
  "period": {
    "start": "2024-01-15"
  },
  "diagnosis": [
    {
      "condition": {
        "reference": "Condition/pregnancy-5428"
      },
      "role": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/diagnosis-role",
            "code": "CC",
            "display": "Chief complaint"
          }
        ]
      },
      "rank": 1
    }
  ]
}
```

This episode represents a patient enrolled in an antenatal care program. The status is `active` (she is currently receiving care), the period has a start date but no end date (still ongoing), and the diagnosis links to a Condition resource describing the pregnancy. The managing organization is the health centre where she enrolled.

## Status Lifecycle

The status tells you where in the lifecycle this episode sits:

1. `planned` -- The enrollment is anticipated but has not started
2. `waitlist` -- The patient is waiting to begin
3. `active` -- Care is being provided
4. `onhold` -- Temporarily paused (e.g., patient relocated)
5. `finished` -- The care episode is complete
6. `cancelled` -- The episode was cancelled before it began

A typical program enrollment moves from `planned` to `active` to `finished`. The `period.end` should be populated when the status becomes `finished`.

## Common Patterns and Gotchas

**Patient is required.** Unlike many resources, `patient` has a cardinality of 1..1 -- every EpisodeOfCare must reference a patient.

**Open-ended periods.** When a patient is still enrolled, `period.start` is set but `period.end` is absent. Do not set `period.end` to a future date as a placeholder -- leave it empty until the episode actually ends.

**Linking encounters.** The Encounter resource has an `episodeOfCare` element that points back to the EpisodeOfCare. This is how you associate individual visits with the overarching enrollment. The EpisodeOfCare itself does not list its encounters.

**Multiple episodes.** A patient can have multiple active episodes simultaneously -- for example, enrolled in both an ANC program and an HIV treatment program. Each is a separate EpisodeOfCare.

**Status history.** FHIR provides a `statusHistory` element that records past statuses with their periods. This is useful for tracking when a patient went on hold or was temporarily inactive.

## Relationship to DHIS2

EpisodeOfCare maps directly to a DHIS2 **Enrollment** -- the association of a tracked entity instance with a specific program. The DHIS2 program becomes the `type`, the enrollment date maps to `period.start`, and the completion date (if any) maps to `period.end`. The organisation unit where the enrollment occurred becomes the `managingOrganization`. Events within the enrollment become Encounter resources that reference this EpisodeOfCare, creating the same hierarchical structure: Program Enrollment contains Events, just as EpisodeOfCare contains Encounters.
