// ============================================================================
// DHIS2-FHIR Learning IG — Mappings
// ============================================================================
//
// Mappings document how elements in one data model correspond to elements in
// another. In FHIR, mappings are metadata attached to StructureDefinitions —
// they appear in the IG as human-readable tables showing source → target
// relationships.
//
// Mappings are NON-EXECUTABLE: they do not generate code or transform data
// automatically. Their purpose is documentation and design guidance. They
// answer the question: "If I have a DHIS2 payload, which FHIR element does
// each field go into?"
//
// For executable transformations, you would use FHIR StructureMap or external
// tools (e.g., DHIS2's built-in FHIR adapter). The mappings defined here
// serve as the specification that such tools implement.
//
// ============================================================================


// ============================================================================
// Mapping: TEIToPatient
// ============================================================================
// This mapping documents the transformation from a DHIS2 Tracked Entity
// Instance (TEI) to FHIR resources. A single TEI fans out into multiple
// FHIR resources:
//
//   DHIS2 Layer          FHIR Resource
//   ──────────────────   ──────────────────
//   TEI                  Patient
//   TEI.attributes       Patient.name, .birthDate, .gender, .identifier, etc.
//   Enrollment           EpisodeOfCare
//   Event                Encounter
//   DataValue            Observation
//
// The mapping is defined on the DHIS2TrackedEntityInstance logical model,
// which means each "Source" path refers to an element in that model.
//
// Important caveats:
//   - Attribute mapping depends on semantics: DHIS2 attributes are generic
//     key-value pairs, so which Patient element they map to depends on the
//     attribute's meaning (e.g., "First Name" → Patient.name.given).
//   - DHIS2 stores everything as strings; FHIR requires typed values.
//   - Organisation unit UIDs must be resolved to FHIR Organization references.
//   - The DHIS2 "trackedEntityType" determines which FHIR profile to use
//     (e.g., "Person" → DHIS2Patient, "Commodity" → Device).
//
// ============================================================================
Mapping: TEIToPatient
Source: DHIS2TrackedEntityInstance
Target: "http://hl7.org/fhir/StructureDefinition/Patient"
Id: tei-to-patient
Title: "DHIS2 TEI to FHIR Patient Mapping"
Description: """
Maps a DHIS2 Tracked Entity Instance to a FHIR Patient resource. The TEI's
top-level properties map to Patient identifiers and metadata, while nested
structures (enrollments, events, data values) map to separate FHIR resources
(EpisodeOfCare, Encounter, Observation) that reference the Patient.
"""

// --- TEI UID → Patient.identifier ---
// The TEI's unique identifier becomes a Patient.identifier with
// system = http://dhis2.org/fhir/id/tracked-entity.
// This allows consumers to look up the original TEI in DHIS2.
* uid -> "Patient.identifier.value" "TEI UID becomes the Patient identifier value with system $DHIS2-TEI"

// --- Organisation Unit → Patient.managingOrganization ---
// The TEI's owning org unit maps to the Patient's managing organization.
// The org unit UID must be resolved to a FHIR Organization reference,
// either by looking up the Organization resource or by using a logical
// reference (Organization.identifier with system $DHIS2-OU).
* orgUnit -> "Patient.managingOrganization" "Org unit UID resolves to an Organization reference"

// --- Tracked Entity Type → Patient.meta.profile ---
// The type determines which FHIR profile applies. For "Person" types,
// the profile is DHIS2Patient. Other types may map to different resources
// entirely (e.g., a "Commodity" type might map to Device).
* trackedEntityType -> "Patient.meta.profile" "Determines which FHIR profile to apply (e.g., Person → DHIS2Patient)"

// --- Creation timestamp → Patient.meta.lastUpdated ---
// DHIS2's created timestamp can inform the Patient's metadata. Note that
// FHIR's meta.lastUpdated is server-managed, so this mapping is primarily
// for informational purposes during initial import.
* created -> "Patient.meta.extension" "Can be preserved as an extension for audit trail"

// --- Last updated → Patient.meta.lastUpdated ---
* lastUpdated -> "Patient.meta.lastUpdated" "Maps to the FHIR server's last updated timestamp"

// --- Inactive flag → Patient.active ---
// DHIS2's inactive=true maps to Patient.active=false (note the inversion).
* inactive -> "Patient.active" "Inverted: DHIS2 inactive=true → Patient.active=false"

// --- Attributes → Multiple Patient elements ---
// This is the most complex part of the mapping. DHIS2 tracked entity
// attributes are generic key-value pairs. Which Patient element they map
// to depends entirely on the attribute's semantic meaning:
//
//   Attribute (example)     FHIR Patient Element
//   ─────────────────────   ─────────────────────
//   First Name              Patient.name.given
//   Last Name               Patient.name.family
//   Date of Birth           Patient.birthDate
//   Sex                     Patient.gender
//   National ID             Patient.identifier (type NI)
//   Phone Number            Patient.telecom (system phone)
//   Address                 Patient.address.text
//
// A mapping implementation needs a configuration table that maps each
// attribute UID to the corresponding FHIR path and any value transformations
// (e.g., DHIS2 "Male"/"Female" → FHIR #male/#female).
* attributes -> "Patient.name, Patient.birthDate, Patient.gender (based on attribute semantics)" "Each attribute maps to a specific Patient element based on its semantic meaning. Requires a configuration mapping table."

// --- Enrollments → EpisodeOfCare ---
// Each DHIS2 program enrollment becomes a FHIR EpisodeOfCare that
// references the Patient. The enrollment captures participation in a
// health program over time.
//
//   Enrollment Field        EpisodeOfCare Element
//   ─────────────────────   ─────────────────────
//   enrollment (UID)        EpisodeOfCare.identifier
//   program                 EpisodeOfCare.type
//   orgUnit                 EpisodeOfCare.managingOrganization
//   enrollmentDate          EpisodeOfCare.period.start
//   status (COMPLETED)      EpisodeOfCare.status = finished
//   status (ACTIVE)         EpisodeOfCare.status = active
//   status (CANCELLED)      EpisodeOfCare.status = cancelled
* enrollments -> "EpisodeOfCare" "Each enrollment becomes an EpisodeOfCare linked to the Patient via EpisodeOfCare.patient"

// --- Events → Encounter ---
// Each event within an enrollment becomes a FHIR Encounter. The Encounter
// references both the Patient and the EpisodeOfCare.
//
//   Event Field             Encounter Element
//   ─────────────────────   ─────────────────────
//   event (UID)             Encounter.identifier
//   programStage            Encounter.type
//   orgUnit                 Encounter.serviceProvider
//   eventDate               Encounter.period.start
//   status (COMPLETED)      Encounter.status = finished
//   status (ACTIVE)         Encounter.status = in-progress
* enrollments.events -> "Encounter" "Each event becomes an Encounter linked to Patient and EpisodeOfCare"

// --- Data Values → Observation ---
// Each data value within an event becomes a FHIR Observation. The
// Observation references the Patient and Encounter.
//
//   DataValue Field         Observation Element
//   ─────────────────────   ─────────────────────
//   dataElement (UID)       Observation.code (with system $DHIS2-DE)
//   value                   Observation.value[x] (type depends on DE)
//
// The data element's metadata (value type, option set) determines which
// Observation.value[x] type to use:
//   - NUMBER/INTEGER → valueQuantity
//   - TEXT → valueString
//   - BOOLEAN → valueBoolean
//   - Option set → valueCodeableConcept
//   - DATE → valueDateTime
* enrollments.events.dataValues -> "Observation" "Each data value becomes an Observation linked to Patient and Encounter"
