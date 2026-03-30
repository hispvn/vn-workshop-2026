// ----------------------------------------------------------------------------
// Instance: QuestionnaireChildImmunization
// ----------------------------------------------------------------------------
// Child Immunization Form — a DHIS2 tracker program stage for recording
// vaccine administration details.
//
// Program stage UID: ZzYYXq4fJie
// Program: Expanded Programme on Immunization (tracker, WITH_REGISTRATION)
//
// This form demonstrates:
//   - enableWhen for adverse event description (only shown if adverse event = YES)
//   - Date fields for scheduling (next appointment)
//   - String fields for batch tracking
//
// Data elements (7 items):
//   hYyB7FUS5eR — Vaccine given (option set -> DHIS2ImmunizationVaccineVS)
//   LNqkAlvGplL — Dose number (integer)
//   rxBfISxXS2U — Batch number (string)
//   ebaJjqltK5N — Date administered (date)
//   rQLFnNXXIL0 — Adverse event observed (option set -> DHIS2YesNoVS)
//   OuJ6sgPyAbC — Adverse event description (text, conditional)
//   m6qECbJgJGS — Next appointment date (date)
// ----------------------------------------------------------------------------

Instance: QuestionnaireChildImmunization
InstanceOf: DHIS2Questionnaire
Title: "Child Immunization Form"
Description: "Child immunization data entry form — a DHIS2 tracker program stage for recording vaccine type, dose, batch number, adverse events, and follow-up scheduling."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireChildImmunization"

* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].value = "ZzYYXq4fJie"

* name = "ChildImmunizationForm"
* title = "Child Immunization Form"
* status = #active
* subjectType = #Patient

// --- Item 1: Vaccine Given ---
* item[0].linkId = "hYyB7FUS5eR"
* item[0].text = "Vaccine given"
* item[0].type = #choice
* item[0].required = true
* item[0].answerValueSet = Canonical(DHIS2ImmunizationVaccineVS)

// --- Item 2: Dose Number ---
* item[1].linkId = "LNqkAlvGplL"
* item[1].text = "Dose number"
* item[1].type = #integer
* item[1].required = true

// --- Item 3: Batch Number ---
// String type (not text) — a short identifier, not free text.
* item[2].linkId = "rxBfISxXS2U"
* item[2].text = "Batch number"
* item[2].type = #string

// --- Item 4: Date Administered ---
* item[3].linkId = "ebaJjqltK5N"
* item[3].text = "Date administered"
* item[3].type = #date
* item[3].required = true

// --- Item 5: Adverse Event Observed ---
* item[4].linkId = "rQLFnNXXIL0"
* item[4].text = "Adverse event observed"
* item[4].type = #choice
* item[4].answerValueSet = Canonical(DHIS2YesNoVS)

// --- Item 6: Adverse Event Description ---
// enableWhen: only shown when adverse event = YES.
// In DHIS2, a program rule hides this field unless the adverse event
// flag is set to YES.
* item[5].linkId = "OuJ6sgPyAbC"
* item[5].text = "Adverse event description"
* item[5].type = #text
* item[5].enableWhen[0].question = "rQLFnNXXIL0"
* item[5].enableWhen[0].operator = #=
* item[5].enableWhen[0].answerCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES

// --- Item 7: Next Appointment Date ---
* item[6].linkId = "m6qECbJgJGS"
* item[6].text = "Next appointment date"
* item[6].type = #date