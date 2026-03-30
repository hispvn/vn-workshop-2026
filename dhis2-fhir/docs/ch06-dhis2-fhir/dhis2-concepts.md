## DHIS2 Concepts Quick Reference

This page gives you the essential DHIS2 vocabulary and mental models you need
before diving into the FHIR mapping chapters. No prior DHIS2 experience is
assumed.

---

## What is DHIS2?

**DHIS2** (District Health Information Software 2) is an open-source platform
for collecting, managing, and analyzing health data. It is the world's largest
health management information system (HMIS), deployed in **80+ countries** and
used primarily by **ministries of health** to run national health programs.

Key facts:

| Aspect | Detail |
|---|---|
| License | BSD 3-Clause (open source) |
| Maintained by | University of Oslo / HISP Centre |
| Primary users | Ministries of health, NGOs, WHO |
| Deployment | Self-hosted or cloud (dhis2.org) |
| Tech stack | Java backend, React frontend, PostgreSQL |
| Website | [dhis2.org](https://dhis2.org) |

DHIS2 serves two fundamentally different data-collection needs, each with its
own data model.

---

## The Two Data Models

### Aggregate Data

Aggregate data captures **facility-level summary counts** reported on a
periodic schedule. Think of it as "a health facility filling out a monthly
reporting form."

> *Example:* "Khammouan Provincial Hospital reported **45 confirmed malaria
> cases** in **January 2025**."

**Key concepts:**

| Concept | What it is | Example |
|---|---|---|
| **Data Set** | A reporting form (collection of fields) | "Monthly Malaria Report" |
| **Data Element** | A single field on the form | "Confirmed malaria cases" |
| **Period** | The time window the report covers | `202501` (January 2025) |
| **Organisation Unit** | The facility or level reporting | "Khammouan Provincial Hospital" |
| **Category Option Combo** | Disaggregation dimensions | Male / 5-14 years |

A single reported number is uniquely identified by the combination:

```
Data Element + Period + Org Unit + Category Option Combo = value
```

A minimal JSON payload for submitting aggregate data:

```json
{
  "dataSet": "BfMAe6Itzgt",
  "period": "202501",
  "orgUnit": "DiszpKrYNg8",
  "dataValues": [
    {
      "dataElement": "f7n9E0hX8qk",
      "categoryOptionCombo": "rXbMvOkFMnZ",
      "value": "45"
    }
  ]
}
```

### Tracker Data

Tracker data captures **individual-level longitudinal records** — following a
single person through a clinical workflow over time.

> *Example:* "Patient Somchai (TEI `dBwrot7S76w`) is enrolled in the ANC
> program, attended her second visit on 15 Feb 2025, blood pressure was
> 120/80."

**Key concepts:**

| Concept | What it is | Example |
|---|---|---|
| **Tracked Entity Instance (TEI)** | A uniquely identified individual record | A specific patient |
| **Tracked Entity Type** | The kind of entity being tracked | "Person" (most common) |
| **Tracked Entity Attribute (TEA)** | Demographic/identifying fields on the TEI | First name, DOB, national ID |
| **Program** | A clinical workflow or health program | "Antenatal Care (ANC)" |
| **Enrollment** | A TEI joining a specific program | Somchai enrolls in ANC on 10 Jan 2025 |
| **Program Stage** | A type of visit or event within the program | "ANC Visit", "Lab Results" |
| **Event** | A single form submission within a stage | ANC Visit on 15 Feb 2025 |
| **Data Value** | A single captured value inside an event | systolicBP = 120 |

---

## How Tracker Fits Together (Visual)

The following diagram shows how the Tracker concepts relate to each other:

```
┌─────────────────────────────────────────────────────────┐
│                  Tracked Entity Instance (TEI)          │
│                  uid: "dBwrot7S76w"                     │
│                  type: Person                           │
│                                                         │
│  ┌─────────────────────────────────────────────────┐    │
│  │  Tracked Entity Attributes (TEAs)               │    │
│  │  ┌──────────────┬──────────────┬──────────────┐ │    │
│  │  │ firstName:   │ dateOfBirth: │ nationalId:  │ │    │
│  │  │ "Somchai"    │ "1992-05-10" │ "LAO-12345"  │ │    │
│  │  └──────────────┴──────────────┴──────────────┘ │    │
│  └─────────────────────────────────────────────────┘    │
└─────────────┬───────────────────────────────────────────┘
              │
              │ enrolls in
              ▼
┌──────────────────────────────────────────────────────────┐
│  Program: "Antenatal Care (ANC)"                         │
│  uid: "IpHINAT79UW"                                     │
│                                                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Enrollment                                         │ │
│  │  enrollmentDate: 2025-01-10                         │ │
│  │  orgUnit: "Khammouan Hospital"                      │ │
│  │                                                     │ │
│  │  ┌───────────────────────────────────────────────┐  │ │
│  │  │  Program Stage: "ANC Visit"                   │  │ │
│  │  │                                               │  │ │
│  │  │  ┌─────────────────┐  ┌─────────────────┐    │  │ │
│  │  │  │ Event 1         │  │ Event 2         │    │  │ │
│  │  │  │ 2025-01-10      │  │ 2025-02-15      │    │  │ │
│  │  │  │                 │  │                 │    │  │ │
│  │  │  │ Data Values:    │  │ Data Values:    │    │  │ │
│  │  │  │  systolicBP=110 │  │  systolicBP=120 │    │  │ │
│  │  │  │  weight=62      │  │  weight=63      │    │  │ │
│  │  │  └─────────────────┘  └─────────────────┘    │  │ │
│  │  └───────────────────────────────────────────────┘  │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

The short version:

```
Program ──► Enrollment ──► Program Stage ──► Event ──► Data Values
                                              │
TEI ──► TEAs (name, DOB, ID, ...)            captured per event
```

---

## Organisation Unit Hierarchy

Every data point in DHIS2 — whether aggregate or tracker — is tied to an
**Organisation Unit** (org unit). Org units form a **tree** that typically
mirrors the administrative geography of a country:

```
National (Level 1)
├── Province A (Level 2)
│   ├── District A1 (Level 3)
│   │   ├── Facility A1-001 (Level 4)
│   │   └── Facility A1-002 (Level 4)
│   └── District A2 (Level 3)
│       └── Facility A2-001 (Level 4)
└── Province B (Level 2)
    └── District B1 (Level 3)
        ├── Facility B1-001 (Level 4)
        └── Facility B1-002 (Level 4)
```

Important properties of org units:

| Property | Description |
|---|---|
| `id` (UID) | Auto-generated 11-char identifier, e.g. `DiszpKrYNg8` |
| `code` | Optional external code, e.g. `OU_559` |
| `name` | Display name, e.g. "Khammouan Provincial Hospital" |
| `shortName` | Abbreviated name |
| `level` | Depth in the tree (1 = national) |
| `parent` | Reference to the parent org unit |
| `openingDate` | When the facility started operating |
| `groups` | Membership in Org Unit Groups (e.g. "Hospitals", "Health Centers") |

Org units are the primary mechanism for **access control** — users are
assigned to org units and can only see data within their branch of the tree.

---

## Identifiers in DHIS2

DHIS2 auto-generates an **11-character alphanumeric UID** for virtually every
object in the system: TEIs, org units, data elements, programs, program
stages, events, and more.

```
Example UIDs:
  TEI:          dBwrot7S76w
  Org Unit:     DiszpKrYNg8
  Data Element: f7n9E0hX8qk
  Program:      IpHINAT79UW
```

UID rules:
- Exactly 11 characters
- First character is always a letter (`[a-zA-Z]`)
- Remaining 10 characters are alphanumeric (`[a-zA-Z0-9]`)

**External identifiers** — such as a national ID number, passport number, or
facility MFL code — are **not** UIDs. They are stored as:

| Identifier type | Stored as |
|---|---|
| Person identifiers (national ID, passport) | Tracked Entity Attributes on the TEI |
| Facility codes (MFL, FHIR ID) | `code` field or attribute on the Org Unit |
| Cross-system references | DHIS2 Attribute Values or custom fields |

This distinction matters for FHIR mapping: the DHIS2 UID becomes one
`Identifier` on the FHIR resource, while external IDs become additional
`Identifier` entries with their own system URIs.

---

## The DHIS2 Web API

DHIS2 exposes a comprehensive **REST API** at the `/api/` path of any DHIS2
instance. All responses are JSON by default.

### Key Endpoints

| Endpoint | Purpose |
|---|---|
| `/api/trackedEntityInstances` | Query and manage individual patient records |
| `/api/enrollments` | Manage program enrollments |
| `/api/events` | Query and submit individual events (visits) |
| `/api/dataValueSets` | Submit and retrieve aggregate data |
| `/api/organisationUnits` | Browse the org unit hierarchy |
| `/api/programs` | List available programs and their stages |
| `/api/dataElements` | List data elements and their metadata |
| `/api/metadata` | Bulk export/import of all metadata |

### Example: Fetch a Tracked Entity Instance

```
GET /api/trackedEntityInstances/dBwrot7S76w.json
    ?fields=attributes,enrollments[events]
```

Response (simplified):

```json
{
  "trackedEntityInstance": "dBwrot7S76w",
  "trackedEntityType": "nEenWldSXaS",
  "orgUnit": "DiszpKrYNg8",
  "attributes": [
    {
      "attribute": "w75KJ2mc4zz",
      "displayName": "First name",
      "value": "Somchai"
    },
    {
      "attribute": "zDhUuAYrxNC",
      "displayName": "Last name",
      "value": "Phanthavong"
    }
  ],
  "enrollments": [
    {
      "enrollment": "RiNIt0aVgMa",
      "program": "IpHINAT79UW",
      "enrollmentDate": "2025-01-10",
      "events": [
        {
          "event": "ZwwuwNpMBMr",
          "programStage": "A03MvHHogjR",
          "eventDate": "2025-02-15",
          "dataValues": [
            {
              "dataElement": "UXz7xuGCEhU",
              "value": "120"
            }
          ]
        }
      ]
    }
  ]
}
```

### Authentication

The API uses **Basic Auth** or **OAuth2 / Personal Access Tokens** depending
on the DHIS2 version. Most integration scripts use Basic Auth for simplicity:

```
Authorization: Basic base64(username:password)
```

---

## Summary Table: DHIS2 vs FHIR Vocabulary

This table previews how DHIS2 concepts translate to FHIR (covered in depth in
the next chapter):

| DHIS2 Concept | FHIR Resource |
|---|---|
| Tracked Entity Instance | Patient |
| Tracked Entity Attribute | Patient fields or Extensions |
| Organisation Unit | Organization / Location |
| Program | EpisodeOfCare or CarePlan |
| Enrollment | EpisodeOfCare |
| Program Stage | Encounter (type) |
| Event | Encounter + Observations |
| Data Value | Observation |
| Data Element | Observation.code |
| Data Set (aggregate) | MeasureReport |

The next section, [Mapping Concepts](mapping-concepts.md), explores these
mappings in detail with worked examples.
