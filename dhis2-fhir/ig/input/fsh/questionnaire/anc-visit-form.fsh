// ============================================================================
// ============================================================================
//
//                    QUESTIONNAIRE INSTANCES (Form Definitions)
//
// ============================================================================
// ============================================================================
//
// The following instances define five DHIS2 program stage forms:
//
//   1. QuestionnaireANCVisit           — Antenatal Care Visit (tracker)
//   2. QuestionnaireMalariaCase        — Malaria Case Investigation (tracker)
//   3. QuestionnaireChildImmunization  — Child Immunization (tracker)
//   4. QuestionnaireDelivery           — Delivery/Birth (tracker, maternal)
//   5. QuestionnaireDiseaseNotification — Notifiable Disease Report (event, anonymous)
//
// Each item's linkId is a realistic DHIS2 data element UID (11 characters).
// The DHIS2 value type to FHIR item type mapping is:
//   DHIS2 NUMBER      -> FHIR decimal
//   DHIS2 INTEGER     -> FHIR integer
//   DHIS2 TEXT        -> FHIR string
//   DHIS2 LONG_TEXT   -> FHIR text
//   DHIS2 BOOLEAN     -> FHIR boolean
//   DHIS2 DATE        -> FHIR date
//   DHIS2 DATETIME    -> FHIR dateTime
//   DHIS2 option set  -> FHIR choice + answerValueSet or answerOption
//
// ============================================================================


// ----------------------------------------------------------------------------
// Instance: QuestionnaireANCVisit
// ----------------------------------------------------------------------------
// Antenatal Care Visit Form — a DHIS2 tracker program stage for recording
// maternal health indicators during ANC visits. This is the most common
// type of DHIS2 form: a repeatable stage in a tracker program where health
// workers record vital signs, test results, and clinical notes at each visit.
//
// Program stage UID: edqlbukiHle
// Program: ANC Program (tracker, WITH_REGISTRATION)
// Repeatable: Yes (one event per visit)
//
// Data elements (11 items):
//   qDkgAbB5Jlk — Visit type (option set -> DHIS2VisitTypeVS)
//   GQY2lXrypjO — Weight in kg (number)
//   wBDRIU8BNun — Blood pressure systolic (integer)
//   RuQaEvkMDCR — Blood pressure diastolic (integer)
//   vANAXwtLwcT — Hemoglobin g/dL (number)
//   bx6fsa0t90x — Malaria RDT result (option set -> DHIS2TestResultVS)
//   CklPZdOd6H1 — HIV status (option set -> DHIS2HIVStatusVS)
//   X8zyunlgUfM — MUAC cm (number)
//   hDZbpskhqDd — Iron/folate given (boolean)
//   cGAyYNUTx4F — ITN given (boolean)
//   uf3svrMdhhH — Clinical notes (long text)
// ----------------------------------------------------------------------------

Instance: QuestionnaireANCVisit
InstanceOf: DHIS2Questionnaire
Title: "ANC Visit Form"
Description: "Antenatal care visit data entry form — a DHIS2 tracker program stage with 11 data elements for recording maternal health indicators during ANC visits. Includes vital signs, lab results, supplies given, and clinical notes."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireANCVisit"

// DHIS2 program stage UID
* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].value = "edqlbukiHle"

* name = "ANCVisitForm"
* title = "ANC Visit Form"
* status = #active

// subjectType = Patient — this is a tracker program stage (WITH_REGISTRATION).
// The form collects data linked to a registered patient (TEI).
* subjectType = #Patient

// --- Item 1: Visit Type ---
// DHIS2 option set mapped to DHIS2VisitTypeVS. Allows the health worker to
// indicate if this is a new visit, follow-up, or referral.
* item[0].linkId = "qDkgAbB5Jlk"
* item[0].text = "Visit type"
* item[0].type = #choice
* item[0].required = true
* item[0].answerValueSet = Canonical(DHIS2VisitTypeVS)

// --- Item 2: Weight (kg) ---
// DHIS2 value type: NUMBER. Maternal weight in kilograms.
// Typical values: 40.0 – 120.0 kg
* item[1].linkId = "GQY2lXrypjO"
* item[1].text = "Weight (kg)"
* item[1].type = #decimal
* item[1].required = true

// --- Item 3: Blood Pressure — Systolic ---
// DHIS2 value type: INTEGER. Systolic blood pressure in mmHg.
// Values > 140 may trigger a high-risk flag via DHIS2 program rules.
* item[2].linkId = "wBDRIU8BNun"
* item[2].text = "Blood pressure — systolic (mmHg)"
* item[2].type = #integer

// --- Item 4: Blood Pressure — Diastolic ---
// DHIS2 value type: INTEGER. Diastolic blood pressure in mmHg.
// Combined with systolic, used to assess pre-eclampsia risk.
* item[3].linkId = "RuQaEvkMDCR"
* item[3].text = "Blood pressure — diastolic (mmHg)"
* item[3].type = #integer

// --- Item 5: Hemoglobin ---
// DHIS2 value type: NUMBER. Hemoglobin concentration in g/dL.
// Values below 11.0 indicate anaemia (common in pregnancy, WHO threshold).
* item[4].linkId = "vANAXwtLwcT"
* item[4].text = "Hemoglobin (g/dL)"
* item[4].type = #decimal

// --- Item 6: Malaria RDT Result ---
// DHIS2 option set mapped to DHIS2TestResultVS (POSITIVE/NEGATIVE/INDETERMINATE).
// A positive result triggers referral for malaria treatment in DHIS2.
* item[5].linkId = "bx6fsa0t90x"
* item[5].text = "Malaria rapid diagnostic test (RDT) result"
* item[5].type = #choice
* item[5].answerValueSet = Canonical(DHIS2TestResultVS)

// --- Item 7: HIV Status ---
// DHIS2 option set mapped to DHIS2HIVStatusVS.
// Critical for PMTCT (prevention of mother-to-child transmission) programs.
* item[6].linkId = "CklPZdOd6H1"
* item[6].text = "HIV status"
* item[6].type = #choice
* item[6].answerValueSet = Canonical(DHIS2HIVStatusVS)

// --- Item 8: MUAC ---
// DHIS2 value type: NUMBER. Mid-upper arm circumference in cm.
// Values < 23 cm indicate malnutrition risk in pregnant women.
* item[7].linkId = "X8zyunlgUfM"
* item[7].text = "Mid-upper arm circumference (MUAC, cm)"
* item[7].type = #decimal

// --- Item 9: Iron/Folate Given ---
// DHIS2 value type: BOOLEAN. Whether iron and folic acid supplements were
// provided. Part of standard ANC protocols in most countries.
* item[8].linkId = "hDZbpskhqDd"
* item[8].text = "Iron/folate given"
* item[8].type = #boolean

// --- Item 10: ITN Given ---
// DHIS2 value type: BOOLEAN. Whether an insecticide-treated bed net was given.
// Part of malaria prevention in ANC programs in endemic areas.
* item[9].linkId = "cGAyYNUTx4F"
* item[9].text = "Insecticide treated net given"
* item[9].type = #boolean

// --- Item 11: Clinical Notes ---
// DHIS2 value type: LONG_TEXT. Free text for observations, concerns,
// follow-up actions discussed during the visit.
* item[10].linkId = "uf3svrMdhhH"
* item[10].text = "Clinical notes"
* item[10].type = #text