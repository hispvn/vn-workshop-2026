# Value Sets and Code Systems

Terminology is central to interoperability. A **Code System** defines a set of codes and their meanings. A **Value Set** selects codes -- from one or more Code Systems -- that are valid for a particular context. Together they ensure that systems agree on what coded values mean.

In DHIS2 terms, think of a Code System as the full option set definition, and a Value Set as the subset of options allowed for a particular data element.

## Code System syntax

```fsh
CodeSystem:  <name>
Id:          <id>
Title:       "<title>"
Description: "<description>"

* #<code> "<display>"              // define a code
* #<code> "<display>" "<definition>"  // with a longer definition
```

## Value Set syntax

```fsh
ValueSet:    <name>
Id:          <id>
Title:       "<title>"
Description: "<description>"

* include codes from system <CodeSystem>           // include all codes
* <CodeSystem>#<code> "<display>"                  // include specific codes
* exclude <CodeSystem>#<code>                      // exclude specific codes
```

## Binding strengths

When you bind a Value Set to a profile element, you specify how strictly the codes must come from that set:

| Strength | Meaning |
|----------|---------|
| `required` | The code **must** come from this Value Set. No exceptions. |
| `extensible` | The code **should** come from this Value Set, but other codes are allowed if no suitable code exists. |
| `preferred` | The Value Set is recommended but not enforced. |
| `example` | The Value Set is illustrative only. |

## Example 1: DHIS2 Data Element Type Code System

A Code System representing the types of data elements in DHIS2.

```fsh
CodeSystem:  DHIS2DataElementTypeCS
Id:          dhis2-data-element-type-cs
Title:       "DHIS2 Data Element Type Code System"
Description: "Types of data elements in DHIS2."

* #AGGREGATE    "Aggregate"     "Data element used in aggregate data entry forms."
* #TRACKER      "Tracker"       "Data element used in tracker programs."
* #EVENT        "Event"         "Data element used in single-event programs."
* #PREDICTOR    "Predictor"     "Data element populated by a predictor rule."
```

## Example 2: DHIS2 Data Element Type Value Set

A Value Set that includes all codes from the Code System above.

```fsh
ValueSet:    DHIS2DataElementTypeVS
Id:          dhis2-data-element-type-vs
Title:       "DHIS2 Data Element Type Value Set"
Description: "Allowed types for DHIS2 data elements."

* include codes from system DHIS2DataElementTypeCS
```

You can also cherry-pick codes if you need a subset:

```fsh
ValueSet:    DHIS2TrackerElementTypeVS
Id:          dhis2-tracker-element-type-vs
Title:       "DHIS2 Tracker Element Types"
Description: "Data element types relevant to tracker programs."

* DHIS2DataElementTypeCS#TRACKER  "Tracker"
* DHIS2DataElementTypeCS#EVENT    "Event"
```

## Example 3: Binding a Value Set to a profile

Bind the Value Set to an element in a profile using the `from` keyword:

```fsh
Profile:     DHIS2Observation
Parent:      Observation
Id:          dhis2-observation
Title:       "DHIS2 Observation"
Description: "Observation profile for DHIS2 data values."

* status MS
* code 1..1 MS
* category 1..* MS
* category from DHIS2DataElementTypeVS (extensible)
* subject 1..1 MS
* effective[x] 1..1 MS
```

The `(extensible)` binding means implementers should use codes from the Value Set but may add others if the set does not cover their needs.

## Generated output

The Code System above produces JSON like this (simplified):

```json
{
  "resourceType": "CodeSystem",
  "id": "dhis2-data-element-type-cs",
  "url": "http://example.org/fhir/CodeSystem/dhis2-data-element-type-cs",
  "name": "DHIS2DataElementTypeCS",
  "title": "DHIS2 Data Element Type Code System",
  "status": "active",
  "content": "complete",
  "concept": [
    {
      "code": "AGGREGATE",
      "display": "Aggregate",
      "definition": "Data element used in aggregate data entry forms."
    },
    {
      "code": "TRACKER",
      "display": "Tracker",
      "definition": "Data element used in tracker programs."
    },
    {
      "code": "EVENT",
      "display": "Event",
      "definition": "Data element used in single-event programs."
    },
    {
      "code": "PREDICTOR",
      "display": "Predictor",
      "definition": "Data element populated by a predictor rule."
    }
  ]
}
```

## Key takeaways

- **Code Systems define** codes; **Value Sets select** codes for use.
- Binding strength controls how strictly validators enforce terminology.
- Use `required` for elements where deviation would break interoperability (e.g., status codes). Use `extensible` when the list is comprehensive but may need local additions.
- Name your Code Systems with a `CS` suffix and Value Sets with `VS` for clarity. This is a common convention, not a requirement.

## Exercise

Open `exercises/ch04-valuesets-codesystems/` and complete the exercise. You will define a Code System for DHIS2 program types (WITH_REGISTRATION, WITHOUT_REGISTRATION), create a matching Value Set, and bind it to a profile element.
