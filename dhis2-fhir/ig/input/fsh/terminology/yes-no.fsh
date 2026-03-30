// ----------------------------------------------------------------------------
// Yes/No Option Set
// ----------------------------------------------------------------------------
// DHIS2 provides BOOLEAN and TRUE_ONLY value types, but many programs prefer
// an explicit option set with YES/NO codes. This is common when the data
// element needs to distinguish between "No" (explicitly answered) and "not
// answered" (no data value recorded). Using an option set also allows the
// response to appear in analytics as a dimension with named categories
// rather than as raw true/false values.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2YesNoCS
Id: dhis2-yes-no
Title: "DHIS2 Yes/No Option Set"
Description: "Common DHIS2 boolean-like option set used when TRUE_ONLY is not sufficient."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #YES "Yes"
    "Affirmative response."
* #NO "No"
    "Negative response."


ValueSet: DHIS2YesNoVS
Id: dhis2-yes-no-vs
Title: "DHIS2 Yes/No Options"
Description: "All options from the DHIS2 Yes/No option set."
* ^experimental = false
* include codes from system DHIS2YesNoCS


// ----------------------------------------------------------------------------
// Yes/No/Unknown Option Set
// ----------------------------------------------------------------------------
// An extension of the Yes/No option set that adds an "Unknown" option. This
// is frequently used in clinical survey forms and case investigation
// questionnaires where the respondent may not know the answer. The UNKNOWN
// code is semantically different from a missing value: it explicitly states
// that the information was sought but could not be determined.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2YesNoUnknownCS
Id: dhis2-yes-no-unknown
Title: "DHIS2 Yes/No/Unknown Option Set"
Description: "Extended boolean option set including an unknown option, common in clinical surveys."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #YES "Yes"
    "Affirmative response."
* #NO "No"
    "Negative response."
* #UNKNOWN "Unknown"
    "The answer is not known or could not be determined."


ValueSet: DHIS2YesNoUnknownVS
Id: dhis2-yes-no-unknown-vs
Title: "DHIS2 Yes/No/Unknown Options"
Description: "All options from the DHIS2 Yes/No/Unknown option set."
* ^experimental = false
* include codes from system DHIS2YesNoUnknownCS
