// ----------------------------------------------------------------------------
// Gender Option Set
// ----------------------------------------------------------------------------
// One of the most common option sets in DHIS2, used for tracked entity
// attributes (e.g., the "Sex" attribute on a Person tracked entity type).
// DHIS2 has a built-in gender concept but many implementations use a custom
// option set to allow more control over the values. This CodeSystem is kept
// separate from FHIR's AdministrativeGender to preserve the original DHIS2
// option codes and avoid lossy mappings.
// ----------------------------------------------------------------------------

CodeSystem: DHIS2GenderCS
Id: dhis2-gender
Title: "DHIS2 Gender Option Set"
Description: "Standard DHIS2 option set for gender/sex. Maps to FHIR AdministrativeGender but kept separate to preserve DHIS2 option codes."
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #MALE "Male"
    "Male gender."
* #FEMALE "Female"
    "Female gender."
* #OTHER "Other"
    "Other or non-binary gender identity."


ValueSet: DHIS2GenderVS
Id: dhis2-gender-vs
Title: "DHIS2 Gender Options"
Description: "All gender options from the standard DHIS2 gender option set."
* ^experimental = false
* include codes from system DHIS2GenderCS
