// ----------------------------------------------------------------------------
// Visit Type Option Set
// ----------------------------------------------------------------------------
// Used across multiple DHIS2 tracker programs (e.g., ANC, PNC, HIV, TB) to
// classify the nature of a clinical encounter. The visit type drives program
// rules (e.g., "if visit type is NEW, auto-generate a case ID") and is also
// important for analytics to distinguish first visits from follow-ups.
// In FHIR, this maps naturally to Encounter.type or Encounter.class.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2VisitTypeCS
Id: dhis2-visit-type
Title: "DHIS2 Visit Type Option Set"
Description: "Type of clinical visit, used across multiple DHIS2 programs."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #NEW "New visit"
    "First visit or initial encounter for this episode of care."
* #FOLLOW_UP "Follow-up visit"
    "Subsequent visit for continued care or monitoring."
* #REFERRAL "Referral visit"
    "Visit resulting from a referral by another facility or provider."
* #EMERGENCY "Emergency visit"
    "Unscheduled emergency visit."


ValueSet: DHIS2VisitTypeVS
Id: dhis2-visit-type-vs
Title: "DHIS2 Visit Type Options"
Description: "All options from the DHIS2 visit type option set."
* ^experimental = false
* include codes from system DHIS2VisitTypeCS
