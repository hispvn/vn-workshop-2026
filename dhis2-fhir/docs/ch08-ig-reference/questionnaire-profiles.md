# Questionnaire Profiles

The Questionnaire/QuestionnaireResponse pattern is the **primary pattern for representing DHIS2 events** in this IG. While individual data elements can be mapped to Observations (see the clinical profiles), the Questionnaire approach preserves the complete structure of the DHIS2 form: which fields appear together, their order, skip logic, and the exact answers the user entered.

## Why Questionnaire Instead of Observation?

Both approaches are valid and complementary:

| Aspect | Questionnaire Pattern | Observation Pattern |
|--------|----------------------|---------------------|
| Granularity | Entire event in one resource | One resource per data value |
| Structure | Preserves form layout and order | Individual atomic values |
| Round-tripping | Lossless back to DHIS2 | May lose form context |
| Analytics | Requires extraction | Directly queryable |
| Best for | Data capture, audit trails | Clinical decision support |

Many implementations use QuestionnaireResponse for data capture and then extract Observations for clinical analytics.

## DHIS2Questionnaire

Represents a DHIS2 program stage data entry form. Each item in the Questionnaire corresponds to a data element in the DHIS2 program stage.

### DHIS2-to-FHIR Mapping

| DHIS2 Concept | FHIR Element |
|---------------|--------------|
| Program stage UID | `identifier[dhis2uid].value` |
| Program stage name | `title` |
| Data elements | `item` (one per data element) |
| Data element UID | `item.linkId` |
| Data element name | `item.text` |
| Data element value type | `item.type` |
| Compulsory flag | `item.required` |
| Option set | `item.answerValueSet` |
| Program rules (show/hide) | `item.enableWhen` |

### Tracker vs. Event Programs

The `subjectType` element distinguishes between the two DHIS2 program types:

- **Tracker programs** (WITH_REGISTRATION): Set `subjectType` to `Patient`. The form collects data linked to a registered individual.
- **Event programs** (WITHOUT_REGISTRATION): Omit `subjectType`. The form captures anonymous, facility-level data.

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `url` | 1..1 MS | Canonical URL for the form definition |
| `identifier` | 0..* MS | Sliced by system |
| `identifier[dhis2uid]` | 0..1 MS | System = `$DHIS2-PROGRAM`, value = program stage UID |
| `title` | 1..1 MS | Human-readable form name |
| `name` | 0..1 MS | Machine-friendly name |
| `status` | 1..1 MS | draft, active, retired |
| `subjectType` | 0..* MS | `Patient` for tracker; omit for event programs |
| `item` | 0..* MS | Data element questions |
| `item.linkId` | 1..1 MS | DHIS2 data element UID |
| `item.text` | 0..1 MS | Question label |
| `item.type` | 1..1 MS | Maps to DHIS2 value type |
| `item.required` | 0..1 MS | Maps to compulsory flag |
| `item.answerValueSet` | 0..1 MS | DHIS2 option set as ValueSet |
| `item.answerOption` | 0..* MS | Inline answer options |

### Value Type Mapping for Items

| DHIS2 Value Type | Questionnaire item.type |
|-------------------|-------------------------|
| TEXT | `string` |
| LONG_TEXT | `text` |
| NUMBER | `decimal` |
| INTEGER | `integer` |
| BOOLEAN | `boolean` |
| DATE | `date` |
| DATETIME | `dateTime` |
| Option set | `choice` |

### FSH Source

```fsh
Profile: DHIS2Questionnaire
Parent: Questionnaire
Id: dhis2-questionnaire
Title: "DHIS2 Questionnaire"
Description: """
Represents a DHIS2 program stage data entry form. Each item corresponds to
a data element, with linkId mapping to the data element UID.
"""

* url 1..1 MS

* identifier MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains dhis2uid 0..1 MS
* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].system MS
* identifier[dhis2uid].value 1..1 MS

* name MS
* title 1..1 MS
* status MS

* subjectType 0..* MS

* item MS
* item.linkId MS
* item.text MS
* item.type MS
* item.required MS
* item.answerValueSet MS
* item.answerOption MS
```

## DHIS2QuestionnaireResponse

Represents a completed DHIS2 event -- a single form submission for a tracked entity at a particular program stage.

### DHIS2-to-FHIR Mapping

| DHIS2 Concept | FHIR Element |
|---------------|--------------|
| Program stage reference | `questionnaire` (canonical URL) |
| Event status | `status` |
| Tracked entity instance | `subject` (tracker programs only) |
| Event date | `authored` |
| Data values | `item` entries |
| Data element UID | `item.linkId` |
| Data value | `item.answer` |
| Organisation unit | `extension[orgUnit]` |

### Subject Cardinality: 0..1

The `subject` is **0..1**, not 1..1. This is a deliberate design choice because:

- **Tracker programs** (WITH_REGISTRATION): `subject` references a DHIS2Patient -- events are linked to a registered individual.
- **Event programs** (WITHOUT_REGISTRATION): `subject` is absent -- events are standalone and anonymous.

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `questionnaire` | 1..1 MS | Canonical URL of the program stage Questionnaire |
| `status` | 1..1 MS | completed, in-progress, amended, stopped |
| `subject` | 0..1 MS | DHIS2Patient for tracker; absent for event programs |
| `encounter` | 0..1 MS | Reference to DHIS2Encounter |
| `authored` | 1..1 MS | DHIS2 event date |
| `author` | 0..1 MS | Data entry user |
| `source` | 0..1 MS | Patient if self-reported |
| `item` | 0..* MS | Data values |
| `item.linkId` | 1..1 MS | DHIS2 data element UID |
| `item.answer` | 0..* MS | Reported data value |
| `extension[orgUnit]` | 0..1 MS | DHIS2OrgUnitExtension |

### FSH Source

```fsh
Profile: DHIS2QuestionnaireResponse
Parent: QuestionnaireResponse
Id: dhis2-questionnaire-response
Title: "DHIS2 Questionnaire Response"
Description: """
Represents a completed DHIS2 event -- a form submission capturing data at a
specific program stage visit.
"""

* questionnaire 1..1 MS
* status MS

* subject 0..1 MS
* subject only Reference(DHIS2Patient)

* encounter 0..1 MS
* encounter only Reference(DHIS2Encounter)

* authored 1..1 MS

* author 0..1 MS
* author only Reference(Practitioner or Organization)

* source 0..1 MS
* source only Reference(DHIS2Patient)

* item MS
* item.linkId MS
* item.answer MS

* extension contains DHIS2OrgUnitExtension named orgUnit 0..1 MS
```

## Status Mapping

The `status` element maps DHIS2 event lifecycle states:

| DHIS2 Event Status | QR Status |
|---------------------|-----------|
| COMPLETED | `completed` |
| ACTIVE | `in-progress` |
| (edited after completion) | `amended` |
| SKIPPED | `stopped` |

## The Primary Pattern for DHIS2 Events

The Questionnaire/QuestionnaireResponse pattern is preferred over individual Observations for several reasons:

1. **Structural fidelity** -- Preserves which fields appear together, their order, and the form context
2. **Round-trip capability** -- Every piece of data needed to reconstruct the DHIS2 event is present
3. **Audit trails** -- Captures exactly what the user saw and entered
4. **Program rules** -- `enableWhen` maps DHIS2 program rules for conditional field display
5. **Single resource** -- One QuestionnaireResponse captures the entire event, reducing the number of resources

The IG includes multiple Questionnaire/QR example pairs for real-world programs: ANC visits, malaria case investigation, child immunization, delivery, and disease notification.

## Source Files

- Profile definitions: `ig/input/fsh/questionnaire/profiles.fsh`
- ANC form: `ig/input/fsh/questionnaire/anc-visit-form.fsh`
- Malaria form: `ig/input/fsh/questionnaire/malaria-case-form.fsh`
- Immunization form: `ig/input/fsh/questionnaire/child-immunization-form.fsh`
- Delivery form: `ig/input/fsh/questionnaire/delivery-form.fsh`
- Disease notification form: `ig/input/fsh/questionnaire/disease-notification-form.fsh`
- Examples: `ig/input/fsh/questionnaire/examples-anc.fsh`, `examples-malaria.fsh`, etc.
