# Exercise 06: Mappings

## Objective

Create a formal mapping from the DHIS2 Tracked Entity Instance logical model to the FHIR Patient resource.

## Background

FSH Mapping definitions document the relationship between a source structure and a target structure. They do not generate executable transformation code, but they produce a formal, published record of how fields correspond. This is valuable for implementers building integration engines and for reviewers validating that the mapping is correct.

Mappings reference a source (typically a logical model or profile) and declare a target specification (identified by a URI). Each rule maps a source element to a target element path.

## Requirements

Create a Mapping named `DHIS2TEItoPatient`:

- Source: `DHIS2TrackedEntityInstance` (the logical model from Exercise 05)
- Target: `http://hl7.org/fhir/StructureDefinition/Patient`
- Id: `dhis2-tei-to-patient`

Map the following elements:

| Source | Target | Comment |
|---|---|---|
| uid | Patient.identifier.value | DHIS2 UID becomes an identifier |
| orgUnit | Patient.managingOrganization.reference | Reference to the org unit |
| attributes (where attribute = firstName) | Patient.name.given | First name attribute |
| attributes (where attribute = lastName) | Patient.name.family | Last name attribute |
| attributes (where attribute = dateOfBirth) | Patient.birthDate | Date of birth |
| attributes (where attribute = gender) | Patient.gender | Administrative gender |

## Instructions

1. Open `starter.fsh`
2. Fill in the mapping rules
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
Mapping: MappingName
Source: SourceProfileOrLogical
Target: "target-uri"
Id: mapping-id
Title: "Title"
* sourceElement -> "targetPath" "Comment"
```
