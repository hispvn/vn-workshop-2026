// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseImmunization1
// ----------------------------------------------------------------------------
// First Penta vaccine dose — a routine immunization event with no adverse
// reaction. Uses PatientJaneDoe as a proxy for a child patient in this
// example.
//
// Clinical summary:
//   Vaccine: PENTA (pentavalent — DTP-HepB-Hib)
//   Dose: 1 (of 3)
//   Batch: PV2024-0342
//   Date: 2024-01-15
//   Adverse event: NO
//   Next appointment: 2024-02-15 (4 weeks for dose 2)
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseImmunization1
InstanceOf: DHIS2QuestionnaireResponse
Title: "Immunization — Penta Dose 1 Response"
Description: "Completed immunization form for Penta dose 1 on 2024-01-15. No adverse events observed. Next appointment scheduled for dose 2."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireChildImmunization"
* status = #completed
* subject = Reference(PatientJaneDoe)
* authored = "2024-01-15"

* item[0].linkId = "hYyB7FUS5eR"
* item[0].text = "Vaccine given"
* item[0].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-immunization-vaccine#PENTA "Pentavalent (DPT-HepB-Hib)"

* item[1].linkId = "LNqkAlvGplL"
* item[1].text = "Dose number"
* item[1].answer[0].valueInteger = 1

* item[2].linkId = "rxBfISxXS2U"
* item[2].text = "Batch number"
* item[2].answer[0].valueString = "PV2024-0342"

* item[3].linkId = "ebaJjqltK5N"
* item[3].text = "Date administered"
* item[3].answer[0].valueDate = "2024-01-15"

* item[4].linkId = "rQLFnNXXIL0"
* item[4].text = "Adverse event observed"
* item[4].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#NO "No"

// Note: Adverse event description is NOT present because enableWhen
// condition is not met (adverse event = NO). The field is hidden in
// both the DHIS2 form and omitted from the FHIR QR.

* item[5].linkId = "m6qECbJgJGS"
* item[5].text = "Next appointment date"
* item[5].answer[0].valueDate = "2024-02-15"


// ----------------------------------------------------------------------------
// Instance: QuestionnaireResponseImmunization2
// ----------------------------------------------------------------------------
// Second Penta vaccine dose — this time WITH an adverse event. Demonstrates
// how the enableWhen-conditional field (adverse event description) appears
// in the QR when the trigger condition is met.
//
// Clinical summary:
//   Vaccine: PENTA dose 2
//   Adverse event: YES -> Description: "Mild fever and swelling at injection site"
//   Next appointment: 2024-03-15 (4 weeks for dose 3)
// ----------------------------------------------------------------------------

Instance: QuestionnaireResponseImmunization2
InstanceOf: DHIS2QuestionnaireResponse
Title: "Immunization — Penta Dose 2 Response"
Description: "Completed immunization form for Penta dose 2 on 2024-02-15. Adverse event observed: mild fever and swelling at injection site."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireChildImmunization"
* status = #completed
* subject = Reference(PatientJaneDoe)
* authored = "2024-02-15"

* item[0].linkId = "hYyB7FUS5eR"
* item[0].text = "Vaccine given"
* item[0].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-immunization-vaccine#PENTA "Pentavalent (DPT-HepB-Hib)"

* item[1].linkId = "LNqkAlvGplL"
* item[1].text = "Dose number"
* item[1].answer[0].valueInteger = 2

* item[2].linkId = "rxBfISxXS2U"
* item[2].text = "Batch number"
* item[2].answer[0].valueString = "PV2024-0567"

* item[3].linkId = "ebaJjqltK5N"
* item[3].text = "Date administered"
* item[3].answer[0].valueDate = "2024-02-15"

* item[4].linkId = "rQLFnNXXIL0"
* item[4].text = "Adverse event observed"
* item[4].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-yes-no#YES "Yes"

// Adverse event description IS present because enableWhen condition is met
// (adverse event = YES). This field was hidden in the first dose QR above.
* item[5].linkId = "OuJ6sgPyAbC"
* item[5].text = "Adverse event description"
* item[5].answer[0].valueString = "Mild fever and swelling at injection site"

* item[6].linkId = "m6qECbJgJGS"
* item[6].text = "Next appointment date"
* item[6].answer[0].valueDate = "2024-03-15"