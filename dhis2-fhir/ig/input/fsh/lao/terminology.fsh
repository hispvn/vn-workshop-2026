// ============================================================================
// Lao PDR Identifier Type CodeSystem
// ============================================================================
//
// Defines identifier type codes specific to the Lao PDR health registry that
// don't have standard HL7 v2-0203 equivalents. Using a custom CodeSystem
// avoids slicing discriminator collisions (e.g., Green Card vs National ID
// both using NI).
//
// Passport uses the existing $V2-0203#PPN — no custom code needed here.
// ============================================================================

CodeSystem: LaoIdentifierType
Id: lao-identifier-type
Title: "Lao PDR Identifier Type"
Description: """
Identifier type codes for the Lao PDR health registry. These codes classify
identifiers issued by Lao government agencies that do not have standard
equivalents in HL7 v2 Table 0203.
"""
* ^url = "http://moh.gov.la/fhir/CodeSystem/identifier-type"
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
