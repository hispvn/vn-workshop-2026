// Exercise 10: Slicing - Starter File
// Slice Patient.identifier for DHIS2 UID vs national ID.

Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203

Profile: DHIS2PatientSliced
Parent: Patient
Id: dhis2-patient-sliced
Title: "DHIS2 Patient with Sliced Identifiers"
Description: "A Patient profile with sliced identifiers for DHIS2 UID and national ID."
* identifier 1..* MS

// TODO: Set up slicing discriminator
// - discriminator type: #pattern
// - discriminator path: "type"
// - rules: #open
// - description: "Slice on identifier type"

// TODO: Define the slices using 'contains'
// - dhis2uid 1..1 MS
// - national 0..1 MS

// TODO: Constrain dhis2uid slice
// - system = "http://dhis2.org/fhir/id/tracked-entity"
// - type = $V2-0203#RI "Resource identifier"

// TODO: Constrain national slice
// - type = $V2-0203#NI "National unique individual identifier"

* name 1..* MS
* birthDate 1..1 MS
* gender 1..1 MS
