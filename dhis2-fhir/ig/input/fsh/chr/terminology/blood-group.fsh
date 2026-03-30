// Blood Group — 14 codes from DHIS2 option set "MCHT_Blood group" (F8Fgxp80qp1)

CodeSystem: CHRBloodGroupCS
Id: chr-blood-group
Title: "CHR Blood Group"
Description: "Blood group codes used in the CHR, sourced from the DHIS2 'MCHT_Blood group' option set."
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-blood-group"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #A "A"
* #A+ "A+"
* #A- "A-"
* #B "B"
* #B+ "B+"
* #B- "B-"
* #O "O"
* #O+ "O+"
* #O- "O-"
* #AB "AB"
* #AB+ "AB+"
* #AB- "AB-"
* #N/A "N/A"
* #NC "NC"


ValueSet: CHRBloodGroupVS
Id: chr-blood-group-vs
Title: "CHR Blood Group"
Description: "Blood group codes used in the CHR."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-blood-group"
* ^status = #active
* include codes from system CHRBloodGroupCS
