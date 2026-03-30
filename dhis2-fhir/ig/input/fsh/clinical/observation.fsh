// ============================================================================
// Profile: DHIS2Observation
// ============================================================================
// Maps a DHIS2 data value (either a tracked entity attribute value or an
// event data value) to FHIR Observation.
//
// In DHIS2 Tracker, each event contains data values keyed by data element.
// For example, a "Weight" data element with UID "qrur9Dvnyt5" might have
// value 65.0 recorded at a specific event. This maps to:
//   Observation.code = LOINC#29463-7 "Body weight"
//   Observation.valueQuantity = 65 kg
//   Observation.extension[dataElement] = Reference to the DHIS2 data element
//
// The DHIS2DataElementExtension carries the original DHIS2 data element
// reference, enabling round-trip mapping between FHIR and DHIS2.
//
// The DHIS2CategoryComboExtension captures the DHIS2 category combination
// (disaggregation), which is a powerful DHIS2 feature for breaking data into
// categories like age group, sex, or service type. This has no direct FHIR
// equivalent, so we carry it as an extension.
//
// Dependencies:
//   aliases.fsh       — $LOINC, $UCUM, $V2-0203
//   extensions.fsh    — DHIS2DataElementExtension, DHIS2CategoryComboExtension
//   profiles-patient.fsh       — DHIS2Patient
// ============================================================================
Profile: DHIS2Observation
Parent: Observation
Id: dhis2-observation
Title: "DHIS2 Observation"
Description: """
Represents a DHIS2 data value — either an event data value from a Tracker
program stage or a data value from an aggregate data set. Each observation
maps to a single DHIS2 data element and carries the recorded value along
with its clinical coding (e.g., LOINC).

The DHIS2DataElementExtension preserves the link to the original DHIS2 data
element, enabling bidirectional mapping between FHIR Observations and DHIS2
data values. The optional DHIS2CategoryComboExtension captures DHIS2's
disaggregation categories when applicable.
"""

// -- Status ------------------------------------------------------------------
// Maps to the lifecycle state. For DHIS2 Tracker events, a completed event
// typically maps to 'final'; an active/scheduled event maps to 'preliminary'.
// ----------------------------------------------------------------------------
* status MS
* status ^short = "Observation status (final for completed DHIS2 events)"

// -- Code --------------------------------------------------------------------
// The clinical concept being observed. In DHIS2, each data element has a
// name and optionally a code. When mapping to FHIR, we use standard
// terminologies (LOINC, SNOMED CT) as the primary code and can include
// the DHIS2 data element code as an additional coding.
// ----------------------------------------------------------------------------
* code 1..1 MS
* code ^short = "What was observed — standard code (LOINC/SNOMED) for the DHIS2 data element"

// -- Subject -----------------------------------------------------------------
// The patient this observation is about. In DHIS2 Tracker, this is the
// tracked entity instance associated with the event.
// ----------------------------------------------------------------------------
* subject 1..1 MS
* subject ^short = "The patient (DHIS2 tracked entity) this observation is about"
* subject only Reference(DHIS2Patient)

// -- Encounter ---------------------------------------------------------------
// The encounter (DHIS2 event) during which this data value was captured.
// This links the observation back to the specific visit/event.
// ----------------------------------------------------------------------------
* encounter MS
* encounter ^short = "The encounter (DHIS2 event) where this value was captured"
* encounter only Reference(DHIS2Encounter)

// -- Effective ---------------------------------------------------------------
// When the observation was made. In DHIS2, this corresponds to the event
// date (eventDate) or the execution date of the program stage event.
// We use effective[x] (dateTime or Period) to accommodate both point-in-time
// and duration-based observations.
// ----------------------------------------------------------------------------
* effective[x] 1..1 MS
* effective[x] ^short = "When observed — maps to DHIS2 event date"

// -- Value -------------------------------------------------------------------
// The observed value. DHIS2 data elements can be of various value types:
//   - NUMBER → valueQuantity (with UCUM units)
//   - TEXT → valueString
//   - BOOLEAN → valueBoolean
//   - DATE → valueDateTime
//   - OPTION_SET → valueCodeableConcept (mapped from DHIS2 option set)
// FHIR's value[x] polymorphism handles all of these naturally.
// ----------------------------------------------------------------------------
* value[x] 0..1 MS
* value[x] ^short = "Observed value — type depends on DHIS2 data element value type"

// -- Extension: DHIS2 Data Element -------------------------------------------
// Links this observation to the original DHIS2 data element. This is critical
// for round-trip mapping: when converting FHIR back to DHIS2, we need to know
// which data element UID to write the value to.
// ----------------------------------------------------------------------------
* extension contains DHIS2DataElementExtension named dataElement 0..1 MS
* extension[dataElement] ^short = "Reference to the DHIS2 data element"

// -- Extension: DHIS2 Category Combination -----------------------------------
// DHIS2's category combinations allow data to be disaggregated by dimensions
// such as age group, sex, or service delivery point type. There is no direct
// FHIR equivalent for this concept, so we carry it as an extension.
// Example: a data element "Malaria cases" might have a category combination
// that disaggregates by age (<5, 5-14, 15+) and sex (Male, Female).
// ----------------------------------------------------------------------------
* extension contains DHIS2CategoryComboExtension named categoryCombo 0..1
* extension[categoryCombo] ^short = "DHIS2 category combination for disaggregation"
