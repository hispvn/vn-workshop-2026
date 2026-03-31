// ----------------------------------------------------------------------------
// Instance: QuestionnaireSensorReading
// ----------------------------------------------------------------------------
// IoT Sensor Reading — a DHIS2 EVENT PROGRAM (WITHOUT_REGISTRATION)
// form for capturing readings from IoT sensors (temperature, humidity,
// air quality, water level).
//
// This is an event program — no subjectType, data is not linked to a patient.
// Demonstrates capturing timestamped sensor data with geolocation.
// ----------------------------------------------------------------------------

Instance: QuestionnaireSensorReading
InstanceOf: DHIS2Questionnaire
Title: "IoT Sensor Reading Form"
Description: "Captures a single reading from an IoT sensor (e.g. temperature, humidity, air quality). Submitted as an anonymous event with no linked patient."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Questionnaire/QuestionnaireSensorReading"

* name = "SensorReading"
* title = "IoT Sensor Reading"
* status = #active

// NO subjectType — this is an event program (WITHOUT_REGISTRATION).

// --- Item 1: Timestamp ---
* item[0].linkId = "sensor_timestamp"
* item[0].text = "Timestamp"
* item[0].type = #dateTime
* item[0].required = true

// --- Item 2: Sensor ID ---
* item[1].linkId = "sensor_id"
* item[1].text = "Sensor ID"
* item[1].type = #string
* item[1].required = true

// --- Item 3: Category ---
* item[2].linkId = "sensor_category"
* item[2].text = "Category"
* item[2].type = #choice
* item[2].required = true
* item[2].answerOption[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-category#TEMPERATURE "Temperature"
* item[2].answerOption[1].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-category#HUMIDITY "Humidity"
* item[2].answerOption[2].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-category#AIR_QUALITY "Air Quality (AQI)"
* item[2].answerOption[3].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-category#WATER_LEVEL "Water Level"

// --- Item 4: Value ---
* item[3].linkId = "sensor_value"
* item[3].text = "Value"
* item[3].type = #decimal
* item[3].required = true

// --- Item 5: Unit ---
* item[4].linkId = "sensor_unit"
* item[4].text = "Unit"
* item[4].type = #string
* item[4].required = false

// --- Item 6: Latitude ---
* item[5].linkId = "sensor_latitude"
* item[5].text = "Latitude"
* item[5].type = #decimal
* item[5].required = false

// --- Item 7: Longitude ---
* item[6].linkId = "sensor_longitude"
* item[6].text = "Longitude"
* item[6].type = #decimal
* item[6].required = false

// --- Item 8: Sensor Status ---
* item[7].linkId = "sensor_status"
* item[7].text = "Sensor Status"
* item[7].type = #choice
* item[7].required = false
* item[7].answerOption[0].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-status#OK "OK"
* item[7].answerOption[1].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-status#LOW_BATTERY "Low Battery"
* item[7].answerOption[2].valueCoding = http://dhis2.org/fhir/learning/CodeSystem/dhis2-sensor-status#MALFUNCTION "Malfunction"

// --- Item 9: Notes ---
* item[8].linkId = "sensor_notes"
* item[8].text = "Notes"
* item[8].type = #text
* item[8].required = false
