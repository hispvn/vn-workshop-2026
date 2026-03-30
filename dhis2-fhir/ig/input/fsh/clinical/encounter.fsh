// ============================================================================
// Profile: DHIS2Encounter
// ============================================================================
// Maps a DHIS2 Tracker event to FHIR Encounter.
//
// In DHIS2 Tracker, events are occurrences of a program stage. For example,
// in an ANC program with a repeatable "ANC Visit" program stage, each visit
// creates a new event. Events have:
//   - An event date (when the visit occurred)
//   - An org unit (where the visit took place)
//   - A status (ACTIVE, COMPLETED, SCHEDULE)
//   - Data values (the clinical data captured at the visit)
//
// DHIS2 also supports "single event" (event) programs without enrollment,
// where each event stands alone. These also map to FHIR Encounter.
//
// The DHIS2ProgramExtension carries a reference to the DHIS2 program,
// connecting the encounter to its originating program context.
//
// Dependencies:
//   aliases.fsh       — $LOINC, $UCUM, $V2-0203
//   extensions.fsh    — DHIS2ProgramExtension
//   profiles-patient.fsh       — DHIS2Patient
//   profiles-organization.fsh  — DHIS2Organization
// ============================================================================
Profile: DHIS2Encounter
Parent: Encounter
Id: dhis2-encounter
Title: "DHIS2 Encounter"
Description: """
Represents a DHIS2 Tracker event or a single event capture as a FHIR
Encounter. In DHIS2 Tracker, events are instances of program stages — they
represent visits, consultations, or service delivery interactions where data
is collected.

Each encounter captures the event date as a period, the facility as the
service provider, and links to the patient. The DHIS2ProgramExtension
identifies which DHIS2 program this event belongs to.
"""

// -- Status ------------------------------------------------------------------
// The encounter status. DHIS2 event statuses map as follows:
//   ACTIVE    → in-progress
//   COMPLETED → finished
//   SCHEDULE  → planned
//   SKIPPED   → cancelled
// ----------------------------------------------------------------------------
* status MS
* status ^short = "Encounter status — maps to DHIS2 event status"

// -- Class -------------------------------------------------------------------
// The type of encounter (ambulatory, inpatient, etc.). DHIS2 does not have
// a direct equivalent, but most DHIS2 Tracker events represent ambulatory
// (outpatient) visits at health facilities.
// ----------------------------------------------------------------------------
* class MS
* class ^short = "Encounter class (typically ambulatory for DHIS2 events)"

// -- Subject -----------------------------------------------------------------
// The patient this encounter is about — the DHIS2 tracked entity instance.
// In DHIS2 Tracker, every event belongs to an enrollment, which belongs to a
// TEI. For single event programs, the TEI link may be implicit.
// ----------------------------------------------------------------------------
* subject 1..1 MS
* subject ^short = "The patient (DHIS2 tracked entity) for this encounter"
* subject only Reference(DHIS2Patient)

// -- Period ------------------------------------------------------------------
// The date/time of the encounter. In DHIS2, this maps to the event date
// (eventDate) and optionally the due date (dueDate). For completed events,
// the period typically has just a start date (the event date).
// ----------------------------------------------------------------------------
* period 1..1 MS
* period ^short = "Event date — maps to DHIS2 eventDate/dueDate"

// -- Location ----------------------------------------------------------------
// The physical location where the encounter took place. This links to a
// DHIS2Location, providing geographic context for the visit.
// ----------------------------------------------------------------------------
* location MS
* location ^short = "Where the encounter occurred (DHIS2 event org unit location)"

// -- Service Provider --------------------------------------------------------
// The organization (DHIS2 org unit) responsible for the encounter. In DHIS2,
// every event is associated with an org unit — the facility where the data
// was captured.
// ----------------------------------------------------------------------------
* serviceProvider MS
* serviceProvider ^short = "The org unit (facility) where this event was captured"
* serviceProvider only Reference(DHIS2Organization)

// -- Extension: DHIS2 Program ------------------------------------------------
// Identifies which DHIS2 program this encounter/event belongs to. Programs
// are a core organizing concept in DHIS2 Tracker — they define the structure
// of data collection (program stages, data elements, program rules, etc.).
// ----------------------------------------------------------------------------
* extension contains DHIS2ProgramExtension named program 0..1 MS
* extension[program] ^short = "Reference to the DHIS2 Tracker program"
