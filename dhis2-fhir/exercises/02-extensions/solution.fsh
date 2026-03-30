// Exercise 02: Extensions - Solution
// A DHIS2 Organisation Unit extension and a Patient profile that uses it.

Extension: DHIS2OrgUnitExtension
Id: dhis2-org-unit
Title: "DHIS2 Organisation Unit"
Description: "A reference to the DHIS2 Organisation Unit where the tracked entity is registered."
Context: Patient
* value[x] only Reference(Organization)

Profile: DHIS2PatientWithOrgUnit
Parent: Patient
Id: dhis2-patient-with-org-unit
Title: "DHIS2 Patient with Organisation Unit"
Description: "A Patient profile that includes the DHIS2 Organisation Unit extension."
* extension contains DHIS2OrgUnitExtension named dhis2OrgUnit 0..1 MS
