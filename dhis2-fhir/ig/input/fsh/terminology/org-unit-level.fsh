// ============================================================================
// DHIS2 Organisation Unit Level — CodeSystem and ValueSet
// ============================================================================
//
// DHIS2 org unit hierarchies typically have named levels (e.g., National,
// District, Chiefdom, Facility). These levels determine aggregation behavior
// and user access. This CodeSystem captures common level names found in
// DHIS2 deployments, based on the Sierra Leone play server (4 levels).
//
// In FHIR, these map to Organization.type — telling consumers what tier
// of the hierarchy an Organization represents.
// ============================================================================

CodeSystem: DHIS2OrgUnitLevelCS
Id: DHIS2OrgUnitLevelCS
Title: "DHIS2 Organisation Unit Level"
Description: """
Codes representing levels in the DHIS2 organisation unit hierarchy.
Most DHIS2 deployments have 3–6 levels, from a single national root
down to individual health facilities or community health posts.
"""
* ^caseSensitive = true
* ^content = #complete
* ^status = #active

* #national "National"
    "The top-level (root) org unit, typically a Ministry of Health or national authority."
* #district "District"
    "A district-level administrative unit responsible for a group of health facilities."
* #chiefdom "Chiefdom"
    "A sub-district administrative unit (common in West African DHIS2 deployments)."
* #facility "Facility"
    "A health facility where services are delivered and data is collected."


ValueSet: DHIS2OrgUnitLevelVS
Id: DHIS2OrgUnitLevelVS
Title: "DHIS2 Organisation Unit Level"
Description: "Organisation unit hierarchy levels used in DHIS2 deployments."
* include codes from system DHIS2OrgUnitLevelCS


// ============================================================================
// DHIS2 Organisation Unit Group — CodeSystem and ValueSet
// ============================================================================
//
// DHIS2 org unit groups classify facilities by type (e.g., Hospital, Health
// Center, CHP). In the Sierra Leone play server, common groups include:
//   - CHP (Community Health Post)
//   - CHC (Community Health Centre)
//   - MCHP (Maternal & Child Health Post)
//   - Hospital
//   - Clinic
//
// In FHIR, these map to Organization.type alongside (or instead of) the
// level code, giving consumers both "where in the hierarchy" and "what kind
// of facility" information.
// ============================================================================

CodeSystem: DHIS2OrgUnitGroupCS
Id: DHIS2OrgUnitGroupCS
Title: "DHIS2 Organisation Unit Group"
Description: """
Codes representing the type of health facility, derived from DHIS2
organisation unit groups. These classify facilities by function and
service capability.
"""
* ^caseSensitive = true
* ^content = #complete
* ^status = #active

* #CHP "Community Health Post"
    "A community-level health post providing basic primary care."
* #CHC "Community Health Centre"
    "A community health centre providing outpatient and basic inpatient services."
* #MCHP "Maternal and Child Health Post"
    "A health post focused on maternal and child health services."
* #hospital "Hospital"
    "A hospital providing comprehensive inpatient and outpatient services."
* #clinic "Clinic"
    "A clinic providing outpatient services."


ValueSet: DHIS2OrgUnitGroupVS
Id: DHIS2OrgUnitGroupVS
Title: "DHIS2 Organisation Unit Group"
Description: "Facility types based on DHIS2 organisation unit groups."
* include codes from system DHIS2OrgUnitGroupCS
