// ============================================================================
// Observations for Amina Hassan — ANC visits
// ============================================================================

Instance: ObservationAminaWeight
InstanceOf: DHIS2Observation
Title: "Observation — Body Weight (Amina Hassan, ANC Visit 1)"
Description: """
Amina Hassan's body weight (58 kg) at her first ANC visit.
"""
Usage: #example

* status = #final
* code = $LOINC#29463-7 "Body weight"
* subject = Reference(PatientAminaHassan)
* encounter = Reference(EncounterAminaANC1)
* effectiveDateTime = "2024-05-20"
* valueQuantity.value = 58
* valueQuantity.unit = "kg"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #kg
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs "Vital Signs"


Instance: ObservationAminaHemoglobin1
InstanceOf: DHIS2Observation
Title: "Observation — Hemoglobin (Amina Hassan, ANC Visit 1)"
Description: """
Amina Hassan's hemoglobin (10.2 g/dL) at first ANC visit. Below the WHO
threshold of 11 g/dL, indicating anemia. Iron supplements prescribed.
"""
Usage: #example

* status = #final
* code = $LOINC#718-7 "Hemoglobin [Mass/volume] in Blood"
* subject = Reference(PatientAminaHassan)
* encounter = Reference(EncounterAminaANC1)
* effectiveDateTime = "2024-05-20"
* valueQuantity.value = 10.2
* valueQuantity.unit = "g/dL"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #g/dL
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"


Instance: ObservationAminaBloodPressure
InstanceOf: DHIS2Observation
Title: "Observation — Blood Pressure (Amina Hassan, ANC Visit 1)"
Description: """
Amina Hassan's blood pressure (110/70 mmHg) at first ANC visit.
Normal reading — no hypertensive disorder.
"""
Usage: #example

* status = #final
* code = $LOINC#85354-9 "Blood pressure panel with all children optional"
* subject = Reference(PatientAminaHassan)
* encounter = Reference(EncounterAminaANC1)
* effectiveDateTime = "2024-05-20"
* component[0].code = $LOINC#8480-6 "Systolic blood pressure"
* component[0].valueQuantity.value = 110
* component[0].valueQuantity.unit = "mmHg"
* component[0].valueQuantity.system = "http://unitsofmeasure.org"
* component[0].valueQuantity.code = #mm[Hg]
* component[1].code = $LOINC#8462-4 "Diastolic blood pressure"
* component[1].valueQuantity.value = 70
* component[1].valueQuantity.unit = "mmHg"
* component[1].valueQuantity.system = "http://unitsofmeasure.org"
* component[1].valueQuantity.code = #mm[Hg]
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs "Vital Signs"


Instance: ObservationAminaMalariaRDT
InstanceOf: DHIS2Observation
Title: "Observation — Malaria RDT (Amina Hassan, ANC Visit 1)"
Description: """
Amina Hassan's malaria RDT result: negative. Routine malaria screening
during ANC in the coastal endemic zone.
"""
Usage: #example

* status = #final
* code = $LOINC#70569-9 "Plasmodium sp Ag [Identifier] in Blood by Rapid immunoassay"
* subject = Reference(PatientAminaHassan)
* encounter = Reference(EncounterAminaANC1)
* effectiveDateTime = "2024-05-20"
* valueCodeableConcept = $SCT#260385009 "Negative"
* valueCodeableConcept.text = "Negative"
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"


Instance: ObservationAminaHIVTest
InstanceOf: DHIS2Observation
Title: "Observation — HIV Test (Amina Hassan, ANC Visit 1)"
Description: """
Amina Hassan's HIV rapid test result: negative. HIV testing is part of
the standard ANC package in Kenya per national guidelines.
"""
Usage: #example

* status = #final
* code = $LOINC#75622-1 "HIV 1 and 2 tests - Meaningful Use set"
* subject = Reference(PatientAminaHassan)
* encounter = Reference(EncounterAminaANC1)
* effectiveDateTime = "2024-05-20"
* valueCodeableConcept = $SCT#260385009 "Negative"
* valueCodeableConcept.text = "Negative"
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"


Instance: ObservationAminaHemoglobin2
InstanceOf: DHIS2Observation
Title: "Observation — Hemoglobin (Amina Hassan, ANC Visit 2)"
Description: """
Amina Hassan's follow-up hemoglobin (11.8 g/dL) at second ANC visit.
Improvement from 10.2 g/dL after 6 weeks of iron supplementation —
now above the WHO 11 g/dL threshold.
"""
Usage: #example

* status = #final
* code = $LOINC#718-7 "Hemoglobin [Mass/volume] in Blood"
* subject = Reference(PatientAminaHassan)
* encounter = Reference(EncounterAminaANC2)
* effectiveDateTime = "2024-07-01"
* valueQuantity.value = 11.8
* valueQuantity.unit = "g/dL"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #g/dL
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"


Instance: ObservationAminaWeight2
InstanceOf: DHIS2Observation
Title: "Observation — Body Weight (Amina Hassan, ANC Visit 2)"
Description: """
Amina Hassan's weight (61 kg) at second ANC visit. Healthy weight gain
of 3 kg over 6 weeks during pregnancy.
"""
Usage: #example

* status = #final
* code = $LOINC#29463-7 "Body weight"
* subject = Reference(PatientAminaHassan)
* encounter = Reference(EncounterAminaANC2)
* effectiveDateTime = "2024-07-01"
* valueQuantity.value = 61
* valueQuantity.unit = "kg"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #kg
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs "Vital Signs"
