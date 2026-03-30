// ============================================================================
// DHIS2-FHIR Learning IG — Invariants
// ============================================================================
//
// Invariants are validation rules expressed in FHIRPath that are applied to
// resource elements at validation time. They enforce business rules that cannot
// be expressed through cardinality or type constraints alone.
//
// In FSH, an Invariant is declared once and then applied to specific elements
// in profiles using the `obeys` keyword. For example:
//
//   * identifier.value obeys dhis2-uid-format
//
// Each invariant has:
//   - A unique name (used with `obeys`)
//   - A human-readable Description shown in error messages
//   - A FHIRPath Expression that must evaluate to true for the element to be
//     valid
//   - A Severity of #error (validation fails) or #warning (advisory)
//
// This file collects all invariants used across multiple profiles so they are
// defined in one place and can be reused consistently.
// ============================================================================


// ----------------------------------------------------------------------------
// dhis2-uid-format
// ----------------------------------------------------------------------------
// DHIS2 uses a proprietary UID format for all metadata and data objects. Every
// UID is exactly 11 characters long: the first character must be a letter
// (a-z or A-Z) and the remaining 10 characters can be letters or digits.
//
// Examples of valid UIDs:   Uvn6LCg7dVU, a1234567890, AbCdEfGhIjK
// Examples of invalid UIDs: 12345678901 (starts with digit), abc (too short)
//
// We enforce this format on identifier values that carry DHIS2 UIDs so that
// downstream systems can rely on the format for lookups and API calls.
// ----------------------------------------------------------------------------

Invariant: dhis2-uid-format
Description: "DHIS2 UIDs must be exactly 11 alphanumeric characters, starting with a letter"
Expression: "matches('^[a-zA-Z][a-zA-Z0-9]{10}$')"
Severity: #error


// ----------------------------------------------------------------------------
// dhis2-birthdate-not-future
// ----------------------------------------------------------------------------
// A basic data quality rule: a patient's birth date must not be in the future.
// DHIS2 Tracker enforces this in its UI, but data imported via the API may
// bypass those checks. Applying this invariant to Patient.birthDate ensures
// that FHIR validation catches the error.
//
// The FHIRPath expression compares the element value ($this) against today's
// date. Because birthDate is a FHIR `date` type, the comparison works at date
// precision (year-month-day) without time-of-day concerns.
// ----------------------------------------------------------------------------

Invariant: dhis2-birthdate-not-future
Description: "Birth date must not be in the future"
Expression: "$this <= today()"
Severity: #error


// ----------------------------------------------------------------------------
// dhis2-identifier-has-system
// ----------------------------------------------------------------------------
// FHIR best practice requires every Identifier to carry a `system` URI that
// namespaces the identifier value. Without a system, consumers cannot
// determine what the identifier means or which authority assigned it.
//
// In DHIS2 mappings we always set the system to one of the $DHIS2-* aliases
// (e.g., $DHIS2-TEI for tracked entity identifiers). This invariant ensures
// that no identifier is left without a system, which could happen if a mapping
// is misconfigured.
//
// Applied to Identifier elements where we want to enforce this rule beyond
// FHIR's base optionality (Identifier.system is 0..1 in base FHIR).
// ----------------------------------------------------------------------------

Invariant: dhis2-identifier-has-system
Description: "Each identifier must have a system"
Expression: "system.exists()"
Severity: #error
