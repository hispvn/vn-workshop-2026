# Data Types and Formats

FHIR defines a rich set of data types used across all resources. Understanding these types is essential for reading resource definitions and writing FSH profiles.

## Primitive Types

Primitive types represent simple values. The most common ones are:

| Type | Description | Example |
|------|-------------|---------|
| `string` | A sequence of Unicode characters | `"Grace Banda"` |
| `boolean` | true or false | `true` |
| `integer` | A signed 32-bit integer | `42` |
| `decimal` | A rational number | `65.5` |
| `date` | A date (year, year-month, or full date) | `"2024-01-15"` |
| `dateTime` | A date with optional time and timezone | `"2024-01-15T10:30:00Z"` |
| `instant` | A precise timestamp including timezone | `"2024-01-15T10:30:00.000+02:00"` |
| `uri` | A Uniform Resource Identifier | `"http://example.org/fhir"` |
| `code` | A string constrained to a value set | `"male"` |
| `id` | A logical identifier (letters, numbers, hyphens) | `"example-patient"` |

Primitive types in FHIR can also carry extensions, which is why they are sometimes called "FHIR primitives" rather than plain JSON primitives.

## Complex Types

Complex types combine multiple fields into a structured value. These appear throughout FHIR resources.

### HumanName

Represents a person's name with structured parts:

```json
{
  "use": "official",
  "family": "Banda",
  "given": ["Grace", "Thandiwe"],
  "prefix": ["Dr."]
}
```

### Address

A postal or physical address:

```json
{
  "use": "home",
  "type": "physical",
  "line": ["123 Main Street"],
  "city": "Lilongwe",
  "country": "MW"
}
```

### CodeableConcept

One of the most important types in FHIR. It represents a concept that can be defined by one or more coding systems, plus optional free text:

```json
{
  "coding": [
    {
      "system": "http://loinc.org",
      "code": "29463-7",
      "display": "Body weight"
    },
    {
      "system": "http://snomed.info/sct",
      "code": "27113001",
      "display": "Body weight"
    }
  ],
  "text": "Body weight"
}
```

A CodeableConcept can have multiple `coding` entries from different code systems, all representing the same concept. The `text` field provides a human-readable fallback.

### Identifier

Used to uniquely identify entities across systems:

```json
{
  "system": "http://dhis2.org/trackedentity",
  "value": "TE-abc-123"
}
```

The `system` is a URI that defines the namespace, and `value` is the identifier within that namespace. This pattern is crucial for cross-system interoperability.

### Reference

Links one resource to another:

```json
{
  "reference": "Patient/example-patient",
  "display": "Grace Banda"
}
```

References can be:
- **Literal** -- a relative or absolute URL (`"Patient/123"` or `"http://example.org/fhir/Patient/123"`)
- **Logical** -- an identifier-based reference using the `identifier` field instead of `reference`

### Quantity

A measured amount with a unit:

```json
{
  "value": 65.0,
  "unit": "kg",
  "system": "http://unitsofmeasure.org",
  "code": "kg"
}
```

### Period

A time range defined by a start and/or end:

```json
{
  "start": "2024-01-01",
  "end": "2024-06-30"
}
```

### ContactPoint

A phone number, email, or other contact detail:

```json
{
  "system": "phone",
  "value": "+265 1 234 567",
  "use": "work"
}
```

## Serialization Formats

FHIR supports two primary serialization formats:

### JSON

JSON is the most widely used format for FHIR. It maps naturally to FHIR's data model and is easy to work with in modern programming languages. All examples in this guide use JSON.

```json
{
  "resourceType": "Patient",
  "id": "example",
  "name": [
    {
      "family": "Banda"
    }
  ]
}
```

### XML

FHIR also supports XML serialization. The same Patient resource in XML:

```xml
<Patient xmlns="http://hl7.org/fhir">
  <id value="example"/>
  <name>
    <family value="Banda"/>
  </name>
</Patient>
```

Note that in XML, primitive values are carried in `value` attributes rather than as element text. Most modern FHIR tooling works with both formats, but JSON tends to be preferred in new implementations.

When working with FHIR APIs, you specify your preferred format using the `Accept` and `Content-Type` HTTP headers: `application/fhir+json` for JSON or `application/fhir+xml` for XML.

## Identifier Type Codes (v2-0203)

Identifiers appear on virtually every FHIR resource. While the `system` and `value` fields tell you the namespace and the ID itself, the optional `type` field classifies what kind of identifier it is. FHIR draws these type codes from HL7 v2 Table 0203 (`http://terminology.hl7.org/CodeSystem/v2-0203`).

This is especially important when a single resource carries multiple identifiers -- for example, a Patient with both a system-generated DHIS2 UID and a government-issued national ID. The type code lets consumers distinguish them without needing to parse the `system` URI.

### Common codes

| Code | Meaning | Description |
|------|---------|-------------|
| RI | Resource Identifier | A system-generated identifier. In DHIS2 context, this is the 11-character alphanumeric UID assigned by DHIS2 to every object (tracked entities, org units, data elements, etc.). |
| NI | National Identifier | A government-issued national identification number. Used for TEI attributes that hold a national health ID or civil registration number. |
| MR | Medical Record Number | A facility-assigned patient record number. Common in hospitals and clinics that maintain local patient registers. |
| PP | Passport Number | An international passport number. Relevant in cross-border health programs or refugee health contexts. |
| DL | Driver's License | A driver's license number. Occasionally used as an alternative patient identifier. |

### Example: Patient with two identifiers

The following JSON shows a Patient carrying both a DHIS2 system-generated UID (type RI) and a national health ID (type NI):

```json
{
  "resourceType": "Patient",
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
  ],
  "name": [{ "family": "Banda", "given": ["Grace"] }],
  "gender": "female"
}
```

The `type.coding` pattern follows the standard CodeableConcept structure: `system` identifies the code system, `code` is the machine-readable value, and `display` is the human-readable label. This is the same pattern used throughout FHIR for coded values.
