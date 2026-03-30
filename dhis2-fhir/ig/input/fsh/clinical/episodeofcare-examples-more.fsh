// ============================================================================
// Additional EpisodeOfCare instances — enrollments for John and Amina
// ============================================================================

Instance: EpisodeOfCareJohnMalaria
InstanceOf: DHIS2EpisodeOfCare
Title: "Episode of Care — John Kamau Malaria Case Management"
Description: """
John Kamau's enrollment in the Malaria Case Management program at
Facility Beta. Enrolled on 2024-04-10 when he presented with fever.
Completed on 2024-04-17 after successful treatment with ACT.
"""
Usage: #example

* status = #finished
* patient = Reference(PatientJohnKamau)
* managingOrganization = Reference(OrganizationFacilityB)
* period.start = "2024-04-10"
* period.end = "2024-04-17"


Instance: EpisodeOfCareAminaANC
InstanceOf: DHIS2EpisodeOfCare
Title: "Episode of Care — Amina Hassan ANC Enrollment"
Description: """
Amina Hassan's enrollment in the Antenatal Care program at Facility Beta.
Enrolled on 2024-05-20 at her first ANC visit. Still active.
"""
Usage: #example

* status = #active
* patient = Reference(PatientAminaHassan)
* managingOrganization = Reference(OrganizationFacilityB)
* period.start = "2024-05-20"
