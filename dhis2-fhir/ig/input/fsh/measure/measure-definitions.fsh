// ============================================================================
// INSTANCES — Measure Definitions
// ============================================================================
// The following instances demonstrate three common patterns in DHIS2:
//   1. A simple count indicator (malaria confirmed cases)
//   2. A proportion indicator with numerator/denominator (ANC coverage)
//   3. A data set definition with multiple data elements (monthly report)


// ----------------------------------------------------------------------------
// Instance: MeasureMalariaCases
// ----------------------------------------------------------------------------
// A simple cohort-type measure that counts confirmed malaria cases at a
// facility during a reporting period. In DHIS2 this would be a data element
// or a simple indicator with a count aggregation type.
//
// Scoring is "cohort" because we are simply counting a population (confirmed
// malaria cases) without dividing by a denominator.
//
// Type is "outcome" because malaria incidence is a health outcome indicator.
// ----------------------------------------------------------------------------
Instance: MeasureMalariaCases
InstanceOf: DHIS2Measure
Title: "Malaria Confirmed Cases"
Description: "Counts confirmed malaria cases at a facility during a reporting period. This measure represents a DHIS2 indicator that tracks malaria morbidity through laboratory-confirmed diagnoses."
Usage: #example

// Canonical URL for this Measure definition
* url = "http://dhis2.org/fhir/learning/Measure/MeasureMalariaCases"

// DHIS2 indicator UID — this is the 11-character UID from DHIS2
* identifier[dhis2uid].system = $DHIS2-INDICATOR
* identifier[dhis2uid].value = "fbfJHSPpUQD"

// Human-readable metadata
* name = "MalariaConfirmedCases"
* title = "Malaria Confirmed Cases"
* status = #active
* description = "Counts the number of laboratory-confirmed malaria cases reported at a health facility during the reporting period. This corresponds to the DHIS2 indicator 'Malaria confirmed cases' which aggregates positive malaria test results from facility registers."

// Scoring: cohort — we are counting individuals in a single population
// (no numerator/denominator division needed)
* scoring = $measure-scoring#cohort "Cohort"

// Type: outcome — malaria incidence is a health outcome
* type = $measure-type#outcome "Outcome"

// The single group defines what we are counting
* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-confirmed "Malaria Confirmed Cases"
* group[0].description = "All laboratory-confirmed malaria cases during the reporting period"

// Initial population — the set of individuals being counted
// In CQL-based measures this would be a formal expression; for DHIS2 we use
// plain text because DHIS2 indicator formulas are not CQL-compatible.
* group[0].population[0].code = $measure-population#initial-population "Initial Population"
* group[0].population[0].criteria.language = #text/plain
* group[0].population[0].criteria.expression = "Patients with confirmed malaria diagnosis"


// ----------------------------------------------------------------------------
// Instance: MeasureANCCoverage
// ----------------------------------------------------------------------------
// A proportion-type measure for antenatal care (ANC) coverage. This is a
// classic DHIS2 indicator with:
//   Numerator:   Number of pregnant women who had at least one ANC visit
//   Denominator: Expected pregnancies in the catchment area
//   Result:      Numerator / Denominator (e.g., 0.80 = 80% coverage)
//
// Proportion scoring tells consumers that the measureScore will be between
// 0 and 1, representing a rate or percentage.
// ----------------------------------------------------------------------------
Instance: MeasureANCCoverage
InstanceOf: DHIS2Measure
Title: "ANC Coverage Rate"
Description: "Proportion of expected pregnancies receiving at least one ANC visit. This is a standard DHIS2 coverage indicator used globally for maternal health monitoring."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Measure/MeasureANCCoverage"

// DHIS2 indicator UID
* identifier[dhis2uid].system = $DHIS2-INDICATOR
* identifier[dhis2uid].value = "ReUHfIn0pTQ"

* name = "ANCCoverageRate"
* title = "ANC Coverage Rate"
* status = #active
* description = "Calculates the proportion of expected pregnancies in a catchment area that received at least one antenatal care (ANC) visit during the reporting period. This is a key maternal health indicator tracked by DHIS2 implementations worldwide."

// Scoring: proportion — this indicator divides numerator by denominator
* scoring = $measure-scoring#proportion "Proportion"

// Type: process — ANC visit attendance is a healthcare delivery process
* type = $measure-type#process "Process"

// Single group with numerator and denominator populations
* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#anc-coverage "ANC Coverage"
* group[0].description = "ANC 1st visit coverage rate"

// Numerator — women who actually attended ANC
* group[0].population[0].code = $measure-population#numerator "Numerator"
* group[0].population[0].criteria.language = #text/plain
* group[0].population[0].criteria.expression = "Pregnant women with at least one ANC visit"

// Denominator — expected pregnancies (estimated from population data)
* group[0].population[1].code = $measure-population#denominator "Denominator"
* group[0].population[1].criteria.language = #text/plain
* group[0].population[1].criteria.expression = "Expected pregnancies in catchment area"


// ----------------------------------------------------------------------------
// Instance: MeasureMonthlyFacilityReport
// ----------------------------------------------------------------------------
// A DHIS2 data set definition represented as a Measure. Data sets in DHIS2 are
// essentially forms that collect multiple data elements. Each data element
// becomes a group in the Measure.
//
// This example represents a simplified monthly facility report with three data
// elements: malaria confirmed cases, malaria tested, and OPD visits.
//
// Scoring is "cohort" because each data element counts a population.
// Type is "structure" because this defines the structure of a reporting form,
// not a calculated outcome.
//
// Note: The identifier uses $DHIS2-DS (data set system) rather than
// $DHIS2-INDICATOR because this represents a data set, not an indicator.
// ----------------------------------------------------------------------------
Instance: MeasureMonthlyFacilityReport
InstanceOf: DHIS2Measure
Title: "Monthly Facility Report"
Description: "Monthly aggregate data collection form — represents a DHIS2 data set with three data elements for malaria and outpatient reporting."
Usage: #example

* url = "http://dhis2.org/fhir/learning/Measure/MeasureMonthlyFacilityReport"

// DHIS2 data set UID — note the use of $DHIS2-DS (data set system)
// rather than $DHIS2-INDICATOR, because this is a data set definition
* identifier[0].system = $DHIS2-DS
* identifier[0].value = "BfMAe6Itzgt"

* name = "MonthlyFacilityReport"
* title = "Monthly Facility Report"
* status = #active
* description = "A monthly aggregate data collection form used by health facilities to report key indicators. This data set includes malaria case counts and outpatient department (OPD) visit totals. In DHIS2, this is a 'data set' that facilities complete each month."

// Scoring: cohort — each data element counts individuals
* scoring = $measure-scoring#cohort "Cohort"

// Type: structure — this defines a reporting form structure
* type = $measure-type#structure "Structure"

// --- Group 1: Malaria cases confirmed ---
// This data element captures the number of laboratory-confirmed malaria cases
* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-confirmed "Malaria Confirmed Cases"
* group[0].description = "Number of laboratory-confirmed malaria cases reported during the month"
* group[0].population[0].code = $measure-population#initial-population "Initial Population"
* group[0].population[0].criteria.language = #text/plain
* group[0].population[0].criteria.expression = "Count of patients with positive malaria test result"

// --- Group 2: Malaria cases tested ---
// This data element captures the total number of malaria tests performed
* group[1].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-tested "Malaria Cases Tested"
* group[1].description = "Total number of patients tested for malaria during the month"
* group[1].population[0].code = $measure-population#initial-population "Initial Population"
* group[1].population[0].criteria.language = #text/plain
* group[1].population[0].criteria.expression = "Count of patients tested for malaria by RDT or microscopy"

// --- Group 3: OPD visits total ---
// This data element captures the total outpatient department visits
* group[2].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#opd-visits "OPD Visits Total"
* group[2].description = "Total number of outpatient department visits during the month"
* group[2].population[0].code = $measure-population#initial-population "Initial Population"
* group[2].population[0].criteria.language = #text/plain
* group[2].population[0].criteria.expression = "Count of all outpatient visits at the facility"