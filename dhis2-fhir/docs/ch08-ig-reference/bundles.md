# Bundle Examples

DHIS2 data rarely maps to a single FHIR resource. A tracker event produces a Patient, an Encounter, and multiple Observations that all need to be created together. Bundles are FHIR's mechanism for grouping multiple resources into a single payload.

The IG includes two bundle examples demonstrating distinct patterns:

1. **BundleANCVisitTransaction** -- A transaction bundle for atomically creating tracker event resources
2. **BundleMonthlyReport** -- A collection bundle packaging aggregate data with its definition

## BundleANCVisitTransaction

A **transaction bundle** that atomically creates all FHIR resources from a single DHIS2 ANC (Antenatal Care) visit event.

### What It Contains

| Entry | Resource | DHIS2 Source |
|-------|----------|--------------|
| 1 | Patient (Jane Doe) | Tracked Entity Instance |
| 2 | Encounter (ANC Visit) | Program stage event |
| 3 | Observation (Weight: 65 kg) | Event data value |
| 4 | Observation (Hemoglobin: 12.5 g/dL) | Event data value |
| 5 | Observation (Malaria RDT: Negative) | Event data value |

### Key Patterns

**Temporary UUIDs:** Each entry uses a `urn:uuid:` as its `fullUrl`. Other entries reference these UUIDs instead of real server IDs. The FHIR server resolves all references when processing the transaction.

```fsh
* entry[0].fullUrl = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* entry[0].resource = PatientInBundle
* entry[0].request.method = #POST
* entry[0].request.url = "Patient"
```

**Cross-references:** The Encounter and Observations reference the Patient via the temporary UUID:

```fsh
// In EncounterInBundle:
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"

// In ObservationWeightInBundle:
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* encounter.reference = "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901"
```

**Atomicity:** If any entry fails validation or processing, the entire transaction is rolled back. No partial creates occur, ensuring data consistency.

**Inline instances:** Bundle entries use `Usage: #inline`, meaning they only exist within the bundle and are not standalone examples.

### FSH Source

```fsh
Instance: BundleANCVisitTransaction
InstanceOf: Bundle
Title: "ANC Visit Transaction Bundle"
Usage: #example
* type = #transaction

// Entry 1: Patient
* entry[0].fullUrl = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* entry[0].resource = PatientInBundle
* entry[0].request.method = #POST
* entry[0].request.url = "Patient"

// Entry 2: Encounter
* entry[1].fullUrl = "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901"
* entry[1].resource = EncounterInBundle
* entry[1].request.method = #POST
* entry[1].request.url = "Encounter"

// Entry 3: Observation -- Weight
* entry[2].fullUrl = "urn:uuid:c3d4e5f6-a7b8-9012-cdef-123456789012"
* entry[2].resource = ObservationWeightInBundle
* entry[2].request.method = #POST
* entry[2].request.url = "Observation"

// Entry 4: Observation -- Hemoglobin
* entry[3].fullUrl = "urn:uuid:d4e5f6a7-b8c9-0123-defa-234567890123"
* entry[3].resource = ObservationHemoglobinInBundle
* entry[3].request.method = #POST
* entry[3].request.url = "Observation"

// Entry 5: Observation -- Malaria RDT
* entry[4].fullUrl = "urn:uuid:e5f6a7b8-c9d0-1234-efab-345678901234"
* entry[4].resource = ObservationMalariaInBundle
* entry[4].request.method = #POST
* entry[4].request.url = "Observation"
```

### Inline Instances

The bundle contains five inline instances. Here is the Encounter as a representative example:

```fsh
Instance: EncounterInBundle
InstanceOf: Encounter
Usage: #inline
* status = #finished
* class = $encounter-class#AMB "ambulatory"
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* subject.display = "Jane Doe"
* period.start = "2024-03-15"
* period.end = "2024-03-15"
* serviceProvider = Reference(OrganizationFacilityA)
```

The Observations use LOINC codes for clinical concepts:
- Weight: `29463-7` "Body weight" -- valueQuantity 65 kg
- Hemoglobin: `718-7` "Hemoglobin [Mass/volume] in Blood" -- valueQuantity 12.5 g/dL
- Malaria RDT: `70569-9` "Plasmodium sp Ag [Presence] in Blood by Rapid immunoassay" -- valueCodeableConcept (SNOMED `260385009` "Negative")

## BundleMonthlyReport

A **collection bundle** that packages a monthly facility MeasureReport together with its Measure definition. This represents the FHIR equivalent of a DHIS2 data set submission.

### Transaction vs. Collection

Unlike the transaction bundle, a collection bundle has **no processing semantics**. The server does not "execute" it. It simply groups related resources for transport, documentation, or storage. This is appropriate here because:

- The Measure definition likely already exists on the server
- The MeasureReport is the primary payload being submitted
- Including the Measure provides context and makes the package self-contained

### What It Contains

| Entry | Resource | DHIS2 Source |
|-------|----------|--------------|
| 1 | MeasureReport (January 2024 data) | Data value set submission |
| 2 | Measure (Monthly Facility Report) | Data set definition |

### The MeasureReport

Facility Alpha's January 2024 monthly submission with three data elements:

| Group | Data Element | Count |
|-------|-------------|-------|
| 1 | Malaria Confirmed Cases | 47 |
| 2 | Malaria Cases Tested | 312 |
| 3 | OPD Visits Total | 1842 |

### FSH Source

```fsh
Instance: BundleMontlyReport
InstanceOf: Bundle
Title: "Monthly Facility Report Collection Bundle"
Usage: #example
* type = #collection

// Entry 1: MeasureReport
* entry[0].fullUrl = "http://dhis2.org/fhir/learning/MeasureReport/monthly-jan-2024-facility-a"
* entry[0].resource = MeasureReportInBundle

// Entry 2: Measure
* entry[1].fullUrl = "http://dhis2.org/fhir/learning/Measure/monthly-facility-report"
* entry[1].resource = MeasureInBundle
```

The MeasureReport inline instance:

```fsh
Instance: MeasureReportInBundle
InstanceOf: MeasureReport
Usage: #inline
* status = #complete
* type = #data-collection
* measure = "http://dhis2.org/fhir/learning/Measure/monthly-facility-report"
* subject = Reference(LocationFacilityA)
* date = "2024-02-03"
* period.start = "2024-01-01"
* period.end = "2024-01-31"
* reporter = Reference(OrganizationFacilityA)

* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-confirmed
* group[0].population[0].code = $measure-population#initial-population
* group[0].population[0].count = 47

* group[1].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-tested
* group[1].population[0].code = $measure-population#initial-population
* group[1].population[0].count = 312

* group[2].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#opd-visits
* group[2].population[0].code = $measure-population#initial-population
* group[2].population[0].count = 1842
```

The Measure inline instance defines the data set structure with scoring type `cohort` and measure type `structure`:

```fsh
Instance: MeasureInBundle
InstanceOf: Measure
Usage: #inline
* url = "http://dhis2.org/fhir/learning/Measure/monthly-facility-report"
* identifier[0].system = $DHIS2-DS
* identifier[0].value = "BfMAe6Itzgt"
* name = "MonthlyFacilityReport"
* title = "Monthly Facility Report"
* status = #active
* scoring = $measure-scoring#cohort "Cohort"
* type = $measure-type#structure "Structure"
```

### Patterns Demonstrated

1. **Collection bundles for documentation** -- Include related resources together for context
2. **MeasureReport for aggregate data** -- Each data element becomes a group with a population count
3. **Subject is Location, not Organization** -- FHIR R4 constraint; Location links to Organization via `managingOrganization`
4. **Period represents reporting month** -- `period.start = 2024-01-01`, `period.end = 2024-01-31`
5. **Reporter vs. subject** -- The reporter (Organization) submitted the data; the subject (Location) is what the data is about

## Source Files

- Transaction bundle: `ig/input/fsh/bundles/anc-visit-transaction.fsh`
- Collection bundle: `ig/input/fsh/bundles/monthly-report.fsh`
