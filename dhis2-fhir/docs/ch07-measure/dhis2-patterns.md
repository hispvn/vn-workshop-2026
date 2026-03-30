# DHIS2-Specific Patterns

This section covers practical patterns for mapping DHIS2 aggregate and event data to FHIR Measure and MeasureReport. Each pattern addresses a specific DHIS2 use case and shows how to represent it using the resources introduced in the previous sections.

## Pattern 1: Aggregate Data Set to Measure + MeasureReport

A DHIS2 **Data Set** is a structured form that facilities fill out periodically. A monthly malaria report might contain 15 data elements for confirmed cases, tested cases, treatments administered, and stock levels. The data set itself defines *what* to collect, and each monthly submission contains the actual numbers.

In FHIR, the data set definition maps to a **Measure** with one `group` per data element. The `scoring` is typically `cohort` since each data element is an independent count. Each monthly submission from a facility maps to a **MeasureReport** with `type: data-collection`, where each group carries the reported value in `measureScore`.

This pattern is the workhorse for DHIS2 aggregate data exchange. It handles the most common integration scenario: getting routine facility reports into a FHIR-based system.

## Pattern 2: Indicators to Measure

A DHIS2 **Indicator** defines a calculated metric with a numerator, denominator, and optional factor (percentage, per-thousand, etc.). For example: "Malaria positivity rate = confirmed cases / tested cases * 100."

This maps directly to a **Measure** with `proportion` or `ratio` scoring. The numerator and denominator criteria reference the underlying data elements. The indicator type determines the scoring:

- Percentage indicators use `proportion` scoring (result between 0 and 1).
- Per-thousand or per-ten-thousand indicators use `ratio` scoring.
- Simple aggregation indicators (sums, counts) use `cohort` scoring.

The calculated value for a given facility and period becomes a **MeasureReport** with `type: summary` and a `measureScore` reflecting the computed result.

## Pattern 3: Program Indicators to Measure

DHIS2 **Program Indicators** compute metrics from tracker data. For example, "average number of days between HIV diagnosis and ART initiation" or "count of patients with viral load below 1000." These differ from aggregate indicators because they derive from individual-level event data rather than pre-aggregated counts.

The mapping is conceptually the same as Pattern 2 -- a Measure with appropriate scoring and criteria. The difference is that the criteria expressions reference tracker data (events, enrollments, tracked entity attributes) rather than aggregate data elements. The CQL expressions or equivalent logic would filter and aggregate individual patient records.

The resulting MeasureReport can be `summary` (showing the aggregated result) or `subject-list` (listing the individual patients who contributed to the count, which is useful for verification and follow-up).

## Pattern 4: Event Reports to MeasureReport

DHIS2 **Event Reports** produce tabular outputs from tracker or event data, often as line lists. For example, "all patients who tested positive for malaria this month at Facility Alpha" is an event report.

In FHIR, this maps to a **MeasureReport** with `type: subject-list`. The report includes the aggregate count in the population section and can reference a `List` resource containing the individual subjects (patients) who met the criteria. This enables both the aggregate view (47 positive cases) and the drill-down (here are the 47 patients).

## Concept Mapping Table

This table summarizes how DHIS2 aggregate reporting concepts map to FHIR resources:

| DHIS2 Concept | FHIR Resource | Notes |
|---|---|---|
| Data Set | Measure (`scoring: cohort`) | One group per data element; type `structure` or `process` |
| Data Element | Measure.group | Each data element becomes a group with a coded identifier |
| Data Value Set | MeasureReport (`type: data-collection`) | One report per facility per period |
| Data Value | MeasureReport.group.measureScore | The reported number for a single data element |
| Indicator | Measure (`scoring: proportion` or `ratio`) | Numerator/denominator in population criteria |
| Indicator Value | MeasureReport (`type: summary`) | measureScore holds the calculated result |
| Program Indicator | Measure (with tracker-based criteria) | Criteria reference event/enrollment data |
| Organisation Unit | MeasureReport.subject | `Reference(Organization)` or `Reference(Location)` |
| Period | MeasureReport.period | `start` and `end` dates matching the DHIS2 period |
| Category Option Combo | Measure.group.stratifier | Disaggregation dimensions (age, sex, etc.) |

## Worked Example: Monthly Malaria Report

Consider a DHIS2 monthly malaria data set with three data elements:

1. **Malaria Tested** (code: `mal-tested`) -- number of patients tested for malaria
2. **Malaria Confirmed** (code: `mal-confirmed`) -- number of confirmed cases
3. **Malaria Positivity Rate** (code: `mal-positivity`) -- confirmed / tested * 100

### The Measure (Data Set Definition)

```json
{
  "resourceType": "Measure",
  "id": "malaria-monthly-dataset",
  "url": "http://dhis2.example.org/fhir/Measure/malaria-monthly-dataset",
  "name": "MalariaMonthlyDataset",
  "title": "Monthly Malaria Reporting Data Set",
  "status": "active",
  "scoring": {
    "coding": [
      {
        "system": "http://terminology.hl7.org/CodeSystem/measure-scoring",
        "code": "cohort"
      }
    ]
  },
  "group": [
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/data-elements",
            "code": "mal-tested",
            "display": "Patients tested for malaria"
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
          "criteria": {
            "language": "text/cql-identifier",
            "expression": "Malaria Tested"
          }
        }
      ]
    },
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/data-elements",
            "code": "mal-confirmed",
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
          "criteria": {
            "language": "text/cql-identifier",
            "expression": "Malaria Confirmed"
          }
        }
      ]
    }
  ]
}
```

Note that the positivity rate (an indicator) would be a separate Measure with `proportion` scoring, referencing the same underlying data elements as numerator and denominator.

### The MeasureReport (Facility Submission)

Facility Alpha submits their January 2024 data: 312 tested, 47 confirmed.

```json
{
  "resourceType": "MeasureReport",
  "id": "malaria-monthly-facility-alpha-2024-01",
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
    "reference": "Organization/facility-alpha"
  },
  "group": [
    {
      "code": {
        "coding": [
          {
            "system": "http://dhis2.example.org/fhir/CodeSystem/data-elements",
            "code": "mal-tested"
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
            "code": "mal-confirmed"
          }
        ]
      },
      "measureScore": {
        "value": 47
      }
    }
  ]
}
```

A separate summary MeasureReport could then report the positivity rate: measureScore of 0.15 (47 / 312) with numerator count 47 and denominator count 312.

## Challenges and Considerations

### Flat vs. hierarchical structure

DHIS2 data value sets are flat: each row is a tuple of (data element, org unit, period, category option combo, value). Measure and MeasureReport impose hierarchy: groups contain populations, populations have codes and counts. Translating between these structures requires a mapping layer that knows how to assemble flat DHIS2 tuples into the nested FHIR structure and disassemble them on the way back.

### Period representation

DHIS2 uses period codes like `202401` (January 2024) or `2024Q1` (first quarter 2024). FHIR uses explicit `start` and `end` dates in ISO 8601 format. Your integration layer needs a period-code-to-date-range converter. Be careful with end dates: DHIS2 periods are inclusive, so January 2024 runs from `2024-01-01` to `2024-01-31`, not `2024-02-01`.

### Category option combinations

DHIS2 disaggregates data using category option combinations. A data element "malaria confirmed" might be disaggregated by age group (under-5, 5-and-over) and sex (male, female), producing four separate data values. In FHIR, this disaggregation maps to **stratifier** elements on the Measure and **stratum** elements on the MeasureReport group. This can make the FHIR representation significantly more verbose than the DHIS2 equivalent.

### Organisation unit hierarchy

DHIS2 has a deep org unit hierarchy (country, region, district, facility). A single MeasureReport references one org unit. If you need to represent aggregated data at higher levels (district totals), you create separate MeasureReports for each level. FHIR does not natively aggregate MeasureReports up a hierarchy the way DHIS2 analytics does -- that aggregation logic must live in your integration or analytics layer.

### Data element grouping

Some DHIS2 data sets contain dozens or even hundreds of data elements. Representing each as a `group` in a single Measure produces very large resources. In practice, you may want to split large data sets into multiple Measures organized by section, or accept that some Measures will be large and optimize your processing accordingly.
