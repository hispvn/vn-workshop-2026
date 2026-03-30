# Bundle

The Bundle resource is a container that holds a collection of other resources. While most FHIR interactions deal with individual resources, there are many situations where you need to send or receive multiple resources together -- submitting a patient with their observations in a single request, returning search results, or exchanging a document. That is what Bundle is for.

## Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `type` | code | 1..1 | The purpose of this bundle (see types below) |
| `total` | unsignedInt | 0..1 | Total number of matches (for searchset bundles) |
| `link` | BackboneElement[] | 0..* | Pagination and self links |
| `entry` | BackboneElement[] | 0..* | The resources in this bundle |
| `entry.fullUrl` | uri | 0..1 | Absolute or temporary URL for this entry |
| `entry.resource` | Resource | 0..1 | The actual resource |
| `entry.request` | BackboneElement | 0..1 | HTTP request details (for transaction/batch) |
| `entry.response` | BackboneElement | 0..1 | HTTP response details (in transaction responses) |
| `timestamp` | instant | 0..1 | When the bundle was assembled |

## Bundle Types

FHIR defines several bundle types, each with a different purpose:

| Type | Purpose | When to use |
|------|---------|-------------|
| `transaction` | All-or-nothing submission of multiple resources | Creating a patient and related data atomically |
| `batch` | Multiple independent operations in one request | Submitting several unrelated resources at once |
| `searchset` | Search results returned by the server | Response to `GET /Patient?name=Banda` |
| `document` | A clinical document (has a Composition as first entry) | Discharge summaries, care plans |
| `message` | A message triggered by an event | Lab result notifications |
| `collection` | An arbitrary collection of resources | Data export, bulk transfer |

The most commonly used types in integration work are `transaction` (for sending data) and `searchset` (returned by the server).

## Transaction Bundle Example

Here is a transaction Bundle that creates a Patient and an Observation together. Either both succeed, or neither does -- the server processes them atomically.

```json
{
  "resourceType": "Bundle",
  "type": "transaction",
  "entry": [
    {
      "fullUrl": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890",
      "resource": {
        "resourceType": "Patient",
        "identifier": [
          {
            "system": "http://dhis2.org/trackedentity",
            "value": "DXz7q34bVcR"
          }
        ],
        "name": [
          {
            "family": "Banda",
            "given": ["Grace"]
          }
        ],
        "gender": "female",
        "birthDate": "1990-03-15"
      },
      "request": {
        "method": "POST",
        "url": "Patient"
      }
    },
    {
      "fullUrl": "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901",
      "resource": {
        "resourceType": "Observation",
        "status": "final",
        "code": {
          "coding": [
            {
              "system": "http://loinc.org",
              "code": "29463-7",
              "display": "Body weight"
            }
          ]
        },
        "subject": {
          "reference": "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
        },
        "effectiveDateTime": "2024-06-10",
        "valueQuantity": {
          "value": 62.5,
          "unit": "kg",
          "system": "http://unitsofmeasure.org",
          "code": "kg"
        }
      },
      "request": {
        "method": "POST",
        "url": "Observation"
      }
    }
  ]
}
```

### Key things to notice

**fullUrl with urn:uuid.** Since these resources do not exist on the server yet, they use temporary UUIDs as their identity. The server will assign real IDs after processing.

**Internal references.** The Observation's `subject.reference` points to the Patient's `fullUrl` UUID. The server resolves this to the real Patient ID after creation. This is how you link resources within a transaction before they have server-assigned IDs.

**request element.** Each entry specifies the HTTP operation. `POST` to the resource type URL means "create this resource." You can also use `PUT` for updates, `DELETE` for removals, and conditional operations.

## Transaction vs. Batch

The critical difference:

- **Transaction**: All entries succeed or all fail. If one entry has a validation error, the entire bundle is rejected. Use this when data integrity across resources matters.
- **Batch**: Each entry is processed independently. Some can succeed while others fail. The server returns a response bundle with the outcome of each entry. Use this when the entries are unrelated.

## Common Patterns and Gotchas

**Order matters in transactions.** If resource B depends on resource A (e.g., an Observation referencing a Patient), some servers process entries in order. Although the spec says servers should handle internal UUID references regardless of order, putting depended-on resources first is safer.

**Conditional creates.** You can use `request.ifNoneExist` to avoid creating duplicates: `"ifNoneExist": "identifier=http://dhis2.org/trackedentity|DXz7q34bVcR"`. The server will skip the creation if a matching resource already exists.

**Searchset bundles are read-only.** When the server returns search results, they come in a searchset Bundle. These do not have `request` elements -- they are just containers for the results, often with pagination links.

**Size limits.** Servers may impose limits on how many entries a bundle can contain. For large data transfers, consider splitting into multiple bundles or using FHIR Bulk Data.

## Relationship to DHIS2

When synchronizing DHIS2 data to a FHIR server, transaction Bundles are the primary mechanism. A single DHIS2 tracker enrollment with its events and data values translates into a Bundle containing a Patient, an EpisodeOfCare, multiple Encounters, and their associated Observations -- all submitted atomically. This mirrors how DHIS2's own API handles tracker data as a single payload containing tracked entities, enrollments, and events together.

## Examples from This IG

This IG includes two Bundle examples that demonstrate the patterns described above. Both are defined in FSH and compiled to JSON by SUSHI.

### ANC Visit Transaction Bundle

The `BundleANCVisitTransaction` example (defined in `input/fsh/bundles/anc-visit-transaction.fsh`) models the FHIR output of processing a single DHIS2 tracker event: an ANC visit for a patient named Jane Doe. It is a `transaction` bundle containing five resources that must be created atomically:

1. **Patient** -- the tracked entity instance (Jane Doe, TEI UID `dNpxRu1mObG`)
2. **Encounter** -- the ANC visit event (ambulatory, at Facility A)
3. **Observation: Weight** -- body weight measurement (65 kg, LOINC 29463-7)
4. **Observation: Hemoglobin** -- hemoglobin level (12.5 g/dL, LOINC 718-7)
5. **Observation: Malaria RDT** -- malaria rapid test result (negative, LOINC 70569-9)

The FSH code uses `Usage: #inline` for resources that exist only inside the bundle, and temporary UUIDs for cross-references:

```fsh
Instance: BundleANCVisitTransaction
InstanceOf: Bundle
Title: "ANC Visit Transaction Bundle"
Usage: #example

* type = #transaction

// Entry 1: Patient with temporary UUID
* entry[0].fullUrl = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* entry[0].resource = PatientInBundle
* entry[0].request.method = #POST
* entry[0].request.url = "Patient"

// Entry 2: Encounter references the Patient via temporary UUID
* entry[1].fullUrl = "urn:uuid:b2c3d4e5-f6a7-8901-bcde-f12345678901"
* entry[1].resource = EncounterInBundle
* entry[1].request.method = #POST
* entry[1].request.url = "Encounter"

// Entries 3-5: Observations reference both Patient and Encounter UUIDs
* entry[2].fullUrl = "urn:uuid:c3d4e5f6-a7b8-9012-cdef-123456789012"
* entry[2].resource = ObservationWeightInBundle
* entry[2].request.method = #POST
* entry[2].request.url = "Observation"
// ... (hemoglobin and malaria entries follow the same pattern)
```

Each inline instance references the Patient and Encounter using the temporary UUIDs:

```fsh
Instance: EncounterInBundle
InstanceOf: Encounter
Usage: #inline

* status = #finished
* class = $encounter-class#AMB "ambulatory"
* subject.reference = "urn:uuid:a1b2c3d4-e5f6-7890-abcd-ef1234567890"
* subject.display = "Jane Doe"
```

When the FHIR server processes this transaction, it replaces every `urn:uuid:...` reference with the real server-assigned ID. If any entry fails validation, the entire transaction is rolled back.

### Monthly Report Collection Bundle

The `BundleMontlyReport` example (defined in `input/fsh/bundles/monthly-report.fsh`) demonstrates the aggregate data pattern. It is a `collection` bundle -- not a transaction -- that packages a MeasureReport with its Measure definition for documentation and transport:

1. **MeasureReport** -- Facility Alpha's January 2024 monthly submission with three data values: malaria confirmed (47), malaria tested (312), OPD visits (1842)
2. **Measure** -- the data set definition specifying what data elements are expected

The FSH code:

```fsh
Instance: BundleMontlyReport
InstanceOf: Bundle
Title: "Monthly Facility Report Collection Bundle"
Usage: #example

* type = #collection

// Entry 1: The actual reported data
* entry[0].fullUrl = "http://dhis2.org/fhir/learning/MeasureReport/monthly-jan-2024-facility-a"
* entry[0].resource = MeasureReportInBundle

// Entry 2: The data set definition (included for context)
* entry[1].fullUrl = "http://dhis2.org/fhir/learning/Measure/monthly-facility-report"
* entry[1].resource = MeasureInBundle
```

Notice the key differences from the transaction bundle:

- **`type = #collection`** instead of `#transaction` -- no processing semantics, just grouping.
- **No `request` elements** -- collection entries are not instructions to the server.
- **Canonical URLs as fullUrl** instead of temporary UUIDs -- these resources have known identities.
- **The MeasureReport references the Measure by canonical URL**, not by a temporary UUID. This works whether the Measure is in the same bundle or already exists on the server.

The inline MeasureReport uses `group` entries to carry each data element value:

```fsh
// Group 1: Malaria confirmed = 47
* group[0].code = http://dhis2.org/fhir/learning/CodeSystem/dhis2-data-elements#malaria-confirmed
    "Malaria Confirmed Cases"
* group[0].population[0].code = $measure-population#initial-population "Initial Population"
* group[0].population[0].count = 47
```

This mirrors how a DHIS2 data entry operator opens a data set form (the Measure) and fills in aggregate values (the MeasureReport) for a specific period and organisation unit.
