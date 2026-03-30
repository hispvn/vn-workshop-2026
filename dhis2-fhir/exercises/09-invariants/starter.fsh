// Exercise 09: Invariants - Starter File
// Create FHIRPath invariants for DHIS2 validation rules.

// TODO: Define invariant dhis2-uid-format
// - Description: "DHIS2 UID must be exactly 11 alphanumeric characters"
// - Severity: #error
// - Expression: matches('^[a-zA-Z][a-zA-Z0-9]{10}$')

// TODO: Define invariant dhis2-identifier-has-system
// - Description: "Every identifier must have a system"
// - Severity: #error
// - Expression: system.exists()

Profile: DHIS2PatientWithInvariants
Parent: Patient
Id: dhis2-patient-invariants
Title: "DHIS2 Patient with Invariants"
Description: "A Patient profile with DHIS2 validation invariants."
* identifier 1..* MS
// TODO: Apply dhis2-identifier-has-system to identifier
* name 1..* MS
* birthDate 1..1 MS
* gender 1..1 MS
