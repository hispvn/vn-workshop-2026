// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseDeliveryJane
// ----------------------------------------------------------------------------
// Jane Doe's delivery — a normal vaginal delivery with a healthy baby girl.
// This demonstrates the delivery form which captures both maternal and
// newborn data in a single DHIS2 event.
//
// Clinical summary:
//   Delivery: 2024-08-20 at 14:30 UTC (dateTime type for precise timing)
//   Mode: NORMAL (vaginal delivery)
//   Outcome: LIVE_BIRTH
//   Baby: female, 3200 g (normal weight)
//   Apgar: 7 at 1 min, 9 at 5 min (normal — healthy transition)
//   Complications: None
//   Blood loss: 350 mL (normal, < 500 mL PPH threshold)
//   Referred: NO
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseDeliveryJane
InstanceOf: DHIS2QuestionnaireResponse
Title: "Jane Doe — Delivery Response"
Description: "Completed delivery form for Jane Doe on 2024-08-20. Normal vaginal delivery, live birth, female baby 3200g, Apgar 7/9, no complications."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireDelivery"
* status = #completed
* subject = Reference(PatientJaneDoe)
* authored = "2024-08-20"

* item[0].linkId = "q2LOAdCPbiD"
* item[0].text = "Date and time of delivery"
* item[0].answer[0].valueDateTime = "2024-08-20T14:30:00Z"

* item[1].linkId = "fF7wxNym0Un"
* item[1].text = "Mode of delivery"
* item[1].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-delivery-mode#NORMAL "Normal/Vaginal delivery"

* item[2].linkId = "gHGyrwKPzej"
* item[2].text = "Pregnancy outcome"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-pregnancy-outcome#LIVE_BIRTH "Live birth"

* item[3].linkId = "sj3j9Hwc7so"
* item[3].text = "Birth weight (grams)"
* item[3].answer[0].valueInteger = 3200

* item[4].linkId = "a3kGcGDCuk6"
* item[4].text = "Apgar score at 1 minute"
* item[4].answer[0].valueInteger = 7

* item[5].linkId = "wTPqAolGMnM"
* item[5].text = "Apgar score at 5 minutes"
* item[5].answer[0].valueInteger = 9

* item[6].linkId = "POZ9ATds1Af"
* item[6].text = "Sex of baby"
* item[6].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-gender#FEMALE "Female"

* item[7].linkId = "fWIAEtYVEGk"
* item[7].text = "Complications"
* item[7].answer[0].valueString = "None"

* item[8].linkId = "mKrdG3wOsFi"
* item[8].text = "Blood loss (mL)"
* item[8].answer[0].valueInteger = 350

* item[9].linkId = "tYAJap1gLwK"
* item[9].text = "Mother referred"
* item[9].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#NO "No"