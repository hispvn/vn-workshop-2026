// ============================================================================
// Instance: EncounterANCVisit1
// ============================================================================
// Jane Doe's first ANC visit at Facility Alpha. In DHIS2 Tracker, this
// corresponds to an event in the "ANC Visit" program stage:
//
//   POST /api/events
//   {
//     "enrollment": "<enrollment-uid>",
//     "program": "lxAQ7Zs9VYR",
//     "programStage": "dBwrot7S420",   (example "ANC Visit" stage UID)
//     "orgUnit": "DiszpKrYNg8",
//     "eventDate": "2024-02-01",
//     "status": "COMPLETED",
//     "dataValues": [
//       { "dataElement": "qrur9Dvnyt5", "value": "65.0" },  // Weight
//       { "dataElement": "vANAXwtLwcT", "value": "12.5" },  // Hemoglobin
//       ...
//     ]
//   }
//
// This is the visit where ObservationWeight, ObservationHemoglobin,
// ObservationBloodPressure, and ObservationMalariaTestResult were captured.
// ============================================================================
Instance: EncounterANCVisit1
InstanceOf: DHIS2Encounter
Title: "Encounter — ANC Visit 1 (Jane Doe)"
Description: """
Jane Doe's first antenatal care visit on 2024-02-01 at Facility Alpha Health
Center. Clinical observations (weight, hemoglobin, blood pressure, malaria
test) were captured during this visit. Status is 'finished' (completed event
in DHIS2).
"""
Usage: #example

// -- Status: finished (maps to DHIS2 event status COMPLETED) -----------------
* status = #finished

// -- Class: ambulatory (outpatient visit — most DHIS2 Tracker events) --------
// The HL7 v3 ActEncounterCode "AMB" represents ambulatory/outpatient visits.
// Most DHIS2 ANC visits happen at outpatient clinics.
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB "ambulatory"

// -- Subject: Jane Doe -------------------------------------------------------
* subject = Reference(PatientJaneDoe)

// -- Period: the event date in DHIS2 (2024-02-01) ----------------------------
// For single-day visits, the period start and end are the same date.
* period.start = "2024-02-01"
* period.end = "2024-02-01"

// -- Location: Facility Alpha Health Center ----------------------------------
* location[0].location = Reference(LocationFacilityA)

// -- Service Provider: the org unit where the event was captured --------------
* serviceProvider = Reference(OrganizationFacilityA)


// ============================================================================
// Instance: EncounterANCVisit2
// ============================================================================
// Jane Doe's second ANC visit, approximately 6 weeks after the first.
// In DHIS2 Tracker, repeatable program stages allow multiple events per
// enrollment — each ANC visit creates a new event in the same stage.
//
// This visit demonstrates the pattern of follow-up visits in DHIS2 Tracker.
// ============================================================================
Instance: EncounterANCVisit2
InstanceOf: DHIS2Encounter
Title: "Encounter — ANC Visit 2 (Jane Doe)"
Description: """
Jane Doe's second antenatal care visit on 2024-03-15 at Facility Alpha Health
Center. This follow-up visit is a second event in the repeatable 'ANC Visit'
program stage in DHIS2 Tracker.
"""
Usage: #example

// -- Status: finished --------------------------------------------------------
* status = #finished

// -- Class: ambulatory -------------------------------------------------------
* class = http://terminology.hl7.org/CodeSystem/v3-ActCode#AMB "ambulatory"

// -- Subject: Jane Doe -------------------------------------------------------
* subject = Reference(PatientJaneDoe)

// -- Period: second visit date -----------------------------------------------
* period.start = "2024-03-15"
* period.end = "2024-03-15"

// -- Service Provider --------------------------------------------------------
* serviceProvider = Reference(OrganizationFacilityA)
