// ============================================================================
// Lao PDR ANC Program — Questionnaire (ANC Visit Details)
// ============================================================================
//
// FHIR Questionnaire instance mapped from the real DHIS2 Lao PDR Antenatal
// Care program, stage "ANC Visit Details" (UID: IZ9GXqMAZV8).
//
// Program: Antenatal Care (fflLsS1lm3g)
// Stage:   ANC Visit Details (IZ9GXqMAZV8)
// Type:    Tracker (WITH_REGISTRATION) — linked to a patient
//
// All 39 data elements from the program stage are mapped. Each item's linkId
// is the real DHIS2 data element UID. The mapping follows these rules:
//
//   DHIS2 ValueType            FHIR item type
//   ─────────────────────────  ───────────────
//   TEXT (with optionSet)      choice + answerValueSet
//   TEXT (without optionSet)   string
//   INTEGER_POSITIVE           integer
//   INTEGER_ZERO_OR_POSITIVE   integer
//   NUMBER                     decimal
//   BOOLEAN                    boolean
//   TRUE_ONLY                  boolean
//   DATE                       date
//
// Items are organized into groups matching clinical workflow:
//   1. Visit Information (service type, visit number, risk, location)
//   2. Obstetric History (gravida, para, abortus, living)
//   3. Maternal Measurements (weight, height, BMI, gestational age)
//   4. Vital Signs (blood pressure, fetus heart rate)
//   5. Laboratory Tests (hemoglobin, HIV, hepatitis B, syphilis, diabetes)
//   6. Supplements & Milestones (IFA, 4th ANC, 36-week visit)
//   7. Referrals (referred to, HIV ARV site)
//   8. Administrative (MCH book number, next appointment)
// ============================================================================

Instance: QuestionnaireLaoANCVisit
InstanceOf: DHIS2Questionnaire
Title: "Lao PDR — ANC Visit Details"
Description: "Antenatal care visit form from the real Lao PDR DHIS2 system. Program stage IZ9GXqMAZV8 with 39 data elements covering visit classification, obstetric history, vital signs, lab tests, supplements, and referrals."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireLaoANCVisit"

// DHIS2 program stage UID
* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].value = "IZ9GXqMAZV8"

* name = "LaoANCVisitDetails"
* title = "Lao PDR — ANC Visit Details"
* status = #active

// Tracker program — linked to a registered patient
* subjectType = #Patient


// =========================================================================
// Group 1: Visit Information
// =========================================================================

* item[0].linkId = "visit-info"
* item[0].text = "Visit Information"
* item[0].type = #group

// --- Service type (Paid / Free) ---
// DHIS2: MCH_T_Services type (cdDw6bEYQYW), option set SPkr4SsJO6S
* item[0].item[0].linkId = "cdDw6bEYQYW"
* item[0].item[0].text = "Services type"
* item[0].item[0].type = #choice
* item[0].item[0].answerValueSet = Canonical(LaoANCServiceCostVS)

// --- ANC Visit Number (1–16+) ---
// DHIS2: MCH_T_Number of ANC visit (kyclqodZVDs), option set Atk12rr4OC9
* item[0].item[1].linkId = "kyclqodZVDs"
* item[0].item[1].text = "Number of ANC visit"
* item[0].item[1].type = #choice
* item[0].item[1].required = true
* item[0].item[1].answerValueSet = Canonical(LaoANCANCVisitNumberVS)

// --- Risk Factor ---
// DHIS2: MCH_T_ANC Visit Risk Factor (rxPKp45sFA2), option set B4kJGll4SYt
* item[0].item[2].linkId = "rxPKp45sFA2"
* item[0].item[2].text = "ANC Visit Risk Factor"
* item[0].item[2].type = #choice
* item[0].item[2].answerValueSet = Canonical(LaoANCRiskFactorVS)

// --- Service Location ---
// DHIS2: MCH_T_Service Location (skhk4NL6E0y), option set leQqckuY6Cp
* item[0].item[3].linkId = "skhk4NL6E0y"
* item[0].item[3].text = "Service Location"
* item[0].item[3].type = #choice
* item[0].item[3].answerValueSet = Canonical(LaoANCServiceLocationVS)

// --- MCH book number ---
// DHIS2: MCH_T_MCH book number (GgfEUl3oXi6), TEXT
* item[0].item[4].linkId = "GgfEUl3oXi6"
* item[0].item[4].text = "MCH book number"
* item[0].item[4].type = #string


// =========================================================================
// Group 2: Obstetric History
// =========================================================================

* item[1].linkId = "obstetric-history"
* item[1].text = "Obstetric History"
* item[1].type = #group

// --- Gravida ---
// DHIS2: MCH_T_ Gravida (x9pl4PJop26), NUMBER
* item[1].item[0].linkId = "x9pl4PJop26"
* item[1].item[0].text = "Gravida"
* item[1].item[0].type = #decimal

// --- Para ---
// DHIS2: MCH_T_ Para (fm0Mge3AePX), NUMBER
* item[1].item[1].linkId = "fm0Mge3AePX"
* item[1].item[1].text = "Para"
* item[1].item[1].type = #decimal

// --- Abortus ---
// DHIS2: MCH_T_ Abortus (E4lPyETCSON), NUMBER
* item[1].item[2].linkId = "E4lPyETCSON"
* item[1].item[2].text = "Abortus"
* item[1].item[2].type = #decimal

// --- Living ---
// DHIS2: MCH_T_ Living (Vny88TWPZ1I), NUMBER
* item[1].item[3].linkId = "Vny88TWPZ1I"
* item[1].item[3].text = "Living"
* item[1].item[3].type = #decimal


// =========================================================================
// Group 3: Maternal Measurements
// =========================================================================

* item[2].linkId = "maternal-measurements"
* item[2].text = "Maternal Measurements"
* item[2].type = #group

// --- Gestational age (weeks) ---
// DHIS2: MCH_T_ Gestational age in ANC (Week) (cmhpujmJ1DJ), NUMBER
* item[2].item[0].linkId = "cmhpujmJ1DJ"
* item[2].item[0].text = "Gestational age in ANC (weeks)"
* item[2].item[0].type = #decimal

// --- Weight before pregnant ---
// DHIS2: MCH_T_Weight before pregnant (wFxRs2V7vAF), NUMBER
* item[2].item[1].linkId = "wFxRs2V7vAF"
* item[2].item[1].text = "Weight before pregnant (kg)"
* item[2].item[1].type = #decimal

// --- Current weight ---
// DHIS2: MCH_T_Current weight (LCbPCTS6M40), NUMBER
* item[2].item[2].linkId = "LCbPCTS6M40"
* item[2].item[2].text = "Current weight (kg)"
* item[2].item[2].type = #decimal

// --- Height ---
// DHIS2: MCH_T_ Height (CvHuHqlazKg), NUMBER
* item[2].item[3].linkId = "CvHuHqlazKg"
* item[2].item[3].text = "Height (cm)"
* item[2].item[3].type = #decimal

// --- BMI ---
// DHIS2: MCH_T_ BMI (pmVVnUV8NkH), NUMBER
* item[2].item[4].linkId = "pmVVnUV8NkH"
* item[2].item[4].text = "BMI"
* item[2].item[4].type = #decimal


// =========================================================================
// Group 4: Vital Signs
// =========================================================================

* item[3].linkId = "vital-signs"
* item[3].text = "Vital Signs"
* item[3].type = #group

// --- Systolic blood pressure ---
// DHIS2: MCH_T_Systolic blood pressure (tVPKjkXrMSB), INTEGER_ZERO_OR_POSITIVE
* item[3].item[0].linkId = "tVPKjkXrMSB"
* item[3].item[0].text = "Systolic blood pressure (mmHg)"
* item[3].item[0].type = #integer

// --- Diastolic blood pressure ---
// DHIS2: MCH_T_Diastolic blood pressure (TThw3XArMBK), INTEGER_ZERO_OR_POSITIVE
* item[3].item[1].linkId = "TThw3XArMBK"
* item[3].item[1].text = "Diastolic blood pressure (mmHg)"
* item[3].item[1].type = #integer

// --- High blood pressure recorded ---
// DHIS2: MCH_T_ High blood pressure recorded (dPMhPYLpmAf), TRUE_ONLY
* item[3].item[2].linkId = "dPMhPYLpmAf"
* item[3].item[2].text = "High blood pressure recorded"
* item[3].item[2].type = #boolean

// --- Fetus heart rate ---
// DHIS2: MCH_T_ Fetus heart rate (NjD9TNfcUu5), NUMBER
* item[3].item[3].linkId = "NjD9TNfcUu5"
* item[3].item[3].text = "Fetus heart rate (bpm)"
* item[3].item[3].type = #decimal


// =========================================================================
// Group 5: Laboratory Tests
// =========================================================================

* item[4].linkId = "lab-tests"
* item[4].text = "Laboratory Tests"
* item[4].type = #group

// --- Hemoglobin test/CBC (done?) ---
// DHIS2: MCH_T_Hemoglobin test/CBC (uRM5be7E75w), BOOLEAN
* item[4].item[0].linkId = "uRM5be7E75w"
* item[4].item[0].text = "Hemoglobin test/CBC done"
* item[4].item[0].type = #boolean

// --- Result of Hemoglobin test ---
// DHIS2: MCH_T_Result of Hemoglobin test (FlkD0kQhHhJ), option set eojKm5iAz1o
* item[4].item[1].linkId = "FlkD0kQhHhJ"
* item[4].item[1].text = "Result of Hemoglobin test"
* item[4].item[1].type = #choice
* item[4].item[1].answerValueSet = Canonical(LaoANCHemoglobinResultVS)

// --- HIV Screening test (done?) ---
// DHIS2: MCH_T_HIV Screening test (KVHZNzocCD6), BOOLEAN
* item[4].item[2].linkId = "KVHZNzocCD6"
* item[4].item[2].text = "HIV Screening test done"
* item[4].item[2].type = #boolean

// --- Result of HIV Screening test ---
// DHIS2: MCH_T_Result of HIV Screening test (nHnNUFMbSYA), option set JBgL4GvS91j
* item[4].item[3].linkId = "nHnNUFMbSYA"
* item[4].item[3].text = "Result of HIV Screening test"
* item[4].item[3].type = #choice
* item[4].item[3].answerValueSet = Canonical(LaoANCHIVResultVS)

// --- HIV test 2 done ---
// DHIS2: MCH_T_HIV test 2 done (BGBniEmtdnp), BOOLEAN
* item[4].item[4].linkId = "BGBniEmtdnp"
* item[4].item[4].text = "HIV test 2 done"
* item[4].item[4].type = #boolean

// --- Result HIV test 2 ---
// DHIS2: MCH_T_Result HIV test 2 (kBpBXfa01Z2), option set JBgL4GvS91j
* item[4].item[5].linkId = "kBpBXfa01Z2"
* item[4].item[5].text = "Result HIV test 2"
* item[4].item[5].type = #choice
* item[4].item[5].answerValueSet = Canonical(LaoANCHIVResultVS)

// --- HIV ARV Refer to confirm ---
// DHIS2: MCH_T_ANC_HIV_Refer to confirm (c3GH15l4IUh), option set FlDLyixoe30
* item[4].item[6].linkId = "c3GH15l4IUh"
* item[4].item[6].text = "HIV — Refer to confirm (ARV site)"
* item[4].item[6].type = #choice
* item[4].item[6].answerValueSet = Canonical(LaoANCHIVARVSiteVS)

// --- Syphilis test (done?) ---
// DHIS2: MCH_T_Syphilis test (q4EdIJjblCf), BOOLEAN
* item[4].item[7].linkId = "q4EdIJjblCf"
* item[4].item[7].text = "Syphilis test done"
* item[4].item[7].type = #boolean

// --- Result of Syphilis test ---
// DHIS2: MCH_T_Result of Syphilis test (aRjhZpPEpLl), option set ysHezUWsqEd
* item[4].item[8].linkId = "aRjhZpPEpLl"
* item[4].item[8].text = "Result of Syphilis test"
* item[4].item[8].type = #choice
* item[4].item[8].answerValueSet = Canonical(LaoANCSyphilisResultVS)

// --- Hepatitis B test (done?) ---
// DHIS2: MCH_T_Hepatitis B test (J4ys94vFsiU), BOOLEAN
* item[4].item[9].linkId = "J4ys94vFsiU"
* item[4].item[9].text = "Hepatitis B test done"
* item[4].item[9].type = #boolean

// --- Result of Hepatitis B test ---
// DHIS2: MCH_T_Result of Hepatitis B test (gVgVUFzbU71), option set bUJTzmyripD
* item[4].item[10].linkId = "gVgVUFzbU71"
* item[4].item[10].text = "Result of Hepatitis B test"
* item[4].item[10].type = #choice
* item[4].item[10].answerValueSet = Canonical(LaoANCHepBResultVS)

// --- Blood sugar test (done?) ---
// DHIS2: MCH_T_Blood sugar test (Diabetes) (dX8tjJYEmLV), BOOLEAN
* item[4].item[11].linkId = "dX8tjJYEmLV"
* item[4].item[11].text = "Blood sugar test (Diabetes) done"
* item[4].item[11].type = #boolean

// --- Result of Blood sugar test ---
// DHIS2: MCH_T_Result of Blood sugar test (KcSmw6TU84h), TEXT (free text)
* item[4].item[12].linkId = "KcSmw6TU84h"
* item[4].item[12].text = "Result of Blood sugar test"
* item[4].item[12].type = #string

// --- Maternal Diabetes Mellitus (GDM) ---
// DHIS2: MCH_T_Maternal Diabetes Mellitus (GDM) (Y/N) (LI6hhC8cmUv), TEXT
* item[4].item[13].linkId = "LI6hhC8cmUv"
* item[4].item[13].text = "Maternal Diabetes Mellitus (GDM) (Y/N)"
* item[4].item[13].type = #string


// =========================================================================
// Group 6: Supplements & Milestones
// =========================================================================

* item[5].linkId = "supplements-milestones"
* item[5].text = "Supplements & Milestones"
* item[5].type = #group

// --- Received IFA tablets? ---
// DHIS2: MCH_T_Received IFA tablets? (ZBpVWbottLH), BOOLEAN
* item[5].item[0].linkId = "ZBpVWbottLH"
* item[5].item[0].text = "Received IFA tablets?"
* item[5].item[0].type = #boolean

// --- Number of IFA distributed ---
// DHIS2: MCH_Core_Number of distribution IFA (SuURKJnCAah), NUMBER
* item[5].item[1].linkId = "SuURKJnCAah"
* item[5].item[1].text = "Number of IFA tablets distributed"
* item[5].item[1].type = #decimal

// --- Completed IFA 90 tablets ---
// DHIS2: MCH_T_Completed IFA 90 tablets (YQIcs5ULyyz), BOOLEAN
* item[5].item[2].linkId = "YQIcs5ULyyz"
* item[5].item[2].text = "Completed IFA 90 tablets"
* item[5].item[2].type = #boolean

// --- 4th ANC ---
// DHIS2: MCH_T_4th ANC (du6VbwHrYa2), BOOLEAN
* item[5].item[3].linkId = "du6VbwHrYa2"
* item[5].item[3].text = "4th ANC visit completed"
* item[5].item[3].type = #boolean

// --- ANC visit at 36 weeks above ---
// DHIS2: MCH_T_ANC visit at 36 weeks above (uPoi29c7GaH), BOOLEAN
* item[5].item[4].linkId = "uPoi29c7GaH"
* item[5].item[4].text = "ANC visit at 36 weeks or above"
* item[5].item[4].type = #boolean


// =========================================================================
// Group 7: Referrals
// =========================================================================

* item[6].linkId = "referrals"
* item[6].text = "Referrals"
* item[6].type = #group

// --- Referred to ---
// DHIS2: MCH_T_ Referred to (D3nWrXpLWNT), option set GFID9hwzjVv
* item[6].item[0].linkId = "D3nWrXpLWNT"
* item[6].item[0].text = "Referred to"
* item[6].item[0].type = #choice
* item[6].item[0].answerValueSet = Canonical(LaoANCReferredToVS)


// =========================================================================
// Group 8: Administrative
// =========================================================================

* item[7].linkId = "administrative"
* item[7].text = "Administrative"
* item[7].type = #group

// --- Next appointment date ---
// DHIS2: MCH_T_Next appointment date (Rg0YjOCLnsl), DATE
* item[7].item[0].linkId = "Rg0YjOCLnsl"
* item[7].item[0].text = "Next appointment date"
* item[7].item[0].type = #date
