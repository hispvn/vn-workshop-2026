// Exercise 08: Aliases - Starter File
// Define aliases for common URIs and use them.

// TODO: Define alias $SCT for http://snomed.info/sct
// TODO: Define alias $LOINC for http://loinc.org
// TODO: Define alias $UCUM for http://unitsofmeasure.org
// TODO: Define alias $V2-0203 for http://terminology.hl7.org/CodeSystem/v2-0203
// TODO: Define alias $DHIS2 for http://dhis2.org/fhir
// TODO: Define alias $DHIS2TEI for http://dhis2.org/fhir/id/tracked-entity

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
// TODO: Use $DHIS2TEI alias for identifier[0].system
// TODO: Use $V2-0203 alias for identifier[0].type
// TODO: Set identifier[0].value to "AbC1dEf2gHi"
// TODO: Set name, gender, birthDate
