# Clinical Profiles

The clinical profiles map DHIS2 Tracker's core data structures to FHIR resources for individual-level clinical data. Three profiles work together to represent the DHIS2 Tracker data hierarchy:

```
DHIS2 Tracker              FHIR
─────────────────          ──────────────────
Enrollment          ──►    DHIS2EpisodeOfCare
  └─ Event          ──►    DHIS2Encounter
       └─ Data Value ──►   DHIS2Observation
```

## DHIS2Observation

Maps a DHIS2 data value -- either an event data value from a Tracker program stage or a data value from an aggregate data set -- to a FHIR Observation.

### DHIS2 Context

In DHIS2 Tracker, each event contains data values keyed by data element UID. For example, a "Weight" data element with UID `qrur9Dvnyt5` might have value `65.0` recorded at a specific event. DHIS2 data elements have value types (NUMBER, TEXT, BOOLEAN, DATE, etc.) that determine the appropriate FHIR `value[x]` type.

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `status` | 1..1 MS | `final` for completed events, `preliminary` for active |
| `code` | 1..1 MS | Standard code (LOINC/SNOMED) for the data element |
| `subject` | 1..1 MS | Reference to DHIS2Patient |
| `encounter` | 0..1 MS | Reference to DHIS2Encounter |
| `effective[x]` | 1..1 MS | Maps to DHIS2 event date |
| `value[x]` | 1..1 MS | Type depends on data element value type |
| `extension[dataElement]` | 0..1 MS | DHIS2DataElementExtension |
| `extension[categoryCombo]` | 0..1 | DHIS2CategoryComboExtension |

The `subject` is constrained to `Reference(DHIS2Patient)` and `encounter` to `Reference(DHIS2Encounter)`, ensuring type safety within the IG's profile ecosystem.

### Value Type Mapping

DHIS2's value types map to FHIR's `value[x]` polymorphism:

| DHIS2 Value Type | FHIR value[x] Type |
|-------------------|---------------------|
| NUMBER | valueQuantity (with UCUM units) |
| TEXT | valueString |
| BOOLEAN | valueBoolean |
| DATE | valueDateTime |
| OPTION_SET | valueCodeableConcept |

### FSH Source

```fsh
Profile: DHIS2Observation
Parent: Observation
Id: dhis2-observation
Title: "DHIS2 Observation"
Description: """
Represents a DHIS2 data value -- either an event data value from a Tracker
program stage or a data value from an aggregate data set.
"""

* status MS
* code 1..1 MS

* subject 1..1 MS
* subject only Reference(DHIS2Patient)

* encounter MS
* encounter only Reference(DHIS2Encounter)

* effective[x] 1..1 MS
* value[x] 1..1 MS

* extension contains DHIS2DataElementExtension named dataElement 0..1 MS
* extension contains DHIS2CategoryComboExtension named categoryCombo 0..1
```

## DHIS2Encounter

Maps DHIS2 Tracker events to FHIR Encounter. Events are occurrences of a program stage -- for example, in an ANC program with a repeatable "ANC Visit" program stage, each visit creates a new event.

### DHIS2 Context

DHIS2 events have:
- An event date (when the visit occurred)
- An org unit (where the visit took place)
- A status (ACTIVE, COMPLETED, SCHEDULE, SKIPPED)
- Data values (the clinical data captured)

### Status Mapping

| DHIS2 Event Status | FHIR Encounter Status |
|---------------------|-----------------------|
| ACTIVE | in-progress |
| COMPLETED | finished |
| SCHEDULE | planned |
| SKIPPED | cancelled |

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `status` | 1..1 MS | Maps to DHIS2 event status |
| `class` | 1..1 MS | Typically `AMB` (ambulatory) for DHIS2 events |
| `subject` | 1..1 MS | Reference to DHIS2Patient |
| `period` | 1..1 MS | Maps to DHIS2 eventDate/dueDate |
| `location` | 0..* MS | DHIS2 event org unit location |
| `serviceProvider` | 0..1 MS | Reference to DHIS2Organization |
| `extension[program]` | 0..1 MS | DHIS2ProgramExtension |

### FSH Source

```fsh
Profile: DHIS2Encounter
Parent: Encounter
Id: dhis2-encounter
Title: "DHIS2 Encounter"
Description: """
Represents a DHIS2 Tracker event or a single event capture as a FHIR
Encounter. Events are instances of program stages -- they represent visits,
consultations, or service delivery interactions where data is collected.
"""

* status MS
* class MS

* subject 1..1 MS
* subject only Reference(DHIS2Patient)

* period 1..1 MS
* location MS

* serviceProvider MS
* serviceProvider only Reference(DHIS2Organization)

* extension contains DHIS2ProgramExtension named program 0..1 MS
```

## DHIS2EpisodeOfCare

Maps a DHIS2 enrollment to FHIR EpisodeOfCare. In DHIS2 Tracker, an enrollment represents a patient's participation in a specific program over a period of time.

### DHIS2 Context

An enrollment has:
- `enrollmentDate` -- when the patient was enrolled (maps to `period.start`)
- `incidentDate` -- when the triggering health event occurred (e.g., last menstrual period for ANC)
- `orgUnit` -- where the enrollment was created
- `status` -- ACTIVE, COMPLETED, or CANCELLED

A patient can be enrolled in multiple programs simultaneously (e.g., ANC and HIV programs), and some programs allow multiple enrollments over time.

### Status Mapping

| DHIS2 Enrollment Status | FHIR EpisodeOfCare Status |
|--------------------------|---------------------------|
| ACTIVE | active |
| COMPLETED | finished |
| CANCELLED | cancelled |

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `status` | 1..1 MS | Maps to DHIS2 enrollment status |
| `patient` | 1..1 MS | Reference to DHIS2Patient |
| `managingOrganization` | 0..1 MS | Enrolling org unit |
| `period` | 1..1 MS | start = enrollmentDate, end = completion date |
| `extension[program]` | 0..1 MS | DHIS2ProgramExtension |

EpisodeOfCare is the closest FHIR match because it represents a continuous care relationship between a patient and a provider for a specific condition or program, containing multiple encounters (events) within it.

### FSH Source

```fsh
Profile: DHIS2EpisodeOfCare
Parent: EpisodeOfCare
Id: dhis2-episode-of-care
Title: "DHIS2 Episode of Care"
Description: """
Represents a DHIS2 enrollment -- a patient's participation in a Tracker
program over a period of time. Enrollments connect a tracked entity instance
to a program and define the time window during which events (visits) can be
recorded.
"""

* status MS

* patient 1..1 MS
* patient only Reference(DHIS2Patient)

* managingOrganization MS
* managingOrganization only Reference(DHIS2Organization)

* period 1..1 MS

* extension contains DHIS2ProgramExtension named program 0..1 MS
```

## How They Work Together

In a typical DHIS2 Tracker workflow:

1. A patient (TEI) is registered at a facility -- creates a **DHIS2Patient**
2. The patient is enrolled in a program (e.g., ANC) -- creates a **DHIS2EpisodeOfCare**
3. The patient visits the facility for a program stage event -- creates a **DHIS2Encounter**
4. Clinical data values are recorded during the visit -- creates **DHIS2Observation** instances

All resources reference back to the DHIS2Patient via `subject` or `patient`, and the Observations also reference the Encounter. The EpisodeOfCare provides the overarching program context.

## Source Files

- Observation: `ig/input/fsh/clinical/observation.fsh`
- Encounter: `ig/input/fsh/clinical/encounter.fsh`
- EpisodeOfCare: `ig/input/fsh/clinical/episodeofcare.fsh`
- Examples: `ig/input/fsh/clinical/observation-examples.fsh`, `encounter-examples.fsh`, `episodeofcare-examples.fsh`

## Expanded Observation Examples

The IG includes observation examples that go beyond basic vital signs to demonstrate the full range of DHIS2 data value types and clinical scenarios. These examples show how observations connect to encounters and episodes of care to tell coherent clinical stories.

### Temperature

Body temperature observations use LOINC code `8310-5` with `valueQuantity` in degrees Celsius. John Kamau's initial encounter records a temperature of 38.9°C, indicating fever -- a key finding that triggers the malaria diagnostic workflow.

### HIV Test

HIV rapid test results use `valueCodeableConcept` with coded outcomes (positive/negative). Amina Hassan's ANC visit includes an HIV test with a negative result, demonstrating how DHIS2 option set values map to FHIR CodeableConcept.

### Follow-up Observations Showing Clinical Progression

Several examples demonstrate how repeated observations across encounters capture clinical progression:

- **Malaria RDT (John Kamau)**: Initial encounter shows a positive result; follow-up encounter shows a negative result, confirming successful treatment with ACT. The two observations share the same `code` but reference different encounters, and the episode of care status transitions from active to completed (finished).
- **Hemoglobin (Amina Hassan)**: First ANC visit records Hb 10.2 g/dL (below normal, indicating anemia); second visit records Hb 11.8 g/dL after iron supplementation, showing clinical improvement. This pattern demonstrates how DHIS2 Tracker's repeatable program stages naturally map to multiple FHIR encounters with linked observations.
- **Weight (Amina Hassan)**: Recorded at both ANC visits (62.0 kg and 63.5 kg), showing expected weight gain during pregnancy.

These follow-up examples illustrate that FHIR's temporal model -- where each Observation references a specific Encounter with its own date -- naturally captures the longitudinal data that DHIS2 Tracker collects through repeatable program stage events.
