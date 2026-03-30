// ============================================================================
// DHIS2-FHIR Learning IG — Bundle Examples
// ============================================================================
//
// Bundles are the FHIR mechanism for grouping multiple resources into a single
// payload. They are essential for DHIS2-FHIR interoperability because DHIS2
// data rarely maps to a single FHIR resource — a tracker event produces a
// Patient, an Encounter, and multiple Observations that all need to be
// created together.
//
// FHIR defines several bundle types:
//
//   - transaction: All entries are processed as a single atomic operation.
//     If any entry fails, the entire bundle is rolled back. This is the
//     preferred type for creating interrelated resources because it
//     guarantees consistency.
//
//   - collection: A read-only grouping of resources. No processing semantics —
//     it simply packages resources together for transport or documentation.
//
//   - batch: Each entry is processed independently (no atomicity guarantee).
//     Useful when entries are unrelated and partial success is acceptable.
//
//   - document: A clinical document with a Composition as the first entry.
//
// ============================================================================


// ============================================================================
// Instance: BundleANCVisitTransaction
// ============================================================================
// This transaction bundle represents the FHIR output of processing a single
// DHIS2 tracker event: an ANC visit for Jane Doe.
//
// When a DHIS2 event is mapped to FHIR, it produces multiple resources:
//   1. Patient — the tracked entity instance (Jane Doe)
//   2. Encounter — the event itself (the clinic visit)
//   3. Observations — one per data value in the event
//
// These resources reference each other:
//   - Encounter.subject → Patient
//   - Observation.subject → Patient
//   - Observation.encounter → Encounter
//
// In a transaction bundle, we use temporary UUIDs (urn:uuid:...) as fullUrl
// values and reference targets. The FHIR server resolves these to real IDs
// when processing the transaction. This is the standard pattern for creating
// interrelated resources atomically.
//
// Transaction entries include a "request" element specifying the HTTP method
// and URL, telling the server what operation to perform:
//   - method: POST (create a new resource)
//   - url: the resource type (e.g., "Patient", "Encounter")
//
// If any entry fails validation or processing, the ENTIRE transaction is
// rolled back — no partial creates. This ensures data consistency.
// ============================================================================
Instance: BundleANCVisitTransaction
InstanceOf: Bundle
Title: "ANC Visit Transaction Bundle"
Description: "A FHIR transaction bundle that atomically creates all resources from a DHIS2 ANC visit event: Patient, Encounter, and three Observations (weight, hemoglobin, malaria test). Demonstrates the transaction pattern for DHIS2 tracker-to-FHIR conversion."
Usage: #example

// Bundle type: transaction — all-or-nothing processing
* type = #transaction

// ---- Entry 1: Patient (Jane Doe) ----
// The tracked entity instance. We create the Patient first (conceptually)
// because other resources reference it. In practice, the FHIR server
// processes all entries together and resolves references at the end.
//
// The fullUrl is a temporary UUID that other entries use to reference this
// Patient. The server will replace it with a real URL after creation.
* entry[0].fullUrl = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* entry[0].resource = PatientInBundle
* entry[0].request.method = #POST
* entry[0].request.url = "Patient"

// ---- Entry 2: Encounter (ANC Visit) ----
// The DHIS2 event becomes a FHIR Encounter. It references the Patient
// above using the temporary UUID. The server resolves this reference
// when processing the transaction.
//
// The Encounter captures:
//   - When the visit happened (period)
//   - Where it happened (serviceProvider — the org unit)
//   - What type of visit (class: ambulatory)
//   - Who was seen (subject → Patient)
* entry[1].fullUrl = "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901"
* entry[1].resource = EncounterInBundle
* entry[1].request.method = #POST
* entry[1].request.url = "Encounter"

// ---- Entry 3: Observation — Weight ----
// First data value from the event: maternal weight (65 kg).
// References both the Patient (subject) and Encounter (encounter).
* entry[2].fullUrl = "urn:uuid:c3d4e5f6-a7b8-9012-cdef-123456789012"
* entry[2].resource = ObservationWeightInBundle
* entry[2].request.method = #POST
* entry[2].request.url = "Observation"

// ---- Entry 4: Observation — Hemoglobin ----
// Second data value: hemoglobin level (12.5 g/dL).
// A key indicator for anaemia screening in pregnancy.
* entry[3].fullUrl = "urn:uuid:d4e5f6a7-b8c9-0123-defa-234567890123"
* entry[3].resource = ObservationHemoglobinInBundle
* entry[3].request.method = #POST
* entry[3].request.url = "Observation"

// ---- Entry 5: Observation — Malaria Test ----
// Third data value: malaria RDT result (negative).
// Coded observation using a simple positive/negative value set.
* entry[4].fullUrl = "urn:uuid:e5f6a7b8-c9d0-1234-efab-345678901234"
* entry[4].resource = ObservationMalariaInBundle
* entry[4].request.method = #POST
* entry[4].request.url = "Observation"


// ============================================================================
// Inline instances for the transaction bundle
// ============================================================================
// These instances are defined with Usage: #inline, meaning they only exist
// within the bundle — they are not standalone examples. This is the standard
// FSH pattern for bundle entries.


// --- Patient (inline) ---
// Jane Doe — the tracked entity instance being seen at this ANC visit.
// In a real system, the Patient might already exist on the server, and
// the transaction would use PUT (update) or a conditional create instead
// of POST. For simplicity, this example always creates a new Patient.
Instance: PatientInBundle
InstanceOf: Patient
Usage: #inline

* identifier[0].system = $DHIS2-TEI
* identifier[0].value = "dNpxRu1mObG"
* identifier[0].type = $V2-0203#RI "Resource identifier"
* name[0].family = "Doe"
* name[0].given[0] = "Jane"
* gender = #female
* birthDate = "1992-05-15"
* managingOrganization = Reference(OrganizationFacilityA)


// --- Encounter (inline) ---
// The ANC visit encounter. References the Patient via the temporary UUID.
// Class is AMB (ambulatory) because ANC visits are outpatient encounters.
Instance: EncounterInBundle
InstanceOf: Encounter
Usage: #inline

* status = #finished
* class = $encounter-class#AMB "ambulatory"
// Reference the Patient using the temporary UUID from the bundle
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* subject.display = "Jane Doe"
* period.start = "2024-03-15"
* period.end = "2024-03-15"
* serviceProvider = Reference(OrganizationFacilityA)


// --- Observation: Weight (inline) ---
// Maternal weight measurement: 65 kg.
// LOINC code 29463-7 = "Body weight"
// The data element UID is preserved in an additional identifier so that
// the source DHIS2 data element can be traced.
Instance: ObservationWeightInBundle
InstanceOf: Observation
Usage: #inline

* status = #final
* category[0] = $observation-category#vital-signs "Vital Signs"
* code = $LOINC#29463-7 "Body weight"
* code.text = "Weight"
// Reference Patient and Encounter via temporary UUIDs
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* subject.display = "Jane Doe"
* encounter.reference = "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901"
* effectiveDateTime = "2024-03-15"
* valueQuantity.value = 65
* valueQuantity.unit = "kg"
* valueQuantity.system = $UCUM
* valueQuantity.code = #kg


// --- Observation: Hemoglobin (inline) ---
// Hemoglobin level: 12.5 g/dL (above anaemia threshold of 11.0).
// LOINC code 718-7 = "Hemoglobin [Mass/volume] in Blood"
Instance: ObservationHemoglobinInBundle
InstanceOf: Observation
Usage: #inline

* status = #final
* category[0] = $observation-category#laboratory "Laboratory"
* code = $LOINC#718-7 "Hemoglobin [Mass/volume] in Blood"
* code.text = "Hemoglobin"
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* subject.display = "Jane Doe"
* encounter.reference = "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901"
* effectiveDateTime = "2024-03-15"
* valueQuantity.value = 12.5
* valueQuantity.unit = "g/dL"
* valueQuantity.system = $UCUM
* valueQuantity.code = #g/dL


// --- Observation: Malaria RDT (inline) ---
// Malaria rapid diagnostic test result: Negative.
// LOINC code 70569-9 = "Plasmodium sp Ag [Presence] in Blood by Rapid
// immunoassay" (a common code for malaria RDT results).
// The value is coded (positive/negative) rather than quantitative.
Instance: ObservationMalariaInBundle
InstanceOf: Observation
Usage: #inline

* status = #final
* category[0] = $observation-category#laboratory "Laboratory"
* code = $LOINC#70569-9 "Plasmodium sp Ag [Identifier] in Blood by Rapid immunoassay"
* code.text = "Malaria RDT Result"
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* subject.display = "Jane Doe"
* encounter.reference = "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901"
* effectiveDateTime = "2024-03-15"
// Coded value: negative result
// SCT 260385009 = "Negative (qualifier value)"
* valueCodeableConcept = $SCT#260385009 "Negative"
* valueCodeableConcept.text = "Negative"
