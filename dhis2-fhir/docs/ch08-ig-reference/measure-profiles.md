# Measure and MeasureReport Profiles

These profiles represent DHIS2's aggregate data model in FHIR. DHIS2 has two core aggregate concepts:

1. **Indicators** -- Calculated values with a numerator and denominator formula (e.g., "ANC coverage = ANC 1st visits / expected pregnancies")
2. **Data Sets** -- Collections of data elements submitted by facilities on a regular schedule (monthly, quarterly)

Both map naturally to FHIR's Measure framework: a Measure defines *what* to count, a MeasureReport records *what was counted* at a specific facility and time period.

## DHIS2Measure

Represents a DHIS2 indicator definition or data set definition.

### DHIS2 Context

DHIS2 indicators have a name, a numerator expression, and a denominator expression. Data sets group multiple data elements into a reporting form. Both translate to FHIR Measure:

- Indicator formula components become population entries (numerator, denominator)
- Each data element in a data set becomes a separate group within the Measure

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `url` | 1..1 MS | Canonical URL |
| `identifier` | 0..* MS | Sliced by system |
| `identifier[dhis2uid]` | 0..1 | System = `$DHIS2-INDICATOR` |
| `name` | 0..1 MS | Machine-friendly name |
| `title` | 1..1 MS | Human-readable name |
| `status` | 1..1 MS | draft, active, retired |
| `description` | 0..1 MS | What the measure evaluates |
| `scoring` | 1..1 MS | proportion, cohort, continuous-variable, ratio |
| `type` | 0..* MS | process, outcome, structure |
| `group` | 1..* MS | Measurable components |
| `group.population` | 0..* MS | Population definitions |
| `group.population.code` | 0..1 MS | Population role |
| `group.population.criteria` | 0..1 MS | Selection expression |

### Scoring Types

The `scoring` element determines how the measure is calculated:

| Scoring | DHIS2 Context | Example |
|---------|---------------|---------|
| proportion | Indicator with numerator/denominator | ANC coverage rate |
| cohort | Simple count of a population | Number of malaria cases |
| continuous-variable | Aggregated continuous values | Average wait time |
| ratio | Numerator/denominator with overlap | Test positivity rate |

### FSH Source

```fsh
Profile: DHIS2Measure
Parent: Measure
Id: dhis2-measure
Title: "DHIS2 Measure"
Description: """
Represents a DHIS2 indicator definition or data set definition.
"""

* url 1..1 MS

* identifier MS
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains dhis2uid 0..1
* identifier[dhis2uid].system = $DHIS2-INDICATOR
* identifier[dhis2uid].value 1..1

* name MS
* title 1..1 MS
* status MS
* description MS

* scoring 1..1 MS
* scoring from http://hl7.org/fhir/ValueSet/measure-scoring (required)

* type MS

* group 1..* MS
* group.population MS
* group.population.code MS
* group.population.criteria MS
```

## DHIS2MeasureReport

Represents a DHIS2 aggregate data submission or indicator value for a specific organisation unit and reporting period.

### The Subject Constraint: Location, Not Organization

In FHIR R4, `MeasureReport.subject` does **not** allow direct Organization references. This is a FHIR R4 constraint, not a DHIS2 limitation. The profile uses `Reference(Location or Group)` for the subject:

- **Location** -- References a DHIS2Location which links to its DHIS2Organization via `managingOrganization`
- **Group** -- For population-level reporting

The `reporter` element uses `Reference(Organization)` to identify who submitted the data.

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `status` | 1..1 MS | complete, pending, error |
| `type` | 1..1 MS | summary, individual, data-collection |
| `measure` | 1..1 MS | Canonical URL of the Measure definition |
| `subject` | 1..1 MS | Reference(Location or Group) -- NOT Organization |
| `date` | 0..1 MS | When the report was generated |
| `period` | 1..1 MS | Reporting period |
| `reporter` | 0..1 MS | Reference(Organization) -- who submitted |
| `group` | 1..* MS | Reported data |
| `group.population` | 0..* MS | Population counts |
| `group.population.count` | 0..1 MS | Reported numeric value |
| `group.measureScore` | 0..1 MS | Calculated indicator value |

### FSH Source

```fsh
Profile: DHIS2MeasureReport
Parent: MeasureReport
Id: dhis2-measure-report
Title: "DHIS2 Measure Report"
Description: """
Represents a DHIS2 aggregate data submission or indicator value for a
specific organisation unit and reporting period.
"""

* status MS
* type 1..1 MS
* measure 1..1 MS

* subject 1..1 MS
* subject only Reference(Location or Group)

* date MS
* period 1..1 MS

* reporter MS
* reporter only Reference(Organization)

* group 1..* MS
* group.population MS
* group.population.count MS
* group.measureScore MS
```

## DHIS2DataCollectionReport

A specialized profile for DHIS2 data set reports -- the monthly or quarterly facility submissions that form the backbone of DHIS2 aggregate reporting.

### Key Difference from DHIS2MeasureReport

The `type` is fixed to `#data-collection`, meaning it captures raw reported counts rather than calculated indicator values. Each group represents a single data element in the data set, with the reported value in `group.population.count`.

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `type` | Fixed: `#data-collection` | Always data-collection |
| `measure` | 1..1 MS | Data set definition |
| `subject` | 1..1 MS | Reference(Location or Group) |
| `reporter` | 0..1 MS | Reference(Organization) |
| `date` | 0..1 MS | When submitted |
| `period` | 1..1 MS | Reporting period |
| `group` | 1..* MS | One group per data element |
| `group.code` | 0..1 MS | Data element identifier |
| `group.population` | 0..* MS | Reported values |
| `group.population.count` | 0..1 MS | The actual reported number |

### FSH Source

```fsh
Profile: DHIS2DataCollectionReport
Parent: MeasureReport
Id: dhis2-data-collection-report
Title: "DHIS2 Data Collection Report"
Description: """
Represents a DHIS2 data set submission -- the monthly or quarterly aggregate
data that facilities report through DHIS2 data entry forms.
"""

* status MS
* type = #data-collection

* measure 1..1 MS

* subject 1..1 MS
* subject only Reference(Location or Group)

* reporter MS
* reporter only Reference(Organization)

* date MS
* period 1..1 MS

* group 1..* MS
* group.code MS
* group.population MS
* group.population.count MS
```

## DHIS2 Aggregate Workflow in FHIR

A typical monthly reporting cycle:

1. A **DHIS2Measure** defines the data set structure (which data elements to collect)
2. A facility data clerk fills in the monthly form in DHIS2
3. The submission becomes a **DHIS2DataCollectionReport** with:
   - `subject` = the facility's Location
   - `period` = the reporting month
   - `group` entries for each data element with reported counts
4. District managers review aggregated **DHIS2MeasureReport** instances (type = summary) that combine data from multiple facilities

## Source Files

- Profile definitions: `ig/input/fsh/measure/profiles.fsh`
- Measure definitions: `ig/input/fsh/measure/measure-definitions.fsh`
- MeasureReport examples: `ig/input/fsh/measure/measure-report-examples.fsh`
