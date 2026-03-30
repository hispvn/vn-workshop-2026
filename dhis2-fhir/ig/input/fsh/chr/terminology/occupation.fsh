// Occupation — 13 codes from DHIS2 option set "Standard Occupation" (WzMWhxUXWn1)

CodeSystem: CHROccupationCS
Id: chr-occupation
Title: "CHR Occupation"
Description: "Standard occupation codes used in the CHR, sourced from the DHIS2 'Standard Occupation' option set."
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-occupation"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #Farmer "Farmer"
* #House_wife "House wife"
* #Student "Student"
* #Factory_worker "Factory worker"
* #Construction_worker "Construction worker"
* #Driver "Driver"
* #Merchant "Merchant"
* #Unemployed "Unemployed"
* #Health_Worker "Health Worker"
* #Military "Military"
* #Police "Police"
* #Government "Government"
* #Other "Other"


ValueSet: CHROccupationVS
Id: chr-occupation-vs
Title: "CHR Occupation"
Description: "Standard occupation codes used in the CHR."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-occupation"
* ^status = #active
* include codes from system CHROccupationCS
