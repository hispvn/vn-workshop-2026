// ============================================================================
// Encounters for John Kamau — Malaria case management
// ============================================================================
// John presents at Facility Beta with fever. Diagnosed with P. falciparum
// malaria, treated with ACT, and returns for a follow-up visit.
// ============================================================================

Instance: EncounterJohnMalaria1
InstanceOf: DHIS2Encounter
Title: "Encounter — Malaria Visit (John Kamau)"
Description: """
John Kamau's initial visit to Facility Beta on 2024-04-10 presenting with
fever and chills. Diagnosed with P. falciparum malaria via RDT.
"""
Usage: #example

* status = #finished
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB "ambulatory"
* subject = Reference(PatientJohnKamau)
* period.start = "2024-04-10"
* period.end = "2024-04-10"
* location[0].location = Reference(LocationFacilityB)
* serviceProvider = Reference(OrganizationFacilityB)


Instance: EncounterJohnMalariaFollowUp
InstanceOf: DHIS2Encounter
Title: "Encounter — Malaria Follow-up (John Kamau)"
Description: """
John Kamau's follow-up visit on 2024-04-17, one week after starting ACT
treatment. Malaria RDT now negative, symptoms resolved.
"""
Usage: #example

* status = #finished
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB "ambulatory"
* subject = Reference(PatientJohnKamau)
* period.start = "2024-04-17"
* period.end = "2024-04-17"
* location[0].location = Reference(LocationFacilityB)
* serviceProvider = Reference(OrganizationFacilityB)
