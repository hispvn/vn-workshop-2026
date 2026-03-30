// ============================================================================
// DHIS2-FHIR Learning IG — Extensions
// ============================================================================
//
// Extensions are FHIR's mechanism for adding data elements that are not part
// of the base resource definition. DHIS2's data model contains concepts that
// have no direct equivalent in core FHIR resources, so we define custom
// extensions to carry that information.
//
// Each extension has:
//   - A canonical URL (auto-generated from Id by SUSHI)
//   - A Context that declares which resource types can use the extension
//   - A value type (simple extensions) or sub-extensions (complex extensions)
//   - Optional bindings to ValueSets for coded values
//
// Extension design principles used in this IG:
//   1. Keep extensions simple where possible (single value).
//   2. Use complex (multi-part) extensions only when multiple related fields
//      must travel together (e.g., DHIS2DataElementExtension).
//   3. Always document the DHIS2 concept being represented and how it maps.
//   4. Set appropriate cardinality on sub-extensions.
// ============================================================================


// ============================================================================
// DHIS2OrgUnitExtension
// ============================================================================
//
// DHIS2 Concept: Organisation Unit
//
// In DHIS2, every data entry and tracker event is associated with an
// organisation unit — the facility, district, or administrative unit where the
// activity took place. The org unit hierarchy is one of the three core
// dimensions of DHIS2's data model (along with data elements and time periods).
//
// FHIR Mapping:
// Some FHIR resources have a natural place for this (e.g.,
// Encounter.serviceProvider), but others (Patient, Observation) do not have a
// standard element for "registering organisation unit". This extension fills
// that gap by providing a Reference to an Organization resource that
// represents the DHIS2 org unit.
//
// Usage example (in a Patient instance):
//   * extension[DHIS2OrgUnitExtension].valueReference = Reference(OrgUnit-Ngelehun-CHC)
// ============================================================================

Extension: DHIS2OrgUnitExtension
Id: dhis2-org-unit
Title: "DHIS2 Organisation Unit"
Description: """
Links a FHIR resource to the DHIS2 organisation unit where it was registered
or where the activity took place. In DHIS2, the organisation unit hierarchy
represents the geographic and administrative structure (e.g., country >
region > district > facility). This extension carries a reference to the
FHIR Organization resource that represents that org unit.

Use this extension on resources where the base FHIR specification does not
provide a standard element for the registering/reporting organisation unit.
"""

// Context declares which resource types may use this extension.
// We allow it on Patient (registration org unit), Encounter (where the visit
// happened), EpisodeOfCare (where the enrollment was created), and
// Observation (where the data was recorded).
* ^context[0].type = #element
* ^context[=].expression = "Patient"
* ^context[+].type = #element
* ^context[=].expression = "Encounter"
* ^context[+].type = #element
* ^context[=].expression = "EpisodeOfCare"
* ^context[+].type = #element
* ^context[=].expression = "Observation"
* ^context[+].type = #element
* ^context[=].expression = "QuestionnaireResponse"

// The extension carries a single value: a Reference to an Organization.
// We constrain value[x] to only allow Reference, and further restrict the
// reference target to Organization (not any resource).
* value[x] only Reference(Organization)

// Short display text shown in profile differential tables.
* value[x] ^short = "Reference to the DHIS2 Organisation Unit (as a FHIR Organization)"


// ============================================================================
// DHIS2ProgramExtension
// ============================================================================
//
// DHIS2 Concept: Program
//
// A DHIS2 program defines a structured data collection workflow. Tracker
// programs follow individuals over time (e.g., antenatal care, immunisation),
// while event programs capture standalone events (e.g., malaria case reports).
//
// FHIR Mapping:
// - Tracker program enrollments -> EpisodeOfCare
// - Program stage events -> Encounter
//
// This extension captures which program an EpisodeOfCare or Encounter belongs
// to, and whether it is a tracker or event program. The value is a Coding
// drawn from DHIS2ProgramTypeVS.
//
// Note: The specific program UID is typically carried in the resource's
// identifier element (with system = $DHIS2-PROGRAM). This extension captures
// the program TYPE (tracker vs. event), not the program identity.
//
// Usage example:
//   * extension[DHIS2ProgramExtension].valueCoding = DHIS2ProgramTypeCS#WITH_REGISTRATION
// ============================================================================

Extension: DHIS2ProgramExtension
Id: dhis2-program
Title: "DHIS2 Program"
Description: """
Identifies which type of DHIS2 program an enrollment (EpisodeOfCare) or event
(Encounter) belongs to. DHIS2 has two program types:

- **Tracker programs** (WITH_REGISTRATION): require a registered tracked
  entity instance (TEI) and support multiple program stages over time.
- **Event programs** (WITHOUT_REGISTRATION): capture standalone, anonymous
  events without individual registration.

This distinction affects how data is structured and aggregated, so it is
important metadata for downstream consumers.
"""

// Context: EpisodeOfCare (for enrollments) and Encounter (for events).
* ^context[0].type = #element
* ^context[=].expression = "EpisodeOfCare"
* ^context[+].type = #element
* ^context[=].expression = "Encounter"

// The value is a Coding (code + system + display) rather than a simple code,
// so that the code system is always explicit in the instance.
* value[x] only Coding

// Bind to the DHIS2 Program Type value set with "example" strength. Example
// strength means validators will not reject other codes — this is appropriate
// because implementers may extend the type list in the future.
* value[x] from DHIS2ProgramTypeVS (example)
* value[x] ^short = "The type of DHIS2 program (tracker or event)"


// ============================================================================
// DHIS2DataElementExtension
// ============================================================================
//
// DHIS2 Concept: Data Element
//
// A DHIS2 data element is the fundamental unit of data collection — a single
// field on a form. Each data element has:
//   - A unique 11-character UID
//   - A human-readable name (e.g., "Hemoglobin value")
//   - A value type (e.g., NUMBER, TEXT, DATE)
//   - An aggregation type (e.g., SUM, AVERAGE)
//
// FHIR Mapping:
// Data elements map to Observations. The data element UID can be placed in
// Observation.code (as a coding with system = $DHIS2-DE), but additional
// metadata such as the value type and aggregation type have no standard FHIR
// home. This complex extension groups all data-element metadata together.
//
// This is a "complex" extension — it contains sub-extensions rather than a
// single value. Complex extensions are used when multiple related attributes
// must travel together as a cohesive unit.
//
// Usage example:
//   * extension[DHIS2DataElementExtension].extension[dataElementId].valueString = "qrur9Dvnyt5"
//   * extension[DHIS2DataElementExtension].extension[dataElementName].valueString = "Age in years"
//   * extension[DHIS2DataElementExtension].extension[valueType].valueCoding = DHIS2DataElementTypeCS#INTEGER
//   * extension[DHIS2DataElementExtension].extension[aggregationType].valueCoding = DHIS2AggregationTypeCS#AVERAGE
// ============================================================================

Extension: DHIS2DataElementExtension
Id: dhis2-data-element
Title: "DHIS2 Data Element"
Description: """
Links an Observation to its source DHIS2 data element and carries metadata
about that data element. This extension groups four related attributes:

1. **dataElementId** (required) — the 11-character DHIS2 UID that uniquely
   identifies the data element.
2. **dataElementName** (optional) — the human-readable name of the data
   element, included for convenience so consumers do not need to look up the
   UID in a DHIS2 instance.
3. **valueType** (optional) — the DHIS2 value type (e.g., NUMBER, TEXT),
   which indicates what kind of data the element captures.
4. **aggregationType** (optional) — how values are aggregated across org units
   and time periods (e.g., SUM, AVERAGE).
"""

// Context: Observation only, since data elements map to Observations.
* ^context[0].type = #element
* ^context[=].expression = "Observation"

// A complex extension does not have a direct value — it uses sub-extensions.
// We explicitly state that the extension itself has no value[x]; all data
// lives in the nested extensions below.

// -- Sub-extension: dataElementId --
// The DHIS2 UID of the data element. This is the primary key used to look up
// the data element in the DHIS2 API (e.g., GET /api/dataElements/qrur9Dvnyt5).
// Required (1..1) because without the UID this extension has no meaning.
* extension contains
    dataElementId 1..1 and
    dataElementName 0..1 and
    valueType 0..1 and
    aggregationType 0..1

* extension[dataElementId] ^short = "The 11-character DHIS2 UID of the data element"
* extension[dataElementId].value[x] only string

// -- Sub-extension: dataElementName --
// The human-readable name (e.g., "MCH ANC Visit"). Optional because the UID
// is sufficient for machine processing; the name is a convenience for humans.
* extension[dataElementName] ^short = "Human-readable name of the data element"
* extension[dataElementName].value[x] only string

// -- Sub-extension: valueType --
// The DHIS2 value type enum (TEXT, NUMBER, BOOLEAN, etc.). Bound to
// DHIS2DataElementTypeVS so that only recognised types are used. The
// binding strength is "required" because the value type list is a closed
// enumeration within DHIS2.
* extension[valueType] ^short = "The DHIS2 value type (e.g., NUMBER, TEXT, BOOLEAN)"
* extension[valueType].value[x] only Coding
* extension[valueType].value[x] from DHIS2DataElementTypeVS (required)

// -- Sub-extension: aggregationType --
// How this data element's values should be aggregated (SUM, AVERAGE, etc.).
// Bound to DHIS2AggregationTypeVS with "required" strength.
* extension[aggregationType] ^short = "How values are aggregated (e.g., SUM, AVERAGE)"
* extension[aggregationType].value[x] only Coding
* extension[aggregationType].value[x] from DHIS2AggregationTypeVS (required)


// ============================================================================
// DHIS2CategoryComboExtension
// ============================================================================
//
// DHIS2 Concept: Category Option Combination (COC)
//
// DHIS2 uses a "category model" for data disaggregation. For example, a data
// element "Number of malaria cases" might be disaggregated by age group
// (<5, 5-14, 15+) and sex (Male, Female). Each unique combination (e.g.,
// "Male, <5") is a Category Option Combination identified by a UID.
//
// FHIR Mapping:
// There is no direct FHIR equivalent for DHIS2's category model. FHIR
// Observations can use `component` for multiple axes, but the DHIS2 category
// combo is a single composite identifier rather than independent axes. This
// extension carries the category option combination as a simple string (the
// UID or a human-readable label), allowing consumers to trace disaggregation
// back to DHIS2.
//
// In aggregate data exports, the category option combination is as important
// as the data element UID — together they form the complete "what" dimension
// of the data value.
//
// Usage example:
//   * extension[DHIS2CategoryComboExtension].valueString = "PT59n8BQbqM"
// ============================================================================

Extension: DHIS2CategoryComboExtension
Id: dhis2-category-combo
Title: "DHIS2 Category Combination"
Description: """
Identifies the DHIS2 category option combination (COC) that disaggregates a
data value. In DHIS2, category combinations represent intersections of
disaggregation dimensions (e.g., age group x sex). The COC UID, together
with the data element UID, uniquely identifies what a data value represents.

This extension carries the COC as a string value, which may be the 11-character
DHIS2 UID or a human-readable composite label depending on implementation
preference.
"""

// Context: Observation (individual data values) and MeasureReport (aggregated
// data). Both may need to indicate which disaggregation category applies.
* ^context[0].type = #element
* ^context[=].expression = "Observation"
* ^context[+].type = #element
* ^context[=].expression = "MeasureReport"

// The value is a simple string — either the COC UID or a display label.
// We chose string over Coding because DHIS2 category combos do not have a
// fixed code system; they are instance-specific metadata.
* value[x] only string
* value[x] ^short = "DHIS2 Category Option Combination UID or label"
