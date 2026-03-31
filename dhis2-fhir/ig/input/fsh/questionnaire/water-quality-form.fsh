// ----------------------------------------------------------------------------
// Instance: QuestionnaireWaterQuality
// ----------------------------------------------------------------------------
// Water Quality Report — a DHIS2 EVENT PROGRAM (WITHOUT_REGISTRATION)
// form for field reporting of water quality at collection points.
//
// This is an event program — no subjectType, data is not linked to a patient.
// Demonstrates environmental/public health monitoring with geolocation
// and lab-style measurements (pH, turbidity, chlorine, E. coli).
// ----------------------------------------------------------------------------

Instance: QuestionnaireWaterQuality
InstanceOf: DHIS2Questionnaire
Title: "Water Quality Report Form"
Description: "Anonymous field report for water quality monitoring at collection points. No patient linked."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireWaterQuality"

* name = "WaterQualityReport"
* title = "Water Quality Report"
* status = #active

// NO subjectType — this is an event program (WITHOUT_REGISTRATION).

// --- Item 1: Collection Date/Time ---
* item[0].linkId = "wq_timestamp"
* item[0].text = "Collection Date/Time"
* item[0].type = #dateTime
* item[0].required = true

// --- Item 2: Collection Site ID ---
* item[1].linkId = "wq_site_id"
* item[1].text = "Collection Site ID"
* item[1].type = #string
* item[1].required = true

// --- Item 3: Water Source Type ---
* item[2].linkId = "wq_source_type"
* item[2].text = "Water Source Type"
* item[2].type = #choice
* item[2].required = true
* item[2].answerOption[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-source#BOREHOLE "Borehole"
* item[2].answerOption[1].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-source#RIVER "River/Stream"
* item[2].answerOption[2].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-source#WELL "Well"
* item[2].answerOption[3].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-source#TAP "Tap Water"
* item[2].answerOption[4].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-source#RAINWATER "Rainwater Collection"

// --- Item 4: pH Level ---
* item[3].linkId = "wq_ph"
* item[3].text = "pH Level"
* item[3].type = #decimal
* item[3].required = true

// --- Item 5: Turbidity ---
* item[4].linkId = "wq_turbidity"
* item[4].text = "Turbidity (NTU)"
* item[4].type = #decimal
* item[4].required = false

// --- Item 6: Residual Chlorine ---
* item[5].linkId = "wq_chlorine"
* item[5].text = "Residual Chlorine (mg/L)"
* item[5].type = #decimal
* item[5].required = false

// --- Item 7: E. coli Present ---
* item[6].linkId = "wq_ecoli"
* item[6].text = "E. coli Present"
* item[6].type = #boolean
* item[6].required = true

// --- Item 8: Latitude ---
* item[7].linkId = "wq_latitude"
* item[7].text = "Latitude"
* item[7].type = #decimal
* item[7].required = false

// --- Item 9: Longitude ---
* item[8].linkId = "wq_longitude"
* item[8].text = "Longitude"
* item[8].type = #decimal
* item[8].required = false

// --- Item 10: Overall Result ---
* item[9].linkId = "wq_result"
* item[9].text = "Overall Result"
* item[9].type = #choice
* item[9].required = true
* item[9].answerOption[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-result#SAFE "Safe for Consumption"
* item[9].answerOption[1].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-result#REQUIRES_TREATMENT "Requires Treatment"
* item[9].answerOption[2].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-water-result#UNSAFE "Unsafe"

// --- Item 11: Field Notes ---
* item[10].linkId = "wq_notes"
* item[10].text = "Field Notes"
* item[10].type = #text
* item[10].required = false
