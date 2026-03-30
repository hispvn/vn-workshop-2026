// ============================================================================
// DHIS2 Patient Profiles and Instances
// ============================================================================
//
// This file defines the core Patient profile for the DHIS2-FHIR Learning IG.
//
// In DHIS2, patients are modeled as Tracked Entity Instances (TEIs) of type
// "Person." Each TEI has a unique auto-generated UID (an 11-character
// alphanumeric string) and can carry any number of Tracked Entity Attributes
// (TEAs) — name, gender, date of birth, national ID, address, etc.
//
// The DHIS2Patient profile maps this concept onto FHIR's Patient resource,
// ensuring that:
//   - Every patient carries a DHIS2 TEI UID as a required identifier.
//   - Standard demographics (name, gender, birthDate) are mandatory so that
//     the resource is clinically useful and aligns with DHIS2 Tracker's
//     required attributes for person-type tracked entities.
//   - An optional national identifier slice supports the common DHIS2 pattern
//     of capturing a government-issued ID as a tracked entity attribute.
//   - The DHIS2 Organisation Unit that "owns" this patient is captured via
//     an extension, mirroring the orgUnit assignment every TEI has in DHIS2.
//
// Dependencies:
//   aliases.fsh        — $DHIS2-TEI, $V2-0203
//   invariants.fsh     — dhis2-uid-format, dhis2-birthdate-not-future
//   extensions.fsh     — DHIS2OrgUnitExtension
// ============================================================================


// ----------------------------------------------------------------------------
// Profile: DHIS2Patient
// ----------------------------------------------------------------------------
// Maps a DHIS2 Tracked Entity Instance (TEI) of type Person to FHIR Patient.
//
// DHIS2 context:
//   - Every TEI has a server-generated UID (11 alphanumeric chars).
//   - TEIs are always registered at (owned by) an Organisation Unit.
//   - Tracker programs commonly require name, sex, and date of birth as
//     mandatory tracked entity attributes. This profile enforces the same.
//   - National ID is frequently captured but not always mandatory, so it is
//     0..1 here.
// ----------------------------------------------------------------------------
Profile: DHIS2Patient
Parent: Patient
Id: dhis2-patient
Title: "DHIS2 Patient"
Description: """
A Patient resource representing a DHIS2 Tracked Entity Instance (TEI) of type
Person. This profile ensures that essential demographics and the DHIS2 UID are
always present, enabling round-trip interoperability between DHIS2 Tracker and
FHIR-based systems.

In DHIS2, every tracked entity is uniquely identified by an 11-character
alphanumeric UID and is registered at (owned by) a specific Organisation Unit.
This profile captures both concepts: the UID as a required identifier slice and
the owning org unit as an extension.
"""

// -- Identifiers (sliced) ---------------------------------------------------
// DHIS2 TEIs can carry multiple identifiers. We define two well-known slices:
//   1. dhis2uid  — the DHIS2-generated UID (mandatory, exactly one)
//   2. national  — a government-issued national identifier (optional)
// Additional identifiers are allowed for local systems.
// ----------------------------------------------------------------------------
* identifier 1..* MS
* identifier ^short = "Identifiers for this patient — must include DHIS2 UID"
* identifier ^definition = """
At least one identifier must be present: the DHIS2 Tracked Entity Instance UID.
Additional identifiers (national ID, facility MRN, etc.) are encouraged.
"""

// Slicing discriminator: we use the identifier type coding to distinguish
// slices. This is a standard FHIR pattern for identifier slicing.
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice identifiers by type code"
* identifier ^slicing.ordered = false

// -- Slice: dhis2uid ---------------------------------------------------------
// The DHIS2 Tracked Entity Instance UID. This is the primary key in DHIS2 and
// is always an 11-character string matching the pattern [a-zA-Z][a-zA-Z0-9]{10}.
// The system is $DHIS2-TEI so consumers know where this identifier originated.
// The type code RI (Resource Identifier) from HL7 v2 Table 0203 indicates a
// system-generated resource identifier.
// ----------------------------------------------------------------------------
* identifier contains dhis2uid 1..1 MS
* identifier[dhis2uid] ^short = "DHIS2 Tracked Entity Instance UID"
* identifier[dhis2uid] ^definition = """
The unique 11-character alphanumeric identifier assigned by DHIS2 to this
Tracked Entity Instance. Format: starts with a letter, followed by exactly
10 alphanumeric characters. Example: 'DXz2k5eGbri'.
"""
* identifier[dhis2uid].system 1..1
* identifier[dhis2uid].system = $DHIS2-TEI (exactly)
* identifier[dhis2uid].type 1..1
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value 1..1
* identifier[dhis2uid].value ^short = "The 11-character DHIS2 UID"
* identifier[dhis2uid].value obeys dhis2-uid-format

// -- Slice: national ---------------------------------------------------------
// A government-issued national identifier. Many DHIS2 implementations capture
// this as a tracked entity attribute (e.g., "National ID"). The type code NI
// (National Identifier) from HL7 v2 Table 0203 is used.
// ----------------------------------------------------------------------------
* identifier contains national 0..1 MS
* identifier[national] ^short = "National identifier (government-issued)"
* identifier[national] ^definition = """
A government-issued national identifier such as a national ID number or social
security number. In DHIS2, this is typically stored as a tracked entity
attribute on the Person tracked entity type.
"""
* identifier[national].system 0..1
* identifier[national].type 1..1
* identifier[national].type = $V2-0203#NI
* identifier[national].value 1..1

// -- Slice: chr ---------------------------------------------------------------
// Community Health Record ID — used in the Lao PDR health registry.
// ----------------------------------------------------------------------------
* identifier contains chr 0..1 MS
* identifier[chr] ^short = "Community Health Record ID"
* identifier[chr].system 1..1
* identifier[chr].system = $LAO-CHR (exactly)
* identifier[chr].type 1..1
* identifier[chr].type = LaoIdentifierType#CHR
* identifier[chr].value 1..1

// -- Slice: cvid --------------------------------------------------------------
// Civil Registration and Vital Statistics ID.
// ----------------------------------------------------------------------------
* identifier contains cvid 0..1 MS
* identifier[cvid] ^short = "Civil Registration and Vital Statistics ID"
* identifier[cvid].system 1..1
* identifier[cvid].system = $LAO-CVID (exactly)
* identifier[cvid].type 1..1
* identifier[cvid].type = LaoIdentifierType#CVID
* identifier[cvid].value 1..1

// -- Slice: insurance ---------------------------------------------------------
// Health insurance number.
// ----------------------------------------------------------------------------
* identifier contains insurance 0..1 MS
* identifier[insurance] ^short = "Insurance number"
* identifier[insurance].system 1..1
* identifier[insurance].system = $LAO-INSURANCE (exactly)
* identifier[insurance].type 1..1
* identifier[insurance].type = LaoIdentifierType#INS
* identifier[insurance].value 1..1

// -- Slice: greenCard ---------------------------------------------------------
// Lao Green National ID Card number.
// ----------------------------------------------------------------------------
* identifier contains greenCard 0..1 MS
* identifier[greenCard] ^short = "Lao Green National ID Card"
* identifier[greenCard].system 1..1
* identifier[greenCard].system = $LAO-GREEN (exactly)
* identifier[greenCard].type 1..1
* identifier[greenCard].type = LaoIdentifierType#GREENCARD
* identifier[greenCard].value 1..1

// -- Slice: familyBook --------------------------------------------------------
// Family Book (tabien baan) registration number.
// ----------------------------------------------------------------------------
* identifier contains familyBook 0..1 MS
* identifier[familyBook] ^short = "Family Book number"
* identifier[familyBook].system 1..1
* identifier[familyBook].system = $LAO-FAMILYBOOK (exactly)
* identifier[familyBook].type 1..1
* identifier[familyBook].type = LaoIdentifierType#FAMILYBOOK
* identifier[familyBook].value 1..1

// -- Slice: passport ----------------------------------------------------------
// Passport number — uses standard v2-0203 PPN code.
// ----------------------------------------------------------------------------
* identifier contains passport 0..1 MS
* identifier[passport] ^short = "Passport number"
* identifier[passport].type 1..1
* identifier[passport].type = $V2-0203#PPN
* identifier[passport].value 1..1

// -- Name --------------------------------------------------------------------
// DHIS2 Tracker programs almost universally require first and last name as
// tracked entity attributes. We enforce at least one name with family and
// given components.
// ----------------------------------------------------------------------------
* name 1..* MS
* name ^short = "Patient name — family and given are required"
* name.family 1..1
* name.family ^short = "Family (last) name"
* name.given 1..*
* name.given ^short = "Given (first) name(s)"

// -- Gender ------------------------------------------------------------------
// DHIS2 captures sex as a mandatory tracked entity attribute in most person-
// type programs. FHIR's gender value set (male | female | other | unknown)
// maps well to DHIS2's common option set for sex.
// ----------------------------------------------------------------------------
* gender 1..1 MS
* gender ^short = "Patient gender (maps to DHIS2 sex attribute)"

// -- Birth Date --------------------------------------------------------------
// Date of birth is a core tracked entity attribute in DHIS2. The custom
// invariant dhis2-birthdate-not-future ensures data quality by preventing
// future dates — a common validation rule in DHIS2 program rules.
// ----------------------------------------------------------------------------
* birthDate 1..1 MS
* birthDate ^short = "Date of birth (must not be in the future)"
* birthDate obeys dhis2-birthdate-not-future

// -- Address -----------------------------------------------------------------
// DHIS2 captures address information at varying levels of granularity across
// implementations. We mark it as Must Support but not required, since not all
// DHIS2 programs collect detailed addresses.
// ----------------------------------------------------------------------------
* address MS
* address ^short = "Patient address (maps to DHIS2 address attributes)"
* address.district MS
* address.district ^short = "District (administrative area)"

// -- Telecom ------------------------------------------------------------------
// Contact details such as phone number or email address.
// ----------------------------------------------------------------------------
* telecom MS
* telecom ^short = "Contact details (phone, email)"

// -- Organisation Unit Extension ---------------------------------------------
// In DHIS2, every TEI is "owned by" an Organisation Unit. This extension
// carries a reference to the DHIS2Organization that owns/registered this
// patient. It mirrors the orgUnit field on the DHIS2 TEI API resource.
// ----------------------------------------------------------------------------
* extension contains DHIS2OrgUnitExtension named orgUnit 0..1 MS
* extension[orgUnit] ^short = "DHIS2 Organisation Unit that owns this patient"
* extension[orgUnit] ^definition = """
A reference to the DHIS2 Organisation Unit where this patient (tracked entity
instance) is registered. In DHIS2, every TEI has an owning org unit that
controls data access and determines the reporting hierarchy.
"""


// ============================================================================
// RuleSet: DHIS2PatientIdentifiers
// ============================================================================
// A reusable rule set for populating identifier values on DHIS2Patient
// instances. This reduces repetition across examples and makes it easy to
// create new patient instances with consistent identifier structure.
//
// Parameters:
//   {dhis2uid}    — the 11-character DHIS2 UID
//   {natId}       — the national identifier value
//   {natSystem}   — the system URI for the national identifier
//
// Usage in an instance:
//   * insert DHIS2PatientIdentifiers(DXz2k5eGbri, 12345678901, urn:oid:2.16.454.1)
// ============================================================================
RuleSet: DHIS2PatientIdentifiers(dhis2uid, natId, natSystem)
// First identifier: the DHIS2 TEI UID — always present
* identifier[dhis2uid].system = $DHIS2-TEI
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value = "{dhis2uid}"
// Second identifier: the national ID
* identifier[national].system = "{natSystem}"
* identifier[national].type = $V2-0203#NI
* identifier[national].value = "{natId}"
