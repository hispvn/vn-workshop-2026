// Exercise 03: Value Sets and Code Systems - Starter File
// Create a CodeSystem for DHIS2 data element types, a ValueSet, and a binding.

CodeSystem: DHIS2DataElementTypeCS
Id: dhis2-data-element-type
Title: "DHIS2 Data Element Type Code System"
Description: "Code system for DHIS2 data element value types."
// TODO: Add code #TEXT with display "Text" and definition "Free-text value"
// TODO: Add code #NUMBER with display "Number" and definition "Numeric value"
// TODO: Add code #BOOLEAN with display "Boolean" and definition "True/false value"
// TODO: Add code #DATE with display "Date" and definition "Date value"

ValueSet: DHIS2DataElementTypeVS
Id: dhis2-data-element-type-vs
Title: "DHIS2 Data Element Type Value Set"
Description: "Value set containing all DHIS2 data element value types."
// TODO: Include all codes from DHIS2DataElementTypeCS

// TODO: Create a profile named DHIS2TypedObservation on Observation
// - Add an extension that carries a code from DHIS2DataElementTypeVS
//   OR bind a suitable element to the value set
