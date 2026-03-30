// ============================================================================
// Lao PDR ANC Program — Example QuestionnaireResponses
// ============================================================================
//
// Two completed ANC visit forms showing realistic data capture from the
// Lao PDR system:
//
//   1. QRLaoANCVisit1 — First visit, low risk, normal results
//   2. QRLaoANCVisit2 — Follow-up visit, medium risk, anaemia detected
//
// These use the real DHIS2 data element UIDs as linkIds.
// ============================================================================


// ----------------------------------------------------------------------------
// Instance: QRLaoANCVisit1
// ----------------------------------------------------------------------------
// First ANC visit for a healthy 26-year-old mother (gravida 2, para 1).
// All test results normal. Visit at a fixed facility, 12 weeks gestation.
// ----------------------------------------------------------------------------

Instance: QRLaoANCVisit1
InstanceOf: DHIS2QuestionnaireResponse
Title: "Lao ANC — Visit 1 (Normal)"
Description: "First ANC visit at 12 weeks gestation. Low risk, all lab results normal, IFA tablets provided. Demonstrates a routine ANC visit with all key fields filled."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireLaoANCVisit"
* status = #completed
* subject = Reference(PatientJaneDoe)
* authored = "2024-06-15"

// --- Visit Information ---
* item[0].linkId = "visit-info"
* item[0].text = "Visit Information"

* item[0].item[0].linkId = "cdDw6bEYQYW"
* item[0].item[0].text = "Services type"
* item[0].item[0].answer[0].valueCoding = LaoANCServiceCostCS#Free "Free"

* item[0].item[1].linkId = "kyclqodZVDs"
* item[0].item[1].text = "Number of ANC visit"
* item[0].item[1].answer[0].valueCoding = LaoANCANCVisitNumberCS#1 "1"

* item[0].item[2].linkId = "rxPKp45sFA2"
* item[0].item[2].text = "ANC Visit Risk Factor"
* item[0].item[2].answer[0].valueCoding = LaoANCRiskFactorCS#norisk "No Risk - Green"

* item[0].item[3].linkId = "skhk4NL6E0y"
* item[0].item[3].text = "Service Location"
* item[0].item[3].answer[0].valueCoding = LaoANCServiceLocationCS#Fixed "Fixed"

* item[0].item[4].linkId = "GgfEUl3oXi6"
* item[0].item[4].text = "MCH book number"
* item[0].item[4].answer[0].valueString = "MCH-2024-00156"

// --- Obstetric History ---
* item[1].linkId = "obstetric-history"
* item[1].text = "Obstetric History"

* item[1].item[0].linkId = "x9pl4PJop26"
* item[1].item[0].text = "Gravida"
* item[1].item[0].answer[0].valueDecimal = 2

* item[1].item[1].linkId = "fm0Mge3AePX"
* item[1].item[1].text = "Para"
* item[1].item[1].answer[0].valueDecimal = 1

* item[1].item[2].linkId = "E4lPyETCSON"
* item[1].item[2].text = "Abortus"
* item[1].item[2].answer[0].valueDecimal = 0

* item[1].item[3].linkId = "Vny88TWPZ1I"
* item[1].item[3].text = "Living"
* item[1].item[3].answer[0].valueDecimal = 1

// --- Maternal Measurements ---
* item[2].linkId = "maternal-measurements"
* item[2].text = "Maternal Measurements"

* item[2].item[0].linkId = "cmhpujmJ1DJ"
* item[2].item[0].text = "Gestational age in ANC (weeks)"
* item[2].item[0].answer[0].valueDecimal = 12

* item[2].item[1].linkId = "wFxRs2V7vAF"
* item[2].item[1].text = "Weight before pregnant (kg)"
* item[2].item[1].answer[0].valueDecimal = 52.0

* item[2].item[2].linkId = "LCbPCTS6M40"
* item[2].item[2].text = "Current weight (kg)"
* item[2].item[2].answer[0].valueDecimal = 54.5

* item[2].item[3].linkId = "CvHuHqlazKg"
* item[2].item[3].text = "Height (cm)"
* item[2].item[3].answer[0].valueDecimal = 155

* item[2].item[4].linkId = "pmVVnUV8NkH"
* item[2].item[4].text = "BMI"
* item[2].item[4].answer[0].valueDecimal = 22.7

// --- Vital Signs ---
* item[3].linkId = "vital-signs"
* item[3].text = "Vital Signs"

* item[3].item[0].linkId = "tVPKjkXrMSB"
* item[3].item[0].text = "Systolic blood pressure (mmHg)"
* item[3].item[0].answer[0].valueInteger = 110

* item[3].item[1].linkId = "TThw3XArMBK"
* item[3].item[1].text = "Diastolic blood pressure (mmHg)"
* item[3].item[1].answer[0].valueInteger = 70

* item[3].item[2].linkId = "NjD9TNfcUu5"
* item[3].item[2].text = "Fetus heart rate (bpm)"
* item[3].item[2].answer[0].valueDecimal = 150

// --- Laboratory Tests ---
* item[4].linkId = "lab-tests"
* item[4].text = "Laboratory Tests"

* item[4].item[0].linkId = "uRM5be7E75w"
* item[4].item[0].text = "Hemoglobin test/CBC done"
* item[4].item[0].answer[0].valueBoolean = true

* item[4].item[1].linkId = "FlkD0kQhHhJ"
* item[4].item[1].text = "Result of Hemoglobin test"
* item[4].item[1].answer[0].valueCoding = LaoANCHemoglobinResultCS#+ "Greater than or equal to 11 g/dL"

* item[4].item[2].linkId = "KVHZNzocCD6"
* item[4].item[2].text = "HIV Screening test done"
* item[4].item[2].answer[0].valueBoolean = true

* item[4].item[3].linkId = "nHnNUFMbSYA"
* item[4].item[3].text = "Result of HIV Screening test"
* item[4].item[3].answer[0].valueCoding = LaoANCHIVResultCS#NR "Non-Reactive"

* item[4].item[4].linkId = "q4EdIJjblCf"
* item[4].item[4].text = "Syphilis test done"
* item[4].item[4].answer[0].valueBoolean = true

* item[4].item[5].linkId = "aRjhZpPEpLl"
* item[4].item[5].text = "Result of Syphilis test"
* item[4].item[5].answer[0].valueCoding = LaoANCSyphilisResultCS#N "Negative"

* item[4].item[6].linkId = "J4ys94vFsiU"
* item[4].item[6].text = "Hepatitis B test done"
* item[4].item[6].answer[0].valueBoolean = true

* item[4].item[7].linkId = "gVgVUFzbU71"
* item[4].item[7].text = "Result of Hepatitis B test"
* item[4].item[7].answer[0].valueCoding = LaoANCHepBResultCS#N "Negative"

// --- Supplements & Milestones ---
* item[5].linkId = "supplements-milestones"
* item[5].text = "Supplements & Milestones"

* item[5].item[0].linkId = "ZBpVWbottLH"
* item[5].item[0].text = "Received IFA tablets?"
* item[5].item[0].answer[0].valueBoolean = true

* item[5].item[1].linkId = "SuURKJnCAah"
* item[5].item[1].text = "Number of IFA tablets distributed"
* item[5].item[1].answer[0].valueDecimal = 30

// --- Administrative ---
* item[6].linkId = "administrative"
* item[6].text = "Administrative"

* item[6].item[0].linkId = "Rg0YjOCLnsl"
* item[6].item[0].text = "Next appointment date"
* item[6].item[0].answer[0].valueDate = "2024-07-13"


// ----------------------------------------------------------------------------
// Instance: QRLaoANCVisit2
// ----------------------------------------------------------------------------
// Second ANC visit — now at 20 weeks. Anaemia detected (hemoglobin < 11),
// elevated blood pressure. Risk factor upgraded to medium. Shows how the
// same form captures different clinical situations.
// ----------------------------------------------------------------------------

Instance: QRLaoANCVisit2
InstanceOf: DHIS2QuestionnaireResponse
Title: "Lao ANC — Visit 2 (Medium Risk)"
Description: "Second ANC visit at 20 weeks. Medium risk: anaemia detected, elevated BP 135/88. Demonstrates a higher-risk ANC visit with abnormal lab results."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireLaoANCVisit"
* status = #completed
* subject = Reference(PatientJaneDoe)
* authored = "2024-08-10"

// --- Visit Information ---
* item[0].linkId = "visit-info"
* item[0].text = "Visit Information"

* item[0].item[0].linkId = "cdDw6bEYQYW"
* item[0].item[0].text = "Services type"
* item[0].item[0].answer[0].valueCoding = LaoANCServiceCostCS#Free "Free"

* item[0].item[1].linkId = "kyclqodZVDs"
* item[0].item[1].text = "Number of ANC visit"
* item[0].item[1].answer[0].valueCoding = LaoANCANCVisitNumberCS#2 "2"

* item[0].item[2].linkId = "rxPKp45sFA2"
* item[0].item[2].text = "ANC Visit Risk Factor"
* item[0].item[2].answer[0].valueCoding = LaoANCRiskFactorCS#medium "Medium Risk - Pink"

* item[0].item[3].linkId = "skhk4NL6E0y"
* item[0].item[3].text = "Service Location"
* item[0].item[3].answer[0].valueCoding = LaoANCServiceLocationCS#Fixed "Fixed"

// --- Maternal Measurements ---
* item[1].linkId = "maternal-measurements"
* item[1].text = "Maternal Measurements"

* item[1].item[0].linkId = "cmhpujmJ1DJ"
* item[1].item[0].text = "Gestational age in ANC (weeks)"
* item[1].item[0].answer[0].valueDecimal = 20

* item[1].item[1].linkId = "LCbPCTS6M40"
* item[1].item[1].text = "Current weight (kg)"
* item[1].item[1].answer[0].valueDecimal = 57.0

// --- Vital Signs ---
* item[2].linkId = "vital-signs"
* item[2].text = "Vital Signs"

* item[2].item[0].linkId = "tVPKjkXrMSB"
* item[2].item[0].text = "Systolic blood pressure (mmHg)"
* item[2].item[0].answer[0].valueInteger = 135

* item[2].item[1].linkId = "TThw3XArMBK"
* item[2].item[1].text = "Diastolic blood pressure (mmHg)"
* item[2].item[1].answer[0].valueInteger = 88

* item[2].item[2].linkId = "dPMhPYLpmAf"
* item[2].item[2].text = "High blood pressure recorded"
* item[2].item[2].answer[0].valueBoolean = true

* item[2].item[3].linkId = "NjD9TNfcUu5"
* item[2].item[3].text = "Fetus heart rate (bpm)"
* item[2].item[3].answer[0].valueDecimal = 142

// --- Laboratory Tests ---
* item[3].linkId = "lab-tests"
* item[3].text = "Laboratory Tests"

* item[3].item[0].linkId = "uRM5be7E75w"
* item[3].item[0].text = "Hemoglobin test/CBC done"
* item[3].item[0].answer[0].valueBoolean = true

* item[3].item[1].linkId = "FlkD0kQhHhJ"
* item[3].item[1].text = "Result of Hemoglobin test"
* item[3].item[1].answer[0].valueCoding = LaoANCHemoglobinResultCS#- "Less than 11 g/dL"

// --- Supplements & Milestones ---
* item[4].linkId = "supplements-milestones"
* item[4].text = "Supplements & Milestones"

* item[4].item[0].linkId = "ZBpVWbottLH"
* item[4].item[0].text = "Received IFA tablets?"
* item[4].item[0].answer[0].valueBoolean = true

* item[4].item[1].linkId = "SuURKJnCAah"
* item[4].item[1].text = "Number of IFA tablets distributed"
* item[4].item[1].answer[0].valueDecimal = 30

// --- Referrals ---
* item[5].linkId = "referrals"
* item[5].text = "Referrals"

* item[5].item[0].linkId = "D3nWrXpLWNT"
* item[5].item[0].text = "Referred to"
* item[5].item[0].answer[0].valueCoding = LaoANCReferredToCS#public_hospital "Public hospital"

// --- Administrative ---
* item[6].linkId = "administrative"
* item[6].text = "Administrative"

* item[6].item[0].linkId = "Rg0YjOCLnsl"
* item[6].item[0].text = "Next appointment date"
* item[6].item[0].answer[0].valueDate = "2024-08-24"
