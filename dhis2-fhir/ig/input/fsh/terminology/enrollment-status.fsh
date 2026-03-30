// ============================================================================
// DHIS2 Enrollment Status
// ============================================================================
//
// An enrollment represents a person's participation in a DHIS2 tracker program.
// Its status indicates whether the person is actively enrolled, has completed
// the program, or had their enrollment cancelled.
//
// In FHIR, enrollments map to EpisodeOfCare resources:
//   ACTIVE    -> EpisodeOfCare.status = active
//   COMPLETED -> EpisodeOfCare.status = finished
//   CANCELLED -> EpisodeOfCare.status = cancelled
// ============================================================================

CodeSystem: DHIS2EnrollmentStatusCS
Id: dhis2-enrollment-status
Title: "DHIS2 Enrollment Status"
Description: """
Lifecycle status codes for DHIS2 tracker enrollments. An enrollment links a
tracked entity instance (TEI) to a tracker program and tracks their progress
through the program's stages.
"""
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #ACTIVE "Active"
    "The tracked entity is currently enrolled and participating in the program."
* #COMPLETED "Completed"
    "The tracked entity has completed all required program stages and the enrollment is closed."
* #CANCELLED "Cancelled"
    "The enrollment was cancelled before completion (e.g., lost to follow-up, data entry error)."


ValueSet: DHIS2EnrollmentStatusVS
Id: dhis2-enrollment-status-vs
Title: "DHIS2 Enrollment Statuses"
Description: """
All lifecycle statuses for DHIS2 tracker enrollments.
"""
* ^experimental = false
* include codes from system DHIS2EnrollmentStatusCS
