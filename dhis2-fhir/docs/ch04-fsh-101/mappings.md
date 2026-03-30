# Mappings

**Mappings** document how elements in one model relate to elements in another. In the DHIS2-FHIR context, mappings describe how fields from a DHIS2 data structure (expressed as a Logical Model) correspond to elements in a FHIR resource or profile.

An important clarification: FSH mappings are **documentation**, not executable transformation code. They do not generate a converter or ETL pipeline. What they do is produce structured metadata in your Implementation Guide that humans and tools can use as a specification for building actual transformations.

## Syntax reference

```fsh
Mapping:  <name>
Source:   <source-model-or-profile>
Target:   "<target-uri>"
Id:       <id>
Title:    "<title>"

* <source-path> -> "<target-path>" "<comment>"
```

| Keyword | Purpose |
|---------|---------|
| `Source` | The FSH profile or logical model being mapped **from**. |
| `Target` | A URI identifying the target specification (often a FHIR resource URL). |
| `->` | The mapping arrow. Left side is source path, right side (in quotes) is target path. |

## Example 1: Tracked Entity Instance to Patient

Map the DHIS2 Tracked Entity Instance logical model to FHIR Patient.

```fsh
Mapping:  TEIToPatient
Source:   DHIS2TrackedEntityInstance
Target:   "http://hl7.org/fhir/StructureDefinition/Patient"
Id:       tei-to-patient
Title:    "DHIS2 TEI to FHIR Patient"

* uid -> "Patient.identifier.value" "TEI UID becomes Patient identifier"
* orgUnit -> "Patient.managingOrganization.reference" "Map to managing org"
* attributes -> "Patient" "Attributes map to various Patient fields"
* enrollments -> "Patient.extension" "Enrollments captured via extension"
```

Each line maps a source element path to a target element path, with an optional comment explaining the rationale.

## Example 2: Data Element to Observation

Map the DHIS2 Data Element logical model to a FHIR Observation.

```fsh
Mapping:  DataElementToObservation
Source:   DHIS2DataElement
Target:   "http://hl7.org/fhir/StructureDefinition/Observation"
Id:       data-element-to-observation
Title:    "DHIS2 Data Element to FHIR Observation"

* uid -> "Observation.identifier.value" "Data element UID"
* name -> "Observation.code.text" "Data element name becomes code display text"
* code -> "Observation.code.coding.code" "DHIS2 code maps to coding code"
* description -> "Observation.note.text" "Description as a note"
* valueType -> "Observation.value[x]" "Determines which value type to use"
* domainType -> "Observation.category" "Aggregate vs Tracker as category"
```

## Example 3: Mapping on a profile

You can also attach mappings directly to a profile, which is useful for documenting how your constrained resource maps to external standards.

```fsh
Mapping:  DHIS2PatientToCSV
Source:   DHIS2Patient
Target:   "https://example.org/dhis2-csv-export"
Id:       dhis2-patient-to-csv
Title:    "DHIS2 Patient to CSV Export"

* identifier.value -> "column:tei_uid" "First column in CSV"
* name.family -> "column:last_name" "Second column"
* name.given -> "column:first_name" "Third column"
* gender -> "column:sex" "Fourth column"
* birthDate -> "column:dob" "Fifth column, format YYYY-MM-DD"
```

The `Target` does not have to be a FHIR resource URL. It can be any URI that identifies the target model, making mappings flexible enough to document relationships with CSV schemas, database tables, or API payloads.

## What mappings look like in the IG

When the IG publisher renders your Implementation Guide, mappings appear as a table on the profile or logical model page. Readers can see, at a glance, which source element maps to which target element and why.

This is valuable for:

- **Developers** building data pipelines between DHIS2 and FHIR servers
- **Analysts** reviewing whether the mapping covers all required fields
- **Governance teams** approving data exchange specifications

## Key takeaways

- Mappings are **metadata**, not executable code. They document intent.
- The `Source` must be a FSH artifact (profile or logical model) defined in your project.
- The `Target` is a URI string. It does not need to resolve to a FSH artifact.
- Mappings pair naturally with Logical Models: define the source structure as a Logical Model, then map it to FHIR.
- Real-world transformation logic (FHIR Mapping Language, StructureMap, custom code) can be built from these documented mappings.

## Exercise

Open `exercises/ch04-mappings/` and complete the exercise. You will write a mapping from the DHIS2 Event logical model (from the previous exercise) to a FHIR Encounter resource, mapping uid, orgUnit, eventDate, and status.
