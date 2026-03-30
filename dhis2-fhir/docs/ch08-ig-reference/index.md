# Part VII: IG Profile Reference

This section provides a detailed walkthrough of every artifact defined in the DHIS2-FHIR Implementation Guide. While earlier chapters taught the *concepts* of FHIR, FSH, and DHIS2 mapping, this chapter serves as a **reference manual** for the actual profiles, extensions, terminology, and examples that make up the IG.

## What This Chapter Covers

The DHIS2-FHIR IG defines a comprehensive set of artifacts for representing DHIS2 data in FHIR:

**Profiles** -- Constrained versions of FHIR resources tailored for DHIS2 data:

- [DHIS2Patient](patient-profile.md) -- Tracked Entity Instances of type Person
- [DHIS2Organization and DHIS2Location](organization-profiles.md) -- Organisation Unit hierarchy
- [DHIS2Observation, DHIS2Encounter, DHIS2EpisodeOfCare](clinical-profiles.md) -- Clinical data
- [DHIS2Questionnaire and DHIS2QuestionnaireResponse](questionnaire-profiles.md) -- Form-based data capture
- [DHIS2Measure, DHIS2MeasureReport, DHIS2DataCollectionReport](measure-profiles.md) -- Aggregate reporting

**Extensions** -- Custom data elements for DHIS2-specific concepts:

- [All four extensions](extensions.md) -- OrgUnit, Program, DataElement, CategoryCombo

**Terminology** -- Code systems and value sets for DHIS2 coded data:

- [15 CodeSystem/ValueSet pairs](terminology.md) -- Data element types, program types, option sets

**Examples** -- Concrete instances demonstrating real-world usage:

- [Bundle examples](bundles.md) -- Transaction and collection bundles
- [Logical models and mappings](logical-models.md) -- Source data structures and field-level mappings

## How to Use This Reference

Each page in this chapter follows a consistent structure:

1. **DHIS2 context** -- What DHIS2 concept the artifact represents
2. **FHIR mapping rationale** -- Why this particular FHIR resource or pattern was chosen
3. **Constraints and cardinality** -- What the profile requires, allows, and forbids
4. **FSH source code** -- The complete FSH definition
5. **Example JSON** -- What conforming instances look like (where applicable)

This chapter complements the FSH source files in `ig/input/fsh/`. When you need to understand *what* an artifact does, read this chapter. When you need to *modify* it, edit the FSH source files directly.

## Artifact Summary

| Category | Count | Description |
|----------|-------|-------------|
| Profiles | 10 | Resource constraints for DHIS2 data |
| Extensions | 4 | Custom elements for DHIS2 concepts |
| Code Systems | 15 | DHIS2 coded value enumerations |
| Value Sets | 15 | Bindable sets for profile/extension use |
| Logical Models | 2 | DHIS2 API data structures |
| Mappings | 2 | Field-level source-to-target maps |
| Examples | 63 | Instances across three patients and two facilities |
| Bundles | 2 | Transaction and collection patterns |

## Example Data Set

The IG includes 63 example instances that tell coherent clinical stories across three patients and two facilities. These examples are designed to demonstrate realistic DHIS2 Tracker workflows, including multi-visit programs, clinical progression, and cross-facility data.

### Patients and Clinical Scenarios

| Patient | Context | Encounters | Observations | QRs | Enrollment |
|---------|---------|------------|--------------|-----|------------|
| Jane Doe (Malawi, female, 35y) | ANC program at Facility Alpha | 2 ANC visits | Weight, Hemoglobin, Blood Pressure, Malaria RDT | 5 (ANC, Malaria, Immunization) | ANC enrollment (active) |
| John Kamau (Kenya, male, 40y) | Malaria case at Facility Beta | Initial + follow-up | Temperature (38.9°C), Malaria RDT (positive then negative), Weight | 1 (Malaria) | Malaria case (completed) |
| Amina Hassan (Kenya, female, 33y) | ANC program at Facility Beta | 2 ANC visits | Weight (x2), Hemoglobin (x2, showing improvement), Blood Pressure, Malaria RDT, HIV test | 2 (ANC, Delivery) | ANC enrollment (active) |

### Organisation Unit Hierarchy

- Ministry of Health (national)
  - District A
    - Facility Alpha Health Center (Lilongwe, Malawi) -- Jane Doe
    - Facility Beta Health Center (Nairobi, Kenya) -- John Kamau, Amina Hassan

### Clinical Stories

- **Jane Doe**: Enrolled in ANC, 2 visits with vital signs and lab tests, all normal
- **John Kamau**: Presents with fever (38.9°C), positive malaria RDT, treated with ACT, follow-up shows negative RDT -- completed case
- **Amina Hassan**: ANC enrollment with anemia detected (Hb 10.2), iron supplements prescribed, follow-up shows improvement (Hb 11.8), HIV test negative
