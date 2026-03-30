// ============================================================================
// Logical Model: DHIS2DataValueSet
// ============================================================================
// This model represents a DHIS2 Data Value Set — the aggregate data submission
// payload sent by facilities on a regular schedule (monthly, quarterly, etc.).
//
// Unlike Tracker data (which is individual-level), aggregate data is already
// summarised: "Facility X reported 47 malaria cases in January 2024". There
// is no patient-level detail.
//
// A Data Value Set contains:
//   - Context: which data set, org unit, and period this submission covers
//   - Data values: a list of data element / category option combo / value
//     triples
//
// The DHIS2 API endpoint is /api/dataValueSets, and this model mirrors
// the JSON payload used for both import and export.
//
// When mapped to FHIR, a Data Value Set becomes a MeasureReport of type
// "data-collection", where:
//   - dataSet → MeasureReport.measure
//   - period → MeasureReport.period
//   - orgUnit → MeasureReport.subject
//   - Each dataValue → a group in the MeasureReport
// ============================================================================
Logical: DHIS2DataValueSet
Id: dhis2-data-value-set
Title: "DHIS2 Data Value Set"
Description: """
Represents a DHIS2 aggregate data value set submission — the payload sent when
a facility reports its periodic aggregate data (e.g., monthly malaria counts,
quarterly OPD statistics).

This model mirrors the JSON structure used by the DHIS2 Web API
`/api/dataValueSets` endpoint for both importing and exporting aggregate data.

Each submission contains a set of data values for a specific organisation unit
and reporting period, optionally scoped to a particular data set. This maps
to a FHIR MeasureReport of type `data-collection`.
"""

// -- Data set reference (optional) --
// The UID of the DHIS2 data set this submission belongs to. A data set
// groups related data elements into a reporting form (e.g., "Monthly
// Facility Report"). This is optional because DHIS2 allows submitting
// data values without specifying a data set.
* dataSet 0..1 string "Data set UID" "The UID of the DHIS2 data set (reporting form) that these values belong to. Optional — data values can be submitted without a data set context."

// -- Completion date --
// When the data entry operator marked this submission as complete. This is
// distinct from the period end date — a January report might be completed
// on February 5th.
* completeDate 0..1 string "Completion date" "The date when this data value set was marked as complete by the data entry operator. Format: YYYY-MM-DD."

// -- Reporting period --
// The period these data values cover, expressed in DHIS2's period format:
//   - Monthly: "202401" (January 2024)
//   - Quarterly: "2024Q1"
//   - Yearly: "2024"
//   - Weekly: "2024W3"
// This must be parsed and converted to FHIR Period (start/end dates).
* period 1..1 string "Reporting period (e.g., 202401)" "The reporting period in DHIS2 format. Monthly: YYYYMM, Quarterly: YYYYQN, Yearly: YYYY. Must be converted to FHIR Period start/end dates."

// -- Organisation unit --
// The facility or administrative unit that this data is reported for.
// Always a DHIS2 org unit UID.
* orgUnit 1..1 string "Organisation unit UID" "The UID of the DHIS2 organisation unit that these values are reported for."

// -- Data values --
// The actual reported data. Each entry is one data element value, optionally
// disaggregated by a category option combination.
* dataValues 1..* BackboneElement "Data values" "The individual data values being submitted. Each entry reports one number for one data element at this org unit and period."

  // Which data element this value is for
  * dataElement 1..1 string "Data element UID" "The UID of the DHIS2 data element being reported on."

  // -- Category option combo (disaggregation) --
  // DHIS2 supports disaggregation of data elements by categories. For
  // example, "Malaria cases" might be disaggregated by age group and sex:
  //   - Male, 0-4 years (combo UID: "HllvX50cXC0")
  //   - Female, 0-4 years (combo UID: "Yjte6foKMny")
  //   - Male, 5-14 years, etc.
  // If no disaggregation is used, DHIS2 uses a "default" combo.
  * categoryOptionCombo 0..1 string "Category option combo UID" "The UID of the category option combination for disaggregation. DHIS2 uses this to break down data elements by dimensions like age group, sex, etc. Omit for non-disaggregated values."

  // The actual reported value. Always a string in the API — can represent
  // integers ("47"), decimals ("12.5"), booleans ("true"), or text.
  * value 1..1 string "Reported value" "The value being reported. Always serialised as a string in the DHIS2 API. Typically a number for aggregate data (e.g., '47', '312')."

  // Optional comment from the data entry operator
  * comment 0..1 string "Comment" "An optional free-text comment about this particular data value. Used by data entry operators to explain anomalies or provide context."
