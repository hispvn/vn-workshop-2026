# Exercise 02: Extensions

## Objective

Create a FHIR extension that captures the DHIS2 Organisation Unit associated with a patient, then apply it to a Patient profile.

## Background

FHIR's base Patient resource has a `managingOrganization` element, but in DHIS2, a Tracked Entity Instance is registered at a specific Organisation Unit. To explicitly model this relationship as a DHIS2-specific concept, we create a custom extension that holds a reference to an Organization resource.

## Requirements

1. Create an extension named `DHIS2OrgUnitExtension`:
   - Id: `dhis2-org-unit`
   - Title and Description
   - Context: `Patient` (this extension applies to Patient resources)
   - Value type: `Reference(Organization)` with cardinality `0..1`

2. Create a profile named `DHIS2PatientWithOrgUnit`:
   - Parent: `Patient`
   - Id: `dhis2-patient-with-org-unit`
   - Apply the `DHIS2OrgUnitExtension` extension with cardinality `0..1` and Must Support

## Instructions

1. Open `starter.fsh`
2. Complete the extension definition by filling in the TODO comments
3. Complete the profile that uses the extension
4. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
Extension: ExtensionName
Id: extension-id
Title: "Title"
Description: "Description"
Context: ResourceType
* value[x] only Reference(TargetResource)

Profile: ProfileName
Parent: ParentResource
* extension contains ExtensionName named extensionSliceName 0..1 MS
```
