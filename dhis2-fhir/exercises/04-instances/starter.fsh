// Exercise 04: Instances - Starter File
// Create two DHIS2 Patient example instances.

Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203

// A simple profile for the instances to conform to
Profile: DHIS2Patient
Parent: Patient
Id: dhis2-patient-ex04
Title: "DHIS2 Patient (Exercise 04)"
Description: "A Patient profile for exercise 04."
* identifier 1..* MS
* name 1..* MS
* birthDate 1..1 MS
* gender 1..1 MS

Instance: PatientExampleMale
InstanceOf: DHIS2Patient
Title: "Patient Example - John Kamau"
Description: "A male DHIS2 Patient example."
// TODO: Add a DHIS2 UID identifier with system http://dhis2.org/fhir/id/tracked-entity and value AbC1dEf2gHi
// TODO: Add a national ID identifier with system http://national-id.example.org and value KE-12345678
// TODO: Set name (given: John, family: Kamau)
// TODO: Set gender to male
// TODO: Set birthDate to 1985-08-22

Instance: PatientExampleFemale
InstanceOf: DHIS2Patient
Title: "Patient Example - Amina Hassan"
Description: "A female DHIS2 Patient example."
// TODO: Add a DHIS2 UID identifier with system http://dhis2.org/fhir/id/tracked-entity and value XyZ9wVu8tSr
// TODO: Add a national ID identifier with system http://national-id.example.org and value KE-87654321
// TODO: Set name (given: Amina, family: Hassan)
// TODO: Set gender to female
// TODO: Set birthDate to 1992-11-03
