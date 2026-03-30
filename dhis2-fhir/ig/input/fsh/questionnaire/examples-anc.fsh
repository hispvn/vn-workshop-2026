// ============================================================================
// ============================================================================
//
//               QUESTIONNAIRERESPONSE INSTANCES (Completed Forms)
//
// ============================================================================
// ============================================================================
//
// The following instances demonstrate completed DHIS2 events across all five
// program stages defined above. They cover:
//
//   ANC Visit:
//     - QuestionnaireResponseANCVisit1Jane   (Jane Doe, first visit, normal)
//     - QuestionnaireResponseANCVisit2Jane   (Jane Doe, follow-up, normal)
//     - QuestionnaireResponseANCVisit1Amina  (Amina Hassan, first visit, high-risk)
//
//   Malaria Case Investigation:
//     - QuestionnaireResponseMalariaJohn     (John Kamau, P. falciparum, cured)
//     - QuestionnaireResponseMalariaAmina    (Amina Hassan, pregnant, referred)
//
//   Child Immunization:
//     - QuestionnaireResponseImmunization1   (first dose, no adverse event)
//     - QuestionnaireResponseImmunization2   (second dose, adverse event)
//
//   Delivery/Birth:
//     - QuestionnaireResponseDeliveryJane    (normal delivery, healthy baby)
//
//   Disease Notification (anonymous — NO subject):
//     - QuestionnaireResponseDiseaseNotification1 (cholera, lab confirmed)
//     - QuestionnaireResponseDiseaseNotification2 (cholera, epidemiological link)
//
// Note how tracker program QRs have subject references (linked to patients)
// while event program QRs do NOT (anonymous facility-level data).
//
// ============================================================================


// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseANCVisit1Jane
// ----------------------------------------------------------------------------
// Jane Doe's first ANC visit — a normal visit with all values in healthy
// ranges. Demonstrates a straightforward tracker event with all fields
// filled out.
//
// DHIS2 event details:
//   Program: ANC Program
//   Stage: ANC Visit (edqlbukiHle)
//   TEI: Jane Doe
//   Event date: 2024-02-01
//   Org unit: Facility Alpha
//   Status: COMPLETED
//
// Clinical summary:
//   Visit type: NEW (first visit in the program)
//   Weight: 65 kg (normal)
//   BP: 120/80 (normal, < 140/90 threshold)
//   Hemoglobin: 12.5 g/dL (above 11.0 anaemia threshold)
//   Malaria RDT: NEGATIVE
//   HIV: NEGATIVE
//   MUAC: 25.5 cm (above 23 cm malnutrition threshold)
//   Supplements: iron/folate given, ITN given
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseANCVisit1Jane
InstanceOf: DHIS2QuestionnaireResponse
Title: "Jane Doe — ANC Visit 1 Response"
Description: "Completed ANC visit form for Jane Doe on 2024-02-01 (first visit). All values within normal range — weight 65 kg, BP 120/80, hemoglobin 12.5, malaria negative, HIV negative."
Usage: #example

// Reference to the ANC Visit form definition (DHIS2 program stage)
* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireANCVisit"

* status = #completed

// Subject: Jane Doe — this is a tracker program event, so the patient is linked.
* subject = Reference(PatientJaneDoe)

// Encounter: links to the DHIS2 encounter for this visit
* encounter = Reference(EncounterANCVisit1)

// Authored = DHIS2 event date (when the visit occurred)
* authored = "2024-02-01"

// Org unit extension: the facility where the event was recorded
* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)

// --- Answers ---

* item[0].linkId = "qDkgAbB5Jlk"
* item[0].text = "Visit type"
* item[0].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-visit-type#NEW "New visit"

* item[1].linkId = "GQY2lXrypjO"
* item[1].text = "Weight (kg)"
* item[1].answer[0].valueDecimal = 65.0

* item[2].linkId = "wBDRIU8BNun"
* item[2].text = "Blood pressure — systolic (mmHg)"
* item[2].answer[0].valueInteger = 120

* item[3].linkId = "RuQaEvkMDCR"
* item[3].text = "Blood pressure — diastolic (mmHg)"
* item[3].answer[0].valueInteger = 80

* item[4].linkId = "vANAXwtLwcT"
* item[4].text = "Hemoglobin (g/dL)"
* item[4].answer[0].valueDecimal = 12.5

* item[5].linkId = "bx6fsa0t90x"
* item[5].text = "Malaria rapid diagnostic test (RDT) result"
* item[5].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#NEGATIVE "Negative"

* item[6].linkId = "CklPZdOd6H1"
* item[6].text = "HIV status"
* item[6].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-hiv-status#NEGATIVE "Negative"

* item[7].linkId = "X8zyunlgUfM"
* item[7].text = "Mid-upper arm circumference (MUAC, cm)"
* item[7].answer[0].valueDecimal = 25.5

* item[8].linkId = "hDZbpskhqDd"
* item[8].text = "Iron/folate given"
* item[8].answer[0].valueBoolean = true

* item[9].linkId = "cGAyYNUTx4F"
* item[9].text = "Insecticide treated net given"
* item[9].answer[0].valueBoolean = true

* item[10].linkId = "uf3svrMdhhH"
* item[10].text = "Clinical notes"
* item[10].answer[0].valueString = "Normal first visit, no complications"


// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseANCVisit2Jane
// ----------------------------------------------------------------------------
// Jane Doe's second ANC visit — a follow-up visit showing progress over
// time. This demonstrates repeatable program stages in DHIS2 where the
// same patient can have multiple events in the same stage.
//
// Note: Not all fields are filled — in a follow-up visit, the health worker
// may skip some optional fields (like HIV and ITN which were recorded at
// the first visit). This is realistic DHIS2 data capture behavior.
//
// Clinical summary:
//   Visit type: FOLLOW_UP
//   Weight: 67 kg (gained 2 kg since first visit — on track)
//   BP: 118/76 (normal)
//   Hemoglobin: 11.8 g/dL (slight decrease but still above 11.0)
//   Malaria RDT: NEGATIVE
//   MUAC: 26.0 cm (normal)
//   Iron/folate: given (continuing supplementation)
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseANCVisit2Jane
InstanceOf: DHIS2QuestionnaireResponse
Title: "Jane Doe — ANC Visit 2 Response"
Description: "Completed ANC follow-up visit for Jane Doe on 2024-03-15. Weight gain on track, all vitals within normal range."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireANCVisit"
* status = #completed
* subject = Reference(PatientJaneDoe)
* encounter = Reference(EncounterANCVisit2)
* authored = "2024-03-15"

* item[0].linkId = "qDkgAbB5Jlk"
* item[0].text = "Visit type"
* item[0].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-visit-type#FOLLOW_UP "Follow-up visit"

* item[1].linkId = "GQY2lXrypjO"
* item[1].text = "Weight (kg)"
* item[1].answer[0].valueDecimal = 67.0

* item[2].linkId = "wBDRIU8BNun"
* item[2].text = "Blood pressure — systolic (mmHg)"
* item[2].answer[0].valueInteger = 118

* item[3].linkId = "RuQaEvkMDCR"
* item[3].text = "Blood pressure — diastolic (mmHg)"
* item[3].answer[0].valueInteger = 76

* item[4].linkId = "vANAXwtLwcT"
* item[4].text = "Hemoglobin (g/dL)"
* item[4].answer[0].valueDecimal = 11.8

* item[5].linkId = "bx6fsa0t90x"
* item[5].text = "Malaria rapid diagnostic test (RDT) result"
* item[5].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#NEGATIVE "Negative"

* item[6].linkId = "X8zyunlgUfM"
* item[6].text = "Mid-upper arm circumference (MUAC, cm)"
* item[6].answer[0].valueDecimal = 26.0

* item[7].linkId = "hDZbpskhqDd"
* item[7].text = "Iron/folate given"
* item[7].answer[0].valueBoolean = true

* item[8].linkId = "uf3svrMdhhH"
* item[8].text = "Clinical notes"
* item[8].answer[0].valueString = "Weight gain on track"


// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseANCVisit1Amina
// ----------------------------------------------------------------------------
// Amina Hassan's first ANC visit — a HIGH-RISK case. This demonstrates how
// abnormal values would look in FHIR data. In a real DHIS2 system, program
// rules would flag these values:
//   - Elevated BP (130/85) — pre-eclampsia risk
//   - Low hemoglobin (10.2) — anaemia
//   - Malaria RDT POSITIVE — requires immediate treatment
//   - Low MUAC (22.5 cm) — malnutrition risk
//
// This contrasts with Jane Doe's normal visits above, showing the range
// of clinical scenarios captured in the same form.
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseANCVisit1Amina
InstanceOf: DHIS2QuestionnaireResponse
Title: "Amina Hassan — ANC Visit 1 Response"
Description: "Completed ANC visit form for Amina Hassan on 2024-04-10 (first visit). High-risk: elevated BP 130/85, low hemoglobin 10.2, malaria positive, low MUAC 22.5."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireANCVisit"
* status = #completed
* subject = Reference(PatientAminaHassan)
* authored = "2024-04-10"

* item[0].linkId = "qDkgAbB5Jlk"
* item[0].text = "Visit type"
* item[0].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-visit-type#NEW "New visit"

* item[1].linkId = "GQY2lXrypjO"
* item[1].text = "Weight (kg)"
* item[1].answer[0].valueDecimal = 58.0

* item[2].linkId = "wBDRIU8BNun"
* item[2].text = "Blood pressure — systolic (mmHg)"
* item[2].answer[0].valueInteger = 130

* item[3].linkId = "RuQaEvkMDCR"
* item[3].text = "Blood pressure — diastolic (mmHg)"
* item[3].answer[0].valueInteger = 85

* item[4].linkId = "vANAXwtLwcT"
* item[4].text = "Hemoglobin (g/dL)"
* item[4].answer[0].valueDecimal = 10.2

* item[5].linkId = "bx6fsa0t90x"
* item[5].text = "Malaria rapid diagnostic test (RDT) result"
* item[5].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-test-result#POSITIVE "Positive"

* item[6].linkId = "CklPZdOd6H1"
* item[6].text = "HIV status"
* item[6].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-hiv-status#NEGATIVE "Negative"

* item[7].linkId = "X8zyunlgUfM"
* item[7].text = "Mid-upper arm circumference (MUAC, cm)"
* item[7].answer[0].valueDecimal = 22.5

* item[8].linkId = "hDZbpskhqDd"
* item[8].text = "Iron/folate given"
* item[8].answer[0].valueBoolean = true

* item[9].linkId = "cGAyYNUTx4F"
* item[9].text = "Insecticide treated net given"
* item[9].answer[0].valueBoolean = true

* item[10].linkId = "uf3svrMdhhH"
* item[10].text = "Clinical notes"
* item[10].answer[0].valueString = "Elevated BP, low hemoglobin, malaria positive — refer for treatment"