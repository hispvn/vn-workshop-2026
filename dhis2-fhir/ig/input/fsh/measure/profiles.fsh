// ============================================================================
// DHIS2-FHIR Learning IG — Measure & MeasureReport Profiles and Instances
// ============================================================================
//
// This is the MOST IMPORTANT file for DHIS2 aggregate data representation in
// FHIR. DHIS2 has two core aggregate concepts:
//
//   1. Indicators — calculated values with a numerator and denominator formula.
//      These map to FHIR Measure (definition) and MeasureReport (computed
//      result for a specific period and organisation unit).
//
//   2. Data Sets — collections of data elements submitted by facilities on a
//      regular schedule (monthly, quarterly, etc.). A data set submission maps
//      to a FHIR MeasureReport of type "data-collection", where each data
//      element becomes a group and its reported value becomes the population
//      count.
//
// Why Measure/MeasureReport for aggregate data?
// FHIR's Measure framework was designed for quality measures, but it maps
// naturally to DHIS2's aggregate model: a Measure defines *what* to count,
// a MeasureReport records *what was counted* at a specific facility and time.
// The data-collection report type was added to FHIR specifically for this kind
// of aggregate facility reporting, making it an ideal match for DHIS2.
//
// ============================================================================


// ============================================================================
// Profile: DHIS2Measure
// ============================================================================
// Represents a DHIS2 indicator definition or data set definition. In DHIS2,
// indicators have a name, a numerator expression, and a denominator expression.
// Data sets group multiple data elements into a reporting form. Both translate
// to FHIR Measure resources: the indicator's formula maps to the Measure's
// population criteria, and the data set's elements map to Measure groups.
//
// Key constraints:
//   - url is required (1..1) — every Measure must have a canonical URL
//   - title is required — human-readable name for display
//   - scoring is required — tells consumers how to interpret the measure
//     (proportion, cohort, etc.)
//   - At least one group is required — each group represents a measurable
//     component (a data element in a data set, or the overall indicator)
//   - identifier is sliced to allow a dedicated DHIS2 indicator UID
// ============================================================================
Profile: DHIS2Measure
Parent: Measure
Id: dhis2-measure
Title: "DHIS2 Measure"
Description: """
Represents a DHIS2 indicator definition or data set definition.

In DHIS2, **indicators** are calculated values defined by a numerator and
denominator formula (e.g., "ANC coverage = ANC 1st visits / expected
pregnancies"). **Data sets** are collections of data elements that facilities
report on a fixed schedule.

Both concepts map to FHIR Measure: the indicator's formula components become
population entries (numerator, denominator), while each data element in a
data set becomes a separate group within the Measure.

The corresponding reported values are captured in DHIS2MeasureReport or
DHIS2DataCollectionReport instances.
"""

// -- Canonical URL --
// Every Measure must have a globally unique canonical URL. For DHIS2 indicators
// this would typically follow the pattern:
//   http://dhis2.org/fhir/learning/Measure/<indicator-uid>
* url 1..1 MS

// -- Identifier (sliced) --
// DHIS2 objects are identified by 11-character alphanumeric UIDs. We slice the
// identifier array to provide a dedicated slot for the DHIS2 indicator UID
// while still allowing other identifiers (e.g., WHO indicator codes).
* identifier MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Slice by identifier system to separate DHIS2 UIDs from other identifiers"
* identifier contains dhis2uid 0..1
* identifier[dhis2uid].system = $DHIS2-INDICATOR
* identifier[dhis2uid].value 1..1
* identifier[dhis2uid] ^short = "DHIS2 indicator UID"
* identifier[dhis2uid] ^definition = "The 11-character alphanumeric UID of this indicator in DHIS2"

// -- Human-readable metadata --
* name MS
* title 1..1 MS
* status MS
* description MS

// -- Scoring --
// Scoring determines how the measure is calculated:
//   - proportion: numerator / denominator (e.g., coverage rates)
//   - cohort: count of a population (e.g., number of malaria cases)
//   - continuous-variable: aggregated continuous values
//   - ratio: numerator / denominator where populations may overlap
// DHIS2 indicators with both numerator and denominator → proportion
// DHIS2 data elements that are simple counts → cohort
* scoring 1..1 MS
* scoring from http://hl7.org/fhir/ValueSet/measure-scoring (required)

// -- Type --
// Classifies what the measure evaluates:
//   - outcome: measures a health outcome (e.g., mortality, incidence)
//   - process: measures a healthcare delivery process (e.g., vaccination rate)
//   - structure: measures resources/infrastructure (data set structure)
* type MS

// -- Groups --
// Each group represents a measurable component. For a simple indicator there
// is typically one group; for a data set each data element is a separate group.
* group 1..* MS
* group.population MS
* group.population.code MS
* group.population.criteria MS


// ============================================================================
// Profile: DHIS2MeasureReport
// ============================================================================
// Represents a DHIS2 aggregate data submission (data value set) or an
// indicator value computed for a specific organisation unit and period.
//
// In DHIS2, when a facility submits its monthly report, each data element
// value for that facility and period becomes part of a "data value set". When
// DHIS2 calculates an indicator, it produces a result for a given org unit and
// period. Both of these translate to FHIR MeasureReport.
//
// Key constraints:
//   - subject must reference Organization or Location (facility-level reporting)
//   - period is required (every DHIS2 report is for a specific period)
//   - at least one group is required (the actual data)
//   - reporter identifies who submitted the data
// ============================================================================
Profile: DHIS2MeasureReport
Parent: MeasureReport
Id: dhis2-measure-report
Title: "DHIS2 Measure Report"
Description: """
Represents a DHIS2 aggregate data submission or indicator value for a specific
organisation unit and reporting period.

DHIS2 aggregate data is fundamentally about "what value was reported for data
element X at facility Y during period Z". This maps naturally to FHIR
MeasureReport where:
- **measure** identifies the indicator or data set definition
- **subject** identifies the reporting facility (organisation unit)
- **period** identifies the reporting period
- **group** contains the reported values

For summary indicator results, the type is `#summary`. For raw data
collection from facilities, use the DHIS2DataCollectionReport profile
with type `#data-collection`.
"""

* status MS

// -- Type --
// Indicates what kind of report this is:
//   - summary: aggregated indicator result
//   - individual: result for a single subject (less common in DHIS2 aggregate)
//   - data-collection: raw facility data submission
* type 1..1 MS

// -- Measure reference --
// Links this report to the Measure definition (indicator or data set) that
// defines what was measured. This is a canonical URL reference.
* measure 1..1 MS

// -- Subject --
// In DHIS2 aggregate reporting, data is reported at the organisation unit level.
// In FHIR R4, MeasureReport.subject does not allow Organization directly — use
// Location instead (which links to its Organization via managingOrganization).
// For individual-level reports, the subject would be a Patient.
* subject 1..1 MS
* subject only Reference(Location or Group)
* subject ^short = "Reporting facility (Location) or population group"

// -- Date and period --
// date: when the report was generated or submitted
// period: the reporting period (e.g., January 2024, Q1 2024)
* date MS
* period 1..1 MS

// -- Reporter --
// The organisation that submitted or generated this report. In DHIS2 this is
// typically the same as the subject (the facility reporting its own data) but
// can differ for aggregated district-level reports.
* reporter MS
* reporter only Reference(Organization)

// -- Groups --
// Each group contains the actual reported data. For a summary indicator report,
// there is typically one group with a measureScore (the calculated indicator
// value). For data-collection reports, each group represents a data element.
* group 1..* MS
* group.population MS
* group.population.count MS
* group.measureScore MS


// ============================================================================
// Profile: DHIS2DataCollectionReport
// ============================================================================
// A specialised profile for DHIS2 data set reports — the monthly or quarterly
// facility submissions that form the backbone of DHIS2 aggregate reporting.
//
// This profile inherits from MeasureReport (not DHIS2MeasureReport, to keep
// the constraint set explicit) and fixes the type to #data-collection. The key
// difference from DHIS2MeasureReport is:
//   - type is always "data-collection" (not summary or individual)
//   - group.code is must-support (identifies each data element)
//   - group.population.count carries the actual reported numeric value
//
// In DHIS2 terms, a DataCollectionReport represents one row in the
// data_value table: a complete set of data values for a given data set,
// organisation unit, and period.
// ============================================================================
Profile: DHIS2DataCollectionReport
Parent: MeasureReport
Id: dhis2-data-collection-report
Title: "DHIS2 Data Collection Report"
Description: """
Represents a DHIS2 data set submission — the monthly or quarterly aggregate
data that facilities report through DHIS2 data entry forms.

This profile fixes the report type to `data-collection`, meaning it captures
raw reported counts rather than calculated indicator values. Each group
represents a single data element in the data set, identified by `group.code`,
with the reported value in `group.population.count`.

Example: A facility's January 2024 monthly report might contain groups for
"malaria confirmed cases" (47), "malaria tested" (312), and "OPD visits"
(1842). Each of these becomes a group in the MeasureReport.
"""

* status MS

// -- Fixed type --
// Data collection reports are always of type "data-collection". This is a FHIR
// report type specifically designed for aggregate facility reporting — exactly
// what DHIS2 data sets represent.
* type = #data-collection

// -- Measure reference --
// Links to the Measure definition that describes the data set structure
// (which data elements are included, their expected types, etc.)
* measure 1..1 MS

// -- Subject and reporter --
// Same facility-level reporting constraints as DHIS2MeasureReport.
// Use Location (not Organization) as FHIR R4 MeasureReport.subject
// does not allow Organization references.
* subject 1..1 MS
* subject only Reference(Location or Group)
* subject ^short = "Reporting facility (Location representing DHIS2 org unit)"
* reporter MS
* reporter only Reference(Organization)

// -- Date and period --
* date MS
* period 1..1 MS

// -- Groups --
// Each group represents one data element from the data set. The group.code
// identifies which data element this is (using the DHIS2 data element system),
// and group.population.count holds the reported numeric value.
* group 1..* MS
* group.code MS
* group.code ^short = "Data element identifier"
* group.code ^definition = "Identifies which DHIS2 data element this group reports on"
* group.population MS
* group.population.count MS
* group.population.count ^short = "Reported value"
* group.population.count ^definition = "The numeric value reported for this data element at this facility during this period"