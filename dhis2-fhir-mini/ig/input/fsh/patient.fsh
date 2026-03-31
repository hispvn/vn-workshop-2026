Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203

Profile: MyPatient
Parent: Patient
Id: my-patient
Title: "My Patient"
Description: "A simple Patient profile to get started with FHIR profiling."

* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open

* identifier contains national 0..1 MS
* identifier[national].type 1..1
* identifier[national].type = $V2-0203#NI
* identifier[national].value 1..1

* name 1..* MS
* name.family 1..1
* name.given 1..*

* gender 1..1 MS
* birthDate 1..1 MS
* birthDate obeys birthdate-not-future

Invariant: birthdate-not-future
Description: "Birth date must not be in the future"
Expression: "$this <= today()"
Severity: #error


// --- Example ---

Instance: PatientExample
InstanceOf: MyPatient
Title: "Example Patient"
Description: "A minimal example of a profiled Patient."
* identifier[national].type = $V2-0203#NI
* identifier[national].value = "1234567890"
* name.family = "Nguyen"
* name.given = "Linh"
* gender = #female
* birthDate = "1990-05-15"
