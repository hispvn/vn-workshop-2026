// ============================================================================
// Instance: ObservationWeight
// ============================================================================
// Body weight measured at Jane Doe's first ANC visit. In DHIS2 Tracker, this
// is a data value within the event:
//   { "dataElement": "qrur9Dvnyt5", "value": "65.0" }
//
// FHIR mapping:
//   - LOINC 29463-7 "Body weight" is the standard code for weight
//   - Value: 65 kg (UCUM unit)
//   - The DHIS2 data element reference is carried via extension
//
// Body weight is one of the most commonly captured data elements in ANC
// programs worldwide and is a key indicator for maternal nutrition.
// ============================================================================
Instance: ObservationWeight
InstanceOf: DHIS2Observation
Title: "Observation — Body Weight (Jane Doe, ANC Visit 1)"
Description: """
Jane Doe's body weight (65 kg) measured during her first ANC visit on
2024-02-01. Maps to DHIS2 data element 'Weight in kg' (LOINC 29463-7).
Weight monitoring is essential in ANC for detecting malnutrition and
abnormal weight gain.
"""
Usage: #example

// -- Status: final (the event was completed in DHIS2) ------------------------
* status = #final

// -- Code: LOINC for body weight ---------------------------------------------
// LOINC 29463-7 is the standard code for body weight. In DHIS2, this data
// element might be named "Weight in kg" with UID "qrur9Dvnyt5".
* code = $LOINC#29463-7 "Body weight"

// -- Subject: Jane Doe -------------------------------------------------------
* subject = Reference(PatientJaneDoe)

// -- Encounter: the first ANC visit ------------------------------------------
* encounter = Reference(EncounterANCVisit1)

// -- Effective: the date of the observation (DHIS2 event date) ---------------
* effectiveDateTime = "2024-02-01"

// -- Value: 65 kg ------------------------------------------------------------
// In DHIS2, this would be stored as a numeric data value "65.0" on a data
// element of value type NUMBER with a unit hint of "kg" in the description.
// In FHIR, we use valueQuantity with UCUM units for precise representation.
* valueQuantity.value = 65
* valueQuantity.unit = "kg"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #kg

// -- Category: vital signs ---------------------------------------------------
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs "Vital Signs"


// ============================================================================
// Instance: ObservationHemoglobin
// ============================================================================
// Hemoglobin measurement at Jane Doe's first ANC visit. Hemoglobin testing
// is a critical part of ANC — low hemoglobin indicates anemia, which is
// a major concern in pregnancy, especially in sub-Saharan Africa.
//
// In DHIS2, this would typically be a data element of value type NUMBER
// with the name "Hemoglobin (g/dL)" and a UID like "vANAXwtLwcT".
//
// The WHO recommends hemoglobin testing at every ANC contact, with a
// threshold of <11 g/dL indicating anemia in pregnancy.
// ============================================================================
Instance: ObservationHemoglobin
InstanceOf: DHIS2Observation
Title: "Observation — Hemoglobin (Jane Doe, ANC Visit 1)"
Description: """
Jane Doe's hemoglobin level (12.5 g/dL) measured during her first ANC visit
on 2024-02-01. Maps to DHIS2 data element 'Hemoglobin' (LOINC 718-7).
A value of 12.5 g/dL is within the normal range for pregnant women (normal
>= 11 g/dL per WHO guidelines).
"""
Usage: #example

// -- Status: final -----------------------------------------------------------
* status = #final

// -- Code: LOINC for hemoglobin ----------------------------------------------
// LOINC 718-7 "Hemoglobin [Mass/volume] in Blood" is the standard code.
* code = $LOINC#718-7 "Hemoglobin [Mass/volume] in Blood"

// -- Subject: Jane Doe -------------------------------------------------------
* subject = Reference(PatientJaneDoe)

// -- Encounter: the first ANC visit ------------------------------------------
* encounter = Reference(EncounterANCVisit1)

// -- Effective: observation date ---------------------------------------------
* effectiveDateTime = "2024-02-01"

// -- Value: 12.5 g/dL -------------------------------------------------------
// 12.5 g/dL is normal for a pregnant woman (WHO threshold for anemia
// in pregnancy is <11 g/dL). In DHIS2, program rules could flag values
// below the threshold to alert health workers.
* valueQuantity.value = 12.5
* valueQuantity.unit = "g/dL"
* valueQuantity.system = "http://unitsofmeasure.org"
* valueQuantity.code = #g/dL

// -- Category: laboratory ----------------------------------------------------
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"


// ============================================================================
// Instance: ObservationBloodPressure
// ============================================================================
// Blood pressure measurement at Jane Doe's first ANC visit. Blood pressure
// monitoring is essential in ANC for early detection of pre-eclampsia and
// eclampsia — leading causes of maternal mortality in sub-Saharan Africa.
//
// In DHIS2, blood pressure is often captured as two separate data elements
// (systolic and diastolic), but in FHIR the standard pattern is a single
// Observation with two components. This demonstrates the structural mapping
// difference between DHIS2 and FHIR.
//
// DHIS2 data elements:
//   - "Systolic blood pressure" (e.g., UID "msodh3rEMJa") = 120
//   - "Diastolic blood pressure" (e.g., UID "K6uUAvq500H") = 80
//
// FHIR representation:
//   - Observation.code = LOINC 85354-9 "Blood pressure panel"
//   - component[0]: systolic = 120 mmHg (LOINC 8480-6)
//   - component[1]: diastolic = 80 mmHg (LOINC 8462-4)
//
// Note: this Observation uses components instead of value[x]. FHIR's blood
// pressure vital sign profile does not use value[x] on the parent resource;
// the values are in the components.
// ============================================================================
Instance: ObservationBloodPressure
InstanceOf: DHIS2Observation
Title: "Observation — Blood Pressure (Jane Doe, ANC Visit 1)"
Description: """
Jane Doe's blood pressure (120/80 mmHg) measured during her first ANC visit
on 2024-02-01. This Observation uses the FHIR component pattern to represent
systolic and diastolic values separately, while DHIS2 typically captures
these as two distinct data elements. The blood pressure reading is normal.
"""
Usage: #example

// -- Status: final -----------------------------------------------------------
* status = #final

// -- Code: LOINC blood pressure panel ----------------------------------------
// LOINC 85354-9 "Blood pressure panel with all children optional" is the
// standard code for a combined blood pressure observation.
* code = $LOINC#85354-9 "Blood pressure panel with all children optional"

// -- Subject: Jane Doe -------------------------------------------------------
* subject = Reference(PatientJaneDoe)

// -- Encounter: the first ANC visit ------------------------------------------
* encounter = Reference(EncounterANCVisit1)

// -- Effective: observation date ---------------------------------------------
* effectiveDateTime = "2024-02-01"

// -- Component: Systolic Blood Pressure --------------------------------------
// LOINC 8480-6 "Systolic blood pressure" — 120 mmHg is normal.
// In DHIS2, this would be a separate data element (e.g., "Systolic BP").
* component[0].code = $LOINC#8480-6 "Systolic blood pressure"
* component[0].valueQuantity.value = 120
* component[0].valueQuantity.unit = "mmHg"
* component[0].valueQuantity.system = "http://unitsofmeasure.org"
* component[0].valueQuantity.code = #mm[Hg]

// -- Component: Diastolic Blood Pressure -------------------------------------
// LOINC 8462-4 "Diastolic blood pressure" — 80 mmHg is normal.
// In DHIS2, this would be a separate data element (e.g., "Diastolic BP").
* component[1].code = $LOINC#8462-4 "Diastolic blood pressure"
* component[1].valueQuantity.value = 80
* component[1].valueQuantity.unit = "mmHg"
* component[1].valueQuantity.system = "http://unitsofmeasure.org"
* component[1].valueQuantity.code = #mm[Hg]

// -- Category: vital signs ---------------------------------------------------
* category = http://terminology.hl7.org/CodeSystem/observation-category#vital-signs "Vital Signs"


// ============================================================================
// Instance: ObservationMalariaTestResult
// ============================================================================
// Malaria Rapid Diagnostic Test (RDT) result at Jane Doe's first ANC visit.
//
// Malaria screening is a standard part of ANC in malaria-endemic regions
// (most of sub-Saharan Africa). DHIS2 is extensively used for malaria
// surveillance and the WHO's Malaria Module in DHIS2 tracks case data.
//
// In DHIS2, a malaria RDT result is typically captured as a data element
// with an option set containing values like "Positive", "Negative", and
// "Not done". In FHIR, we map this to a CodeableConcept value using
// SNOMED CT codes for the test result.
//
// DHIS2 data element example:
//   { "dataElement": "oZg33kd9taw", "value": "Negative" }
//
// FHIR mapping:
//   Observation.code = LOINC 70569-9 "Plasmodium sp Ag [Presence] in Blood
//     by Rapid immunoassay"
//   Observation.valueCodeableConcept = SNOMED 260385009 "Negative"
// ============================================================================
Instance: ObservationMalariaTestResult
InstanceOf: DHIS2Observation
Title: "Observation — Malaria RDT Result (Jane Doe, ANC Visit 1)"
Description: """
Jane Doe's malaria rapid diagnostic test result (Negative) from her first ANC
visit on 2024-02-01. Malaria screening is routine during ANC in endemic areas.
The negative result is mapped from a DHIS2 option set value to SNOMED CT.
"""
Usage: #example

// -- Status: final -----------------------------------------------------------
* status = #final

// -- Code: LOINC for malaria RDT --------------------------------------------
// LOINC 70569-9 covers Plasmodium antigen detection by rapid immunoassay,
// which is the standard malaria RDT used at most health facilities in
// sub-Saharan Africa. In DHIS2, the data element might be named
// "Malaria RDT Result".
* code = $LOINC#70569-9 "Plasmodium sp Ag [Identifier] in Blood by Rapid immunoassay"

// -- Subject: Jane Doe -------------------------------------------------------
* subject = Reference(PatientJaneDoe)

// -- Encounter: the first ANC visit ------------------------------------------
* encounter = Reference(EncounterANCVisit1)

// -- Effective: observation date ---------------------------------------------
* effectiveDateTime = "2024-02-01"

// -- Value: Negative (mapped from DHIS2 option set) --------------------------
// In DHIS2, the option set for malaria RDT results typically contains:
//   - Positive (SNOMED 10828004)
//   - Negative (SNOMED 260385009)
//   - Indeterminate / Not done
// Here, Jane tested negative for malaria.
* valueCodeableConcept = $SCT#260385009 "Negative"
* valueCodeableConcept.text = "Negative"

// -- Category: laboratory ----------------------------------------------------
* category = http://terminology.hl7.org/CodeSystem/observation-category#laboratory "Laboratory"
