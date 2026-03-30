// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseMalariaJohn
// ----------------------------------------------------------------------------
// John Kamau's malaria case — a confirmed P. falciparum infection that was
// successfully treated. Demonstrates the enableWhen pattern in practice:
// because the RDT result is POSITIVE, the malaria species and parasite
// density fields are present with values.
//
// Clinical summary:
//   Symptom onset: 2024-03-18 (2 days before visit)
//   Fever: YES, Temperature: 38.9°C
//   RDT: POSITIVE -> Species: P. falciparum, Density: 45,000/uL
//   Pregnant: NO
//   Bed net: NO (risk factor!)
//   Travel history: YES (possible imported case)
//   Treatment: Artemether-lumefantrine (standard ACT for uncomplicated malaria)
//   Outcome: CURED
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseMalariaJohn
InstanceOf: DHIS2QuestionnaireResponse
Title: "John Kamau — Malaria Case Response"
Description: "Completed malaria case investigation for John Kamau on 2024-03-20. Confirmed P. falciparum (45,000/uL), treated with artemether-lumefantrine, outcome cured."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireMalariaCase"
* status = #completed
* subject = Reference(PatientJohnKamau)
* authored = "2024-03-20"

* item[0].linkId = "bOYWVEBaWy6"
* item[0].text = "Date of symptom onset"
* item[0].answer[0].valueDate = "2024-03-18"

* item[1].linkId = "fWIAEtYVEGk"
* item[1].text = "Fever present"
* item[1].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES "Yes"

* item[2].linkId = "CYaPLMARlPm"
* item[2].text = "Temperature (°C)"
* item[2].answer[0].valueDecimal = 38.9

* item[3].linkId = "bx6fsa0t90x"
* item[3].text = "Malaria rapid diagnostic test (RDT) result"
* item[3].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#POSITIVE "Positive"

// Species and density are present because RDT is POSITIVE (enableWhen satisfied)
* item[4].linkId = "pCiAvXGclgy"
* item[4].text = "Malaria species"
* item[4].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-malaria-species#P_FALCIPARUM "P. falciparum"

* item[5].linkId = "J5BhSYzHiOy"
* item[5].text = "Parasite density (/uL)"
* item[5].answer[0].valueInteger = 45000

* item[6].linkId = "sPDKWSQ2bKR"
* item[6].text = "Pregnant"
* item[6].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no-unknown#NO "No"

* item[7].linkId = "ITsYPKclgfy"
* item[7].text = "Bed net used last night"
* item[7].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#NO "No"

* item[8].linkId = "G7vUx908SwP"
* item[8].text = "Travel history in past 2 weeks"
* item[8].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES "Yes"

* item[9].linkId = "s46m5MS0hxu"
* item[9].text = "Treatment given"
* item[9].answer[0].valueString = "Artemether-lumefantrine 3-day course"

* item[10].linkId = "WjP7dP80yVo"
* item[10].text = "Outcome"
* item[10].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#CURED "Cured"


// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseMalariaAmina
// ----------------------------------------------------------------------------
// Amina Hassan's malaria case — a COMPLICATED case because she is pregnant.
// This demonstrates how the same form captures different clinical scenarios.
// Because pregnancy is a contraindication for artemisinin-based therapy,
// quinine was used instead, and the patient was referred.
//
// Clinical summary:
//   Symptom onset: 2024-04-30
//   Fever: YES, Temperature: 39.2°C (higher than John's case)
//   RDT: POSITIVE -> Species: P. falciparum, Density: 78,000/uL (higher)
//   Pregnant: YES (affects treatment choice)
//   Bed net: YES (still got infected despite preventive measures)
//   Travel: NO (locally acquired)
//   Treatment: Quinine (safe in pregnancy)
//   Outcome: REFERRED (to hospital for monitoring)
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseMalariaAmina
InstanceOf: DHIS2QuestionnaireResponse
Title: "Amina Hassan — Malaria Case Response"
Description: "Completed malaria case investigation for Amina Hassan on 2024-05-02. Pregnant patient with P. falciparum (78,000/uL), treated with quinine, referred to hospital."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireMalariaCase"
* status = #completed
* subject = Reference(PatientAminaHassan)
* authored = "2024-05-02"

* item[0].linkId = "bOYWVEBaWy6"
* item[0].text = "Date of symptom onset"
* item[0].answer[0].valueDate = "2024-04-30"

* item[1].linkId = "fWIAEtYVEGk"
* item[1].text = "Fever present"
* item[1].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES "Yes"

* item[2].linkId = "CYaPLMARlPm"
* item[2].text = "Temperature (°C)"
* item[2].answer[0].valueDecimal = 39.2

* item[3].linkId = "bx6fsa0t90x"
* item[3].text = "Malaria rapid diagnostic test (RDT) result"
* item[3].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#POSITIVE "Positive"

* item[4].linkId = "pCiAvXGclgy"
* item[4].text = "Malaria species"
* item[4].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-malaria-species#P_FALCIPARUM "P. falciparum"

* item[5].linkId = "J5BhSYzHiOy"
* item[5].text = "Parasite density (/uL)"
* item[5].answer[0].valueInteger = 78000

* item[6].linkId = "sPDKWSQ2bKR"
* item[6].text = "Pregnant"
* item[6].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no-unknown#YES "Yes"

* item[7].linkId = "ITsYPKclgfy"
* item[7].text = "Bed net used last night"
* item[7].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES "Yes"

* item[8].linkId = "G7vUx908SwP"
* item[8].text = "Travel history in past 2 weeks"
* item[8].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#NO "No"

* item[9].linkId = "s46m5MS0hxu"
* item[9].text = "Treatment given"
* item[9].answer[0].valueString = "Quinine (pregnant patient)"

* item[10].linkId = "WjP7dP80yVo"
* item[10].text = "Outcome"
* item[10].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-options#REFERRED "Referred"