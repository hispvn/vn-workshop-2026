// ============================================================================
// DHIS2 Aggregation Type
// ============================================================================
//
// Every DHIS2 data element and indicator specifies an aggregation type that
// controls how values are combined across time periods and organisation units.
// For example, "number of malaria cases" uses SUM (add up cases from all
// facilities), while "stock on hand" uses LAST (only the most recent value
// matters).
//
// In FHIR, this metadata is captured in Measure resources or in the
// DHIS2DataElementExtension so that consumers understand how to interpret
// aggregated data.
// ============================================================================

CodeSystem: DHIS2AggregationTypeCS
Id: dhis2-aggregation-type
Title: "DHIS2 Aggregation Type"
Description: """
Defines how values for a DHIS2 data element or indicator are aggregated across
organisation units and time periods. The aggregation type is critical for
correct interpretation of summary data.
"""
* ^caseSensitive = true
* ^content = #complete
* ^experimental = false

* #SUM "Sum"
    "Values are summed. Appropriate for counts and additive quantities (e.g., number of patients seen)."
* #AVERAGE "Average"
    "Values are averaged. Appropriate for rates and non-additive quantities (e.g., average wait time)."
* #COUNT "Count"
    "The number of non-empty values is counted rather than the values themselves."
* #NONE "None"
    "No aggregation is performed. The value is used as-is at each level."
* #LAST "Last value"
    "Only the most recent value in the period is used. Appropriate for stock/inventory levels."
* #MIN "Min"
    "The minimum value across the aggregation dimension is selected."
* #MAX "Max"
    "The maximum value across the aggregation dimension is selected."


ValueSet: DHIS2AggregationTypeVS
Id: dhis2-aggregation-type-vs
Title: "DHIS2 Aggregation Types"
Description: """
All aggregation types supported by DHIS2 data elements and indicators.
"""
* ^experimental = false
* include codes from system DHIS2AggregationTypeCS
