// Exercise 10: Slicing - Solution
// Patient.identifier sliced for DHIS2 UID and national ID.

Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203

Profile: DHIS2PatientSliced
Parent: Patient
Id: dhis2-patient-sliced
Title: "DHIS2 Patient with Sliced Identifiers"
Description: "A Patient profile with sliced identifiers for DHIS2 UID and national ID."
* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice on identifier type"
* identifier contains
    dhis2uid 1..1 MS and
    national 0..1 MS
* identifier[dhis2uid].system = "http://dhis2.org/fhir/id/tracked-entity"
* identifier[dhis2uid].type = $V2-0203#RI "Resource identifier"
* identifier[national].type = $V2-0203#NI "National unique individual identifier"
* name 1..* MS
* birthDate 1..1 MS
* gender 1..1 MS
