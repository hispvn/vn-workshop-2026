// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseDiseaseNotification1
// ----------------------------------------------------------------------------
// ANONYMOUS disease notification — a cholera case report. This is an EVENT
// PROGRAM (WITHOUT_REGISTRATION) QuestionnaireResponse, which means:
//
//   - NO subject reference (no patient linked)
//   - Age and sex are captured as form fields (not from a Patient resource)
//   - The orgUnit extension identifies the reporting facility
//   - This is facility-level surveillance data, not individual patient data
//
// This is a critical distinction from the tracker program QRs above. In
// DHIS2, event programs are used for:
//   - Disease surveillance / case notifications
//   - Facility-level aggregate event reporting
//   - Anonymous data collection (no TEI registration)
//
// Clinical summary:
//   Disease: CHOLERA
//   Patient demographics: 34-year-old male (captured as form fields)
//   Onset: 2024-06-13 (2 days before report)
//   Condition: ALIVE
//   Lab: sample collected, POSITIVE result
//   Treatment: ORS and IV fluids, doxycycline
//   Comment: possible outbreak in market area
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseDiseaseNotification1
InstanceOf: DHIS2QuestionnaireResponse
Title: "Disease Notification — Cholera Case 1"
Description: "Anonymous disease notification for a cholera case on 2024-06-15. Lab-confirmed positive, 34-year-old male from market area. No subject reference (event program)."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireDiseaseNotification"
* status = #completed

// NO subject — this is an event program (WITHOUT_REGISTRATION).
// The data is anonymous, captured at facility level.
// Compare with the tracker QRs above which all have subject references.

* authored = "2024-06-15"

// Org unit: the facility reporting this case
* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)

* item[0].linkId = "oZg33kd9taw"
* item[0].text = "Disease"
* item[0].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#CHOLERA "Cholera"

// Demographics captured as form fields (not from a Patient resource)
* item[1].linkId = "qrur9Dvnyt5"
* item[1].text = "Age of patient (years)"
* item[1].answer[0].valueInteger = 34

* item[2].linkId = "oindugucx72"
* item[2].text = "Sex"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-gender#MALE "Male"

* item[3].linkId = "bOYWVEBaWy6"
* item[3].text = "Date of onset"
* item[3].answer[0].valueDate = "2024-06-13"

* item[4].linkId = "PVQH9dSknDi"
* item[4].text = "Patient condition"
* item[4].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#ALIVE "Alive"

* item[5].linkId = "SZo9E0gFiRq"
* item[5].text = "Lab sample collected"
* item[5].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES "Yes"

// Lab result is present because enableWhen condition is met (sample collected = YES)
* item[6].linkId = "Gy2SSAX5hhb"
* item[6].text = "Lab result"
* item[6].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#POSITIVE "Positive"

* item[7].linkId = "s46m5MS0hxu"
* item[7].text = "Treatment given"
* item[7].answer[0].valueString = "ORS and IV fluids, doxycycline"

* item[8].linkId = "uf3svrMdhhH"
* item[8].text = "Comment"
* item[8].answer[0].valueString = "Patient from market area, possible outbreak"


// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseDiseaseNotification2
// ----------------------------------------------------------------------------
// Second anonymous cholera case — reported one day after the first.
// Demonstrates epidemiological linking through narrative comments. In DHIS2,
// program indicators and analytics would detect the cluster of cases at the
// same org unit.
//
// Note: Lab sample was NOT collected for this case, so the lab result field
// is absent (enableWhen condition not met). Compare with the first case
// above where the lab result IS present.
//
// Clinical summary:
//   Disease: CHOLERA
//   Patient demographics: 28-year-old female
//   Onset: 2024-06-14
//   Condition: ALIVE
//   Lab: NO sample collected (so no lab result — enableWhen not triggered)
//   Treatment: ORS, zinc supplements
//   Comment: epidemiological link to first case
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseDiseaseNotification2
InstanceOf: DHIS2QuestionnaireResponse
Title: "Disease Notification — Cholera Case 2"
Description: "Anonymous disease notification for a second cholera case on 2024-06-16. No lab sample collected. 28-year-old female, epidemiological link to first case."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireDiseaseNotification"
* status = #completed

// NO subject — event program, anonymous data
* authored = "2024-06-16"

* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)

* item[0].linkId = "oZg33kd9taw"
* item[0].text = "Disease"
* item[0].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#CHOLERA "Cholera"

* item[1].linkId = "qrur9Dvnyt5"
* item[1].text = "Age of patient (years)"
* item[1].answer[0].valueInteger = 28

* item[2].linkId = "oindugucx72"
* item[2].text = "Sex"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-gender#FEMALE "Female"

* item[3].linkId = "bOYWVEBaWy6"
* item[3].text = "Date of onset"
* item[3].answer[0].valueDate = "2024-06-14"

* item[4].linkId = "PVQH9dSknDi"
* item[4].text = "Patient condition"
* item[4].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#ALIVE "Alive"

* item[5].linkId = "SZo9E0gFiRq"
* item[5].text = "Lab sample collected"
* item[5].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#NO "No"

// Note: Lab result (Gy2SSAX5hhb) is NOT present here because enableWhen
// condition is not met — lab sample collected = NO. In DHIS2, the program
// rule hides the lab result field when no sample was collected. In the FHIR
// QuestionnaireResponse, we simply omit the item.

* item[6].linkId = "s46m5MS0hxu"
* item[6].text = "Treatment given"
* item[6].answer[0].valueString = "ORS, zinc supplements"

* item[7].linkId = "uf3svrMdhhH"
* item[7].text = "Comment"
* item[7].answer[0].valueString = "Lives near first case, epidemiological link suspected"