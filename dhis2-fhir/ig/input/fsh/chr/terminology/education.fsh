// Education — 6 codes from DHIS2 option set "HIV - Education" (Vq9lgX1qvfL)

CodeSystem: CHREducationCS
Id: chr-education
Title: "CHR Education"
Description: "Education level codes used in the CHR, sourced from the DHIS2 'HIV - Education' option set."
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-education"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #NONE "None"
* #KDER "Kindergarten"
* #PRI "Primary"
* #2ND "Secondary"
* #UNI "University/College"
* #Other "Other"


ValueSet: CHREducationVS
Id: chr-education-vs
Title: "CHR Education"
Description: "Education level codes used in the CHR."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-education"
* ^status = #active
* include codes from system CHREducationCS
