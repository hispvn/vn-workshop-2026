// ============================================================================
// Profile: DHIS2EpisodeOfCare
// ============================================================================
// Maps a DHIS2 enrollment to FHIR EpisodeOfCare.
//
// In DHIS2 Tracker, an enrollment represents a patient's participation in a
// specific program. Key enrollment properties:
//   - enrollmentDate: when the patient was enrolled
//   - incidentDate: when the "incident" occurred (e.g., last menstrual period
//     for an ANC program)
//   - org unit: where the enrollment was created
//   - status: ACTIVE, COMPLETED, CANCELLED
//
// A patient can be enrolled in multiple programs simultaneously (e.g., ANC
// and HIV programs), and some programs allow multiple enrollments over time.
//
// EpisodeOfCare is the closest FHIR match because it represents a continuous
// care relationship between a patient and a provider for a specific condition
// or program, containing multiple encounters (events) within it.
//
// Dependencies:
//   extensions.fsh    — DHIS2ProgramExtension
//   profiles-patient.fsh       — DHIS2Patient
//   profiles-organization.fsh  — DHIS2Organization
// ============================================================================
Profile: DHIS2EpisodeOfCare
Parent: EpisodeOfCare
Id: dhis2-episode-of-care
Title: "DHIS2 Episode of Care"
Description: """
Represents a DHIS2 enrollment — a patient's participation in a Tracker program
over a period of time. In DHIS2, enrollments connect a tracked entity instance
to a program and define the time window during which events (visits) can be
recorded.

The enrollment period maps to EpisodeOfCare.period, the enrolling org unit
maps to managingOrganization, and the program itself is referenced via the
DHIS2ProgramExtension. Encounters (DHIS2 events) occur within the context
of this episode of care.
"""

// -- Status ------------------------------------------------------------------
// The enrollment status. DHIS2 enrollment statuses map as follows:
//   ACTIVE    → active
//   COMPLETED → finished
//   CANCELLED → cancelled
// ----------------------------------------------------------------------------
* status MS
* status ^short = "Enrollment status (active, finished, or cancelled)"

// -- Patient -----------------------------------------------------------------
// The enrolled patient (DHIS2 tracked entity instance).
// In DHIS2, each enrollment belongs to exactly one TEI.
// ----------------------------------------------------------------------------
* patient 1..1 MS
* patient ^short = "The enrolled patient (DHIS2 tracked entity instance)"
* patient only Reference(DHIS2Patient)

// -- Managing Organization ---------------------------------------------------
// The org unit where the enrollment was created. In DHIS2, the enrollment
// org unit may differ from the event org units if the patient visits
// different facilities within the same enrollment.
// ----------------------------------------------------------------------------
* managingOrganization MS
* managingOrganization ^short = "Enrolling org unit in DHIS2"
* managingOrganization only Reference(DHIS2Organization)

// -- Period ------------------------------------------------------------------
// The enrollment period. Start date maps to DHIS2's enrollmentDate.
// End date maps to the completion date (when the enrollment is completed
// or cancelled). For active enrollments, the end date is absent.
// ----------------------------------------------------------------------------
* period 1..1 MS
* period ^short = "Enrollment period — start is enrollmentDate, end is completion date"

// -- Extension: DHIS2 Program ------------------------------------------------
// Identifies which DHIS2 program the patient is enrolled in. This is the
// central organizing concept — the program defines what data can be collected,
// what program stages exist, and what program rules apply.
// ----------------------------------------------------------------------------
* extension contains DHIS2ProgramExtension named program 0..1 MS
* extension[program] ^short = "The DHIS2 program the patient is enrolled in"
