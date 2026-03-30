// Identifier Type — 5 codes for Lao government-issued identifiers

CodeSystem: CHRIdentifierType
Id: chr-identifier-type
Title: "CHR Identifier Type"
Description: """
Identifier type codes for the CHR health registry. These codes classify
identifiers issued by Lao government agencies that do not have standard
equivalents in HL7 v2 Table 0203.
"""
* ^url = "http://moh.gov.la/fhir/CodeSystem/chr-identifier-type"
* ^status = #active
* ^caseSensitive = true
* ^content = #complete
* #CHR "Community Health Record ID"
    "Identifier assigned by the community health record system."
* #CVID "Civil Registration and Vital Statistics ID"
    "Identifier from the civil registration and vital statistics (CRVS) system."
* #GREENCARD "Lao Green National ID Card"
    "The Lao green national identity card number."
* #FAMILYBOOK "Family Book Number"
    "Family book (tabien baan) registration number."
* #INS "Insurance Number"
    "Health insurance scheme number."


ValueSet: CHRIdentifierTypeVS
Id: chr-identifier-type-vs
Title: "CHR Identifier Type"
Description: "Identifier types used in the CHR health registry."
* ^url = "http://moh.gov.la/fhir/ValueSet/chr-identifier-type"
* ^status = #active
* include codes from system CHRIdentifierType
