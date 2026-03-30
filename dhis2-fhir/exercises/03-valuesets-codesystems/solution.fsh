// Exercise 03: Value Sets and Code Systems - Solution
// A CodeSystem, ValueSet, and profile binding for DHIS2 data element types.

CodeSystem: DHIS2DataElementTypeCS
Id: dhis2-data-element-type
Title: "DHIS2 Data Element Type Code System"
Description: "Code system for DHIS2 data element value types."
* #TEXT "Text" "Free-text value"
* #NUMBER "Number" "Numeric value"
* #BOOLEAN "Boolean" "True/false value"
* #DATE "Date" "Date value"

ValueSet: DHIS2DataElementTypeVS
Id: dhis2-data-element-type-vs
Title: "DHIS2 Data Element Type Value Set"
Description: "Value set containing all DHIS2 data element value types."
* include codes from system DHIS2DataElementTypeCS

Extension: DHIS2DataElementType
Id: dhis2-data-element-type-ext
Title: "DHIS2 Data Element Type"
Description: "The DHIS2 value type of the data element this observation represents."
Context: Observation
* value[x] only CodeableConcept
* valueCodeableConcept from DHIS2DataElementTypeVS (required)

Profile: DHIS2TypedObservation
Parent: Observation
Id: dhis2-typed-observation
Title: "DHIS2 Typed Observation"
Description: "An Observation profile that carries the DHIS2 data element value type."
* extension contains DHIS2DataElementType named dataElementType 0..1 MS
* status MS
* code 1..1 MS
* subject 1..1 MS
* value[x] MS
