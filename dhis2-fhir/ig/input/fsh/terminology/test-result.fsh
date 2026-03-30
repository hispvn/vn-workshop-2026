// ----------------------------------------------------------------------------
// Test Result Option Set
// ----------------------------------------------------------------------------
// Used across laboratory and point-of-care testing programs (e.g., malaria
// rapid diagnostic tests, HIV rapid tests, TB sputum smear results). The
// INDETERMINATE code handles equivocal or invalid test results that require
// repeat testing. NOT_DONE captures cases where the test was ordered but
// not performed (e.g., reagent stockout, patient refusal).
// ----------------------------------------------------------------------------

CodeSystem: DHIS2TestResultCS
Id: dhis2-test-result
Title: "DHIS2 Test Result Option Set"
Description: "Standard option set for laboratory/rapid test results."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #POSITIVE "Positive"
    "The test result is positive (reactive)."
* #NEGATIVE "Negative"
    "The test result is negative (non-reactive)."
* #INDETERMINATE "Indeterminate"
    "The test result is equivocal or invalid and requires repeat testing."
* #NOT_DONE "Not done"
    "The test was not performed."


ValueSet: DHIS2TestResultVS
Id: dhis2-test-result-vs
Title: "DHIS2 Test Result Options"
Description: "All options from the DHIS2 test result option set."
* ^experimental = false
* include codes from system DHIS2TestResultCS
