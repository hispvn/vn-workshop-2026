// Identification Field — 7 codes from DHIS2 option set
// "CHR - Identification field" (jhREwueLyPL)

CodeSystem: CHRIdentificationFieldCS
Id: chr-identification-field
Title: "CHR Identification Field"
Description: "Identification field codes used in the CHR search, sourced from the DHIS2 'CHR - Identification field' option set."
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-identification-field"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #cvid "COVID-19 Vaccination ID"
* #nationalid "CVR - National ID"
* #passportnumber "Passport number"
* #systemcvid "CVR - System CVID"
* #insurancenumber "Insurance number"
* #familybooknumber "Family book number"
* #laogreennationalidbottom "Lao Green National ID (Bottom)"


ValueSet: CHRIdentificationFieldVS
Id: chr-identification-field-vs
Title: "CHR Identification Field"
Description: "Identification field codes used in the CHR search."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-identification-field"
* ^status = #active
* include codes from system CHRIdentificationFieldCS
