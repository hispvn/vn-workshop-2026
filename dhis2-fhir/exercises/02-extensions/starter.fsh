// Exercise 02: Extensions - Starter File
// Create a DHIS2 Organisation Unit extension and apply it to a Patient profile.

Extension: DHIS2OrgUnitExtension
// TODO: Add Id (dhis2-org-unit)
// TODO: Add Title
// TODO: Add Description
// TODO: Set Context to Patient
// TODO: Constrain value[x] to only Reference(Organization)

Profile: DHIS2PatientWithOrgUnit
Parent: Patient
// TODO: Add Id (dhis2-patient-with-org-unit)
// TODO: Add Title
// TODO: Add Description
// TODO: Add the DHIS2OrgUnitExtension extension with cardinality 0..1 and MS flag
