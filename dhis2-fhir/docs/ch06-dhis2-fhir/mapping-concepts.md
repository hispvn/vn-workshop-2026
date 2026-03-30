# Mapping DHIS2 Concepts to FHIR Resources

This section maps the core DHIS2 tracker and metadata objects to FHIR resources. The goal is not a one-size-fits-all prescription but a reference starting point that you can adapt to your specific use case and national context.

## Mapping Overview

| DHIS2 Concept | FHIR Resource | Notes |
|---|---|---|
| Tracked Entity Instance (Person) | Patient | The most direct mapping. TEI attributes map to Patient elements and extensions. |
| Enrollment | EpisodeOfCare | An enrollment represents a patient's participation in a program over time. |
| Event | QuestionnaireResponse | Each event is a submitted form; the primary mapping preserves form structure. Encounter may supplement with visit context. |
| Program Stage | Questionnaire | The form definition: data elements become items, option sets become answer bindings. |
| Data Element / TEI Attribute | Observation | Individual data values captured in events or on the TEI (used when clinical resources are needed). |
| Organisation Unit | Organization / Location | Org units map to Organization for the administrative entity, Location for the physical facility. |
| Program | PlanDefinition | A program definition maps to PlanDefinition; program stages map to PlanDefinition.action. |
| DataSet | Measure | Defines which aggregate data elements are collected for a period and org unit. |
| DataValueSet | MeasureReport (data-collection) | Submitted aggregate values for a reporting period. |
| Indicator | Measure (with scoring) | A calculated metric with numerator, denominator, and indicator type. |
| Indicator Value | MeasureReport (summary) | The computed indicator value for a given period and org unit. |

## Tracked Entity Instance to Patient

A DHIS2 Tracked Entity Instance (TEI) of type "Person" maps naturally to a FHIR Patient resource. The TEI's unique identifier (an 11-character alphanumeric UID) becomes a Patient.identifier with a DHIS2-specific system URI. Tracked Entity Attributes that correspond to standard Patient fields -- such as first name, last name, date of birth, and gender -- map directly to the corresponding Patient elements. Attributes that have no counterpart in the base Patient resource (for example, a national health ID or a custom program-specific field) are represented using extensions or additional identifier slices.

```
TEI.uid              → Patient.identifier (system = http://dhis2.org/fhir/id/tracked-entity)
TEI.firstName        → Patient.name.given
TEI.lastName         → Patient.name.family
TEI.dateOfBirth      → Patient.birthDate
TEI.gender           → Patient.gender
TEI.orgUnit          → Patient.managingOrganization (Reference)
TEI.nationalId       → Patient.identifier (slice for national ID)
```

## Enrollment to EpisodeOfCare

An Enrollment in DHIS2 represents a tracked entity's participation in a specific program -- for example, a patient enrolled in an Antenatal Care program. FHIR's EpisodeOfCare resource captures this concept: it links a Patient to a managed period of care with a status (active, finished, cancelled) and a managing organization.

```
Enrollment.uid       → EpisodeOfCare.identifier
Enrollment.program   → EpisodeOfCare.type (coded reference to the program)
Enrollment.status    → EpisodeOfCare.status (active | finished | cancelled)
Enrollment.enrollmentDate → EpisodeOfCare.period.start
Enrollment.completedDate  → EpisodeOfCare.period.end
Enrollment.orgUnit   → EpisodeOfCare.managingOrganization
Enrollment.tei       → EpisodeOfCare.patient (Reference to Patient)
```

## Event to QuestionnaireResponse (Primary Pattern)

The primary mapping for DHIS2 events uses **Questionnaire** (form definition) and **QuestionnaireResponse** (submitted data). This pairing is the most natural fit because a DHIS2 event is fundamentally a filled-in form -- a program stage defines the questions (data elements), and an event records the answers (data values).

```
ProgramStage.uid         → Questionnaire.identifier
ProgramStage.name        → Questionnaire.title
ProgramStage.dataElements → Questionnaire.item (one item per data element)
DataElement.uid          → Questionnaire.item.linkId
DataElement.name         → Questionnaire.item.text
DataElement.valueType    → Questionnaire.item.type
OptionSet                → CodeSystem + ValueSet (bound via item.answerValueSet)

Event.uid                → QuestionnaireResponse.identifier
Event.status             → QuestionnaireResponse.status
Event.eventDate          → QuestionnaireResponse.authored
Event.programStage       → QuestionnaireResponse.questionnaire (canonical reference)
Event.tei                → QuestionnaireResponse.subject (Reference to Patient)
DataValue.dataElement    → QuestionnaireResponse.item.linkId
DataValue.value          → QuestionnaireResponse.item.answer.value[x]
```

### Events as Questionnaire Responses

QuestionnaireResponse is the primary pattern for DHIS2 events because it provides a one-to-one structural mapping: every data element in a program stage becomes a Questionnaire item, and every data value in an event becomes a QuestionnaireResponse answer. Unlike the Observation-per-data-value approach, this preserves the form structure in a single resource and avoids the "explosion" of resources per event.

This pattern works for both DHIS2 program types:

- **Tracker program events:** The QuestionnaireResponse includes a `subject` reference pointing to the Patient (the tracked entity). The event is part of an enrollment, which maps to an EpisodeOfCare.
- **Event program events (anonymous):** The QuestionnaireResponse omits the `subject` element entirely, since event programs collect data without linking to a specific individual. This is common for disease notification, stock management, and facility assessment forms.

Key metadata mappings:

- **Option sets** are represented as a CodeSystem (defining the codes) and a ValueSet (grouping them). The Questionnaire item binds to the ValueSet using `answerValueSet`, giving each choice item a controlled vocabulary.
- **Data elements** map to `item.linkId` (using the data element UID) and `item.text` (using the data element display name). The data element's value type determines the item type (`integer`, `decimal`, `string`, `date`, `choice`, etc.).
- **Program rules** that show or hide fields based on other answers map to `enableWhen` conditions on Questionnaire items.

The **Encounter** resource is still used when visit context is needed -- for example, to record the service provider, location, or link the event to an episode of care. In that case, the QuestionnaireResponse can reference the Encounter via an extension or the `encounter` element, but the form data itself lives in the QuestionnaireResponse.

#### Why QuestionnaireResponse is preferred over raw Observations

The Questionnaire/QuestionnaireResponse pattern is the primary event mapping in this IG for several reasons:

1. **Preserves form structure.** A DHIS2 program stage is a form. A Questionnaire is a form. The structural alignment is direct -- one program stage becomes one Questionnaire, one event becomes one QuestionnaireResponse. With Observations, a single event "explodes" into dozens of individual resources, and the original form grouping is lost.

2. **One-to-one mapping to program stages.** Each program stage maps to exactly one Questionnaire resource. Each event maps to exactly one QuestionnaireResponse. This 1:1 correspondence makes bidirectional mapping straightforward -- you can reconstruct the original DHIS2 event from a single QuestionnaireResponse without needing to reassemble scattered Observations.

3. **Works for both tracker and event programs.** For tracker programs (WITH_REGISTRATION), the QuestionnaireResponse includes a `subject` reference to the Patient. For event programs (WITHOUT_REGISTRATION), the `subject` is simply omitted. The same structural pattern handles both program types.

4. **Enables round-tripping.** Because the form structure is preserved, you can convert DHIS2 events to FHIR QuestionnaireResponses and convert them back without information loss. The `linkId` values (mapped from data element UIDs) provide the stable keys needed for faithful reconstruction.

5. **Reduces resource count.** An event with 20 data values produces one QuestionnaireResponse with 20 items, versus 20 separate Observation resources. Fewer resources means simpler transactions, fewer references to manage, and less overhead for FHIR servers.

6. **Natural fit for data entry workflows.** DHIS2 data capture is form-based. Health workers open a form, fill in fields, and submit. QuestionnaireResponse preserves this workflow semantics. Observations, by contrast, are better suited for lab results and clinical measurements that exist independently of a form context.

### Event to Encounter (Supplementary)

When visit context is required alongside the QuestionnaireResponse, an Encounter resource captures the clinical interaction metadata.

```
Event.uid            → Encounter.identifier
Event.status         → Encounter.status
Event.eventDate      → Encounter.period.start
Event.orgUnit        → Encounter.serviceProvider (Reference to Organization)
Event.enrollment     → Encounter.episodeOfCare (Reference to EpisodeOfCare)
Event.programStage   → Encounter.type (coded reference to the stage)
```

## Data Element / TEI Attribute to Observation

Individual data values in DHIS2 -- whether captured as Data Elements in an event or as Tracked Entity Attributes on a TEI -- map to FHIR Observation resources. Each Observation carries a code identifying what was measured, a value, and references to the Patient (subject) and Encounter (context).

```
DataValue.dataElement → Observation.code (mapped to a standard code or DHIS2 code)
DataValue.value       → Observation.value[x] (type depends on data element type)
DataValue.event       → Observation.encounter (Reference to Encounter)
DataValue.tei         → Observation.subject (Reference to Patient)
```

The `value[x]` type depends on the DHIS2 data element's value type:

| DHIS2 Value Type | FHIR value[x] Type |
|---|---|
| TEXT | valueString |
| NUMBER | valueQuantity or valueInteger |
| BOOLEAN | valueBoolean |
| DATE | valueDateTime |
| COORDINATE | Extension (latitude/longitude) |

## Organisation Unit to Organization / Location

DHIS2 Organisation Units serve a dual purpose: they represent both the administrative hierarchy (ministry, region, district, facility) and physical locations. In FHIR, these concepts are split across two resources:

- **Organization** represents the administrative entity (the institution).
- **Location** represents the physical place (with coordinates, address).

A common pattern is to create both an Organization and a Location for each DHIS2 org unit and link them with `Location.managingOrganization`.

```
OrgUnit.uid          → Organization.identifier[dhis2uid] (system = $DHIS2-OU)
OrgUnit.code         → Organization.identifier[dhis2code] (system = $DHIS2-OU-CODE)
OrgUnit.name         → Organization.name / Location.name
OrgUnit.parent       → Organization.partOf (Reference to parent Organization)
OrgUnit.level        → Organization.type (from DHIS2OrgUnitLevelCS)
OrgUnit.groups       → Organization.type (from DHIS2OrgUnitGroupCS)
OrgUnit.geometry     → Location.position (latitude, longitude)
```

### The DHIS2 Org Unit API

The DHIS2 API exposes organisation units at `/api/organisationUnits`. A typical response looks like:

```json
{
  "id": "DiszpKrYNg8",
  "code": "OU_559",
  "name": "Ngelehun CHC",
  "level": 4,
  "parent": { "id": "ImspTQPwCqd" },
  "organisationUnitGroups": [
    { "id": "oRVt7g429ZO", "name": "CHC" }
  ],
  "geometry": {
    "type": "Point",
    "coordinates": [-11.085, 7.948]
  }
}
```

Key fields for FHIR mapping:

| DHIS2 Field | Description | FHIR Mapping |
|---|---|---|
| `id` | The 11-character UID | `Organization.identifier[dhis2uid].value` |
| `code` | Human-readable code (e.g., `OU_559`) | `Organization.identifier[dhis2code].value` |
| `name` | Display name | `Organization.name` |
| `level` | Hierarchy level (1=national, 2=district, etc.) | `Organization.type` (from `DHIS2OrgUnitLevelCS`) |
| `parent.id` | Parent org unit UID | `Organization.partOf` (Reference) |
| `organisationUnitGroups` | Facility type classifications | `Organization.type` (from `DHIS2OrgUnitGroupCS`) |
| `geometry.coordinates` | GeoJSON `[longitude, latitude]` | `Location.position.latitude` / `.longitude` |

### Two identifier slices: UID and Code

DHIS2 org units have two identifiers:

1. **UID** (`id`): Auto-generated 11-character alphanumeric string (e.g., `DiszpKrYNg8`). Used in all API calls. Immutable.
2. **Code** (`code`): Human-readable code assigned by administrators (e.g., `OU_559`). Used in reports and integrations. Mutable.

The DHIS2Organization profile defines two identifier slices to capture both:

```fsh
* identifier contains dhis2uid 1..1 MS and dhis2code 0..1 MS

// UID slice — always present
* identifier[dhis2uid].system = $DHIS2-OU
* identifier[dhis2uid].type = $V2-0203#RI    // Resource Identifier
* identifier[dhis2uid].value = "DiszpKrYNg8"

// Code slice — optional
* identifier[dhis2code].system = $DHIS2-OU-CODE
* identifier[dhis2code].type = $V2-0203#XX   // Organization identifier
* identifier[dhis2code].value = "OU_559"
```

### Organization type: level and group

A DHIS2 org unit can be classified in two ways:

1. **By level** — its position in the hierarchy (national, district, chiefdom, facility). This is inherent to the tree structure and determined by the `level` integer in the API.
2. **By group** — its functional classification (hospital, community health centre, health post). This comes from the `organisationUnitGroups` array in the API.

Both map to `Organization.type`, and an Organization can have multiple type codings:

```fsh
// Level 4 facility that is classified as a Community Health Centre
* type[0] = DHIS2OrgUnitLevelCS#facility "Facility"
* type[+] = DHIS2OrgUnitGroupCS#CHC "Community Health Centre"
```

The IG defines two CodeSystems for this:

- **DHIS2OrgUnitLevelCS**: `national`, `district`, `chiefdom`, `facility`
- **DHIS2OrgUnitGroupCS**: `CHP`, `CHC`, `MCHP`, `hospital`, `clinic`

### Coordinate mapping: GeoJSON to FHIR

DHIS2 stores coordinates in GeoJSON format, where the order is **[longitude, latitude]**. FHIR's `Location.position` uses separate `latitude` and `longitude` fields. When converting, swap the order:

```
DHIS2 GeoJSON: { "coordinates": [-11.085, 7.948] }
                                  ↑ lon    ↑ lat

FHIR Location: { "position": { "latitude": 7.948, "longitude": -11.085 } }
```

This is a common source of bugs — GeoJSON uses `[lon, lat]` while most human-readable formats (including Google Maps URLs) use `lat, lon`.

### Why both Organization and Location are needed

DHIS2 combines two concerns into a single "Organisation Unit" concept:

1. **Administrative identity** -- the institution or administrative body (e.g., "Ngelehun Community Health Centre" as a legal entity that employs staff, manages budgets, and reports to a parent district).
2. **Physical site** -- the building with a GPS location, address, and operational status where services are delivered.

FHIR deliberately separates these into two resources because they serve different purposes:

- **Organization** models the administrative hierarchy. `Organization.partOf` builds the org unit tree (country > region > district > facility). Other resources reference Organization when they need to indicate "who is responsible" -- for example, `Patient.managingOrganization`, `Encounter.serviceProvider`, and `MeasureReport.reporter`.
- **Location** models the physical place. `Location.position` carries GPS coordinates (latitude, longitude). `Location.address` provides the postal address. Location is what you use when you need to answer "where did this happen" on a map.

The link between the two is `Location.managingOrganization`, which points from the physical site to the administrative entity that manages it. In practice, a DHIS2 org unit at the facility level produces both an Organization and a Location with the same name and identifier, linked by this reference:

```json
{
  "resourceType": "Location",
  "name": "Ngelehun CHC",
  "position": { "latitude": 7.948, "longitude": -11.085 },
  "managingOrganization": { "reference": "Organization/OrganizationFacilityA" }
}
```

### When to create a Location

Not every org unit needs a Location resource. The decision depends on the level:

| Level | Organization | Location | Rationale |
|---|---|---|---|
| National (MOH) | Yes | No | Purely administrative, no physical site |
| District | Yes | Rarely | Administrative unit; may have office coordinates |
| Chiefdom | Yes | Rarely | Sub-district admin; rarely has coordinates |
| Facility | Yes | **Yes** | Physical site with GPS, where services are delivered |

In the Sierra Leone DHIS2 play server, 766 out of 1,332 org units have geometry — almost all at the facility level. The hierarchy has 4 levels:

```
Level 1: Sierra Leone (1 org unit — national root)
  └─ Level 2: Districts (14 org units)
       └─ Level 3: Chiefdoms (~200 org units)
            └─ Level 4: Facilities (~1,100 org units, most with GPS)
```

### Example: 4-level hierarchy in FSH

```fsh
// Level 1 — National
Instance: OrganizationMOH
InstanceOf: DHIS2Organization
* identifier[dhis2uid].value = "GOLswS44mh8"
* identifier[dhis2code].value = "OU_525"
* name = "Ministry of Health"
* type = DHIS2OrgUnitLevelCS#national "National"
* active = true
// No partOf — root of the hierarchy

// Level 2 — District
Instance: OrganizationDistrictA
InstanceOf: DHIS2Organization
* identifier[dhis2uid].value = "ImspTQPwCqd"
* identifier[dhis2code].value = "OU_278371"
* name = "District A Health Office"
* type = DHIS2OrgUnitLevelCS#district "District"
* partOf = Reference(OrganizationMOH)

// Level 3 — Facility (with both level and group types)
Instance: OrganizationFacilityA
InstanceOf: DHIS2Organization
* identifier[dhis2uid].value = "DiszpKrYNg8"
* identifier[dhis2code].value = "OU_559"
* name = "Facility Alpha Health Center"
* type[0] = DHIS2OrgUnitLevelCS#facility "Facility"
* type[+] = DHIS2OrgUnitGroupCS#CHC "Community Health Centre"
* partOf = Reference(OrganizationDistrictA)

// Physical location for the facility
Instance: LocationFacilityA
InstanceOf: DHIS2Location
* name = "Facility Alpha Health Center"
* status = #active
* position.latitude = -13.9626
* position.longitude = 33.7741
* managingOrganization = Reference(OrganizationFacilityA)
```

## Program to PlanDefinition

A DHIS2 Program defines the structure of a tracker or event program: which stages it has, which data elements are collected at each stage, and enrollment rules. FHIR's PlanDefinition resource captures this kind of protocol or workflow definition.

```
Program.uid          → PlanDefinition.identifier
Program.name         → PlanDefinition.title
Program.description  → PlanDefinition.description
Program.programStages → PlanDefinition.action (one action per stage)
ProgramStage.dataElements → PlanDefinition.action.input
```

## Challenges and Considerations

### Different data models

DHIS2 uses a flexible, metadata-driven model: data elements are generic containers configured at runtime. FHIR resources have fixed, pre-defined structures. Bridging this gap requires careful profiling -- creating FHIR profiles that constrain resources to match the specific DHIS2 program's structure.

### Terminology mapping

DHIS2 data elements and option sets use internal codes. For interoperability, these should be mapped to standard terminologies (LOINC, SNOMED CT, ICD-10) wherever possible. This is often the most labor-intensive part of the mapping process and may require clinical expertise.

### Granularity differences

A single DHIS2 Event may contain dozens of data values. In FHIR, each data value typically becomes a separate Observation resource (or a component within a grouped Observation). This "explosion" in resource count is normal but requires careful design of references and groupings.

### Identity and matching

DHIS2 UIDs are system-specific identifiers. When exchanging data with other systems, you need a strategy for patient matching -- using national IDs, facility-assigned MRNs, or probabilistic matching algorithms. Your FHIR profiles should accommodate multiple identifier types through slicing.

#### Identifier type codes (HL7 v2 Table 0203)

FHIR inherits a set of identifier type codes from HL7 v2 Table 0203. These codes classify what kind of identifier is being carried, which is critical when a resource has multiple identifiers from different systems. The code system URI is `http://terminology.hl7.org/CodeSystem/v2-0203`.

| Code | Meaning | Typical use in DHIS2 context |
|------|---------|------------------------------|
| RI | Resource Identifier | System-generated DHIS2 UID (the 11-character alphanumeric ID for TEIs, org units, data elements, etc.) |
| NI | National Identifier | Government-issued national health ID or national ID number stored as a TEI attribute |
| MR | Medical Record Number | Facility-assigned patient number, often a TEI attribute like "Facility MRN" |
| PP | Passport Number | Passport number stored as a TEI attribute, used in cross-border health programs |
| DL | Driver's License | Driver's license number, occasionally used as an alternative identifier |

In this IG, the `DHIS2Identifier` RuleSet assigns `type = $V2-0203#RI "Resource identifier"` to every DHIS2 UID. When a Patient also carries a national health ID, you would add a second identifier slice with `type = $V2-0203#NI "National Identifier"`:

```json
{
  "identifier": [
    {
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "RI",
            "display": "Resource identifier"
          }
        ]
      },
      "system": "http://dhis2.org/fhir/id/tracked-entity",
      "value": "dNpxRu1mObG"
    },
    {
      "type": {
        "coding": [
          {
            "system": "http://terminology.hl7.org/CodeSystem/v2-0203",
            "code": "NI",
            "display": "National identifier"
          }
        ]
      },
      "system": "http://example.org/national-id",
      "value": "MW-1990-05-12345"
    }
  ]
}
```

The `type.coding` pattern tells downstream consumers how to interpret each identifier without needing to understand the `system` URI.

### Bidirectional sync

If data flows both ways between DHIS2 and FHIR-based systems, you need to handle conflict resolution, update timestamps, and version management. The mapping described here focuses on the conceptual alignment; a production integration will also need an operational synchronization strategy.

### Aggregate Data and Indicators

The mappings above focus on tracker (individual-level) data. DHIS2 also has a rich aggregate data model -- DataSets, DataValueSets, and Indicators -- that maps to FHIR's Measure and MeasureReport resources.

| DHIS2 Concept | FHIR Resource | Notes |
|---|---|---|
| DataSet | Measure | A DataSet defines which data elements are collected together for a period and org unit. This maps to a Measure resource that describes what is to be reported. |
| DataValueSet | MeasureReport (type: data-collection) | A completed DataValueSet -- the actual aggregate values submitted for a period -- maps to a MeasureReport with `type` set to `data-collection`. Each data value becomes a `group.population` or `group.measureScore` entry. |
| Indicator | Measure (with scoring) | A DHIS2 Indicator defines a calculated metric (numerator, denominator, factor). This maps to a Measure with `scoring` set to `proportion`, `ratio`, or `continuous-variable` depending on the indicator type. |
| Indicator Value | MeasureReport (type: summary) | The computed value of an indicator for a given period and org unit maps to a MeasureReport with `type` set to `summary`. |

```
DataSet.uid              → Measure.identifier
DataSet.name             → Measure.title
DataSet.periodType       → Measure.effectivePeriod (defines reporting cadence)
DataSet.dataElements     → Measure.group (one group per data element or section)

DataValueSet.period      → MeasureReport.period
DataValueSet.orgUnit     → MeasureReport.reporter (Reference to Organization)
DataValueSet.dataValues  → MeasureReport.group.population / group.measureScore

Indicator.uid            → Measure.identifier
Indicator.numerator      → Measure.group.population (numerator criteria)
Indicator.denominator    → Measure.group.population (denominator criteria)
Indicator.indicatorType  → Measure.scoring (proportion | ratio | continuous-variable)
```

> **Deep dive:** For a comprehensive guide to working with Measure and MeasureReport -- including DHIS2-specific patterns and FSH examples -- see [Part VI: Measure and MeasureReport](../ch07-measure/index.md).
