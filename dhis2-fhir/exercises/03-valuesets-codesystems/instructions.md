# Exercise 03: Value Sets and Code Systems

## Objective

Create a FHIR CodeSystem representing DHIS2 data element value types, a ValueSet that includes all codes from that CodeSystem, and demonstrate binding the ValueSet to a profile element.

## Background

DHIS2 data elements have a "value type" that determines what kind of data they accept (text, number, boolean, date, etc.). In FHIR, we represent this as a CodeSystem (the list of codes) and a ValueSet (a selection of codes for use in a binding). Bindings connect a ValueSet to a specific element in a profile, constraining what values are allowed.

## Requirements

1. Create a CodeSystem named `DHIS2DataElementTypeCS`:
   - Id: `dhis2-data-element-type`
   - Include codes: `TEXT`, `NUMBER`, `BOOLEAN`, `DATE`
   - Each code should have a display string and a definition

2. Create a ValueSet named `DHIS2DataElementTypeVS`:
   - Id: `dhis2-data-element-type-vs`
   - Include all codes from `DHIS2DataElementTypeCS`

3. Create a profile named `DHIS2Observation` on Observation that binds `Observation.code.coding.code` or uses the ValueSet in a meaningful way (for example, bind an extension that carries the DHIS2 value type).

## Instructions

1. Open `starter.fsh`
2. Fill in the CodeSystem codes, ValueSet include, and profile binding
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
CodeSystem: CSName
Id: cs-id
Title: "Title"
* #CODE "Display" "Definition"

ValueSet: VSName
Id: vs-id
Title: "Title"
* include codes from system CSName

Profile: ProfileName
Parent: ParentResource
* element from VSName (required)
```
