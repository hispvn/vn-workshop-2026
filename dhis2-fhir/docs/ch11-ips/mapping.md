# DHIS2 to IPS Mapping

This chapter explains how to map data from a DHIS2 immunization tracker program into the four IPS resources. The mapping covers the complete flow from DHIS2 API data to a valid IPS Bundle.

## DHIS2 Immunization Program Structure

A typical DHIS2 immunization tracker program looks like:

```
Program: Child Immunization
├── Tracked Entity Type: Person
│   ├── First name (TEA)
│   ├── Last name (TEA)
│   ├── Sex (TEA, option set)
│   ├── Date of birth (TEA)
│   ├── National ID (TEA)
│   ├── Phone (TEA)
│   └── Address (TEA)
│
├── Program Stage: Immunization Visit (repeatable)
│   ├── Vaccine given (DE, option set)
│   ├── Date given (DE, DATE)
│   ├── Dose number (DE, INTEGER)
│   ├── Lot number (DE, TEXT)
│   ├── Site (DE, option set)
│   └── Adverse event (DE, BOOLEAN)
│
└── Organisation Unit: Health facility
```

Each **enrollment** creates one Patient. Each **event** in the program stage creates one Immunization. The IPS Bundle wraps them all together with a Composition.

## Resource Mapping Overview

| DHIS2 Concept | FHIR IPS Resource | Cardinality |
|---------------|-------------------|-------------|
| Tracked Entity Instance | DHIS2IPSPatient | 1 per IPS |
| Program Stage Event (Immunization Visit) | DHIS2IPSImmunization | 0..* per IPS |
| (Generated) | DHIS2IPSComposition | 1 per IPS |
| (Generated) | DHIS2IPSBundle | 1 per IPS |

The Composition and Bundle are **generated artifacts** — they don't map directly to a DHIS2 concept. They are created by the integration layer to package the Patient and Immunization resources into a valid IPS document.

## Step-by-Step Mapping

### Step 1: TEI → Patient

Read the Tracked Entity Instance from the DHIS2 API:

```
GET /api/trackedEntityInstances/{tei}?fields=*&program={programId}
```

Map the TEI attributes to FHIR Patient elements:

```json
{
  "resourceType": "Patient",
  "id": "ips-patient-001",
  "identifier": [
    {
      "system": "http://dhis2.org/fhir/id/tracked-entity",
      "type": { "coding": [{ "system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "RI" }] },
      "value": "DXz2k5eGbri"
    }
  ],
  "name": [{ "family": "Doe", "given": ["Jane"] }],
  "gender": "female",
  "birthDate": "2020-03-15",
  "telecom": [{ "system": "phone", "value": "+26599912345" }],
  "address": [{ "city": "Lilongwe", "country": "MW" }]
}
```

### Step 2: Events → Immunizations

Read all events for the TEI in the immunization program stage:

```
GET /api/trackedEntityInstances/{tei}?fields=enrollments[events[*]]&program={programId}
```

Each event becomes one Immunization resource. The key mapping is **vaccine option set code → CVX code**:

```json
{
  "resourceType": "Immunization",
  "id": "ips-imm-001-01",
  "status": "completed",
  "vaccineCode": {
    "coding": [
      {
        "system": "http://hl7.org/fhir/sid/cvx",
        "code": "19",
        "display": "BCG"
      }
    ]
  },
  "patient": { "reference": "Patient/ips-patient-001" },
  "occurrenceDateTime": "2020-03-15",
  "lotNumber": "AB1234",
  "site": {
    "coding": [{
      "system": "http://snomed.info/sct",
      "code": "61396006",
      "display": "Left thigh"
    }]
  },
  "route": {
    "coding": [{
      "system": "http://snomed.info/sct",
      "code": "78421000",
      "display": "Intramuscular route"
    }]
  },
  "protocolApplied": [{
    "doseNumberPositiveInt": 1,
    "targetDisease": [{
      "coding": [{
        "system": "http://snomed.info/sct",
        "code": "56717001",
        "display": "Tuberculosis"
      }]
    }]
  }]
}
```

### Step 3: Generate Composition

The Composition is created by the integration layer. It references the Patient and all Immunization resources:

```json
{
  "resourceType": "Composition",
  "id": "ips-composition-001",
  "status": "final",
  "type": {
    "coding": [{
      "system": "http://loinc.org",
      "code": "60591-5",
      "display": "Patient summary Document"
    }]
  },
  "subject": { "reference": "Patient/ips-patient-001" },
  "date": "2025-01-15",
  "author": [{ "display": "DHIS2 System" }],
  "title": "International Patient Summary",
  "section": [{
    "title": "Immunizations",
    "code": {
      "coding": [{
        "system": "http://loinc.org",
        "code": "11369-6",
        "display": "History of Immunization Narrative"
      }]
    },
    "entry": [
      { "reference": "Immunization/ips-imm-001-01" },
      { "reference": "Immunization/ips-imm-001-02" },
      { "reference": "Immunization/ips-imm-001-03" }
    ]
  }]
}
```

### Step 4: Wrap in Bundle

The Bundle wraps everything into a single document payload:

```json
{
  "resourceType": "Bundle",
  "id": "ips-bundle-001",
  "type": "document",
  "timestamp": "2025-01-15T10:00:00Z",
  "entry": [
    {
      "fullUrl": "urn:uuid:composition-001",
      "resource": { "...Composition..." }
    },
    {
      "fullUrl": "urn:uuid:patient-001",
      "resource": { "...Patient..." }
    },
    {
      "fullUrl": "urn:uuid:imm-001",
      "resource": { "...Immunization 1..." }
    },
    {
      "fullUrl": "urn:uuid:imm-002",
      "resource": { "...Immunization 2..." }
    }
  ]
}
```

## Event Status Mapping

| DHIS2 Event Status | FHIR Immunization.status | Notes |
|-------------------|--------------------------|-------|
| `COMPLETED` | `completed` | Normal case |
| `ACTIVE` | `completed` | Still completing but vaccine was given |
| `SCHEDULE` | Not exported | Planned, not yet administered |
| `OVERDUE` | Not exported | Missed appointment |
| `SKIPPED` | `not-done` | Vaccine intentionally skipped |

Only `COMPLETED` events should be included in the IPS. Scheduled or overdue events represent vaccines **not yet given** and should not appear as Immunization resources.

## Handling Missing Data

Not all DHIS2 data elements have values for every event. The IPS handles missing data differently depending on the element:

| Element | If missing | Action |
|---------|-----------|--------|
| `vaccineCode` | **Cannot be missing** | Required — skip the entire event if unknown |
| `occurrenceDateTime` | Use event date | Fall back to `event.eventDate` |
| `lotNumber` | Omit | Simply don't include the element |
| `site` | Omit | Don't include — common in resource-limited settings |
| `route` | Omit | Can be inferred from vaccine type if needed |
| `doseNumber` | Omit | Don't include `protocolApplied` |
| `targetDisease` | Derive from vaccine | Look up the disease from the CVX code |

## Generating IPS for Multiple Patients

In a typical DHIS2 deployment, you might need to generate IPS documents in bulk (e.g., for all children in a district). The flow is:

```
1. Query DHIS2 for TEIs enrolled in immunization program
   GET /api/trackedEntityInstances?program={id}&ou={district}&fields=*

2. For each TEI:
   a. Map TEI → Patient
   b. Map each event → Immunization
   c. Generate Composition (referencing Patient + Immunizations)
   d. Wrap in Bundle

3. Output: one IPS Bundle JSON file per patient
```

The `gen_examples.py` script in this IG demonstrates this pattern programmatically, generating 55 complete IPS documents with realistic data.

## Integration Architecture

```
┌──────────┐     API      ┌──────────────────┐    FHIR    ┌──────────┐
│          │ ────────────► │                  │ ─────────► │          │
│  DHIS2   │  TEI + Events │  Integration     │  IPS Bundle│  FHIR    │
│  Tracker │ ◄──────────── │  Layer           │ ◄───────── │  Server  │
│          │               │  (mapping +      │            │  / HIE   │
└──────────┘               │   CVX lookup)    │            └──────────┘
                           └──────────────────┘
```

The integration layer is responsible for:
1. Reading DHIS2 data via the Tracker API
2. Mapping option set codes to standard terminologies (CVX, SNOMED CT)
3. Constructing the four FHIR resources (Patient, Immunization, Composition, Bundle)
4. Submitting the IPS Bundle to the receiving FHIR server

This can be implemented as a DHIS2 app, a middleware service, or a scheduled job.
