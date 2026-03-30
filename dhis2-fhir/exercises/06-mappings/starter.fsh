// Exercise 06: Mappings - Starter File
// Create a mapping from DHIS2 TEI to FHIR Patient.

// First, include the logical model (or assume it exists from Exercise 05)
Logical: DHIS2TrackedEntityInstance
Id: dhis2-tracked-entity-instance
Title: "DHIS2 Tracked Entity Instance"
Description: "Logical model for a DHIS2 TEI."
* uid 1..1 string "DHIS2 UID" "The 11-character DHIS2 UID."
* orgUnit 1..1 string "Organisation Unit" "Org unit UID."
* trackedEntityType 1..1 string "Tracked Entity Type" "Entity type."
* created 1..1 dateTime "Created" "Creation timestamp."
* lastUpdated 1..1 dateTime "Last Updated" "Last update timestamp."
* inactive 0..1 boolean "Inactive" "Whether inactive."
* attributes 0..* BackboneElement "Attributes" "TEI attribute values."
* attributes.attribute 1..1 string "Attribute UID" "Attribute identifier."
* attributes.value 1..1 string "Value" "Attribute value."

Mapping: DHIS2TEItoPatient
Source: DHIS2TrackedEntityInstance
// TODO: Set Target to the FHIR Patient StructureDefinition URI
// TODO: Set Id to dhis2-tei-to-patient
// TODO: Set Title
// TODO: Map uid -> Patient.identifier.value
// TODO: Map orgUnit -> Patient.managingOrganization.reference
// TODO: Map attributes (firstName) -> Patient.name.given
// TODO: Map attributes (lastName) -> Patient.name.family
// TODO: Map attributes (dateOfBirth) -> Patient.birthDate
// TODO: Map attributes (gender) -> Patient.gender
