// Exercise 04: Instances - Solution
// Two DHIS2 Patient example instances with realistic data.

Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203

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
Description: "A male DHIS2 Patient example from Kenya."
* identifier[0].system = "http://dhis2.org/fhir/id/tracked-entity"
* identifier[0].type = $V2-0203#RI "Resource identifier"
* identifier[0].value = "AbC1dEf2gHi"
* identifier[1].system = "http://national-id.example.org"
* identifier[1].type = $V2-0203#NI "National unique individual identifier"
* identifier[1].value = "KE-12345678"
* name.given = "John"
* name.family = "Kamau"
* gender = #male
* birthDate = "1985-08-22"

Instance: PatientExampleFemale
InstanceOf: DHIS2Patient
Title: "Patient Example - Amina Hassan"
Description: "A female DHIS2 Patient example from Kenya."
* identifier[0].system = "http://dhis2.org/fhir/id/tracked-entity"
* identifier[0].type = $V2-0203#RI "Resource identifier"
* identifier[0].value = "XyZ9wVu8tSr"
* identifier[1].system = "http://national-id.example.org"
* identifier[1].type = $V2-0203#NI "National unique individual identifier"
* identifier[1].value = "KE-87654321"
* name.given = "Amina"
* name.family = "Hassan"
* gender = #female
* birthDate = "1992-11-03"
