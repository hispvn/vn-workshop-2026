// ============================================================================
// Mapping: DataValueSetToMeasureReport
// ============================================================================
// This mapping documents the transformation from a DHIS2 aggregate data value
// set to a FHIR MeasureReport. This is the aggregate-data counterpart to the
// TEI-to-Patient mapping above.
//
// The mapping is simpler because aggregate data is already summarised — there
// are no patient-level records to fan out. One DataValueSet becomes one
// MeasureReport.
//
//   DHIS2 Element              FHIR MeasureReport Element
//   ──────────────────────     ──────────────────────────
//   dataSet                    MeasureReport.measure
//   period                     MeasureReport.period
//   orgUnit                    MeasureReport.subject
//   completeDate               MeasureReport.date
//   dataValues[]               MeasureReport.group[]
//   dataValues[].dataElement   MeasureReport.group.code
//   dataValues[].value         MeasureReport.group.population.count
//   dataValues[].catOptCombo   MeasureReport.group.stratifier
//
// The MeasureReport type is always "data-collection" for aggregate submissions.
//
// ============================================================================
Mapping: DataValueSetToMeasureReport
Source: DHIS2DataValueSet
Target: "http://hl7.org/fhir/StructureDefinition/MeasureReport"
Id: dvs-to-measure-report
Title: "DHIS2 Data Value Set to FHIR MeasureReport Mapping"
Description: """
Maps a DHIS2 aggregate data value set to a FHIR MeasureReport of type
data-collection. Each data value in the set becomes a group in the
MeasureReport, with the data element as the group code and the value as the
population count.
"""

// --- Data Set → MeasureReport.measure ---
// The DHIS2 data set UID is resolved to the canonical URL of the
// corresponding FHIR Measure resource. The Measure defines the structure
// of the reporting form (which data elements are expected).
* dataSet -> "MeasureReport.measure" "Data set UID resolves to the canonical URL of the Measure that defines the reporting form"

// --- Period → MeasureReport.period ---
// DHIS2 periods are encoded as strings (e.g., "202401" for January 2024).
// These must be parsed and converted to FHIR Period with explicit start
// and end dates:
//   "202401"  → period.start=2024-01-01, period.end=2024-01-31
//   "2024Q1"  → period.start=2024-01-01, period.end=2024-03-31
//   "2024"    → period.start=2024-01-01, period.end=2024-12-31
//   "2024W3"  → period.start=2024-01-15, period.end=2024-01-21
* period -> "MeasureReport.period" "DHIS2 period code (e.g., 202401) is converted to FHIR Period with explicit start and end dates"

// --- Organisation Unit → MeasureReport.subject ---
// The org unit UID is resolved to a FHIR Organization or Location reference.
// In aggregate reporting, the subject is always the reporting facility or
// administrative unit — never a patient.
* orgUnit -> "MeasureReport.subject" "Org unit UID resolves to an Organization or Location reference representing the reporting facility"

// --- Complete Date → MeasureReport.date ---
// When the data entry operator marked the submission as complete.
// This becomes the MeasureReport.date (when the report was generated).
* completeDate -> "MeasureReport.date" "Date the submission was marked complete by the data entry operator"

// --- Data Values → MeasureReport.group ---
// Each data value in the set becomes a group in the MeasureReport.
// The group contains the data element identity and reported value.

// --- Data Element → MeasureReport.group.code ---
// The data element UID is stored in group.code with system $DHIS2-DE.
// Optionally, if the data element has been mapped to a standard terminology
// (LOINC, SNOMED), additional codings can be added.
* dataValues.dataElement -> "MeasureReport.group.code" "Data element UID becomes the group code (system: $DHIS2-DE). Additional standard terminology codes (LOINC, SNOMED) can be added as extra codings."

// --- Value → MeasureReport.group.population.count ---
// The reported numeric value becomes the population count. For non-numeric
// values (text, boolean), alternative representations may be needed — but
// in aggregate DHIS2 data, values are almost always numeric counts.
* dataValues.value -> "MeasureReport.group.population.count" "The reported value becomes the population count. DHIS2 aggregate values are typically integers representing counts."

// --- Category Option Combo → MeasureReport.group.stratifier ---
// DHIS2's disaggregation mechanism (category option combinations) maps to
// FHIR's stratifier concept. For example, if malaria cases are disaggregated
// by age group and sex, each combination becomes a stratifier stratum.
//
// This is one of the more complex aspects of the mapping:
//   - If no disaggregation: no stratifier needed (use default combo)
//   - If disaggregated: each unique combo becomes a stratifier stratum
//     with a code identifying the category options
//
// Alternative: disaggregated values can also be represented as separate
// groups (one per combo) rather than using stratifiers.
* dataValues.categoryOptionCombo -> "MeasureReport.group.stratifier" "Category option combo UID maps to stratifier for disaggregation by dimensions like age group, sex, etc."

// --- Comment → MeasureReport.group.extension ---
// DHIS2 allows comments on individual data values. There is no standard
// FHIR element for this, so it would be captured as an extension on the
// group or as a note on the MeasureReport.
* dataValues.comment -> "MeasureReport.group.extension" "Data value comments can be preserved as extensions since there is no standard FHIR element for per-group comments"
