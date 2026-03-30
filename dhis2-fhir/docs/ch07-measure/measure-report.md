# MeasureReport

While a Measure defines *what* to calculate, a **MeasureReport** contains the actual results. It reports the numbers: counts, scores, and population breakdowns for a specific subject (typically a facility or district) over a specific time period. If the Measure is the form, the MeasureReport is the completed form with data filled in.

## Key Elements

**status** -- `complete`, `pending`, `error`. Most reports from DHIS2 would be `complete` since the data has already been submitted and validated.

**type** -- This determines the nature of the report and is critical for mapping DHIS2 data correctly:

| Type | Purpose | DHIS2 Mapping |
|---|---|---|
| `summary` | Aggregate counts and scores with no individual-level detail | Indicator analytics output, aggregated values |
| `individual` | Evaluation of a measure for a single patient | Single tracker entity evaluation |
| `subject-list` | Like summary, but includes a list of subjects that contributed | Event reports with line lists |
| `data-collection` | Raw data submission, not tied to quality evaluation | Data Value Set submission (monthly reports) |

The `data-collection` type is particularly important for DHIS2. It represents a raw data submission rather than a quality measure evaluation -- which is exactly what a facility monthly report is.

**measure** -- A canonical reference to the Measure definition that this report is based on.

**subject** -- Who or what this report is about. For DHIS2 aggregate data, this is typically a `Reference(Organization)` or `Reference(Location)` pointing to the reporting facility. For individual evaluations, it would be a `Reference(Patient)`.

**date** -- When the report was generated or submitted.

**period** -- The time window the report covers. In DHIS2, this maps directly to the reporting period (e.g., January 2024 for a monthly report).

**reporter** -- The entity submitting the report, typically the reporting organization.

**group** -- Mirrors the group structure of the referenced Measure. Each group contains **population** entries with actual `count` values and a **measureScore** with the calculated result.

## Example: Malaria Cases Summary Report

A summary MeasureReport for the malaria cohort measure, reporting 47 confirmed cases from Facility Alpha in January 2024:

```json
{
  "resourceType": "MeasureReport",
  "id": "malaria-report-facility-alpha-2024-01",
  "status": "complete",
  "type": "summary",
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
  "reporter": {
    "reference": "Organization/facility-alpha",
    "display": "Facility Alpha"
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
          "count": 47
        }
      ],
      "measureScore": {
        "value": 47,
        "unit": "cases",
        "system": "http://unitsofmeasure.org",
        "code": "{count}"
      }
    }
  ]
}
```

## Example: ANC Coverage Proportion Report

A summary MeasureReport for the ANC coverage proportion measure, showing 120 first visits out of 150 expected pregnancies (80% coverage):

```json
{
  "resourceType": "MeasureReport",
  "id": "anc-coverage-report-facility-alpha-2024-01",
  "status": "complete",
  "type": "summary",
  "measure": "http://dhis2.example.org/fhir/Measure/anc-coverage",
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
          "count": 120
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
          "count": 150
        }
      ],
      "measureScore": {
        "value": 0.80,
        "unit": "score",
        "system": "http://unitsofmeasure.org",
        "code": "1"
      }
    }
  ]
}
```

The `measureScore` of 0.80 represents the calculated proportion: 120 / 150 = 80%. The individual population counts for numerator and denominator are also preserved, allowing consumers to reconstruct the calculation.

## Example: Data-Collection MeasureReport (DHIS2 Monthly Facility Report)

The `data-collection` type is the closest fit for a standard DHIS2 data set submission. Here a facility submits its monthly malaria report containing three data elements:

```json
{
  "resourceType": "MeasureReport",
  "id": "monthly-malaria-report-facility-alpha-2024-01",
  "status": "complete",
  "type": "data-collection",
  "measure": "http://dhis2.example.org/fhir/Measure/malaria-monthly-dataset",
  "subject": {
    "reference": "Organization/facility-alpha",
    "display": "Facility Alpha"
  },
  "date": "2024-02-03",
  "period": {
    "start": "2024-01-01",
    "end": "2024-01-31"
  },
  "reporter": {
    "reference": "Organization/facility-alpha",
    "display": "Facility Alpha"
  },
  "group": [
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/data-elements",
            "code": "mal001",
            "display": "Malaria cases confirmed"
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
            "display": "Malaria cases tested"
          }
        ]
      },
      "measureScore": {
        "value": 312
      }
    },
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/data-elements",
            "code": "mal003",
            "display": "Malaria RDT stock (remaining)"
          }
        ]
      },
      "measureScore": {
        "value": 580
      }
    }
  ]
}
```

This pattern maps each DHIS2 data element to a separate `group` within the MeasureReport. The `measureScore` carries the reported value. This is a pragmatic use of MeasureReport that closely mirrors how DHIS2 data value sets are structured: a flat collection of data element values for a given facility and period.

## Mapping to DHIS2

| MeasureReport Element | DHIS2 Concept |
|---|---|
| `type: data-collection` | Data Value Set (periodic facility submission) |
| `type: summary` | Analytics output (calculated indicator value) |
| `measure` | Reference to the Data Set or Indicator definition |
| `subject` | Organisation Unit (the reporting facility) |
| `period` | Reporting period (monthly, quarterly, yearly) |
| `reporter` | The submitting Organisation Unit or user |
| `group[n].code` | Data Element identifier |
| `group[n].measureScore` | Data Value (the actual reported number) |
| `group[n].population[n].count` | Numerator or denominator count for indicators |

The `data-collection` type maps to raw data submissions (what DHIS2 calls a Data Value Set), while `summary` maps to pre-calculated analytics output. This distinction aligns with how DHIS2 separates data entry from analytics: facilities submit raw values, and the DHIS2 analytics engine computes the indicators.
