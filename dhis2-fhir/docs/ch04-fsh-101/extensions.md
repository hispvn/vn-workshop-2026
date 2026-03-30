# Extensions

FHIR cannot anticipate every data element that every health system needs. **Extensions** let you add custom elements to resources without breaking the standard. If a base resource lacks a field you need -- for instance, a reference to the DHIS2 Organisation Unit that registered a patient -- you define an extension.

Extensions are first-class citizens in FHIR. They appear in the `extension` array of a resource and are identified by a canonical URL. FSH makes defining and using extensions concise.

## Simple vs complex extensions

- A **simple extension** holds a single value (a string, a date, a Reference, etc.).
- A **complex extension** groups multiple sub-extensions under one umbrella, each with its own value.

## Syntax reference

```fsh
Extension:   <name>
Id:          <id>
Title:       "<title>"
Description: "<description>"
Context:     <ResourceType>           // where this extension can be used

* value[x] only <dataType>           // simple extension: restrict the value type
* value[x] 1..1                      // make the value required
```

For complex extensions, you omit `value[x]` at the root and define nested `extension` elements instead.

## Example 1: Simple string extension

A basic extension that captures a registration note as free text.

```fsh
Extension:   RegistrationNote
Id:          registration-note
Title:       "Registration Note"
Description: "A free-text note captured at registration time."
Context:     Patient

* value[x] only string
* valueString 1..1
```

This extension can be applied to any Patient resource. It carries exactly one string value.

## Example 2: DHIS2 Organisation Unit extension

A more practical extension: a reference to the DHIS2 Organisation Unit that owns a resource.

```fsh
Extension:   DHIS2OrgUnit
Id:          dhis2-org-unit
Title:       "DHIS2 Organisation Unit"
Description: "Reference to the DHIS2 Organisation Unit (as a FHIR Organization) associated with this resource."
Context:     Patient, Encounter, Observation

* value[x] only Reference(Organization)
* valueReference 1..1
```

Listing multiple types in `Context` means the extension can appear on Patient, Encounter, or Observation resources. The value is constrained to a Reference that points to an Organization.

## Example 3: Complex extension with sub-extensions

When a single value is not enough, use a complex extension. This one captures DHIS2 enrollment metadata: the program UID, enrollment date, and status.

```fsh
Extension:   DHIS2Enrollment
Id:          dhis2-enrollment
Title:       "DHIS2 Enrollment"
Description: "Captures DHIS2 Tracker enrollment metadata."
Context:     Patient

* extension contains
    program 1..1 and
    enrollmentDate 1..1 and
    status 1..1

* extension[program].value[x] only string
* extension[program] ^short = "DHIS2 program UID"

* extension[enrollmentDate].value[x] only date
* extension[enrollmentDate] ^short = "Date of enrollment"

* extension[status].value[x] only code
* extension[status] ^short = "active | completed | cancelled"
```

Complex extensions have no `value[x]` at the root level. Instead, each sub-extension (accessed via `extension[name]`) carries its own value. SUSHI generates the nested structure automatically.

## Generated output

The simple DHIS2OrgUnit extension produces a StructureDefinition like this (simplified):

```json
{
  "resourceType": "StructureDefinition",
  "id": "dhis2-org-unit",
  "url": "http://example.org/fhir/StructureDefinition/dhis2-org-unit",
  "name": "DHIS2OrgUnit",
  "title": "DHIS2 Organisation Unit",
  "status": "active",
  "kind": "complex-type",
  "type": "Extension",
  "context": [
    { "type": "element", "expression": "Patient" },
    { "type": "element", "expression": "Encounter" },
    { "type": "element", "expression": "Observation" }
  ],
  "differential": {
    "element": [
      {
        "id": "Extension.value[x]",
        "path": "Extension.value[x]",
        "min": 1,
        "type": [
          {
            "code": "Reference",
            "targetProfile": [
              "http://hl7.org/fhir/StructureDefinition/Organization"
            ]
          }
        ]
      }
    ]
  }
}
```

Notice the `context` array: SUSHI translates your `Context:` declaration into structured entries that tell validators where the extension is allowed.

## Using an extension in a profile

Once defined, you apply an extension to a profile with the `extension` keyword:

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"

* extension contains DHIS2OrgUnit named orgUnit 0..1 MS
* extension contains DHIS2Enrollment named enrollment 0..* MS
```

## Key takeaways

- Use simple extensions for single values, complex extensions for grouped data.
- Always declare `Context` so validators know where the extension is allowed.
- Extensions are identified by their canonical URL, making them globally unique.
- FHIR's extension mechanism is what keeps the base standard stable while allowing infinite customization.

## Extensions in This IG

The DHIS2-FHIR Learning IG defines four extensions (in `ig/input/fsh/foundation/extensions.fsh`) to carry DHIS2 metadata that has no standard home in base FHIR resources. Two are simple extensions (single value) and two are complex extensions (sub-extensions).

### DHIS2OrgUnitExtension (simple)

Links a resource to the DHIS2 organisation unit where it was registered or where the activity took place. The value is a Reference to an Organization resource.

```fsh
Extension: DHIS2OrgUnitExtension
Id: dhis2-org-unit
Title: "DHIS2 Organisation Unit"
Description: "Links a FHIR resource to the DHIS2 organisation unit."

* ^context[0].type = #element
* ^context[=].expression = "Patient"
* ^context[+].type = #element
* ^context[=].expression = "Encounter"
* ^context[+].type = #element
* ^context[=].expression = "EpisodeOfCare"
* ^context[+].type = #element
* ^context[=].expression = "Observation"
* ^context[+].type = #element
* ^context[=].expression = "QuestionnaireResponse"

* value[x] only Reference(Organization)
* value[x] ^short = "Reference to the DHIS2 Organisation Unit (as a FHIR Organization)"
```

This is a simple extension: it holds a single `valueReference`. The broad context list (Patient, Encounter, EpisodeOfCare, Observation, QuestionnaireResponse) reflects that DHIS2 org units are associated with many types of data.

### DHIS2ProgramExtension (simple)

Identifies the type of DHIS2 program (tracker vs. event) that an enrollment or encounter belongs to. The value is a Coding from the DHIS2 program type vocabulary.

```fsh
Extension: DHIS2ProgramExtension
Id: dhis2-program
Title: "DHIS2 Program"
Description: "Identifies which type of DHIS2 program an enrollment or event belongs to."

* ^context[0].type = #element
* ^context[=].expression = "EpisodeOfCare"
* ^context[+].type = #element
* ^context[=].expression = "Encounter"

* value[x] only Coding
* value[x] from DHIS2ProgramTypeVS (example)
* value[x] ^short = "The type of DHIS2 program (tracker or event)"
```

Although this has a ValueSet binding, it is still a simple extension -- it carries a single `valueCoding`. The binding strength is `example`, meaning validators will not reject codes outside the ValueSet.

### DHIS2DataElementExtension (complex)

Carries DHIS2 data element metadata on an Observation. This is a complex extension with four sub-extensions, because multiple related attributes (UID, name, value type, aggregation type) must travel together.

```fsh
Extension: DHIS2DataElementExtension
Id: dhis2-data-element
Title: "DHIS2 Data Element"
Description: "Links an Observation to its source DHIS2 data element and carries metadata."

* ^context[0].type = #element
* ^context[=].expression = "Observation"

* extension contains
    dataElementId 1..1 and
    dataElementName 0..1 and
    valueType 0..1 and
    aggregationType 0..1

* extension[dataElementId] ^short = "The 11-character DHIS2 UID of the data element"
* extension[dataElementId].value[x] only string

* extension[dataElementName] ^short = "Human-readable name of the data element"
* extension[dataElementName].value[x] only string

* extension[valueType] ^short = "The DHIS2 value type (e.g., NUMBER, TEXT, BOOLEAN)"
* extension[valueType].value[x] only Coding
* extension[valueType].value[x] from DHIS2DataElementTypeVS (required)

* extension[aggregationType] ^short = "How values are aggregated (e.g., SUM, AVERAGE)"
* extension[aggregationType].value[x] only Coding
* extension[aggregationType].value[x] from DHIS2AggregationTypeVS (required)
```

Key design decisions:
- Only `dataElementId` is required (1..1) -- it is the minimum needed to link back to DHIS2.
- `valueType` and `aggregationType` use `Coding` (not plain `code`) so the code system is always explicit.
- Binding strengths are `required` because these are closed enumerations within DHIS2.

### DHIS2CategoryComboExtension (simple)

Carries the DHIS2 category option combination (COC) that disaggregates a data value. Despite the "combo" name suggesting complexity, this is a simple extension -- it holds a single string value (the COC UID).

```fsh
Extension: DHIS2CategoryComboExtension
Id: dhis2-category-combo
Title: "DHIS2 Category Combination"
Description: "Identifies the DHIS2 category option combination (COC) that disaggregates a data value."

* ^context[0].type = #element
* ^context[=].expression = "Observation"
* ^context[+].type = #element
* ^context[=].expression = "MeasureReport"

* value[x] only string
* value[x] ^short = "DHIS2 Category Option Combination UID or label"
```

The value is a plain string rather than a Coding because DHIS2 category combos are instance-specific metadata -- there is no fixed code system to bind to.

## Exercise

Open `exercises/ch04-extensions/` and complete the exercise. You will define a simple extension for a DHIS2 Tracked Entity Attribute value and then apply it to a Patient profile.
