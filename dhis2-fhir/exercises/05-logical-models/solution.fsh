// Exercise 05: Logical Models - Solution
// A DHIS2 Tracked Entity Instance logical model.

Logical: DHIS2TrackedEntityInstance
Id: dhis2-tracked-entity-instance
Title: "DHIS2 Tracked Entity Instance"
Description: "Logical model representing a DHIS2 Tracked Entity Instance (TEI) in DHIS2's tracker data model."
* uid 1..1 string "DHIS2 UID" "The 11-character alphanumeric unique identifier assigned by DHIS2."
* orgUnit 1..1 string "Organisation Unit" "The UID of the Organisation Unit where this TEI is registered."
* trackedEntityType 1..1 string "Tracked Entity Type" "The type of tracked entity, e.g., Person, Commodity."
* created 1..1 dateTime "Created" "Timestamp when the TEI was created in DHIS2."
* lastUpdated 1..1 dateTime "Last Updated" "Timestamp when the TEI was last modified."
* inactive 0..1 boolean "Inactive" "Whether the tracked entity instance is marked as inactive."
* attributes 0..* BackboneElement "Attributes" "Tracked entity attribute values associated with this TEI."
* attributes.attribute 1..1 string "Attribute UID" "The UID of the tracked entity attribute."
* attributes.value 1..1 string "Value" "The value of the tracked entity attribute."
