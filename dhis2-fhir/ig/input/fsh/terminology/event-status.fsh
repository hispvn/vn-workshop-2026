// ============================================================================
// DHIS2 Event Status
// ============================================================================
//
// Each event (program stage instance) in DHIS2 Tracker has a lifecycle status.
// This status determines whether the event is still being worked on, has been
// completed, was skipped, etc.
//
// In FHIR, events map to Encounters. The event status informs the
// Encounter.status value:
//   ACTIVE   -> in-progress
//   COMPLETED -> finished
//   SCHEDULE  -> planned
//   OVERDUE   -> in-progress (with an overdue flag)
//   SKIPPED   -> cancelled
//   VISITED   -> finished
// ============================================================================

CodeSystem: DHIS2EventStatusCS
Id: dhis2-event-status
Title: "DHIS2 Event Status"
Description: """
Lifecycle status codes for DHIS2 tracker events (program stage instances).
Each event progresses through these statuses as data is collected and
finalised.
"""
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #ACTIVE "Active"
    "The event is open and data entry is in progress."
* #COMPLETED "Completed"
    "The event has been finalised and data entry is closed."
* #SCHEDULE "Schedule"
    "The event is scheduled for a future date but has not yet started."
* #OVERDUE "Overdue"
    "The event was scheduled but the due date has passed without completion."
* #SKIPPED "Skipped"
    "The event was intentionally skipped (e.g., patient did not attend)."
* #VISITED "Visited"
    "The event was visited / data was viewed but may not have been fully completed. Used in some DHIS2 configurations."


ValueSet: DHIS2EventStatusVS
Id: dhis2-event-status-vs
Title: "DHIS2 Event Statuses"
Description: """
All lifecycle statuses for DHIS2 tracker events.
"""
* ^experimental = false
* include codes from system DHIS2EventStatusCS
