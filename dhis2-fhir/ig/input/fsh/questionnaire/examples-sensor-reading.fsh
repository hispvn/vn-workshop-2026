// ----------------------------------------------------------------------------
// Instance: QRSensorReading1
// ----------------------------------------------------------------------------
// Temperature reading from a field sensor in Lilongwe.
// Anonymous event — no patient linked.
// ----------------------------------------------------------------------------

Instance: QRSensorReading1
InstanceOf: DHIS2QuestionnaireResponse
Title: "Sensor Reading — Temperature at Site Alpha"
Description: "Temperature sensor reading of 38.2 C from sensor TMP-001 at coordinates near Lilongwe."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireSensorReading"
* status = #completed
* authored = "2025-11-10"

* item[0].linkId = "sensor_timestamp"
* item[0].text = "Timestamp"
* item[0].answer[0].valueDateTime = "2025-11-10T08:30:00+02:00"

* item[1].linkId = "sensor_id"
* item[1].text = "Sensor ID"
* item[1].answer[0].valueString = "TMP-001"

* item[2].linkId = "sensor_category"
* item[2].text = "Category"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-category#TEMPERATURE "Temperature"

* item[3].linkId = "sensor_value"
* item[3].text = "Value"
* item[3].answer[0].valueDecimal = 38.2

* item[4].linkId = "sensor_unit"
* item[4].text = "Unit"
* item[4].answer[0].valueString = "Celsius"

* item[5].linkId = "sensor_latitude"
* item[5].text = "Latitude"
* item[5].answer[0].valueDecimal = -13.9626

* item[6].linkId = "sensor_longitude"
* item[6].text = "Longitude"
* item[6].answer[0].valueDecimal = 33.7741

* item[7].linkId = "sensor_status"
* item[7].text = "Sensor Status"
* item[7].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-status#OK "OK"


// ----------------------------------------------------------------------------
// Instance: QRSensorReading2
// ----------------------------------------------------------------------------
// Air quality reading with a low-battery warning.
// ----------------------------------------------------------------------------

Instance: QRSensorReading2
InstanceOf: DHIS2QuestionnaireResponse
Title: "Sensor Reading — Air Quality at Industrial Zone"
Description: "Air quality (AQI) reading of 157 from sensor AQ-042 near an industrial zone. Sensor reporting low battery."
Usage: #example

* questionnaire = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireSensorReading"
* status = #completed
* authored = "2025-11-12"

* item[0].linkId = "sensor_timestamp"
* item[0].text = "Timestamp"
* item[0].answer[0].valueDateTime = "2025-11-12T14:15:00+02:00"

* item[1].linkId = "sensor_id"
* item[1].text = "Sensor ID"
* item[1].answer[0].valueString = "AQ-042"

* item[2].linkId = "sensor_category"
* item[2].text = "Category"
* item[2].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-category#AIR_QUALITY "Air Quality (AQI)"

* item[3].linkId = "sensor_value"
* item[3].text = "Value"
* item[3].answer[0].valueDecimal = 157

* item[4].linkId = "sensor_unit"
* item[4].text = "Unit"
* item[4].answer[0].valueString = "AQI"

* item[5].linkId = "sensor_latitude"
* item[5].text = "Latitude"
* item[5].answer[0].valueDecimal = -13.9800

* item[6].linkId = "sensor_longitude"
* item[6].text = "Longitude"
* item[6].answer[0].valueDecimal = 33.8100

* item[7].linkId = "sensor_status"
* item[7].text = "Sensor Status"
* item[7].answer[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-status#LOW_BATTERY "Low Battery"

* item[8].linkId = "sensor_notes"
* item[8].text = "Notes"
* item[8].answer[0].valueString = "Elevated AQI near cement factory, downwind conditions"
