// ============================================================================
// DHIS2 Data Element Value Types
// ============================================================================
//
// In DHIS2, every data element declares a "valueType" that constrains what kind
// of data can be entered. This is conceptually similar to FHIR's element types
// but uses DHIS2's own enumeration. When mapping to FHIR we need to translate
// these types (e.g., NUMBER -> Quantity, BOOLEAN -> boolean, DATE -> dateTime).
//
// This CodeSystem enumerates all value types supported by DHIS2 as of version
// 2.40. Profiles and extensions can bind to the companion ValueSet so that
// tooling can validate that only recognised types are used.
// ============================================================================

CodeSystem: DHIS2DataElementTypeCS
Id: dhis2-data-element-type
Title: "DHIS2 Data Element Value Type"
Description: """
Enumerates the value types that a DHIS2 data element can hold. Each code
corresponds to the `valueType` property on a DHIS2 DataElement object.

When converting DHIS2 data to FHIR, the value type determines which FHIR
data type to use for `Observation.value[x]`:
- TEXT / LONG_TEXT -> valueString
- NUMBER / INTEGER / PERCENTAGE -> valueQuantity
- BOOLEAN / TRUE_ONLY -> valueBoolean
- DATE / DATETIME / TIME -> valueDateTime / valueTime
- COORDINATE -> extension with latitude/longitude
- PHONE_NUMBER / EMAIL / URL / USERNAME -> valueString with constraints
- FILE_RESOURCE -> valueAttachment
- ORGANISATION_UNIT -> valueReference(Organization)
- AGE -> valueQuantity (with UCUM unit 'a' for years)
- TRACKER_ASSOCIATE -> valueReference(Patient)
"""

// The caseSensitive flag indicates that code comparison must respect letter
// case. DHIS2 value types are conventionally UPPER_SNAKE_CASE.
* ^caseSensitive = true

// The content flag tells consumers whether this CodeSystem resource contains
// all codes (complete) or just a subset (fragment/example). We include every
// value type, so this is complete.
* ^content = #complete

// Experimental = false means this is intended for real use, not a draft.
* ^experimental = false

// --- Text types ---
// Used for free-text fields such as names, notes, and descriptions.
* #TEXT "Text"
    "Single-line text input. Maps to FHIR valueString."
* #LONG_TEXT "Long text"
    "Multi-line text input for longer narratives. Maps to FHIR valueString."

// --- Numeric types ---
// Used for quantitative data such as counts, measurements, and percentages.
* #NUMBER "Number"
    "Decimal number. Maps to FHIR valueQuantity (no unit constraint)."
* #INTEGER "Integer"
    "Whole number (positive, negative, or zero). Maps to FHIR valueInteger."
* #INTEGER_POSITIVE "Positive Integer"
    "Whole number greater than zero. Maps to FHIR valueInteger with min = 1."
* #INTEGER_NEGATIVE "Negative Integer"
    "Whole number less than zero. Maps to FHIR valueInteger with max = -1."
* #INTEGER_ZERO_OR_POSITIVE "Zero or Positive Integer"
    "Whole number >= 0. Maps to FHIR valueInteger with min = 0."
* #PERCENTAGE "Percentage"
    "Number between 0 and 100 representing a percentage. Maps to FHIR valueQuantity with unit '%' (UCUM)."

// --- Boolean types ---
// DHIS2 distinguishes between true/false (BOOLEAN) and true-only (TRUE_ONLY)
// where the absence of a value means false.
* #BOOLEAN "Boolean"
    "True or false. Maps to FHIR valueBoolean."
* #TRUE_ONLY "True Only"
    "Can only be true; absence means false. Maps to FHIR valueBoolean (true when present)."

// --- Date and time types ---
// DHIS2 supports separate date, datetime, and time types.
* #DATE "Date"
    "Calendar date (YYYY-MM-DD). Maps to FHIR valueDateTime with date precision."
* #DATETIME "Date and Time"
    "Full timestamp (YYYY-MM-DDThh:mm:ss). Maps to FHIR valueDateTime."
* #TIME "Time"
    "Time of day without date (HH:mm). Maps to FHIR valueTime."

// --- Contact and identifier types ---
// These are semantically strings but carry validation rules in DHIS2.
* #PHONE_NUMBER "Phone Number"
    "Phone number string. Maps to FHIR valueString or ContactPoint."
* #EMAIL "Email"
    "Email address string. Maps to FHIR valueString or ContactPoint."
* #URL "URL"
    "A URL / web address. Maps to FHIR valueUrl."
* #USERNAME "Username"
    "A DHIS2 username. Maps to FHIR valueString."

// --- Complex types ---
// These types carry structured or referential data.
* #COORDINATE "Coordinate"
    "Geographic coordinate (latitude, longitude). Maps to a FHIR extension or Observation.component with lat/lon."
* #TRACKER_ASSOCIATE "Tracker Associate"
    "Reference to another tracked entity instance. Maps to FHIR valueReference(Patient)."
* #FILE_RESOURCE "File Resource"
    "Reference to an uploaded file in DHIS2. Maps to FHIR valueAttachment."
* #ORGANISATION_UNIT "Organisation Unit"
    "Reference to a DHIS2 organisation unit. Maps to FHIR valueReference(Organization)."
* #AGE "Age"
    "An age value computed from a date of birth. Maps to FHIR valueQuantity with UCUM unit 'a' (years)."


// Companion ValueSet that includes every code from DHIS2DataElementTypeCS.
// Profiles bind to this ValueSet (not the CodeSystem directly) so that future
// IGs can create restricted subsets if needed.
ValueSet: DHIS2DataElementTypeVS
Id: dhis2-data-element-type-vs
Title: "DHIS2 Data Element Value Types"
Description: """
All value types supported by DHIS2 data elements. Used to indicate what kind
of data a particular data element captures so that FHIR mapping logic can
select the appropriate value[x] type.
"""
* ^experimental = false
* include codes from system DHIS2DataElementTypeCS
