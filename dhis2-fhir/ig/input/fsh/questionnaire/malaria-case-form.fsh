// ----------------------------------------------------------------------------
// Instance: QuestionnaireMalariaCase
// ----------------------------------------------------------------------------
// Malaria Case Investigation Form — a DHIS2 tracker program stage for
// recording malaria case details including symptoms, test results, treatment,
// and epidemiological information.
//
// Program stage UID: pTo4uMt3xur
// Program: Malaria Case Management (tracker, WITH_REGISTRATION)
//
// This form demonstrates enableWhen — DHIS2 program rules that conditionally
// show/hide fields based on other answers. Here, the "Malaria species" and
// "Parasite density" fields only appear when the RDT result is POSITIVE.
// In DHIS2, this is implemented as a program rule:
//   WHEN #{bx6fsa0t90x} == 'POSITIVE' THEN SHOW #{pCiAvXGclgy}, #{J5BhSYzHiOy}
// In FHIR, this maps to enableWhen on the conditional items.
//
// Data elements (11 items):
//   bOYWVEBaWy6 — Date of symptom onset (date)
//   fWIAEtYVEGk — Fever present (option set -> DHIS2YesNoVS)
//   CYaPLMARlPm — Temperature °C (number)
//   bx6fsa0t90x — RDT result (option set -> DHIS2TestResultVS)
//   pCiAvXGclgy — Malaria species (option set, conditional)
//   J5BhSYzHiOy — Parasite density /uL (integer, conditional)
//   sPDKWSQ2bKR — Pregnant (option set -> DHIS2YesNoUnknownVS)
//   ITsYPKclgfy — Bed net used last night (option set -> DHIS2YesNoVS)
//   G7vUx908SwP — Travel history 2 weeks (option set -> DHIS2YesNoVS)
//   s46m5MS0hxu — Treatment given (text)
//   WjP7dP80yVo — Outcome (option set, inline answerOption)
// ----------------------------------------------------------------------------

Instance: QuestionnaireMalariaCase
InstanceOf: DHIS2Questionnaire
Title: "Malaria Case Investigation Form"
Description: "Malaria case investigation form — a DHIS2 tracker program stage for recording symptoms, test results, species identification, treatment, and epidemiological factors. Demonstrates enableWhen for conditional fields."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireMalariaCase"

* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].value = "pTo4uMt3xur"

* name = "MalariaCaseForm"
* title = "Malaria Case Investigation Form"
* status = #active
* subjectType = #Patient

// --- Item 1: Date of Symptom Onset ---
* item[0].linkId = "bOYWVEBaWy6"
* item[0].text = "Date of symptom onset"
* item[0].type = #date
* item[0].required = true

// --- Item 2: Fever Present ---
* item[1].linkId = "fWIAEtYVEGk"
* item[1].text = "Fever present"
* item[1].type = #choice
* item[1].required = true
* item[1].answerValueSet = Canonical(DHIS2YesNoVS)

// --- Item 3: Temperature (°C) ---
* item[2].linkId = "CYaPLMARlPm"
* item[2].text = "Temperature (°C)"
* item[2].type = #decimal

// --- Item 4: RDT Result ---
// This is the "trigger" field for the enableWhen logic below.
* item[3].linkId = "bx6fsa0t90x"
* item[3].text = "Malaria rapid diagnostic test (RDT) result"
* item[3].type = #choice
* item[3].required = true
* item[3].answerValueSet = Canonical(DHIS2TestResultVS)

// --- Item 5: Malaria Species ---
// enableWhen: only shown when RDT result = POSITIVE.
// In DHIS2, this is a program rule: SHOW field when #{bx6fsa0t90x} == 'POSITIVE'
// In FHIR, enableWhen references the linkId of the trigger field and the
// expected answer value.
* item[4].linkId = "pCiAvXGclgy"
* item[4].text = "Malaria species"
* item[4].type = #choice
* item[4].answerValueSet = Canonical(DHIS2MalariaSpeciesVS)
* item[4].enableWhen[0].question = "bx6fsa0t90x"
* item[4].enableWhen[0].operator = #=
* item[4].enableWhen[0].answerCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#POSITIVE

// --- Item 6: Parasite Density ---
// enableWhen: only shown when RDT result = POSITIVE (same logic as species).
* item[5].linkId = "J5BhSYzHiOy"
* item[5].text = "Parasite density (/uL)"
* item[5].type = #integer
* item[5].enableWhen[0].question = "bx6fsa0t90x"
* item[5].enableWhen[0].operator = #=
* item[5].enableWhen[0].answerCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#POSITIVE

// --- Item 7: Pregnant ---
// Uses DHIS2YesNoUnknownVS (YES/NO/UNKNOWN) — important for treatment
// decisions as some antimalarials are contraindicated in pregnancy.
* item[6].linkId = "sPDKWSQ2bKR"
* item[6].text = "Pregnant"
* item[6].type = #choice
* item[6].answerValueSet = Canonical(DHIS2YesNoUnknownVS)

// --- Item 8: Bed Net Used Last Night ---
* item[7].linkId = "ITsYPKclgfy"
* item[7].text = "Bed net used last night"
* item[7].type = #choice
* item[7].answerValueSet = Canonical(DHIS2YesNoVS)

// --- Item 9: Travel History (2 weeks) ---
// Epidemiological factor for malaria surveillance — helps determine if
// the case is locally acquired or imported.
* item[8].linkId = "G7vUx908SwP"
* item[8].text = "Travel history in past 2 weeks"
* item[8].type = #choice
* item[8].answerValueSet = Canonical(DHIS2YesNoVS)

// --- Item 10: Treatment Given ---
// Free text describing the treatment prescribed.
* item[9].linkId = "s46m5MS0hxu"
* item[9].text = "Treatment given"
* item[9].type = #text

// --- Item 11: Outcome ---
// Uses inline answerOption instead of answerValueSet — demonstrates the
// alternative approach for small, form-specific option lists that don't
// warrant a separate ValueSet.
* item[10].linkId = "WjP7dP80yVo"
* item[10].text = "Outcome"
* item[10].type = #choice
* item[10].answerOption[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#CURED "Cured"
* item[10].answerOption[1].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#TREATMENT_FAILURE "Treatment failure"
* item[10].answerOption[2].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#REFERRED "Referred"
* item[10].answerOption[3].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#DEATH "Death"