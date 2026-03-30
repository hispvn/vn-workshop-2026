// ============================================================================
// INSTANCES — MeasureReport (Indicator Results)
// ============================================================================
// The following instances show how reported values are captured in FHIR. Each
// MeasureReport links to a Measure definition and records the actual counts
// or scores for a specific facility and period.


// ----------------------------------------------------------------------------
// Instance: MeasureReportMalariaJan2024
// ----------------------------------------------------------------------------
// A summary report showing that Facility Alpha reported 47 confirmed malaria
// cases in January 2024. This is the simplest type of aggregate report: a
// single count for a single indicator at one facility.
//
// The measureScore is 47 (same as the count) because cohort measures simply
// report the population size without dividing by a denominator.
// ----------------------------------------------------------------------------
Instance: MeasureReportMalariaJan2024
InstanceOf: DHIS2MeasureReport
Title: "Malaria Cases Report — January 2024"
Description: "Facility Alpha reported 47 confirmed malaria cases in January 2024. This demonstrates a cohort-type summary MeasureReport for a simple count indicator."
Usage: #example

* status = #complete

// Type: summary — this is an aggregated result, not individual-level data
* type = #summary

// Reference to the Measure definition that describes what was measured
* measure = "http://dhis2.org/fhir/learning/Measure/MeasureMalariaCases"

// Subject: the facility that reported this data (DHIS2 organisation unit)
* subject = Reference(LocationFacilityA)

// Date: when this report was generated
* date = "2024-02-05"

// Period: January 2024 — the month being reported on
* period.start = "2024-01-01"
* period.end = "2024-01-31"

// Reporter: same as subject in this case (facility self-reporting)
* reporter = Reference(OrganizationFacilityA)

// The actual data: 47 confirmed malaria cases
* group[0].population[0].code = $measure-population#initial-population "Initial Population"
* group[0].population[0].count = 47

// For cohort measures, the count is in population[0].count above.
// measureScore is not used for cohort scoring types.


// ----------------------------------------------------------------------------
// Instance: MeasureReportANCQ1
// ----------------------------------------------------------------------------
// A proportion-type summary report for ANC coverage at Facility Alpha during
// Q1 2024 (January–March). This demonstrates how DHIS2 indicator results with
// numerator and denominator are represented in FHIR.
//
// Numerator:   120 women had at least one ANC visit
// Denominator: 150 expected pregnancies
// Score:       120/150 = 0.80 (80% coverage)
//
// The measureScore is 0.8 — a decimal between 0 and 1 representing the rate.
// This is the standard FHIR convention for proportion measures.
// ----------------------------------------------------------------------------
Instance: MeasureReportANCQ1
InstanceOf: DHIS2MeasureReport
Title: "ANC Coverage Report — Q1 2024"
Description: "Facility Alpha achieved 80% ANC coverage in Q1 2024 (120 of 150 expected pregnancies received at least one ANC visit). Demonstrates a proportion-type indicator result."
Usage: #example

* status = #complete
* type = #summary

// Reference to the ANC Coverage Measure definition
* measure = "http://dhis2.org/fhir/learning/Measure/MeasureANCCoverage"

// Subject: Facility Alpha
* subject = Reference(LocationFacilityA)
* date = "2024-04-10"

// Period: Q1 2024 (January through March)
* period.start = "2024-01-01"
* period.end = "2024-03-31"

* reporter = Reference(OrganizationFacilityA)

// --- Numerator ---
// 120 pregnant women had at least one ANC visit during Q1
* group[0].population[0].code = $measure-population#numerator "Numerator"
* group[0].population[0].count = 120

// --- Denominator ---
// 150 pregnancies were expected in the catchment area during Q1
* group[0].population[1].code = $measure-population#denominator "Denominator"
* group[0].population[1].count = 150

// --- Measure Score ---
// 120 / 150 = 0.80 (80% coverage)
// FHIR convention: proportion scores are expressed as decimals (0.0–1.0),
// not percentages (0–100). Consumers can multiply by 100 for display.
* group[0].measureScore.value = 0.8


// ----------------------------------------------------------------------------
// Instance: MeasureReportMonthlyJan2024
// ----------------------------------------------------------------------------
// A data-collection report representing a complete DHIS2 monthly facility
// submission. This is the most common pattern in DHIS2 aggregate reporting:
// a facility fills out a data entry form with multiple data elements and
// submits it at the end of the month.
//
// This example contains three data elements:
//   - Malaria confirmed: 47 cases
//   - Malaria tested: 312 tests
//   - OPD visits: 1842 visits
//
// The type is #data-collection (not #summary) because this represents raw
// reported values, not calculated indicator results.
// ----------------------------------------------------------------------------
Instance: MeasureReportMonthlyJan2024
InstanceOf: DHIS2MeasureReport
Title: "Monthly Facility Report — January 2024"
Description: "Complete monthly facility data submission for Facility Alpha, January 2024. Contains reported values for malaria cases, malaria testing, and OPD visits."
Usage: #example

* status = #complete

// Type: summary — contains aggregated reported values with group/population data
* type = #summary

// Reference to the Monthly Facility Report Measure (data set definition)
* measure = "http://dhis2.org/fhir/learning/Measure/MeasureMonthlyFacilityReport"

// Subject: Facility Alpha
* subject = Reference(LocationFacilityA)
* date = "2024-02-03"

// Period: January 2024
* period.start = "2024-01-01"
* period.end = "2024-01-31"

// Reporter: the facility itself
* reporter = Reference(OrganizationFacilityA)

// --- Group 1: Malaria confirmed cases = 47 ---
// This group corresponds to the "malaria-confirmed" data element in the data set.
// The code identifies which data element this value belongs to, and the
// population count holds the actual reported number.
* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-confirmed "Malaria Confirmed Cases"
* group[0].population[0].code = $measure-population#initial-population "Initial Population"
* group[0].population[0].count = 47

// --- Group 2: Malaria tested = 312 ---
// Total number of malaria tests performed (RDT + microscopy)
// Positivity rate can be derived: 47/312 = 15.1%
* group[1].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-tested "Malaria Cases Tested"
* group[1].population[0].code = $measure-population#initial-population "Initial Population"
* group[1].population[0].count = 312

// --- Group 3: OPD visits total = 1842 ---
// Total outpatient visits — a general workload indicator
* group[2].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#opd-visits "OPD Visits Total"
* group[2].population[0].code = $measure-population#initial-population "Initial Population"
* group[2].population[0].count = 1842