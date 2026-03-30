// ============================================================================
// Instance: EpisodeOfCareANCEnrollment
// ============================================================================
// Jane Doe's enrollment in the ANC (Antenatal Care) program at Facility
// Alpha Health Center. In DHIS2 Tracker, this corresponds to:
//   POST /api/enrollments
//   {
//     "trackedEntityInstance": "DXz2k5eGbri",
//     "program": "lxAQ7Zs9VYR",       (example ANC program UID)
//     "orgUnit": "DiszpKrYNg8",
//     "enrollmentDate": "2024-01-15",
//     "status": "ACTIVE"
//   }
//
// The enrollment is active (ongoing) — Jane is currently receiving ANC
// services. It will be marked as "COMPLETED" when she delivers or is
// discharged from the ANC program.
// ============================================================================
Instance: EpisodeOfCareANCEnrollment
InstanceOf: DHIS2EpisodeOfCare
Title: "Episode of Care — Jane Doe ANC Enrollment"
Description: """
Jane Doe's enrollment in the Antenatal Care (ANC) Tracker program at Facility
Alpha Health Center. Enrolled on 2024-01-15 with status active (ongoing).
This enrollment contains multiple ANC visits (encounters) during which
clinical observations are recorded.
"""
Usage: #example

// -- Status: active enrollment (patient is still receiving ANC services) ------
* status = #active

// -- Patient: Jane Doe (TEI UID DXz2k5eGbri) --------------------------------
* patient = Reference(PatientJaneDoe)

// -- Managing Organization: Facility Alpha (where enrollment was created) ----
* managingOrganization = Reference(OrganizationFacilityA)

// -- Period: enrollment started 2024-01-15, no end date (still active) -------
// In DHIS2, enrollmentDate = 2024-01-15.
// The enrollment has no completion date because it is still ACTIVE.
* period.start = "2024-01-15"
