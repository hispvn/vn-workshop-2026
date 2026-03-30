// Exercise 06: Mappings - Solution
// Mapping from DHIS2 TEI logical model to FHIR Patient.

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
Target: "http://hl7.org/fhir/StructureDefinition/Patient"
Id: dhis2-tei-to-patient
Title: "DHIS2 TEI to FHIR Patient Mapping"
* uid -> "Patient.identifier.value" "DHIS2 UID maps to Patient identifier"
* orgUnit -> "Patient.managingOrganization.reference" "Org unit becomes managing organization reference"
* attributes -> "Patient" "TEI attributes map to various Patient elements"
* attributes.value -> "Patient.name.given" "First name attribute maps to given name (where attribute = firstName)"
* attributes.value -> "Patient.name.family" "Last name attribute maps to family name (where attribute = lastName)"
* attributes.value -> "Patient.birthDate" "Date of birth attribute (where attribute = dateOfBirth)"
* attributes.value -> "Patient.gender" "Gender attribute (where attribute = gender)"
