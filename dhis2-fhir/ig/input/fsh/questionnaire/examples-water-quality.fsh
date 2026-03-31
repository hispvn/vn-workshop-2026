// ----------------------------------------------------------------------------
// Instance: QRWaterQuality1
// ----------------------------------------------------------------------------
// Borehole water sample — safe for consumption, no E. coli detected.
// Anonymous event — no patient linked.
// ----------------------------------------------------------------------------

Instance: QRWaterQuality1
InstanceOf: DHIS2QuestionnaireResponse
Title: "Water Quality — Borehole Site BH-07 (Safe)"
Description: "Water quality report from borehole BH-07. pH 7.1, low turbidity, adequate chlorine. Safe for consumption."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireWaterQuality"
* status = #completed
* authored = "2025-10-20"
* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)

* item[0].linkId = "wq_timestamp"
* item[0].text = "Collection Date/Time"
* item[0].answer[0].valueDateTime = "2025-10-20T09:00:00+02:00"

* item[1].linkId = "wq_site_id"
* item[1].text = "Collection Site ID"
* item[1].answer[0].valueString = "BH-07"

* item[2].linkId = "wq_source_type"
* item[2].text = "Water Source Type"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-source#BOREHOLE "Borehole"

* item[3].linkId = "wq_ph"
* item[3].text = "pH Level"
* item[3].answer[0].valueDecimal = 7.1

* item[4].linkId = "wq_turbidity"
* item[4].text = "Turbidity (NTU)"
* item[4].answer[0].valueDecimal = 1.2

* item[5].linkId = "wq_chlorine"
* item[5].text = "Residual Chlorine (mg/L)"
* item[5].answer[0].valueDecimal = 0.5

* item[6].linkId = "wq_ecoli"
* item[6].text = "E. coli Present"
* item[6].answer[0].valueBoolean = false

* item[7].linkId = "wq_latitude"
* item[7].text = "Latitude"
* item[7].answer[0].valueDecimal = -13.9450

* item[8].linkId = "wq_longitude"
* item[8].text = "Longitude"
* item[8].answer[0].valueDecimal = 33.7200

* item[9].linkId = "wq_result"
* item[9].text = "Overall Result"
* item[9].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-result#SAFE "Safe for Consumption"


// ----------------------------------------------------------------------------
// Instance: QRWaterQuality2
// ----------------------------------------------------------------------------
// River water sample — E. coli detected, unsafe, requires treatment.
// ----------------------------------------------------------------------------

Instance: QRWaterQuality2
InstanceOf: DHIS2QuestionnaireResponse
Title: "Water Quality — River Site RV-12 (Unsafe)"
Description: "Water quality report from river collection point RV-12. High turbidity, no chlorine, E. coli present. Unsafe for consumption."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireWaterQuality"
* status = #completed
* authored = "2025-10-22"
* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)

* item[0].linkId = "wq_timestamp"
* item[0].text = "Collection Date/Time"
* item[0].answer[0].valueDateTime = "2025-10-22T11:30:00+02:00"

* item[1].linkId = "wq_site_id"
* item[1].text = "Collection Site ID"
* item[1].answer[0].valueString = "RV-12"

* item[2].linkId = "wq_source_type"
* item[2].text = "Water Source Type"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-source#RIVER "River/Stream"

* item[3].linkId = "wq_ph"
* item[3].text = "pH Level"
* item[3].answer[0].valueDecimal = 6.3

* item[4].linkId = "wq_turbidity"
* item[4].text = "Turbidity (NTU)"
* item[4].answer[0].valueDecimal = 45.8

* item[5].linkId = "wq_chlorine"
* item[5].text = "Residual Chlorine (mg/L)"
* item[5].answer[0].valueDecimal = 0.0

* item[6].linkId = "wq_ecoli"
* item[6].text = "E. coli Present"
* item[6].answer[0].valueBoolean = true

* item[7].linkId = "wq_latitude"
* item[7].text = "Latitude"
* item[7].answer[0].valueDecimal = -14.0100

* item[8].linkId = "wq_longitude"
* item[8].text = "Longitude"
* item[8].answer[0].valueDecimal = 33.7850

* item[9].linkId = "wq_result"
* item[9].text = "Overall Result"
* item[9].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-result#UNSAFE "Unsafe"

* item[10].linkId = "wq_notes"
* item[10].text = "Field Notes"
* item[10].answer[0].valueString = "Downstream from cattle crossing point. Visible sediment. Community advised to boil water."
