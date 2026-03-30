// Exercise 01: Profiles - Solution
// A DHIS2Patient profile constraining the FHIR Patient resource.

Profile: DHIS2Patient
Parent: Patient
Id: dhis2-patient
Title: "DHIS2 Patient"
Description: "A Patient profile representing a DHIS2 Tracked Entity Instance of type Person."
* identifier 1..* MS
* name 1..* MS
* birthDate 1..1 MS
* gender 1..1 MS
