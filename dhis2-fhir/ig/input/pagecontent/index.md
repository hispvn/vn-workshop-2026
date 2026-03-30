### DHIS2-FHIR Learning Implementation Guide

This Implementation Guide (IG) demonstrates how [DHIS2](https://dhis2.org) health information system concepts map to [HL7 FHIR](https://hl7.org/fhir/) resources. It serves as both a learning resource and a reference implementation for DHIS2-to-FHIR interoperability.

#### Core Profiles

| Profile | Base Resource | DHIS2 Concept |
|---------|--------------|---------------|
| **DHIS2Patient** | Patient | Tracked Entity Instance (Person) |
| **DHIS2Organization** | Organization | Organisation Unit (administrative) |
| **DHIS2Location** | Location | Organisation Unit (physical site) |
| **DHIS2Encounter** | Encounter | Tracker Event (visit context) |
| **DHIS2EpisodeOfCare** | EpisodeOfCare | Enrollment (program participation) |
| **DHIS2Observation** | Observation | Data Value (clinical measurement) |
| **DHIS2Questionnaire** | Questionnaire | Program Stage (form definition) |
| **DHIS2QuestionnaireResponse** | QuestionnaireResponse | Event (completed form submission) |
| **DHIS2Measure** | Measure | Indicator / Data Set definition |
| **DHIS2MeasureReport** | MeasureReport | Indicator value / Data Value Set |
| **DHIS2DataCollectionReport** | MeasureReport | Monthly facility report |

#### Extensions

- **DHIS2OrgUnitExtension** — Links a resource to its DHIS2 organisation unit
- **DHIS2ProgramExtension** — Identifies the DHIS2 program (tracker vs event)
- **DHIS2DataElementExtension** — Links an Observation to its DHIS2 data element metadata
- **DHIS2CategoryComboExtension** — Carries the DHIS2 category option combination for disaggregation

#### Terminology

The IG defines 17 CodeSystems and ValueSets covering DHIS2 concepts:

- **System types**: Data element types, program types, event/enrollment status, aggregation types, org unit levels, org unit groups
- **Option sets**: Gender, Yes/No, Test Result, HIV Status, Visit Type, Delivery Mode, Malaria Species, Immunization Vaccines, Pregnancy Outcome

These map DHIS2 option sets to FHIR coded terminology, enabling structured data exchange.

#### Key Patterns

**Events as QuestionnaireResponses** — DHIS2 events (form submissions) are modelled as FHIR QuestionnaireResponse resources. The program stage defines the Questionnaire (form structure), and each event submission becomes a QuestionnaireResponse. This preserves the form structure, supports both tracker programs (with patient link) and event programs (anonymous), and enables round-tripping.

**Aggregate data as Measure/MeasureReport** — DHIS2 data sets and indicators map to FHIR Measure (definition) and MeasureReport (reported values). Monthly facility reports use the `data-collection` report type, while calculated indicators use `summary` reports with proportion/cohort scoring.

**Organisation unit hierarchy** — DHIS2 org units map to Organization (administrative identity) and Location (physical site with GPS coordinates), linked via `managingOrganization`. The `partOf` element preserves the org unit hierarchy.

#### Logical Models

Two logical models document the DHIS2 API data structures:

- **DHIS2TrackedEntityInstance** — with nested attributes, enrollments, events, and data values
- **DHIS2DataValueSet** — aggregate data submission with period, org unit, and data values

Mappings document the field-level relationships from these structures to FHIR resources.

#### Examples

The IG includes 63 example instances across three patients and two facilities, demonstrating real-world clinical workflows:

| Patient | Setting | Clinical Story |
|---------|---------|---------------|
| **Jane Doe** (Malawi, F, 35y) | ANC at Facility Alpha | 2 ANC visits, weight/hemoglobin/BP/malaria RDT observations, 5 form submissions |
| **John Kamau** (Kenya, M, 40y) | Malaria at Facility Beta | Fever (38.9°C), positive malaria RDT, ACT treatment, follow-up with negative RDT |
| **Amina Hassan** (Kenya, F, 33y) | ANC at Facility Beta | 2 ANC visits, anemia detected (Hb 10.2→11.8 after iron), HIV test, malaria screening |

Resources: 3 Patients, 6 Encounters, 3 EpisodesOfCare, 15 Observations, 5 Questionnaires, 10 QuestionnaireResponses, 3 Measures, 3 MeasureReports, 2 Bundles, 4 Organizations, 2 Locations.

#### Project Structure

```
ig/input/fsh/
├── foundation/       Aliases, extensions, invariants, rulesets
├── terminology/      CodeSystems and ValueSets (one file per option set)
├── patient/          DHIS2Patient profile and examples
├── organization/     Organization + Location profiles and examples
├── clinical/         Observation, Encounter, EpisodeOfCare
├── questionnaire/    Form definitions + completed event responses
├── measure/          Aggregate reporting profiles and examples
├── models/           Logical models and mappings
└── bundles/          Transaction and collection bundle examples
```

#### Getting Started

```sh
make docker-sushi    # Compile FSH → JSON
make docker-build    # Full IG Publisher build (SUSHI + validation + HTML)
make run             # Render Questionnaires locally (http://localhost:8000)
```
