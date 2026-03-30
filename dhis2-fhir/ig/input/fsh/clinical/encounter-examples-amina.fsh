// ============================================================================
// Encounters for Amina Hassan — ANC and immunization
// ============================================================================

Instance: EncounterAminaANC1
InstanceOf: DHIS2Encounter
Title: "Encounter — ANC Visit 1 (Amina Hassan)"
Description: """
Amina Hassan's first antenatal care visit at Facility Beta on 2024-05-20.
Initial ANC assessment with vital signs and lab work.
"""
Usage: #example

* status = #finished
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB "ambulatory"
* subject = Reference(PatientAminaHassan)
* period.start = "2024-05-20"
* period.end = "2024-05-20"
* location[0].location = Reference(LocationFacilityB)
* serviceProvider = Reference(OrganizationFacilityB)


Instance: EncounterAminaANC2
InstanceOf: DHIS2Encounter
Title: "Encounter — ANC Visit 2 (Amina Hassan)"
Description: """
Amina Hassan's second ANC visit on 2024-07-01. Follow-up assessment
with repeat hemoglobin test showing improvement after iron supplements.
"""
Usage: #example

* status = #finished
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB "ambulatory"
* subject = Reference(PatientAminaHassan)
* period.start = "2024-07-01"
* period.end = "2024-07-01"
* location[0].location = Reference(LocationFacilityB)
* serviceProvider = Reference(OrganizationFacilityB)
