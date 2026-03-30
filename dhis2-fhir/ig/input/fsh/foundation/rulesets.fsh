// ============================================================================
// DHIS2-FHIR Learning IG — RuleSets
// ============================================================================
//
// RuleSets are reusable blocks of FSH rules that can be inserted into profiles,
// extensions, or instances using the "insert" keyword. They reduce duplication
// and enforce consistency across the IG.
//
// Think of a RuleSet as a macro: SUSHI expands it inline wherever it is
// inserted, substituting any parameters you provide. RuleSets do NOT produce
// standalone artifacts — they only exist as authoring helpers.
//
// This file defines four RuleSets used throughout the DHIS2-FHIR IG:
//   1. DHIS2Identifier     — adds a typed DHIS2 identifier to an instance
//   2. DHIS2MetaData       — constrains identifier elements on a profile
//   3. DHIS2Period         — sets period.start and period.end on an instance
//   4. DHIS2MeasurePopulation — adds a population entry to a Measure group
//
// ============================================================================


// ----------------------------------------------------------------------------
// RuleSet: DHIS2Identifier
// ----------------------------------------------------------------------------
// Adds a DHIS2 identifier to a resource instance. DHIS2 objects are identified
// by 11-character alphanumeric UIDs. When we translate them to FHIR we store
// the UID in Identifier.value and record the DHIS2 domain namespace in
// Identifier.system so consumers know what kind of DHIS2 object it refers to.
//
// Parameters:
//   {system} — the identifier system URI (e.g., $DHIS2-OU, $DHIS2-TEI)
//   {value}  — the DHIS2 UID string (e.g., "ImspTQPwCqd")
//
// Usage example (inside an instance):
//   * insert DHIS2Identifier($DHIS2-TEI, "dNpxRu1mObG")
//
// This expands to:
//   * identifier.system = "http://dhis2.org/fhir/id/tracked-entity"
//   * identifier.value = "dNpxRu1mObG"
//   * identifier.type = $V2-0203#RI "Resource identifier"
// ----------------------------------------------------------------------------
RuleSet: DHIS2Identifier(system, value)
* identifier.system = {system}
* identifier.value = {value}
* identifier.type = $V2-0203#RI "Resource identifier"


// ----------------------------------------------------------------------------
// RuleSet: DHIS2MetaData
// ----------------------------------------------------------------------------
// Constrains the identifier element on a profile so that every conforming
// resource carries at least one well-formed identifier. This RuleSet is
// intended for use inside Profile definitions — not instances.
//
// It enforces:
//   - At least one identifier (1..*)
//   - Each identifier must have both system and value (1..1)
//   - The identifier element is Must Support
//
// Usage example (inside a profile):
//   * insert DHIS2MetaData
//
// This expands to:
//   * identifier 1..* MS
//   * identifier.system 1..1
//   * identifier.value 1..1
// ----------------------------------------------------------------------------
RuleSet: DHIS2MetaData
* identifier 1..* MS
* identifier.system 1..1
* identifier.value 1..1


// ----------------------------------------------------------------------------
// RuleSet: DHIS2Period
// ----------------------------------------------------------------------------
// Sets the start and end dates of a period element on an instance. DHIS2
// reporting periods are expressed as codes (e.g., "202401" for January 2024),
// but FHIR uses explicit start/end dates. This RuleSet makes it easy to set
// both in one line.
//
// Parameters:
//   {start} — the period start date in FHIR date format (YYYY-MM-DD)
//   {end}   — the period end date in FHIR date format (YYYY-MM-DD)
//
// Usage example (inside an instance):
//   * insert DHIS2Period("2024-01-01", "2024-01-31")
//
// This expands to:
//   * period.start = "2024-01-01"
//   * period.end = "2024-01-31"
// ----------------------------------------------------------------------------
RuleSet: DHIS2Period(start, end)
* period.start = {start}
* period.end = {end}


// ----------------------------------------------------------------------------
// RuleSet: DHIS2MeasurePopulation
// ----------------------------------------------------------------------------
// Adds a population component to a Measure group. FHIR Measures describe their
// populations (initial-population, numerator, denominator, etc.) using coded
// entries with criteria expressions. In this IG we use text-based criteria
// because DHIS2 indicator formulas are not written in CQL.
//
// Parameters:
//   {popCode}      — code from $measure-population (e.g., initial-population)
//   {popDisplay}   — human-readable display for the code
//   {criteriaText} — plain-text description of what this population captures
//
// Usage example (inside a Measure instance):
//   * group[0].population[0].insert DHIS2MeasurePopulation(
//       initial-population, "Initial Population",
//       "All patients seen during the reporting period")
//
// Note: Because this RuleSet targets a nested element (population), the caller
// must already be positioned inside the correct group. Typically you set
// group[n].population[m] rules directly and use this RuleSet to fill in the
// code and criteria sub-elements.
// ----------------------------------------------------------------------------
RuleSet: DHIS2MeasurePopulation(popCode, popDisplay, criteriaText)
* code = $measure-population#{popCode} {popDisplay}
* criteria.language = #text/plain
* criteria.expression = {criteriaText}
