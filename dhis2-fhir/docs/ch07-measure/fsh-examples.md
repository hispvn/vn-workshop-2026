# FSH Examples for Measure and MeasureReport

This section demonstrates how to define FHIR profiles and example instances for Measure and MeasureReport using FHIR Shorthand (FSH). These profiles constrain the base resources for the DHIS2 aggregate data use case, and the instances show concrete examples with actual data. All examples here are for learning purposes -- a production Implementation Guide would include additional constraints, terminology bindings, and documentation.

## Profile: DHIS2Measure

This profile constrains the Measure resource to require the elements that every DHIS2-derived measure definition must carry: a canonical URL, a status, a scoring type, and at least one group.

```fsh
Profile:     DHIS2Measure
Parent:      Measure
Id:          dhis2-measure
Title:       "DHIS2 Measure"
Description: "Profile for Measure resources representing DHIS2 indicators and data set definitions."

* url 1..1 MS
* identifier MS
* identifier.system 1..1
* identifier.value 1..1
* name 1..1 MS
* status 1..1 MS
* scoring 1..1 MS
* group 1..* MS
* group.code 1..1 MS
* group.code.coding 1..* MS
* group.population MS
```

Key constraints explained:

- `url 1..1 MS` -- Every DHIS2 Measure must have a canonical URL. This URL uniquely identifies the indicator or data set definition and is referenced by MeasureReports.
- `identifier MS` with required `system` and `value` -- Carries the DHIS2 UID for the indicator or data set, with the system URI identifying the DHIS2 instance.
- `scoring 1..1 MS` -- Required because the scoring type determines how the measure result is interpreted (cohort, proportion, ratio).
- `group 1..* MS` -- At least one group is required. For data sets, each group represents a data element. For indicators, a single group typically holds the numerator and denominator populations.
- `group.code 1..1 MS` -- Each group must be coded so that consumers can identify which data element or indicator component it represents.

## Profile: DHIS2MeasureReport

This profile constrains MeasureReport for DHIS2 aggregate data submissions and indicator results.

```fsh
Profile:     DHIS2MeasureReport
Parent:      MeasureReport
Id:          dhis2-measure-report
Title:       "DHIS2 Measure Report"
Description: "Profile for MeasureReport resources representing DHIS2 data value sets and indicator values."

* status 1..1 MS
* type 1..1 MS
* measure 1..1 MS
* subject 1..1 MS
* subject only Reference(Organization or Location)
* date 1..1 MS
* period 1..1 MS
* period.start 1..1
* period.end 1..1
* reporter MS
* reporter only Reference(Organization)
* group 1..* MS
* group.code 1..1 MS
* group.measureScore MS
```

Key constraints explained:

- `subject 1..1 MS` and `subject only Reference(Organization or Location)` -- Every DHIS2 report must identify the reporting facility. The subject is constrained to Organization or Location since aggregate reports are always about a facility or administrative unit, not an individual patient.
- `period 1..1 MS` with required `start` and `end` -- The reporting period is mandatory and must have explicit boundaries. This ensures unambiguous mapping to DHIS2's period codes.
- `measure 1..1 MS` -- The canonical reference to the Measure definition is required so that consumers know which data set or indicator this report corresponds to.
- `reporter only Reference(Organization)` -- The reporting entity must be an Organization, reflecting the fact that DHIS2 data submissions come from facilities.
- `group 1..* MS` -- At least one group of reported data is required.

## Instance: Example Malaria Measure

An example instance demonstrating a cohort Measure for confirmed malaria case counting:

```fsh
Instance:    ExampleMalariaMeasure
InstanceOf:  DHIS2Measure
Title:       "Example - Malaria Confirmed Cases Measure"
Description: "Measure definition for counting confirmed malaria cases."
Usage:       #example

* url = "http://dhis2.example.org/fhir/Measure/malaria-confirmed-cases"
* identifier[0].system = "http://dhis2.example.org/fhir/id/indicator"
* identifier[0].value = "qL5sk40T3e8"
* name = "MalariaConfirmedCases"
* title = "Confirmed Malaria Cases"
* status = #active
* scoring = http://terminology.hl7.org/CodeSystem/measure-scoring#cohort "Cohort"
* type = http://terminology.hl7.org/CodeSystem/measure-type#outcome "Outcome"
* improvementNotation = http://terminology.hl7.org/CodeSystem/measure-improvement-notation#decrease "Decreased score indicates improvement"
* group[0].code = http://dhis2.example.org/fhir/CodeSystem/data-elements#mal001 "Confirmed malaria cases"
* group[0].population[0].code = http://terminology.hl7.org/CodeSystem/measure-population#initial-population
* group[0].population[0].criteria.language = #text/cql-identifier
* group[0].population[0].criteria.expression = "Malaria Confirmed Cases"
```

When you run `sushi .`, this instance produces a Measure JSON resource that conforms to the DHIS2Measure profile. The key parts of the generated output are the `scoring`, `group`, and `population` structures shown in the JSON examples in the previous sections.

## Instance: Example MeasureReport with Data

An example instance showing a completed monthly report from a facility:

```fsh
Instance:    ExampleMalariaMeasureReport
InstanceOf:  DHIS2MeasureReport
Title:       "Example - Malaria Report from Facility Alpha, January 2024"
Description: "Monthly malaria data submission from Facility Alpha."
Usage:       #example

* status = #complete
* type = #data-collection
* measure = "http://dhis2.example.org/fhir/Measure/malaria-confirmed-cases"
* subject = Reference(Organization/facility-alpha) "Facility Alpha"
* date = "2024-02-05"
* period.start = "2024-01-01"
* period.end = "2024-01-31"
* reporter = Reference(Organization/facility-alpha) "Facility Alpha"
* group[0].code = http://dhis2.example.org/fhir/CodeSystem/data-elements#mal001 "Confirmed malaria cases"
* group[0].measureScore.value = 47
* group[+].code = http://dhis2.example.org/fhir/CodeSystem/data-elements#mal002 "Patients tested for malaria"
* group[=].measureScore.value = 312
```

Notice the FSH indexing syntax: `group[0]` references the first group, `group[+]` creates a new group, and `group[=]` continues referencing the current group. This is how FSH handles repeating elements cleanly.

## Generated JSON (Key Parts)

Running `sushi .` on the MeasureReport instance above produces JSON that includes:

```json
{
  "resourceType": "MeasureReport",
  "id": "ExampleMalariaMeasureReport",
  "meta": {
    "profile": [
      "http://example.org/fhir/StructureDefinition/dhis2-measure-report"
    ]
  },
  "status": "complete",
  "type": "data-collection",
  "measure": "http://dhis2.example.org/fhir/Measure/malaria-confirmed-cases",
  "subject": {
    "reference": "Organization/facility-alpha",
    "display": "Facility Alpha"
  },
  "date": "2024-02-05",
  "period": {
    "start": "2024-01-01",
    "end": "2024-01-31"
  },
  "group": [
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/data-elements",
            "code": "mal001",
            "display": "Confirmed malaria cases"
          }
        ]
      },
      "measureScore": {
        "value": 47
      }
    },
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/data-elements",
            "code": "mal002",
            "display": "Patients tested for malaria"
          }
        ]
      },
      "measureScore": {
        "value": 312
      }
    }
  ]
}
```

The `meta.profile` array confirms that this instance claims conformance to the DHIS2MeasureReport profile. Validators will check the instance against the profile's constraints -- verifying that `subject`, `period`, `measure`, and `group` are all present and correctly typed.

## Tips for Building Your Own Profiles

**Start with the data-collection pattern.** If you are mapping DHIS2 aggregate data, the `data-collection` type MeasureReport with one group per data element is the most straightforward pattern. Add `summary` type reports later for indicator values.

**Use consistent code systems.** Define a CodeSystem for your DHIS2 data elements and use it consistently across Measure group codes and MeasureReport group codes. This makes it possible to match reported data back to the correct data element definition.

**Consider stratifiers for disaggregation.** If your DHIS2 data elements are disaggregated by category option combinations (age, sex, etc.), explore the `stratifier` element on Measure and the `stratum` element on MeasureReport.group. This is more complex but preserves the disaggregation structure that DHIS2 relies on for analytics.

**Validate early and often.** Run `sushi .` after every change to catch FSH syntax errors. Use the HL7 FHIR Validator to check generated instances against your profiles. Catching structural issues early saves significant debugging time later.
