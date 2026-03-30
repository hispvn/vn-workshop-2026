// ----------------------------------------------------------------------------
// HIV Status Option Set
// ----------------------------------------------------------------------------
// Core option set for HIV programs, used on data elements that capture a
// person's HIV testing status. This is distinct from a test result because
// it includes the broader concept of "unknown status" (never tested or
// result not available) and "exposed infant" (born to an HIV-positive
// mother, status not yet confirmed). These categories are central to the
// DHIS2 HIV case surveillance and treatment modules.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2HIVStatusCS
Id: dhis2-hiv-status
Title: "DHIS2 HIV Status Option Set"
Description: "HIV testing status as commonly tracked in DHIS2 HIV programs."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #POSITIVE "Positive"
    "Confirmed HIV-positive status."
* #NEGATIVE "Negative"
    "Confirmed HIV-negative status."
* #UNKNOWN "Unknown status"
    "HIV status is unknown (never tested or result unavailable)."
* #EXPOSED_INFANT "Exposed infant"
    "Infant born to an HIV-positive mother whose own HIV status is not yet confirmed."


ValueSet: DHIS2HIVStatusVS
Id: dhis2-hiv-status-vs
Title: "DHIS2 HIV Status Options"
Description: "All options from the DHIS2 HIV status option set."
* ^experimental = false
* include codes from system DHIS2HIVStatusCS
