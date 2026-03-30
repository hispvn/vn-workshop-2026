// ============================================================================
// DHIS2 International Patient Summary (IPS) Profiles
// ============================================================================
//
// A minimal IPS implementation focused on demographics and immunization data.
// The IPS is a standardized, minimal patient summary designed for cross-border
// and cross-system sharing of essential health information.
//
// This module defines three profiles:
//   1. DHIS2IPSPatient       — Demographics (extends DHIS2Patient)
//   2. DHIS2IPSImmunization  — Vaccine administration records
//   3. DHIS2IPSComposition   — The IPS document structure
//   4. DHIS2IPSBundle        — The IPS document Bundle
//
// The IPS Composition ties together Patient and Immunization resources into
// a single document. The Bundle wraps everything for transport.
// ============================================================================


// ----------------------------------------------------------------------------
// Profile: DHIS2IPSPatient
// ----------------------------------------------------------------------------
// Extends DHIS2Patient with additional constraints for IPS compliance.
// IPS requires at minimum: name, gender, birthDate — all of which DHIS2Patient
// already enforces. We add contact telecom as Must Support since IPS
// recommends it for patient matching.
// ----------------------------------------------------------------------------

Profile: DHIS2IPSPatient
Parent: DHIS2Patient
Id: dhis2-ips-patient
Title: "DHIS2 IPS Patient"
Description: """
A Patient profile for the DHIS2 International Patient Summary. Extends the
base DHIS2Patient with IPS-relevant constraints. Includes demographics,
identifiers, and contact information needed for cross-border patient matching.
"""

* telecom MS
* telecom ^short = "Contact details (phone, email) — recommended for patient matching"
* maritalStatus MS
* communication MS
* communication.language MS


// ----------------------------------------------------------------------------
// Profile: DHIS2IPSImmunization
// ----------------------------------------------------------------------------
// Records a single vaccine administration event. In DHIS2, immunizations are
// typically captured as tracker program events with data elements for vaccine
// type, dose number, date, lot number, and site.
//
// Key mappings from DHIS2:
//   - Data element (vaccine type)  -> vaccineCode
//   - Event date                   -> occurrenceDateTime
//   - Data element (dose number)   -> protocolApplied.doseNumberPositiveInt
//   - Data element (lot number)    -> lotNumber
//   - Organisation unit            -> location (via performer)
// ----------------------------------------------------------------------------

Profile: DHIS2IPSImmunization
Parent: Immunization
Id: dhis2-ips-immunization
Title: "DHIS2 IPS Immunization"
Description: """
An Immunization resource for the DHIS2 International Patient Summary. Records
a single vaccine administration with vaccine code, date, dose number, and
optional lot/site information. Maps from DHIS2 tracker program events where
immunization data is captured as data elements.
"""

* status MS
* status ^short = "completed | entered-in-error | not-done"

* vaccineCode 1..1 MS
* vaccineCode ^short = "Vaccine product administered"
* vaccineCode.coding 1..* MS
* vaccineCode.coding ^slicing.discriminator.type = #pattern
* vaccineCode.coding ^slicing.discriminator.path = "system"
* vaccineCode.coding ^slicing.rules = #open

* vaccineCode.coding contains
    cvx 0..1 MS and
    whoAtc 0..1 MS

* vaccineCode.coding[cvx] ^short = "CDC CVX vaccine code"
* vaccineCode.coding[cvx].system = "http://hl7.org/fhir/sid/cvx" (exactly)
* vaccineCode.coding[cvx].code 1..1
* vaccineCode.coding[cvx].display 1..1

* vaccineCode.coding[whoAtc] ^short = "WHO ATC classification"
* vaccineCode.coding[whoAtc].system = "http://www.whocc.no/atc" (exactly)
* vaccineCode.coding[whoAtc].code 1..1

* patient 1..1 MS
* patient ^short = "Patient who received the vaccine"

* occurrence[x] 1..1 MS
* occurrence[x] ^short = "Date/time the vaccine was administered"

* lotNumber MS
* lotNumber ^short = "Vaccine lot number"

* site MS
* site ^short = "Body site where vaccine was administered"

* route MS
* route ^short = "Route of administration (IM, SC, oral, etc.)"

* performer MS

* protocolApplied MS
* protocolApplied.doseNumber[x] MS
* protocolApplied.doseNumber[x] ^short = "Dose number in the series"
* protocolApplied.targetDisease MS
* protocolApplied.targetDisease ^short = "Disease the vaccine protects against"


// ----------------------------------------------------------------------------
// Profile: DHIS2IPSComposition
// ----------------------------------------------------------------------------
// The IPS document Composition. This is the "table of contents" that
// references the Patient and all Immunization resources. IPS requires at
// minimum an Immunizations section (even if empty with a "no known
// immunizations" code).
// ----------------------------------------------------------------------------

Profile: DHIS2IPSComposition
Parent: Composition
Id: dhis2-ips-composition
Title: "DHIS2 IPS Composition"
Description: """
A Composition resource for the DHIS2 International Patient Summary. Structures
the IPS document with a required Immunizations section. The subject is the
IPS Patient and each section entry references an Immunization resource.
"""

* status MS
* type 1..1 MS
* type = http://loinc.org#60591-5 "Patient summary Document"
* subject 1..1 MS
* subject only Reference(DHIS2IPSPatient)
* date 1..1 MS
* author 1..* MS
* title 1..1 MS
* title = "International Patient Summary"

// Immunizations section (required by IPS)
* section 1..* MS
* section ^slicing.discriminator.type = #pattern
* section ^slicing.discriminator.path = "code"
* section ^slicing.rules = #open

* section contains immunizations 1..1 MS

* section[immunizations].title = "Immunizations"
* section[immunizations].code 1..1
* section[immunizations].code = http://loinc.org#11369-6 "History of Immunization note"
* section[immunizations].entry MS
* section[immunizations].entry only Reference(DHIS2IPSImmunization)


// ----------------------------------------------------------------------------
// Profile: DHIS2IPSBundle
// ----------------------------------------------------------------------------
// The IPS document Bundle. Wraps the Composition, Patient, and all
// Immunization resources into a single transportable document.
// ----------------------------------------------------------------------------

Profile: DHIS2IPSBundle
Parent: Bundle
Id: dhis2-ips-bundle
Title: "DHIS2 IPS Bundle"
Description: """
A Bundle of type 'document' containing a DHIS2 IPS Composition as the first
entry, followed by the Patient and Immunization resources. This is the
top-level resource exchanged when sharing an International Patient Summary.
"""

* type = #document (exactly)
* timestamp 1..1 MS
* entry 1..* MS
* entry.resource 1..1 MS
