// OPD Consultation Questionnaire (Cambodia)
// Source: DHIS2 program stage bIZ0zHSu1HA
// "1 Outpatient consultation V3"

Instance: OPDConsultation
InstanceOf: Questionnaire
Title: "OPD Consultation Form (Cambodia)"
Description: "Outpatient consultation form with 21 data elements from Cambodia DHIS2."
* status = #active

// 1. No in Register
* item[0].linkId = "CAukLNxe4r5"
* item[0].text = "No in Register"
* item[0].type = #string

// 2. Age unit
* item[1].linkId = "WCEENSxlj1t"
* item[1].text = "Age unit"
* item[1].type = #choice
* item[1].answerValueSet = Canonical(OPDAgeUnitVS)

// 3. Age
* item[2].linkId = "P4tiyjGf0aV"
* item[2].text = "Age"
* item[2].type = #integer

// 4. Date of Birth
* item[3].linkId = "vWju3cVvwhJ"
* item[3].text = "Date of Birth"
* item[3].type = #date

// 5. Sex
* item[4].linkId = "fcIyTYmLBCJ"
* item[4].text = "Sex"
* item[4].type = #choice
* item[4].answerValueSet = Canonical(OPDSexVS)

// 6. Coverage area
* item[5].linkId = "yJdkrXzhNKa"
* item[5].text = "Coverage area"
* item[5].type = #choice
* item[5].answerValueSet = Canonical(OPDCoverageAreaVS)

// 7. Patient District -- skipped: DHIS2 type ORGANISATION_UNIT has no direct FHIR mapping

// 8. Patient location type
* item[6].linkId = "pnwpDumYRLA"
* item[6].text = "Patient location type"
* item[6].type = #choice
* item[6].answerValueSet = Canonical(OPDPatientLocationVS)

// 9. Referred from HC
* item[7].linkId = "yHPAANy0Pw2"
* item[7].text = "Referred from HC"
* item[7].type = #choice
* item[7].answerValueSet = Canonical(OPDReferredFromVS)

// 10. Health Facility Name -- skipped: DHIS2 type ORGANISATION_UNIT has no direct FHIR mapping

// 11. Facility service level
* item[8].linkId = "qeaobkSmQ4f"
* item[8].text = "Facility service level"
* item[8].type = #choice
* item[8].answerValueSet = Canonical(OPDFacilityLevelVS)

// 12. OPD case type
* item[9].linkId = "AHpmaTaWPE3"
* item[9].text = "OPD case type"
* item[9].type = #choice
* item[9].answerValueSet = Canonical(OPDCaseTypeVS)

// 13. Main Diagnosis
* item[10].linkId = "DzjUvXnbuxU"
* item[10].text = "Main Diagnosis"
* item[10].type = #choice
* item[10].answerValueSet = Canonical(OPDMainDiagnosisVS)

// 14. Diagnosis -- 540 options, mapped as free text instead of choice
* item[11].linkId = "vHEypt0SCOR"
* item[11].text = "Diagnosis"
* item[11].type = #string

// 15. Referred to
* item[12].linkId = "aTsiY7pU1I0"
* item[12].text = "Referred to"
* item[12].type = #boolean

// 16. Referred to (Detail)
* item[13].linkId = "ZZajhBNVSMi"
* item[13].text = "Referred to (Detail)"
* item[13].type = #choice
* item[13].answerValueSet = Canonical(OPDReferredToVS)

// 17. Payment method
* item[14].linkId = "lsCKHBZFH0C"
* item[14].text = "Payment method"
* item[14].type = #choice
* item[14].answerValueSet = Canonical(OPDPaymentMethodVS)

// 18. Vulnerable group
* item[15].linkId = "jEgWuE3RA8F"
* item[15].text = "Vulnerable group"
* item[15].type = #choice
* item[15].answerValueSet = Canonical(OPDVulnerableGroupVS)

// 19. SpO2 detection
* item[16].linkId = "xJWjBj9PC9H"
* item[16].text = "SpO2 detection"
* item[16].type = #choice
* item[16].answerValueSet = Canonical(OPDSpO2VS)

// 20. Received Oxygen
* item[17].linkId = "FRmQqbMkr37"
* item[17].text = "Received Oxygen"
* item[17].type = #boolean

// 21. Age in Years/Months
* item[18].linkId = "h9ZHlQOV0ml"
* item[18].text = "Age in Years/Months"
* item[18].type = #decimal
