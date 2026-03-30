// ============================================================================
// CHR Extensions
// ============================================================================
//
// Extensions for Community Health Record (CHR) fields that are not part of
// base FHIR. These capture Lao PDR-specific demographic and administrative
// data from the CHR/EIR system.
// ============================================================================


Extension: CHRProvinceCode
Id: chr-province-code
Title: "CHR Province Code"
Description: "The organisation unit code for the province level of the address."
Context: Address
* value[x] only string
* valueString 1..1


Extension: CHRDistrictCode
Id: chr-district-code
Title: "CHR District Code"
Description: "The organisation unit code for the district level of the address."
Context: Address
* value[x] only string
* valueString 1..1


Extension: CHRVillageCode
Id: chr-village-code
Title: "CHR Village Code"
Description: "The organisation unit code for the village level of the address."
Context: Address
* value[x] only string
* valueString 1..1


Extension: CHRNationality
Id: chr-nationality
Title: "CHR Nationality"
Description: "The patient's nationality as recorded in the Community Health Record."
Context: Patient
* value[x] only CodeableConcept
* valueCodeableConcept 1..1
* valueCodeableConcept from CHRNationalityVS (extensible)


Extension: CHREthnicity
Id: chr-ethnicity
Title: "CHR Ethnicity"
Description: "The patient's ethnicity as recorded in the Community Health Record."
Context: Patient
* value[x] only CodeableConcept
* valueCodeableConcept 1..1
* valueCodeableConcept from CHREthnicityVS (extensible)


Extension: CHROccupation
Id: chr-occupation
Title: "CHR Occupation"
Description: "The patient's occupation as recorded in the Community Health Record."
Context: Patient
* value[x] only CodeableConcept
* valueCodeableConcept 1..1
* valueCodeableConcept from CHROccupationVS (extensible)


Extension: CHREducation
Id: chr-education
Title: "CHR Education"
Description: "The patient's education level as recorded in the Community Health Record."
Context: Patient
* value[x] only CodeableConcept
* valueCodeableConcept 1..1
* valueCodeableConcept from CHREducationVS (extensible)


Extension: CHRBloodGroup
Id: chr-blood-group
Title: "CHR Blood Group"
Description: "The patient's blood group as recorded in the Community Health Record."
Context: Patient
* value[x] only CodeableConcept
* valueCodeableConcept 1..1
* valueCodeableConcept from CHRBloodGroupVS (extensible)


Extension: CHRIsForeigner
Id: chr-is-foreigner
Title: "CHR Is Foreigner"
Description: "Indicates whether the patient is a foreign national."
Context: Patient
* value[x] only boolean
* valueBoolean 1..1


Extension: CHRBirthYear
Id: chr-birth-year
Title: "CHR Birth Year"
Description: "The patient's birth year when only the year is known (exact date unavailable)."
Context: Patient
* value[x] only integer
* valueInteger 1..1


Extension: CHRPlaceOfVaccination
Id: chr-place-of-vaccination
Title: "CHR Place of Vaccination"
Description: "The type of location where the vaccination was administered (mass campaign, health facility, or outreach)."
Context: Immunization
* value[x] only code
* valueCode 1..1
* valueCode from CHRPlaceOfVaccinationVS (required)
