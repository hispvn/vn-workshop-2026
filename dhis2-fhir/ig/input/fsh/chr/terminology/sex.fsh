// Sex — 2 codes from DHIS2 option set "Sex" (inQY8oa767s)

CodeSystem: CHRSexCS
Id: chr-sex
Title: "CHR Sex"
Description: "Sex codes used in the CHR, sourced from the DHIS2 'Sex' option set."
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-sex"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #M "Male"
* #F "Female"


ValueSet: CHRSexVS
Id: chr-sex-vs
Title: "CHR Sex"
Description: "Sex codes used in the CHR."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-sex"
* ^status = #active
* include codes from system CHRSexCS
