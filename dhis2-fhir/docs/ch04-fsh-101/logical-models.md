# Logical Models

A **Logical Model** describes a data structure that is not itself a FHIR resource. When you need to formally represent a DHIS2 Tracker payload, a CSV import format, or any external schema, you use a Logical Model. This lets you document, validate, and map non-FHIR structures using the same tooling as the rest of your Implementation Guide.

Logical Models are particularly valuable in the DHIS2-FHIR context because DHIS2 has its own data model (Tracked Entity Instances, Events, Data Values) that does not map one-to-one onto FHIR resources. By expressing the DHIS2 model in FSH, you create a formal bridge that you can then map to FHIR resources.

## Syntax reference

```fsh
Logical:        <name>
Id:             <id>
Title:          "<title>"
Description:    "<description>"
Characteristics: #can-be-target

* <elementName> <cardinality> <dataType> "<short description>"
```

The `Characteristics` keyword is optional:

| Value | Meaning |
|-------|---------|
| `#can-be-target` | Other resources can reference instances of this model. |

If omitted, the logical model is purely structural and cannot be the target of a Reference.

## Example 1: DHIS2 Tracked Entity Instance

A logical model representing the core fields of a DHIS2 Tracked Entity Instance.

```fsh
Logical:        DHIS2TrackedEntityInstance
Id:             dhis2-tracked-entity-instance
Title:          "DHIS2 Tracked Entity Instance"
Description:    "Represents a tracked entity instance from DHIS2 Tracker."
Characteristics: #can-be-target

* uid 1..1 string "DHIS2 UID (11 alphanumeric characters)"
* orgUnit 1..1 string "UID of the registering Organisation Unit"
* trackedEntityType 1..1 string "UID of the Tracked Entity Type"
* created 0..1 dateTime "Creation timestamp"
* lastUpdated 0..1 dateTime "Last modification timestamp"
* attributes 0..* BackboneElement "Tracked entity attribute values"
  * attribute 1..1 string "Attribute UID"
  * value 1..1 string "Attribute value"
* enrollments 0..* BackboneElement "Program enrollments"
  * program 1..1 string "Program UID"
  * enrollmentDate 1..1 date "Date of enrollment"
  * status 1..1 string "ACTIVE | COMPLETED | CANCELLED"
  * orgUnit 1..1 string "Enrollment Organisation Unit UID"
```

Nested elements use indentation to show hierarchy. `BackboneElement` is used for anonymous complex sub-structures that contain child elements.

## Example 2: DHIS2 Data Element

A simpler logical model representing a DHIS2 data element definition.

```fsh
Logical:        DHIS2DataElement
Id:             dhis2-data-element
Title:          "DHIS2 Data Element"
Description:    "Represents a data element definition from DHIS2."

* uid 1..1 string "DHIS2 UID"
* name 1..1 string "Display name"
* shortName 1..1 string "Short name"
* code 0..1 string "Code"
* description 0..1 string "Detailed description"
* valueType 1..1 string "TEXT | NUMBER | BOOLEAN | DATE | etc."
* aggregationType 0..1 string "SUM | AVERAGE | COUNT | NONE"
* domainType 1..1 string "AGGREGATE | TRACKER"
* categoryCombo 0..1 string "Category combination UID"
```

This model does not use `Characteristics: #can-be-target` because nothing needs to reference a data element definition directly.

## Generated output

The Tracked Entity Instance logical model produces a StructureDefinition with `kind: logical`:

```json
{
  "resourceType": "StructureDefinition",
  "id": "dhis2-tracked-entity-instance",
  "url": "http://example.org/fhir/StructureDefinition/dhis2-tracked-entity-instance",
  "name": "DHIS2TrackedEntityInstance",
  "title": "DHIS2 Tracked Entity Instance",
  "status": "active",
  "kind": "logical",
  "type": "http://example.org/fhir/StructureDefinition/dhis2-tracked-entity-instance",
  "baseDefinition": "http://hl7.org/fhir/StructureDefinition/Base",
  "derivation": "specialization",
  "differential": {
    "element": [
      {
        "id": "DHIS2TrackedEntityInstance.uid",
        "path": "DHIS2TrackedEntityInstance.uid",
        "short": "DHIS2 UID (11 alphanumeric characters)",
        "min": 1,
        "max": "1",
        "type": [{ "code": "string" }]
      },
      {
        "id": "DHIS2TrackedEntityInstance.orgUnit",
        "path": "DHIS2TrackedEntityInstance.orgUnit",
        "short": "UID of the registering Organisation Unit",
        "min": 1,
        "max": "1",
        "type": [{ "code": "string" }]
      }
    ]
  }
}
```

Notice `"kind": "logical"` and `"derivation": "specialization"` -- this tells FHIR tooling that this is a custom structure, not a constraint on an existing resource.

## Key takeaways

- Logical Models describe **non-FHIR structures** using FHIR's StructureDefinition framework.
- Use `BackboneElement` for nested complex sub-elements.
- Logical Models pair naturally with **Mappings** (covered in the next section) to document how external data maps to FHIR.
- They appear in your IG as formal documentation, making your data model explicit and machine-readable.

## Exercise

Open `exercises/ch04-logical-models/` and complete the exercise. You will define a logical model for a DHIS2 Event (with fields: uid, program, programStage, orgUnit, eventDate, status, and a list of data values).
