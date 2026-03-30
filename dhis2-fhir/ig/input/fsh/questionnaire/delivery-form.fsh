// ----------------------------------------------------------------------------
// Instance: QuestionnaireDelivery
// ----------------------------------------------------------------------------
// Delivery/Birth Form — a DHIS2 tracker program stage for recording delivery
// and newborn details in a maternal health program.
//
// Program stage UID: WZbXY0S00lP
// Program: ANC/Maternal Health Program (tracker, WITH_REGISTRATION)
//
// This form captures both maternal (mode of delivery, blood loss, referral)
// and newborn (weight, Apgar scores, sex) data elements. In DHIS2, this is
// often a non-repeatable stage — each mother has one delivery event per
// enrollment.
//
// Data elements (10 items):
//   q2LOAdCPbiD — Date/time of delivery (dateTime)
//   fF7wxNym0Un — Mode of delivery (option set -> DHIS2DeliveryModeVS)
//   gHGyrwKPzej — Pregnancy outcome (option set -> DHIS2PregnancyOutcomeVS)
//   sj3j9Hwc7so — Birth weight grams (integer)
//   a3kGcGDCuk6 — Apgar score 1 min (integer)
//   wTPqAolGMnM — Apgar score 5 min (integer)
//   POZ9ATds1Af — Sex of baby (option set -> DHIS2GenderVS)
//   fWIAEtYVEGk — Complications (text)
//   mKrdG3wOsFi — Blood loss mL (integer)
//   tYAJap1gLwK — Mother referred (option set -> DHIS2YesNoVS)
// ----------------------------------------------------------------------------

Instance: QuestionnaireDelivery
InstanceOf: DHIS2Questionnaire
Title: "Delivery/Birth Form"
Description: "Delivery and birth data entry form — a DHIS2 tracker program stage for recording delivery mode, pregnancy outcome, newborn indicators (weight, Apgar), and maternal complications."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireDelivery"

* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].value = "WZbXY0S00lP"

* name = "DeliveryForm"
* title = "Delivery/Birth Form"
* status = #active
* subjectType = #Patient

// --- Item 1: Date and Time of Delivery ---
// DHIS2 value type: DATETIME. Uses FHIR dateTime type to capture both
// date and time, which is clinically important for delivery records.
* item[0].linkId = "q2LOAdCPbiD"
* item[0].text = "Date and time of delivery"
* item[0].type = #dateTime
* item[0].required = true

// --- Item 2: Mode of Delivery ---
* item[1].linkId = "fF7wxNym0Un"
* item[1].text = "Mode of delivery"
* item[1].type = #choice
* item[1].required = true
* item[1].answerValueSet = Canonical(DHIS2DeliveryModeVS)

// --- Item 3: Pregnancy Outcome ---
* item[2].linkId = "gHGyrwKPzej"
* item[2].text = "Pregnancy outcome"
* item[2].type = #choice
* item[2].required = true
* item[2].answerValueSet = Canonical(DHIS2PregnancyOutcomeVS)

// --- Item 4: Birth Weight (grams) ---
// DHIS2 value type: INTEGER. Birth weight in grams (not kg).
// Normal range: 2500 – 4000 g. Below 2500 g = low birth weight.
* item[3].linkId = "sj3j9Hwc7so"
* item[3].text = "Birth weight (grams)"
* item[3].type = #integer

// --- Item 5: Apgar Score at 1 Minute ---
// Score 0-10. Used to assess newborn condition immediately after birth.
* item[4].linkId = "a3kGcGDCuk6"
* item[4].text = "Apgar score at 1 minute"
* item[4].type = #integer

// --- Item 6: Apgar Score at 5 Minutes ---
// Score 0-10. Reassessment at 5 minutes — better predictor of outcome.
* item[5].linkId = "wTPqAolGMnM"
* item[5].text = "Apgar score at 5 minutes"
* item[5].type = #integer

// --- Item 7: Sex of Baby ---
* item[6].linkId = "POZ9ATds1Af"
* item[6].text = "Sex of baby"
* item[6].type = #choice
* item[6].answerValueSet = Canonical(DHIS2GenderVS)

// --- Item 8: Complications ---
// Free text describing any delivery complications.
* item[7].linkId = "fWIAEtYVEGk"
* item[7].text = "Complications"
* item[7].type = #text

// --- Item 9: Blood Loss (mL) ---
// Estimated maternal blood loss during delivery.
// > 500 mL = postpartum hemorrhage (PPH) for vaginal delivery.
* item[8].linkId = "mKrdG3wOsFi"
* item[8].text = "Blood loss (mL)"
* item[8].type = #integer

// --- Item 10: Mother Referred ---
* item[9].linkId = "tYAJap1gLwK"
* item[9].text = "Mother referred"
* item[9].type = #choice
* item[9].answerValueSet = Canonical(DHIS2YesNoVS)