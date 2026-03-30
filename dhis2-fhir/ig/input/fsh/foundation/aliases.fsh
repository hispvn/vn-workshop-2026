// ============================================================================
// DHIS2-FHIR Learning IG — Aliases
// ============================================================================
//
// This file defines shorthand aliases used throughout the IG. Aliases let us
// refer to long canonical URLs with short, readable tokens (e.g., $SCT instead
// of http://snomed.info/sct). SUSHI resolves every alias at compile time, so
// the generated StructureDefinitions contain the full URL — aliases are purely
// an authoring convenience.
//
// Aliases are grouped into three categories:
//   1. Standard terminologies — international coding systems
//   2. HL7 code systems — FHIR-defined or HL7-published code systems
//   3. DHIS2 identifiers — custom URI schemes for DHIS2 concepts
//
// Naming convention:
//   - Standard terminologies use their common abbreviation ($SCT, $LOINC, …).
//   - HL7 code systems use a descriptive name prefixed with $ ($V2-0203, …).
//   - DHIS2 URIs are prefixed with $DHIS2 and a hyphenated suffix ($DHIS2-TEI).
//
// When adding a new alias, place it in the correct group and add a short
// comment explaining what it identifies.
// ============================================================================


// === Standard Terminologies ===
// These are internationally recognised coding systems used across healthcare.
// FHIR expects coded elements to reference these systems by their canonical URL.

// SNOMED CT — comprehensive clinical terminology covering diseases, findings,
// procedures, body structures, and more. Used worldwide as a reference
// terminology for interoperability.
Alias: $SCT = http://snomed.info/sct

// LOINC — Logical Observation Identifiers Names and Codes. Primarily used to
// identify laboratory and clinical observations (e.g., "Hemoglobin [Mass/volume]
// in Blood"). In DHIS2 mappings we use LOINC codes to identify the meaning of
// individual data elements when a suitable code exists.
Alias: $LOINC = http://loinc.org

// UCUM — Unified Code for Units of Measure. The standard for expressing units
// in FHIR Quantity values (e.g., "kg", "mm[Hg]", "%"). Every numeric
// Observation.valueQuantity should reference UCUM for its unit system.
Alias: $UCUM = http://unitsofmeasure.org

// ICD-10 — International Classification of Diseases, 10th Revision. Used for
// morbidity and mortality coding. In DHIS2 many program-stage data elements
// capture diagnosis codes that map to ICD-10.
Alias: $ICD10 = http://hl7.org/fhir/sid/icd-10


// === HL7 Code Systems ===
// These code systems are defined by HL7 and published as part of the FHIR
// specification or the HL7 Terminology (THO) package. They provide standard
// value sets for common FHIR elements such as identifier types, observation
// categories, and encounter classes.

// V2 Table 0203 — Identifier Type. Classifies the kind of identifier (e.g.,
// MR = Medical Record Number, NI = National Identifier). Used in
// Patient.identifier.type and Organization.identifier.type to tell consumers
// what the identifier represents.
Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203

// V3 NullFlavor — Reasons why a value may be absent (e.g., UNK = unknown,
// ASKU = asked but unknown). Useful when DHIS2 data elements have no recorded
// value and we need to express the reason in FHIR.
Alias: $V3-NullFlavor = http://terminology.hl7.org/CodeSystem/v3-NullFlavor

// Observation Category — Classifies observations into broad buckets such as
// "vital-signs", "laboratory", "social-history", etc. Required by many FHIR
// profiles (e.g., US Core Vital Signs). When mapping DHIS2 data elements we
// assign the appropriate category so downstream consumers can filter
// observations efficiently.
Alias: $observation-category = http://terminology.hl7.org/CodeSystem/observation-category

// Condition Clinical Status — Indicates whether a condition is active,
// recurrence, relapse, inactive, remission, or resolved. Used in
// Condition.clinicalStatus when we map DHIS2 diagnosis or disease-tracking
// data elements to FHIR Conditions.
Alias: $condition-clinical = http://terminology.hl7.org/CodeSystem/condition-clinical

// V3 ActCode (Encounter Class) — Provides codes for encounter classification
// such as AMB (ambulatory), IMP (inpatient), EMER (emergency). In DHIS2,
// tracker events often correspond to facility visits, which we represent as
// FHIR Encounters with an appropriate class drawn from this code system.
Alias: $encounter-class = http://terminology.hl7.org/CodeSystem/v3-ActCode

// Episode of Care Status — Lifecycle status of an EpisodeOfCare (planned,
// waitlist, active, onhold, finished, cancelled). We use EpisodeOfCare to
// represent DHIS2 enrollments, and this code system drives the status element.
Alias: $episode-of-care-status = http://hl7.org/fhir/episode-of-care-status

// Measure Scoring — How a Measure is scored (proportion, ratio, continuous-
// variable, cohort). DHIS2 indicators and data-set reporting rates map to FHIR
// Measures, and the scoring type determines how numerator/denominator are
// interpreted.
Alias: $measure-scoring = http://terminology.hl7.org/CodeSystem/measure-scoring

// Measure Type — Classifies what a measure evaluates (process, outcome,
// structure, etc.). Helps consumers understand whether a DHIS2 indicator
// measures an outcome (e.g., mortality rate) or a process (e.g., number of
// vaccinations given).
Alias: $measure-type = http://terminology.hl7.org/CodeSystem/measure-type

// Measure Population — Identifies the role of a population within a measure
// (initial-population, numerator, denominator, etc.). Each DHIS2 indicator has
// a numerator and denominator expression; these map directly to the FHIR
// population components.
Alias: $measure-population = http://terminology.hl7.org/CodeSystem/measure-population

// Measure Report Type — Indicates whether a MeasureReport is individual,
// subject-list, summary, or data-collection. DHIS2 aggregate data exports
// typically produce summary-type reports; individual tracker data produces
// individual-type reports.
Alias: $measure-report-type = http://hl7.org/fhir/measure-report-type


// === DHIS2 Identifiers ===
// These URIs are custom to this IG. They serve as the "system" value in FHIR
// Identifier elements so that consumers can recognise which DHIS2 domain object
// a given identifier refers to. The base URI http://dhis2.org/fhir is a
// convention established by this IG — it is not (yet) a registered FHIR
// NamingSystem.

// Base DHIS2 FHIR namespace. Used as a prefix for all DHIS2-specific URIs and
// as the system for generic DHIS2 identifiers that do not fall into a more
// specific category below.
Alias: $DHIS2 = http://dhis2.org/fhir

// Tracked Entity Instance (TEI) — The unique ID assigned to a person (or other
// tracked entity) in DHIS2 Tracker. Mapped to Patient.identifier or
// RelatedPerson.identifier with this system.
Alias: $DHIS2-TEI = http://dhis2.org/fhir/id/tracked-entity

// Organisation Unit — The unique ID of a facility, district, or other node in
// the DHIS2 organisation unit hierarchy. Mapped to Organization.identifier.
Alias: $DHIS2-OU = http://dhis2.org/fhir/id/org-unit

// Organisation Unit Code — The human-readable code assigned to org units in
// DHIS2 (separate from the auto-generated UID). Often follows patterns like
// "OU_559" and is used in reports and integrations.
Alias: $DHIS2-OU-CODE = http://dhis2.org/fhir/id/org-unit-code

// Data Element — The unique ID of a DHIS2 data element (a single field within
// a data set or program stage). Used in Observation.code or in the
// DHIS2DataElementExtension to trace an observation back to its source element.
Alias: $DHIS2-DE = http://dhis2.org/fhir/id/data-element

// Data Set — The unique ID of a DHIS2 data set (an aggregate reporting form).
// Used in Measure.identifier when mapping a data set to a FHIR Measure.
Alias: $DHIS2-DS = http://dhis2.org/fhir/id/data-set

// Program — The unique ID of a DHIS2 program (tracker or event program). Used
// in EpisodeOfCare or Encounter identifiers to link back to the originating
// program.
Alias: $DHIS2-PROGRAM = http://dhis2.org/fhir/id/program

// Indicator — The unique ID of a DHIS2 indicator. Indicators are calculated
// values (numerator / denominator) that map to FHIR Measures.
Alias: $DHIS2-INDICATOR = http://dhis2.org/fhir/id/indicator


// === Lao PDR Health Registry Identifiers ===
// These URIs identify Lao government-issued identifiers used in the health
// registry. Each serves as the "system" in a Patient.identifier element.

Alias: $LAO-CHR = http://moh.gov.la/fhir/id/chr
Alias: $LAO-CVID = http://moh.gov.la/fhir/id/cvid
Alias: $LAO-GREEN = http://moh.gov.la/fhir/id/green-national-id
Alias: $LAO-INSURANCE = http://moh.gov.la/fhir/id/insurance
Alias: $LAO-FAMILYBOOK = http://moh.gov.la/fhir/id/family-book
Alias: $LAO-CHRID = http://moh.gov.la/fhir/id/client-health-id
