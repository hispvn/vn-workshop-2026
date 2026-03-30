// ============================================================================
// Instance: BundleMontlyReport
// ============================================================================
// A collection bundle that packages a monthly facility MeasureReport together
// with its Measure definition. This represents the FHIR equivalent of a
// DHIS2 data set submission (data value set).
//
// Why a collection bundle?
// Unlike the transaction bundle above, a collection bundle has no processing
// semantics — the server does not "execute" it. It simply groups related
// resources for transport, documentation, or storage. This is appropriate
// here because:
//   - The Measure definition likely already exists on the server
//   - The MeasureReport is the primary payload being submitted
//   - Including the Measure is for context/completeness, not for creation
//
// In a production system, the Measure would be created once (via a separate
// transaction) and the MeasureReport would be POSTed individually or in a
// batch. The collection bundle is a documentation convenience that shows
// how the pieces fit together.
//
// The bundle contains:
//   1. MeasureReport — the actual monthly data (47 malaria cases, 312 tested,
//      1842 OPD visits)
//   2. Measure — the data set definition (what data elements are expected)
//
// This pattern mirrors the DHIS2 workflow where a data entry operator opens
// a data set form (Measure) and fills in the values (MeasureReport).
// ============================================================================
Instance: BundleMontlyReport
InstanceOf: Bundle
Title: "Monthly Facility Report Collection Bundle"
Description: "A FHIR collection bundle containing a monthly facility MeasureReport (data values) and its corresponding Measure definition (data set structure). Represents a complete DHIS2 data set submission as a self-contained FHIR package."
Usage: #example

// Bundle type: collection — a read-only grouping of resources
* type = #collection

// ---- Entry 1: MeasureReport ----
// The actual reported data — Facility Alpha's January 2024 monthly submission.
// This is the primary payload of the bundle. It contains three data element
// values: malaria confirmed (47), malaria tested (312), and OPD visits (1842).
//
// The MeasureReport references the Measure by its canonical URL. This
// reference works regardless of whether the Measure is in the same bundle
// or already exists on the server.
* entry[0].fullUrl = "http://dhis2.org/fhir/learning/MeasureReport/MeasureReportInBundle"
* entry[0].resource = MeasureReportInBundle

// ---- Entry 2: Measure ----
// The data set definition — included for context so that consumers can
// understand the structure of the report without a separate lookup.
//
// In a production system, the Measure would typically already exist on
// the FHIR server. Including it in the collection bundle makes the
// package self-contained and easier to understand.
* entry[1].fullUrl = "http://dhis2.org/fhir/learning/Measure/MeasureInBundle"
* entry[1].resource = MeasureInBundle


// ============================================================================
// Inline instances for the collection bundle
// ============================================================================

// --- MeasureReport (inline) ---
// The monthly data submission. This is essentially the same content as
// MeasureReportMonthlyJan2024 (defined in profiles-measure.fsh) but
// packaged as an inline resource within the bundle.
Instance: MeasureReportInBundle
InstanceOf: MeasureReport
Usage: #inline

* status = #complete
* type = #summary
* measure = "http://dhis2.org/fhir/learning/Measure/MeasureInBundle"
* subject = Reference(LocationFacilityA)
* date = "2024-02-03"
* period.start = "2024-01-01"
* period.end = "2024-01-31"
* reporter = Reference(OrganizationFacilityA)

// Group 1: Malaria confirmed = 47
* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-confirmed "Malaria Confirmed Cases"
* group[0].population[0].code = $measure-population#initial-population "Initial Population"
* group[0].population[0].count = 47

// Group 2: Malaria tested = 312
* group[1].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-tested "Malaria Cases Tested"
* group[1].population[0].code = $measure-population#initial-population "Initial Population"
* group[1].population[0].count = 312

// Group 3: OPD visits = 1842
* group[2].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#opd-visits "OPD Visits Total"
* group[2].population[0].code = $measure-population#initial-population "Initial Population"
* group[2].population[0].count = 1842


// --- Measure (inline) ---
// The data set definition. Included in the bundle so consumers have the
// full context of what data elements are expected in the report.
Instance: MeasureInBundle
InstanceOf: Measure
Usage: #inline

* url = "http://dhis2.org/fhir/learning/Measure/MeasureInBundle"
* identifier[0].system = $DHIS2-DS
* identifier[0].value = "BfMAe6Itzgt"
* name = "MonthlyFacilityReport"
* title = "Monthly Facility Report"
* status = #active
* description = "Monthly aggregate data collection form for health facilities"
* scoring = $measure-scoring#cohort "Cohort"
* type = $measure-type#structure "Structure"

// Data element 1: Malaria confirmed
* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-confirmed "Malaria Confirmed Cases"
* group[0].population[0].code = $measure-population#initial-population "Initial Population"
* group[0].population[0].criteria.language = #text/plain
* group[0].population[0].criteria.expression = "Count of confirmed malaria cases"

// Data element 2: Malaria tested
* group[1].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-tested "Malaria Cases Tested"
* group[1].population[0].code = $measure-population#initial-population "Initial Population"
* group[1].population[0].criteria.language = #text/plain
* group[1].population[0].criteria.expression = "Count of malaria tests performed"

// Data element 3: OPD visits
* group[2].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#opd-visits "OPD Visits Total"
* group[2].population[0].code = $measure-population#initial-population "Initial Population"
* group[2].population[0].criteria.language = #text/plain
* group[2].population[0].criteria.expression = "Count of all outpatient visits"
