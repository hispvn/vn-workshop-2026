# Logical Models and Mappings

Logical models document the structure of data as it exists in the source or target system, without mapping it to a specific FHIR resource. The IG defines two logical models representing DHIS2 API payloads, and two mappings that document the field-level transformations to FHIR.

## What Are Logical Models?

Unlike profiles (which constrain existing FHIR resources), logical models define entirely new structures. They appear in the IG as StructureDefinitions with `kind = "logical"`. Their purposes include:

- Documenting non-FHIR data structures (like DHIS2 API payloads)
- Providing a clear "source of truth" for mapping discussions
- Generating human-readable documentation in the IG
- Serving as the source or target in formal Mapping definitions

## DHIS2TrackedEntityInstance

Models the DHIS2 TEI API structure with nested attributes, enrollments, events, and data values. This mirrors the JSON payload returned by the DHIS2 Web API `/api/trackedEntityInstances` endpoint.

### Structure

```
DHIS2TrackedEntityInstance
├── uid (1..1 string)                    -- 11-char UID
├── orgUnit (1..1 string)                -- Owning org unit UID
├── trackedEntityType (1..1 string)      -- e.g., "Person"
├── created (1..1 dateTime)
├── lastUpdated (1..1 dateTime)
├── inactive (0..1 boolean)
├── attributes (0..* BackboneElement)    -- TEA values
│   ├── attribute (1..1 string)          -- Attribute UID
│   ├── value (1..1 string)
│   └── displayName (0..1 string)
└── enrollments (0..* BackboneElement)   -- Program enrollments
    ├── enrollment (1..1 string)         -- Enrollment UID
    ├── program (1..1 string)            -- Program UID
    ├── orgUnit (1..1 string)
    ├── enrollmentDate (1..1 dateTime)
    ├── incidentDate (0..1 dateTime)
    ├── status (1..1 string)             -- ACTIVE | COMPLETED | CANCELLED
    └── events (0..* BackboneElement)    -- Program stage events
        ├── event (1..1 string)          -- Event UID
        ├── programStage (1..1 string)
        ├── orgUnit (1..1 string)
        ├── eventDate (1..1 dateTime)
        ├── status (1..1 string)         -- ACTIVE | COMPLETED | SCHEDULE
        └── dataValues (0..* BackboneElement)
            ├── dataElement (1..1 string)
            └── value (1..1 string)
```

### Key Characteristics

- `Characteristics: #can-be-target` -- Allows this model to be the target of References, useful for mapping definitions
- All values are strings in the DHIS2 API, regardless of the attribute's declared value type
- The nested structure (TEI > Enrollment > Event > DataValue) is the backbone of DHIS2 Tracker

### FSH Source

```fsh
Logical: DHIS2TrackedEntityInstance
Id: dhis2-tracked-entity-instance
Title: "DHIS2 Tracked Entity Instance"
Characteristics: #can-be-target

* uid 1..1 string "Unique identifier (11 alphanumeric characters)"
* orgUnit 1..1 string "Organisation unit UID where registered"
* trackedEntityType 1..1 string "Type of tracked entity (e.g., Person)"
* created 1..1 dateTime "Creation timestamp"
* lastUpdated 1..1 dateTime "Last update timestamp"
* inactive 0..1 boolean "Whether the TEI is inactive"

* attributes 0..* BackboneElement "Tracked entity attribute values"
  * attribute 1..1 string "Attribute UID"
  * value 1..1 string "Attribute value"
  * displayName 0..1 string "Human-readable attribute name"

* enrollments 0..* BackboneElement "Program enrollments"
  * enrollment 1..1 string "Enrollment UID"
  * program 1..1 string "Program UID"
  * orgUnit 1..1 string "Enrollment org unit"
  * enrollmentDate 1..1 dateTime "Enrollment date"
  * incidentDate 0..1 dateTime "Incident date"
  * status 1..1 string "ACTIVE | COMPLETED | CANCELLED"

  * events 0..* BackboneElement "Events in this enrollment"
    * event 1..1 string "Event UID"
    * programStage 1..1 string "Program stage UID"
    * orgUnit 1..1 string "Event org unit"
    * eventDate 1..1 dateTime "Event date"
    * status 1..1 string "ACTIVE | COMPLETED | SCHEDULE"

    * dataValues 0..* BackboneElement "Data values"
      * dataElement 1..1 string "Data element UID"
      * value 1..1 string "Value"
```

## DHIS2DataValueSet

Models the aggregate data submission structure sent by facilities on a regular schedule. This mirrors the JSON payload used by the DHIS2 Web API `/api/dataValueSets` endpoint.

### Structure

```
DHIS2DataValueSet
├── dataSet (0..1 string)           -- Data set UID (optional)
├── completeDate (0..1 string)      -- When marked complete
├── period (1..1 string)            -- e.g., "202401" for January 2024
├── orgUnit (1..1 string)           -- Reporting facility UID
└── dataValues (1..* BackboneElement)
    ├── dataElement (1..1 string)   -- Data element UID
    ├── categoryOptionCombo (0..1 string)  -- Disaggregation
    ├── value (1..1 string)         -- Reported value
    └── comment (0..1 string)       -- Optional data entry comment
```

### DHIS2 Period Formats

DHIS2 periods are encoded as strings that must be parsed into FHIR Period start/end dates:

| DHIS2 Format | Example | FHIR Period |
|-------------|---------|-------------|
| Monthly | `202401` | 2024-01-01 to 2024-01-31 |
| Quarterly | `2024Q1` | 2024-01-01 to 2024-03-31 |
| Yearly | `2024` | 2024-01-01 to 2024-12-31 |
| Weekly | `2024W3` | 2024-01-15 to 2024-01-21 |

### FSH Source

```fsh
Logical: DHIS2DataValueSet
Id: dhis2-data-value-set
Title: "DHIS2 Data Value Set"

* dataSet 0..1 string "Data set UID"
* completeDate 0..1 string "Completion date"
* period 1..1 string "Reporting period (e.g., 202401)"
* orgUnit 1..1 string "Organisation unit UID"

* dataValues 1..* BackboneElement "Data values"
  * dataElement 1..1 string "Data element UID"
  * categoryOptionCombo 0..1 string "Category option combo UID"
  * value 1..1 string "Reported value"
  * comment 0..1 string "Comment"
```

## Mapping: TEI to Patient

Documents the field-level transformation from a DHIS2 Tracked Entity Instance to FHIR resources. A single TEI fans out into multiple FHIR resources:

| DHIS2 Layer | FHIR Resource |
|-------------|---------------|
| TEI | Patient |
| TEI.attributes | Patient.name, .birthDate, .gender, .identifier |
| Enrollment | EpisodeOfCare |
| Event | Encounter |
| DataValue | Observation |

### Field-Level Mappings

| Source (TEI) | Target (FHIR) | Notes |
|-------------|----------------|-------|
| `uid` | `Patient.identifier.value` | System = `$DHIS2-TEI` |
| `orgUnit` | `Patient.managingOrganization` | Resolve UID to Organization reference |
| `trackedEntityType` | `Patient.meta.profile` | "Person" -> DHIS2Patient profile |
| `created` | `Patient.meta.extension` | Preserved for audit trail |
| `lastUpdated` | `Patient.meta.lastUpdated` | Server-managed in FHIR |
| `inactive` | `Patient.active` | **Inverted**: inactive=true -> active=false |
| `attributes` | Various Patient elements | Semantic mapping required |
| `enrollments` | `EpisodeOfCare` | One per enrollment |
| `enrollments.events` | `Encounter` | One per event |
| `enrollments.events.dataValues` | `Observation` | One per data value |

### Attribute Mapping Complexity

The attribute mapping is the most complex part because DHIS2 tracked entity attributes are generic key-value pairs. Which Patient element they map to depends entirely on the attribute's semantic meaning:

| Attribute (example) | FHIR Patient Element |
|--------------------|---------------------|
| First Name | `Patient.name.given` |
| Last Name | `Patient.name.family` |
| Date of Birth | `Patient.birthDate` |
| Sex | `Patient.gender` |
| National ID | `Patient.identifier` (type NI) |
| Phone Number | `Patient.telecom` (system phone) |
| Address | `Patient.address.text` |

A mapping implementation needs a configuration table that maps each attribute UID to the corresponding FHIR path and any value transformations (e.g., DHIS2 "Male"/"Female" to FHIR `#male`/`#female`).

### FSH Source

```fsh
Mapping: TEIToPatient
Source: DHIS2TrackedEntityInstance
Target: "http://hl7.org/fhir/StructureDefinition/Patient"
Id: tei-to-patient
Title: "DHIS2 TEI to FHIR Patient Mapping"

* uid -> "Patient.identifier.value"
* orgUnit -> "Patient.managingOrganization"
* trackedEntityType -> "Patient.meta.profile"
* created -> "Patient.meta.extension"
* lastUpdated -> "Patient.meta.lastUpdated"
* inactive -> "Patient.active"
* attributes -> "Patient.name, Patient.birthDate, Patient.gender"
* enrollments -> "EpisodeOfCare"
* enrollments.events -> "Encounter"
* enrollments.events.dataValues -> "Observation"
```

## Mapping: DataValueSet to MeasureReport

Documents the transformation from a DHIS2 aggregate data value set to a FHIR MeasureReport. This mapping is simpler than TEI-to-Patient because aggregate data is already summarised -- one DataValueSet becomes one MeasureReport.

### Field-Level Mappings

| Source (DataValueSet) | Target (MeasureReport) | Notes |
|----------------------|------------------------|-------|
| `dataSet` | `MeasureReport.measure` | Resolve to Measure canonical URL |
| `period` | `MeasureReport.period` | Parse DHIS2 period format to FHIR Period |
| `orgUnit` | `MeasureReport.subject` | Resolve to Location reference |
| `completeDate` | `MeasureReport.date` | When marked complete |
| `dataValues[]` | `MeasureReport.group[]` | One group per data value |
| `dataValues[].dataElement` | `MeasureReport.group.code` | System = `$DHIS2-DE` |
| `dataValues[].value` | `MeasureReport.group.population.count` | Usually integer counts |
| `dataValues[].categoryOptionCombo` | `MeasureReport.group.stratifier` | Disaggregation dimensions |
| `dataValues[].comment` | `MeasureReport.group.extension` | No standard FHIR element |

The MeasureReport type is always `data-collection` for aggregate submissions.

### FSH Source

```fsh
Mapping: DataValueSetToMeasureReport
Source: DHIS2DataValueSet
Target: "http://hl7.org/fhir/StructureDefinition/MeasureReport"
Id: dvs-to-measure-report
Title: "DHIS2 Data Value Set to FHIR MeasureReport Mapping"

* dataSet -> "MeasureReport.measure"
* period -> "MeasureReport.period"
* orgUnit -> "MeasureReport.subject"
* completeDate -> "MeasureReport.date"
* dataValues.dataElement -> "MeasureReport.group.code"
* dataValues.value -> "MeasureReport.group.population.count"
* dataValues.categoryOptionCombo -> "MeasureReport.group.stratifier"
* dataValues.comment -> "MeasureReport.group.extension"
```

## Important Caveats

Mappings in FHIR are **non-executable**. They do not generate code or transform data automatically. Their purpose is documentation and design guidance. For executable transformations, you would use:

- FHIR StructureMap
- DHIS2's built-in FHIR adapter
- Custom integration middleware

The mappings defined here serve as the specification that such tools implement.

## Source Files

- Logical models: `ig/input/fsh/models/tracked-entity.fsh`, `ig/input/fsh/models/data-value-set.fsh`
- Mappings: `ig/input/fsh/models/mapping-tei-patient.fsh`, `ig/input/fsh/models/mapping-dvs-measurereport.fsh`
