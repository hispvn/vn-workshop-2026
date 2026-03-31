Instance: BloodPressureQuestionnaire
InstanceOf: Questionnaire
Title: "Blood Pressure Form"
Description: "A simple form for recording blood pressure readings."
* status = #active
* item[0].linkId = "date"
* item[0].text = "Date of measurement"
* item[0].type = #date
* item[0].required = true
* item[1].linkId = "systolic"
* item[1].text = "Systolic (mmHg)"
* item[1].type = #integer
* item[1].required = true
* item[2].linkId = "diastolic"
* item[2].text = "Diastolic (mmHg)"
* item[2].type = #integer
* item[2].required = true
* item[3].linkId = "category"
* item[3].text = "Visit category"
* item[3].type = #choice
* item[3].required = true
* item[3].answerValueSet = Canonical(CategoryVS)
