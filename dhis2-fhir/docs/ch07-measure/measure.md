# Measure

A **Measure** resource defines a computable health quality measure, indicator, or aggregate calculation. It does not contain data -- it describes *how* to compute a result. In clinical quality measurement, this might be "percentage of diabetic patients with controlled blood sugar." In public health and DHIS2 contexts, it is more likely "number of confirmed malaria cases" or "ANC coverage rate."

## Key Elements

**url** and **identifier** -- Every Measure needs a canonical URL that uniquely identifies it across systems. For DHIS2, you would typically construct this from the DHIS2 instance URL and the indicator or data set UID, for example `http://dhis2.example.org/fhir/Measure/abc123xyz`.

**status** -- One of `draft`, `active`, `retired`, or `unknown`. Active measures are the ones currently in use for reporting.

**scoring** -- This is the most important structural element. It determines how the measure result is calculated:

| Scoring Type | Meaning | DHIS2 Equivalent |
|---|---|---|
| `proportion` | A ratio where numerator is a subset of denominator (result 0-1) | Indicator with percentage type |
| `ratio` | A ratio where numerator and denominator are independent | Indicator with ratio type |
| `continuous-variable` | A measure based on a continuous value (e.g., median wait time) | Less common in DHIS2 |
| `cohort` | A count of subjects meeting criteria | Simple count data element |

**type** -- Categorizes the measure as `process` (measuring activities), `outcome` (measuring results), or `structure` (measuring capacity/infrastructure). A DHIS2 data set that collects counts of available beds would be `structure`; one that counts treatments delivered would be `process`.

**improvementNotation** -- Indicates whether a higher score means better performance (`increase`) or worse (`decrease`). Malaria case counts would use `decrease`; vaccination coverage would use `increase`.

## Groups and Populations

A Measure contains one or more **group** elements. Each group represents a distinct calculation within the measure. For a simple count measure, there is one group. For a DHIS2 data set with 20 data elements, you might model each data element as a separate group.

Each group contains **population** entries that define the different sets of subjects involved in the calculation:

| Population Type | Purpose |
|---|---|
| `initial-population` | The full set of subjects relevant to the measure |
| `denominator` | The subset used as the base for a proportion or ratio |
| `numerator` | The subset that meets the desired criteria |
| `denominator-exclusion` | Subjects to remove from the denominator |
| `measure-population` | For continuous-variable measures, the population being measured |

Population criteria are expressed using **criteria** elements, which typically contain expressions written in Clinical Quality Language (CQL). CQL is a domain-specific language for clinical logic, but for DHIS2 mappings the criteria often amount to simple filters or counts rather than complex clinical logic. We will not deep-dive into CQL here, but it is worth knowing that this is the standard expression language for FHIR quality measures.

## Example: Malaria Cases (Cohort Measure)

A simple count measure for confirmed malaria cases at a facility during a reporting period:

```json
{
  "resourceType": "Measure",
  "id": "malaria-confirmed-cases",
  "url": "http://dhis2.example.org/fhir/Measure/malaria-confirmed-cases",
  "identifier": [
    {
      "system": "http://dhis2.example.org/fhir/id/indicator",
      "value": "qL5sk40T3e8"
    }
  ],
  "name": "MalariaConfirmedCases",
  "title": "Confirmed Malaria Cases",
  "status": "active",
  "description": "Count of confirmed malaria cases reported by a facility in a given period.",
  "scoring": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/measure-scoring",
        "code": "cohort",
        "display": "Cohort"
      }
    ]
  },
  "type": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/measure-type",
          "code": "outcome",
          "display": "Outcome"
        }
      ]
    }
  ],
  "improvementNotation": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/measure-improvement-notation",
        "code": "decrease",
        "display": "Decreased score indicates improvement"
      }
    ]
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
      "population": [
        {
          "code": {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                "code": "initial-population"
              }
            ]
          },
          "description": "All patients tested for malaria at the facility during the reporting period",
          "criteria": {
            "language": "text/cql-identifier",
            "expression": "Malaria Tested Patients"
          }
        }
      ]
    }
  ]
}
```

## Example: ANC Coverage (Proportion Measure)

A proportion measure for antenatal care coverage, calculating the ratio of ANC visits delivered to expected pregnancies:

```json
{
  "resourceType": "Measure",
  "id": "anc-coverage",
  "url": "http://dhis2.example.org/fhir/Measure/anc-coverage",
  "name": "ANCCoverage",
  "title": "Antenatal Care Coverage",
  "status": "active",
  "description": "Proportion of expected pregnancies that received at least one ANC visit.",
  "scoring": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/measure-scoring",
        "code": "proportion",
        "display": "Proportion"
      }
    ]
  },
  "type": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/measure-type",
          "code": "process",
          "display": "Process"
        }
      ]
    }
  ],
  "improvementNotation": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/measure-improvement-notation",
        "code": "increase",
        "display": "Increased score indicates improvement"
      }
    ]
  },
  "group": [
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/indicators",
            "code": "anc-cov-1",
            "display": "ANC 1st Visit Coverage"
          }
        ]
      },
      "population": [
        {
          "code": {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                "code": "numerator"
              }
            ]
          },
          "description": "Women who received at least one ANC visit",
          "criteria": {
            "language": "text/cql-identifier",
            "expression": "ANC First Visit Count"
          }
        },
        {
          "code": {
            "coding": [
              {
                "system": "http://terminology.hl7.org/CodeSystem/measure-population",
                "code": "denominator"
              }
            ]
          },
          "description": "Expected pregnancies in the catchment area",
          "criteria": {
            "language": "text/cql-identifier",
            "expression": "Expected Pregnancies"
          }
        }
      ]
    }
  ]
}
```

## Mapping to DHIS2

The Measure resource maps to the *definition* side of DHIS2:

- A **DHIS2 Indicator** maps to a Measure with `proportion` or `ratio` scoring. The indicator's numerator and denominator formulas correspond to the population criteria. The indicator type (percentage, per-thousand, etc.) informs the scoring choice.
- A **DHIS2 Data Set** can be represented as a Measure with `cohort` scoring and one group per data element. This treats the data set as a structured collection definition.
- A **DHIS2 Program Indicator** (a calculated metric derived from tracker data) also maps to a Measure, with criteria that reference the tracker data rather than aggregate data elements.

The key insight is that Measure captures the *structure and logic* of what DHIS2 defines through its metadata configuration. The actual numbers belong in MeasureReport, which is covered in the next section.
