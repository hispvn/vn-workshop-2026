# Exercise 05: Logical Models

## Objective

Model a DHIS2 Tracked Entity Instance (TEI) as a FHIR Logical Model using FSH.

## Background

Logical Models in FHIR describe data structures that are not FHIR resources. They are useful for documenting external systems' data models within an IG. For DHIS2 integration work, logical models let you formally describe DHIS2 objects (like a TEI) so that mappings to FHIR resources can be defined against a concrete, published structure.

A Logical Model is defined like a profile but uses `Base` or `Element` as its parent and defines all elements from scratch.

## Requirements

Create a Logical Model named `DHIS2TrackedEntityInstance` with the following elements:

| Element | Type | Cardinality | Description |
|---|---|---|---|
| uid | string | 1..1 | The 11-character DHIS2 UID |
| orgUnit | string | 1..1 | Organisation Unit UID where the TEI is registered |
| trackedEntityType | string | 1..1 | The type of tracked entity (e.g., Person) |
| created | dateTime | 1..1 | Creation timestamp |
| lastUpdated | dateTime | 1..1 | Last update timestamp |
| inactive | boolean | 0..1 | Whether the TEI is inactive |
| attributes | BackboneElement | 0..* | Tracked entity attribute values |
| attributes.attribute | string | 1..1 | Attribute UID |
| attributes.value | string | 1..1 | Attribute value |

## Instructions

1. Open `starter.fsh`
2. Add the elements listed above
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
Logical: LogicalModelName
Id: logical-id
Title: "Title"
Description: "Description"
* elementName cardinality type "Short description" "Full definition"
* parent.child cardinality type "Short" "Definition"
```
