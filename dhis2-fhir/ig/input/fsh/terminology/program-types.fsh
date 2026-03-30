// ============================================================================
// DHIS2 Program Type
// ============================================================================
//
// DHIS2 distinguishes two fundamental program types:
//   - Tracker programs (WITH_REGISTRATION) require a tracked entity instance
//     (TEI) to be registered first. They model longitudinal workflows such as
//     antenatal care, HIV treatment, or immunisation schedules.
//   - Event programs (WITHOUT_REGISTRATION) capture standalone events that are
//     not linked to a registered individual, e.g., malaria case reports
//     submitted at facility level.
//
// In FHIR, tracker programs map to EpisodeOfCare (the enrollment) with linked
// Encounters (events/visits), while event programs map to standalone Encounters.
// ============================================================================

CodeSystem: DHIS2ProgramTypeCS
Id: dhis2-program-type
Title: "DHIS2 Program Type"
Description: """
Classifies a DHIS2 program as either a tracker program (WITH_REGISTRATION) that
follows individuals over time, or an event program (WITHOUT_REGISTRATION) that
captures standalone, anonymous events.
"""
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #WITH_REGISTRATION "Tracker program"
    "A tracker program that requires registration of a tracked entity instance (TEI). Models longitudinal patient journeys such as antenatal care or HIV treatment."
* #WITHOUT_REGISTRATION "Event program"
    "An event program that captures standalone events without registering an individual. Used for aggregate-style data collection at facility level."


ValueSet: DHIS2ProgramTypeVS
Id: dhis2-program-type-vs
Title: "DHIS2 Program Types"
Description: """
Value set containing all DHIS2 program types (tracker and event).
"""
* ^experimental = false
* include codes from system DHIS2ProgramTypeCS
