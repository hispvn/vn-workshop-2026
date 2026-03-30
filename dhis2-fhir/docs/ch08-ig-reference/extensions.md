# Extensions

Extensions are FHIR's mechanism for adding data elements that are not part of the base resource definition. DHIS2's data model contains several concepts that have no direct equivalent in core FHIR resources, so the IG defines four custom extensions to carry that information.

## Design Principles

The extensions in this IG follow these principles:

1. **Simple where possible** -- Use a single value type (not sub-extensions) when only one piece of data is needed
2. **Complex when necessary** -- Use sub-extensions when multiple related fields must travel together
3. **Context-restricted** -- Each extension declares which resource types may use it
4. **Documented** -- Every extension explains the DHIS2 concept it represents

## DHIS2OrgUnitExtension

**Type:** Simple (single value)
**Value:** `Reference(Organization)`
**Id:** `dhis2-org-unit`

Links a FHIR resource to the DHIS2 organisation unit where it was registered or where the activity took place. In DHIS2, the organisation unit hierarchy is one of the three core dimensions of the data model.

### Context

This extension is allowed on resources where the base FHIR specification does not provide a standard element for the registering/reporting organisation unit:

| Resource | Use Case |
|----------|----------|
| Patient | Registration org unit (where TEI was registered) |
| Encounter | Where the visit happened |
| EpisodeOfCare | Where the enrollment was created |
| Observation | Where the data was recorded |
| QuestionnaireResponse | Where the event was captured |

### FSH Source

```fsh
Extension: DHIS2OrgUnitExtension
Id: dhis2-org-unit
Title: "DHIS2 Organisation Unit"
Description: """
Links a FHIR resource to the DHIS2 organisation unit where it was registered
or where the activity took place.
"""

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

### Usage Example

```fsh
* extension[orgUnit].valueReference = Reference(OrganizationFacilityA)
```

### Generated JSON

```json
{
  "url": "http://dhis2.org/fhir/StructureDefinition/dhis2-org-unit",
  "valueReference": {
    "reference": "Organization/OrganizationFacilityA"
  }
}
```

## DHIS2ProgramExtension

**Type:** Simple (single value)
**Value:** `Coding` from `DHIS2ProgramTypeVS`
**Id:** `dhis2-program`

Identifies which type of DHIS2 program an enrollment (EpisodeOfCare) or event (Encounter) belongs to. DHIS2 has two program types:

- **WITH_REGISTRATION** (Tracker program) -- Requires a registered tracked entity instance (TEI) and supports multiple program stages over time
- **WITHOUT_REGISTRATION** (Event program) -- Captures standalone, anonymous events without individual registration

### Context

| Resource | Use Case |
|----------|----------|
| EpisodeOfCare | Identifies the program type for an enrollment |
| Encounter | Identifies the program type for an event |

### FSH Source

```fsh
Extension: DHIS2ProgramExtension
Id: dhis2-program
Title: "DHIS2 Program"
Description: """
Identifies which type of DHIS2 program an enrollment (EpisodeOfCare) or event
(Encounter) belongs to.
"""

* ^context[0].type = #element
* ^context[=].expression = "EpisodeOfCare"
* ^context[+].type = #element
* ^context[=].expression = "Encounter"

* value[x] only Coding
* value[x] from DHIS2ProgramTypeVS (example)
* value[x] ^short = "The type of DHIS2 program (tracker or event)"
```

### Usage Example

```fsh
* extension[program].valueCoding = DHIS2ProgramTypeCS#WITH_REGISTRATION
```

## DHIS2DataElementExtension

**Type:** Complex (four sub-extensions)
**Id:** `dhis2-data-element`

Links an Observation to its source DHIS2 data element and carries metadata about that data element. This is a **complex extension** because four related attributes must travel together as a cohesive unit.

### Sub-extensions

| Name | Cardinality | Type | Binding | Description |
|------|-------------|------|---------|-------------|
| `dataElementId` | 1..1 | `string` | -- | The 11-character DHIS2 UID |
| `dataElementName` | 0..1 | `string` | -- | Human-readable name |
| `valueType` | 0..1 | `Coding` | `DHIS2DataElementTypeVS` (required) | DHIS2 value type (NUMBER, TEXT, etc.) |
| `aggregationType` | 0..1 | `Coding` | `DHIS2AggregationTypeVS` (required) | How values are aggregated (SUM, AVERAGE, etc.) |

### Context

| Resource | Use Case |
|----------|----------|
| Observation | Links observation to its DHIS2 data element |

### FSH Source

```fsh
Extension: DHIS2DataElementExtension
Id: dhis2-data-element
Title: "DHIS2 Data Element"
Description: """
Links an Observation to its source DHIS2 data element and carries metadata
about that data element.
"""

* ^context[0].type = #element
* ^context[=].expression = "Observation"

* extension contains
    dataElementId 1..1 and
    dataElementName 0..1 and
    valueType 0..1 and
    aggregationType 0..1

* extension[dataElementId].value[x] only string
* extension[dataElementName].value[x] only string
* extension[valueType].value[x] only Coding
* extension[valueType].value[x] from DHIS2DataElementTypeVS (required)
* extension[aggregationType].value[x] only Coding
* extension[aggregationType].value[x] from DHIS2AggregationTypeVS (required)
```

### Usage Example

```fsh
* extension[dataElement].extension[dataElementId].valueString = "qrur9Dvnyt5"
* extension[dataElement].extension[dataElementName].valueString = "Age in years"
* extension[dataElement].extension[valueType].valueCoding = DHIS2DataElementTypeCS#INTEGER
* extension[dataElement].extension[aggregationType].valueCoding = DHIS2AggregationTypeCS#AVERAGE
```

### Generated JSON

```json
{
  "url": "http://dhis2.org/fhir/StructureDefinition/dhis2-data-element",
  "extension": [
    {
      "url": "dataElementId",
      "valueString": "qrur9Dvnyt5"
    },
    {
      "url": "dataElementName",
      "valueString": "Age in years"
    },
    {
      "url": "valueType",
      "valueCoding": {
        "system": "http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-element-type",
        "code": "INTEGER",
        "display": "Integer"
      }
    },
    {
      "url": "aggregationType",
      "valueCoding": {
        "system": "http://dhis2.org/fhir/learning/CodeSystem/dhis2-aggregation-type",
        "code": "AVERAGE",
        "display": "Average"
      }
    }
  ]
}
```

## DHIS2CategoryComboExtension

**Type:** Simple (single value)
**Value:** `string`
**Id:** `dhis2-category-combo`

Identifies the DHIS2 category option combination (COC) that disaggregates a data value. DHIS2's category model is a powerful mechanism for data disaggregation with no direct FHIR equivalent.

### DHIS2 Context

DHIS2 uses a "category model" for data disaggregation. For example, a data element "Number of malaria cases" might be disaggregated by:
- Age group (<5, 5-14, 15+)
- Sex (Male, Female)

Each unique combination (e.g., "Male, <5") is a Category Option Combination identified by a UID. Together with the data element UID, the COC UID forms the complete "what" dimension of a data value.

### Context

| Resource | Use Case |
|----------|----------|
| Observation | Disaggregation category for individual data values |
| MeasureReport | Disaggregation category for aggregated data |

### FSH Source

```fsh
Extension: DHIS2CategoryComboExtension
Id: dhis2-category-combo
Title: "DHIS2 Category Combination"
Description: """
Identifies the DHIS2 category option combination (COC) that disaggregates a
data value.
"""

* ^context[0].type = #element
* ^context[=].expression = "Observation"
* ^context[+].type = #element
* ^context[=].expression = "MeasureReport"

* value[x] only string
* value[x] ^short = "DHIS2 Category Option Combination UID or label"
```

### Why String Instead of Coding?

The extension uses `string` rather than `Coding` because DHIS2 category combos do not have a fixed code system -- they are instance-specific metadata. The value can be either the 11-character DHIS2 UID or a human-readable composite label, depending on implementation preference.

### Usage Example

```fsh
* extension[categoryCombo].valueString = "PT59n8BQbqM"
```

## Extension Summary

| Extension | Type | Value | Contexts | Purpose |
|-----------|------|-------|----------|---------|
| DHIS2OrgUnitExtension | Simple | Reference(Organization) | Patient, Encounter, EpisodeOfCare, Observation, QR | Owning/reporting org unit |
| DHIS2ProgramExtension | Simple | Coding | EpisodeOfCare, Encounter | Program type (tracker/event) |
| DHIS2DataElementExtension | Complex | 4 sub-extensions | Observation | Data element metadata |
| DHIS2CategoryComboExtension | Simple | string | Observation, MeasureReport | Disaggregation category |

## Source File

All four extensions are defined in: `ig/input/fsh/foundation/extensions.fsh`
