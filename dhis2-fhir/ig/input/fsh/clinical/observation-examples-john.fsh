// ============================================================================
// Observations for John Kamau — Malaria case
// ============================================================================

Instance: ObservationJohnTemperature
InstanceOf: DHIS2Observation
Title: "Observation — Temperature (John Kamau, Malaria Visit)"
Description: """
John Kamau's body temperature (38.9°C) at his malaria visit on 2024-04-10.
Fever is the primary presenting symptom of malaria.
"""
Usage: #example

* status = #final
* code = $LOINC#8310-5 "Body temperature"
* subject = Reference(PatientJohnKamau)
* encounter = Reference(EncounterJohnMalaria1)
* effectiveDateTime = "2024-04-10"
* valueQuantity.value = 38.9
* valueQuantity.unit = "°C"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #Cel
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs "Vital Signs"


Instance: ObservationJohnMalariaRDT
InstanceOf: DHIS2Observation
Title: "Observation — Malaria RDT Positive (John Kamau)"
Description: """
John Kamau's malaria rapid diagnostic test result: positive for
P. falciparum. This triggers case notification in DHIS2.
"""
Usage: #example

* status = #final
* code = $LOINC#70569-9 "Plasmodium sp Ag [Identifier] in Blood by Rapid immunoassay"
* subject = Reference(PatientJohnKamau)
* encounter = Reference(EncounterJohnMalaria1)
* effectiveDateTime = "2024-04-10"
* valueCodeableConcept = $SCT#10828004 "Positive"
* valueCodeableConcept.text = "Positive"
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"


Instance: ObservationJohnWeight
InstanceOf: DHIS2Observation
Title: "Observation — Body Weight (John Kamau)"
Description: """
John Kamau's body weight (72 kg) at malaria visit. Weight is used
to calculate ACT dosage for malaria treatment.
"""
Usage: #example

* status = #final
* code = $LOINC#29463-7 "Body weight"
* subject = Reference(PatientJohnKamau)
* encounter = Reference(EncounterJohnMalaria1)
* effectiveDateTime = "2024-04-10"
* valueQuantity.value = 72
* valueQuantity.unit = "kg"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #kg
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs "Vital Signs"


Instance: ObservationJohnMalariaFollowUpRDT
InstanceOf: DHIS2Observation
Title: "Observation — Malaria RDT Negative (John Kamau, Follow-up)"
Description: """
John Kamau's follow-up malaria RDT result: negative. Treatment was
successful — the ACT course cleared the parasites.
"""
Usage: #example

* status = #final
* code = $LOINC#70569-9 "Plasmodium sp Ag [Identifier] in Blood by Rapid immunoassay"
* subject = Reference(PatientJohnKamau)
* encounter = Reference(EncounterJohnMalariaFollowUp)
* effectiveDateTime = "2024-04-17"
* valueCodeableConcept = $SCT#260385009 "Negative"
* valueCodeableConcept.text = "Negative"
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"
