// ----------------------------------------------------------------------------
// Instance: QuestionnaireDiseaseNotification
// ----------------------------------------------------------------------------
// Notifiable Disease Report — a DHIS2 EVENT PROGRAM (WITHOUT_REGISTRATION)
// form for reporting cases of notifiable diseases at facility level.
//
// Program stage UID: LpWNjNGvCO5
// Program: Disease Surveillance (event program, WITHOUT_REGISTRATION)
//
// CRITICAL DIFFERENCE: This is an event program, NOT a tracker program.
//   - There is NO subjectType — data is not linked to a registered individual
//   - QuestionnaireResponses for this form will have NO subject reference
//   - The form captures age and sex as data elements (not from a Patient resource)
//   - This models DHIS2 event programs used for aggregate surveillance
//
// This form also demonstrates:
//   - enableWhen for lab result (only shown if sample collected = YES)
//   - Inline answerOption for disease list and patient condition
//
// Data elements (9 items):
//   oZg33kd9taw — Disease (inline option list)
//   qrur9Dvnyt5 — Age of patient (integer)
//   oindugucx72 — Sex (option set -> DHIS2GenderVS)
//   bOYWVEBaWy6 — Date of onset (date)
//   PVQH9dSknDi — Patient condition (inline option list)
//   SZo9E0gFiRq — Lab sample collected (option set -> DHIS2YesNoVS)
//   Gy2SSAX5hhb — Lab result (option set, conditional)
//   s46m5MS0hxu — Treatment given (text)
//   uf3svrMdhhH — Comment (text)
// ----------------------------------------------------------------------------

Instance: QuestionnaireDiseaseNotification
InstanceOf: DHIS2Questionnaire
Title: "Notifiable Disease Report Form"
Description: "Notifiable disease reporting form — a DHIS2 event program (anonymous, no patient registration) for disease surveillance. Reports cases of cholera, measles, meningitis, and other notifiable diseases at facility level."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireDiseaseNotification"

* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].value = "LpWNjNGvCO5"

* name = "DiseaseNotificationForm"
* title = "Notifiable Disease Report"
* status = #active

// NO subjectType — this is an event program (WITHOUT_REGISTRATION).
// Data is captured at facility level, not linked to a registered individual.
// Age and sex are captured as data elements within the form itself.

// --- Item 1: Disease ---
// Inline answerOption for the list of notifiable diseases.
* item[0].linkId = "oZg33kd9taw"
* item[0].text = "Disease"
* item[0].type = #choice
* item[0].required = true
* item[0].answerOption[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#CHOLERA "Cholera"
* item[0].answerOption[1].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#MEASLES "Measles"
* item[0].answerOption[2].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#MENINGITIS "Meningitis"
* item[0].answerOption[3].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#YELLOW_FEVER "Yellow Fever"
* item[0].answerOption[4].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#PLAGUE "Plague"
* item[0].answerOption[5].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#RABIES "Rabies"
* item[0].answerOption[6].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#TYPHOID "Typhoid"

// --- Item 2: Age of Patient ---
// Since this is an event program with no registered patient, demographics
// like age are captured directly in the form as data elements.
* item[1].linkId = "qrur9Dvnyt5"
* item[1].text = "Age of patient (years)"
* item[1].type = #integer
* item[1].required = true

// --- Item 3: Sex ---
* item[2].linkId = "oindugucx72"
* item[2].text = "Sex"
* item[2].type = #choice
* item[2].required = true
* item[2].answerValueSet = Canonical(DHIS2GenderVS)

// --- Item 4: Date of Onset ---
* item[3].linkId = "bOYWVEBaWy6"
* item[3].text = "Date of onset"
* item[3].type = #date
* item[3].required = true

// --- Item 5: Patient Condition ---
* item[4].linkId = "PVQH9dSknDi"
* item[4].text = "Patient condition"
* item[4].type = #choice
* item[4].answerOption[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#ALIVE "Alive"
* item[4].answerOption[1].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#DEAD "Dead"
* item[4].answerOption[2].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#UNKNOWN "Unknown"

// --- Item 6: Lab Sample Collected ---
* item[5].linkId = "SZo9E0gFiRq"
* item[5].text = "Lab sample collected"
* item[5].type = #choice
* item[5].answerValueSet = Canonical(DHIS2YesNoVS)

// --- Item 7: Lab Result ---
// enableWhen: only shown when lab sample collected = YES.
// In DHIS2, a program rule hides this field unless the sample was collected.
* item[6].linkId = "Gy2SSAX5hhb"
* item[6].text = "Lab result"
* item[6].type = #choice
* item[6].answerValueSet = Canonical(DHIS2TestResultVS)
* item[6].enableWhen[0].question = "SZo9E0gFiRq"
* item[6].enableWhen[0].operator = #=
* item[6].enableWhen[0].answerCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES

// --- Item 8: Treatment Given ---
* item[7].linkId = "s46m5MS0hxu"
* item[7].text = "Treatment given"
* item[7].type = #text

// --- Item 9: Comment ---
* item[8].linkId = "uf3svrMdhhH"
* item[8].text = "Comment"
* item[8].type = #text