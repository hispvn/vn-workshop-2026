// Place of Vaccination — 3 codes for vaccination location types

CodeSystem: CHRPlaceOfVaccinationCS
Id: chr-place-of-vaccination
Title: "CHR Place of Vaccination"
Description: "Types of locations where vaccinations are administered in the Lao PDR immunization programme."
* ^url = "http://moh.gov.la/fhir/CodeSystem/place-of-vaccination"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #mass "Mass Campaign"
    "Vaccination administered during a mass immunization campaign."
* #facility "Health Facility"
    "Vaccination administered at a health facility (hospital, health centre)."
* #outreach "Outreach"
    "Vaccination administered during an outreach session in the community."


ValueSet: CHRPlaceOfVaccinationVS
Id: chr-place-of-vaccination-vs
Title: "CHR Place of Vaccination"
Description: "Types of locations where vaccinations are administered."
* ^url = "http://moh.gov.la/fhir/ValueSet/place-of-vaccination"
* ^status = #active
* include codes from system CHRPlaceOfVaccinationCS
