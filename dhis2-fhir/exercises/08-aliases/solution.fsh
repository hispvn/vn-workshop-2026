// Exercise 08: Aliases - Solution
// Aliases for common URIs used throughout DHIS2-FHIR work.

Alias: $SCT = http://snomed.info/sct
Alias: $LOINC = http://loinc.org
Alias: $UCUM = http://unitsofmeasure.org
Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203
Alias: $DHIS2 = http://dhis2.org/fhir
Alias: $DHIS2TEI = http://dhis2.org/fhir/id/tracked-entity

Profile: DHIS2Patient
Parent: Patient
Id: dhis2-patient-ex08
Title: "DHIS2 Patient (Exercise 08)"
Description: "A Patient profile for exercise 08."
* identifier 1..* MS
* name 1..* MS
* birthDate 1..1 MS
* gender 1..1 MS

Instance: PatientWithAliases
InstanceOf: DHIS2Patient
Title: "Patient Using Aliases"
Description: "A patient instance demonstrating alias usage."
* identifier[0].system = $DHIS2TEI
* identifier[0].type = $V2-0203#RI "Resource identifier"
* identifier[0].value = "AbC1dEf2gHi"
* name.given = "Grace"
* name.family = "Banda"
* gender = #female
* birthDate = "1990-03-15"
