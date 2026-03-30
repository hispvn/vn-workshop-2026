// ============================================================================
// DHIS2-FHIR Learning IG — Questionnaire Profiles and Instances
// ============================================================================
//
// THE QUESTIONNAIRE/QUESTIONNAIRERESPONSE PATTERN FOR DHIS2 EVENTS
//
// This file is the showcase for modeling DHIS2 program stage data in FHIR.
// It defines two profiles and many example instances that demonstrate how
// DHIS2's form-based data collection maps to FHIR's Questionnaire resources.
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ KEY DESIGN DECISIONS                                                    │
// │                                                                         │
// │ 1. Questionnaire = DHIS2 Program Stage                                  │
// │    The form definition. Each Questionnaire instance represents one       │
// │    program stage, with its data elements as items.                       │
// │                                                                         │
// │ 2. QuestionnaireResponse = DHIS2 Event                                  │
// │    A completed form submission. Each QR instance is one event — a        │
// │    single data entry at a point in time.                                 │
// │                                                                         │
// │ 3. item.linkId = Data Element UID                                       │
// │    The linkId on each question/answer maps directly to the DHIS2 data   │
// │    element's 11-character UID. This is the primary mapping key.          │
// │                                                                         │
// │ 4. answerValueSet = DHIS2 Option Set                                    │
// │    When a data element has an option set in DHIS2, the corresponding     │
// │    Questionnaire item binds to a FHIR ValueSet via answerValueSet.      │
// │                                                                         │
// │ 5. subject = Patient reference (tracker programs only)                   │
// │    For tracker programs (WITH_REGISTRATION), the QR links to a Patient. │
// │    For event programs (WITHOUT_REGISTRATION), subject is omitted —       │
// │    the data is anonymous / facility-level.                               │
// │                                                                         │
// │ 6. encounter = DHIS2 visit context                                      │
// │    When the QR is associated with a visit, it links to a DHIS2Encounter.│
// │                                                                         │
// │ 7. authored = DHIS2 event date                                          │
// │    The date the form was filled out maps to the DHIS2 eventDate.        │
// │                                                                         │
// │ 8. orgUnit extension = DHIS2 organisation unit                          │
// │    The DHIS2OrgUnitExtension carries the facility/org unit where the    │
// │    event was recorded — a core DHIS2 dimension.                         │
// │                                                                         │
// │ 9. enableWhen = DHIS2 Program Rules                                     │
// │    Conditional display logic in DHIS2 (program rules that show/hide     │
// │    fields) maps to Questionnaire.item.enableWhen in FHIR.              │
// └─────────────────────────────────────────────────────────────────────────┘
//
// WHY QUESTIONNAIRE INSTEAD OF OBSERVATION?
//
// While individual data elements can be mapped to Observations (see
// DHIS2Observation in profiles-clinical.fsh), the Questionnaire approach
// preserves the *structure* of the DHIS2 form: which fields appear together,
// their order, skip logic, and the exact answers the user entered. This is
// valuable for:
//   - Round-tripping data back to DHIS2 without loss
//   - Audit trails (exactly what the user saw and entered)
//   - Forms with interdependent fields (enableWhen / program rules)
//   - Capturing the full event in a single resource
//
// Both approaches are valid and complementary. Many implementations use
// QuestionnaireResponse for data capture and then extract Observations for
// clinical decision support and analytics.
//
// TRACKER vs EVENT PROGRAMS
//
// DHIS2 has two program types that affect how QRs are structured:
//
//   Tracker programs (WITH_REGISTRATION):
//     - Require a registered tracked entity instance (TEI = Patient)
//     - Support multiple program stages and repeatable events
//     - QR.subject references a DHIS2Patient
//     - Example: ANC program, Malaria case management, Immunization
//
//   Event programs (WITHOUT_REGISTRATION):
//     - Capture standalone anonymous events at facility level
//     - No registered individual — no QR.subject
//     - Example: Disease surveillance, aggregate case notifications
//
// This is why the DHIS2QuestionnaireResponse profile makes subject 0..1
// rather than 1..1.
//
// Dependencies:
//   aliases.fsh         — $DHIS2-PROGRAM, $V2-0203, etc.
//   extensions.fsh      — DHIS2OrgUnitExtension
//   terminology.fsh     — ValueSets referenced by answerValueSet
//   profiles-patient.fsh — DHIS2Patient, PatientJaneDoe, etc.
//   profiles-organization.fsh — OrganizationFacilityA
//   profiles-clinical.fsh — DHIS2Encounter, EncounterANCVisit1, etc.
//
// ============================================================================


// ============================================================================
// Profile: DHIS2Questionnaire
// ============================================================================
// Represents a DHIS2 program stage data entry form. Each item in the
// Questionnaire corresponds to a data element in the DHIS2 program stage.
//
// DHIS2 program stages have:
//   - A UID and name   -> Questionnaire.identifier, .name, .title
//   - Data elements    -> Questionnaire.item (one item per data element)
//   - Value types      -> Questionnaire.item.type
//   - Compulsory flags -> Questionnaire.item.required
//   - Option sets      -> Questionnaire.item.answerValueSet or .answerOption
//   - Program rules    -> Questionnaire.item.enableWhen (conditional display)
//
// The identifier is sliced to include a "dhis2uid" slice that carries the
// program stage UID, enabling consumers to look up the original DHIS2 object.
//
// subjectType indicates whether this form collects patient-linked data
// (tracker programs set subjectType = Patient) or anonymous data (event
// programs omit subjectType or leave it empty).
// ============================================================================

Profile: DHIS2Questionnaire
Parent: Questionnaire
Id: dhis2-questionnaire
Title: "DHIS2 Questionnaire"
Description: """
Represents a DHIS2 program stage data entry form.

Each item in the Questionnaire corresponds to a data element in a DHIS2
program stage. The item's `linkId` maps to the DHIS2 data element UID, the
`text` is the human-readable label, and the `type` reflects the data element's
value type (TEXT, NUMBER, INTEGER, BOOLEAN, etc.).

DHIS2 option sets (dropdown lists) map to Questionnaire items of type
`choice` with an `answerValueSet` binding (preferred) or inline `answerOption`
entries. DHIS2 program rules that conditionally show/hide fields map to
`enableWhen` clauses on the corresponding items.

This profile preserves the form structure so that data can be round-tripped
between FHIR and DHIS2 without loss of structure or context.
"""

// -- Canonical URL --
// Every Questionnaire needs a unique URL. For DHIS2 program stages this
// typically follows: http://dhis2.org/fhir/learning/Questionnaire/<stage-uid>
* url 1..1 MS

// -- Identifier --
// The DHIS2 program stage UID is stored as an identifier. We use a slice
// named "dhis2uid" so that the program stage UID can be clearly distinguished
// from any other identifiers. The system is $DHIS2-PROGRAM to indicate this
// is a DHIS2 program stage identifier.
* identifier MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains dhis2uid 0..1 MS
* identifier[dhis2uid].system = $DHIS2-PROGRAM
* identifier[dhis2uid].system MS
* identifier[dhis2uid].value 1..1 MS
* identifier[dhis2uid].value ^short = "DHIS2 program stage UID (11-character alphanumeric)"

// -- Human-readable metadata --
// name: machine-friendly name (no spaces, camelCase or PascalCase)
// title: human-friendly name displayed in UIs
* name MS
* title 1..1 MS
* status MS

// -- Subject type --
// Indicates whether this form collects patient-linked data. For tracker
// programs (WITH_REGISTRATION), set subjectType to Patient. For event
// programs (WITHOUT_REGISTRATION), omit subjectType — the form captures
// anonymous facility-level data.
* subjectType 0..* MS
  * ^short = "Patient for tracker programs; omit for event programs"
  * ^definition = "Resource type(s) that the Questionnaire is about. Tracker program stages set this to 'Patient' to indicate the form collects data linked to a registered individual. Event programs leave this empty because data is anonymous."

// -- Items (data elements) --
// Each item represents one data element from the DHIS2 program stage.
// The constraints below ensure every item has the minimum information
// needed to map it back to DHIS2 and to render it in a form.
* item MS
* item.linkId MS
  * ^short = "DHIS2 data element UID"
  * ^definition = "The 11-character UID of the DHIS2 data element that this question maps to. This linkId is the primary key for mapping between FHIR and DHIS2."
* item.text MS
  * ^short = "Question label (data element display name)"
  * ^definition = "The human-readable label displayed to the user when filling out the form. Corresponds to the DHIS2 data element's formName or displayName."
* item.type MS
  * ^short = "Data element value type"
  * ^definition = "The type of answer expected. Maps to DHIS2 value types: TEXT->string, LONG_TEXT->text, NUMBER->decimal, INTEGER->integer, BOOLEAN->boolean, DATE->date, DATETIME->dateTime, etc."
* item.required MS
  * ^short = "Whether the data element is compulsory"
  * ^definition = "When true, the health worker must provide a value for this field. Maps to the 'compulsory' flag on the DHIS2 program stage data element."
* item.answerValueSet MS
  * ^short = "DHIS2 option set (as a FHIR ValueSet)"
  * ^definition = "When a DHIS2 data element has an associated option set, this binds the question to the corresponding FHIR ValueSet. The health worker selects from the allowed values."
* item.answerOption MS
  * ^short = "Inline answer options"
  * ^definition = "Alternative to answerValueSet for small option lists. Each answerOption represents one allowed value from the DHIS2 option set."


// ============================================================================
// Profile: DHIS2QuestionnaireResponse
// ============================================================================
// Represents a completed DHIS2 event — a single form submission for a tracked
// entity at a particular program stage.
//
// In DHIS2 terms:
//   - The QuestionnaireResponse is the "event"
//   - The questionnaire reference is the "program stage"
//   - The subject is the "tracked entity instance" (patient) — for tracker
//     programs only
//   - The authored date is the "event date" (eventDate in DHIS2 API)
//   - Each item/answer pair is a "data value" in the event
//
// IMPORTANT: subject is 0..1, NOT 1..1
// This is because DHIS2 has two program types:
//   - Tracker programs (WITH_REGISTRATION): events are linked to a registered
//     individual (TEI). In FHIR, QR.subject references a DHIS2Patient.
//   - Event programs (WITHOUT_REGISTRATION): events are standalone and
//     anonymous. In FHIR, QR.subject is absent — there is no patient.
//
// The orgUnit extension carries the DHIS2 organisation unit where the event
// was recorded. In DHIS2, every event must belong to an org unit — it is one
// of the three core dimensions (what, where, when). The extension references
// a FHIR Organization resource that represents the DHIS2 org unit.
// ============================================================================

Profile: DHIS2QuestionnaireResponse
Parent: QuestionnaireResponse
Id: dhis2-questionnaire-response
Title: "DHIS2 Questionnaire Response"
Description: """
Represents a completed DHIS2 event — a form submission capturing data at a
specific program stage visit.

Each item in the response corresponds to a data value in the DHIS2 event.
The `item.linkId` maps back to the data element UID, and `item.answer`
holds the reported value.

For **tracker programs** (WITH_REGISTRATION), `subject` references the
DHIS2Patient (tracked entity instance) and `encounter` may link to the
visit context. For **event programs** (WITHOUT_REGISTRATION), `subject` is
absent because data is anonymous — the event is not linked to any individual.

The `authored` date captures the DHIS2 event date (when the activity occurred,
not when it was entered into the system). The org unit extension carries the
DHIS2 organisation unit where the event was recorded.
"""

// -- Questionnaire reference --
// Links to the Questionnaire (program stage) that defines the form structure.
// This is a canonical URL reference, not a resource reference.
// In DHIS2 terms: this is the program stage UID that the event belongs to.
* questionnaire 1..1 MS
  * ^short = "Canonical URL of the DHIS2 program stage Questionnaire"

// -- Status --
// Maps to DHIS2 event status:
//   completed   -> the event has been fully entered and saved (COMPLETED)
//   in-progress -> the event is partially filled / data entry ongoing (ACTIVE)
//   amended     -> the event was edited after initial completion
//   stopped     -> the event was cancelled / skipped (SKIPPED)
* status MS

// -- Subject --
// The patient (DHIS2 tracked entity instance) that this event is about.
// 0..1 because event programs (WITHOUT_REGISTRATION) have no subject.
// When present, constrained to DHIS2Patient to ensure the TEI identifier
// is available for mapping back to DHIS2.
* subject 0..1 MS
* subject only Reference(DHIS2Patient)
* subject ^short = "Patient (DHIS2 tracked entity instance) — present for tracker events, absent for event programs"
* subject ^definition = "For tracker programs (WITH_REGISTRATION), references the DHIS2Patient representing the tracked entity instance. For event programs (WITHOUT_REGISTRATION), this element is absent because data is anonymous."

// -- Encounter --
// Links to the DHIS2Encounter when the QR is associated with a visit context.
// This allows grouping multiple QRs under the same visit.
* encounter 0..1 MS
* encounter only Reference(DHIS2Encounter)
* encounter ^short = "Visit context (DHIS2 event as Encounter)"

// -- Authored date --
// When the form was completed. Maps to the DHIS2 event date (eventDate).
// In DHIS2, eventDate is when the event occurred (e.g., the clinic visit
// date), not when it was entered into the system.
* authored 1..1 MS
  * ^short = "Event date (when the activity occurred)"
  * ^definition = "The date the event took place, corresponding to the DHIS2 eventDate field. This is the clinical date (e.g., visit date), not the data entry timestamp."

// -- Author --
// Who entered the data. In DHIS2 this is the user account that created the
// event. In FHIR, this can reference a Practitioner or Organization.
* author 0..1 MS
* author only Reference(Practitioner or Organization)
* author ^short = "Data entry user (DHIS2 user who created the event)"

// -- Source --
// The patient themselves if the data is self-reported. Relevant for
// community-based programs where patients enter their own data.
* source 0..1 MS
* source only Reference(DHIS2Patient)
* source ^short = "Self-reported data source (the patient themselves)"

// -- Items (data values) --
// Each item holds one data value from the DHIS2 event. The linkId maps to
// the data element UID, and the answer holds the value.
* item MS
* item.linkId MS
  * ^short = "DHIS2 data element UID"
  * ^definition = "The 11-character UID of the DHIS2 data element, matching the linkId in the Questionnaire definition."
* item.answer MS
  * ^short = "Reported data value"
  * ^definition = "The value entered by the health worker for this data element. The value type (valueString, valueInteger, valueCoding, etc.) corresponds to the DHIS2 data element's value type."

// -- Org unit extension --
// Carries the DHIS2 organisation unit where the event was recorded.
// In DHIS2, orgUnit is a required field on every event — it identifies
// the facility, district, or administrative unit.
* extension contains DHIS2OrgUnitExtension named orgUnit 0..1 MS