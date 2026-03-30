# FHIR Resources

Resources are the fundamental building blocks of FHIR. Every piece of health data -- a patient record, a lab result, a medication -- is represented as a resource. FHIR R4 defines over 140 resource types, each modeling a specific concept in healthcare.

## What is a Resource?

A FHIR resource is a discrete unit of health-related data with a defined structure. Resources are self-contained: each one has enough context to be understood on its own, while also supporting references to other resources. You can think of resources as the "nouns" of the FHIR world.

Common resource types include:

| Resource | Description |
|----------|-------------|
| **Patient** | Demographics and administrative information about a person receiving care |
| **Observation** | A measurement or assertion about a patient (lab results, vital signs) |
| **Encounter** | An interaction between a patient and a healthcare provider |
| **Condition** | A clinical condition, problem, or diagnosis |
| **Organization** | A formally recognized grouping of people or organizations |
| **Location** | A physical place where services are provided |

## Resource Structure

Every resource shares a common structure:

- **resourceType** -- The type of resource (e.g., "Patient", "Observation")
- **id** -- A server-assigned logical identifier
- **meta** -- Metadata about the resource (version, last updated, profile)
- **text** -- A human-readable summary (the "narrative")
- **Elements** -- The data fields specific to that resource type

## Example: Patient Resource

Here is a minimal Patient resource in JSON:

```json
{
  "resourceType": "Patient",
  "id": "example-patient",
  "meta": {
    "profile": [
      "http://hl7.org/fhir/StructureDefinition/Patient"
    ]
  },
  "identifier": [
    {
      "system": "http://example.org/ids",
      "value": "12345"
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
}
```

Key things to notice:
- `resourceType` is always present and identifies what kind of resource this is.
- `identifier` uses a system/value pair to uniquely identify the patient within a given namespace.
- `name` is an array because a patient can have multiple names (legal name, nickname, etc.).

## Example: Observation Resource

An Observation records a measurement or finding. Here is a body weight observation:

```json
{
  "resourceType": "Observation",
  "id": "body-weight-example",
  "status": "final",
  "category": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/observation-category",
          "code": "vital-signs",
          "display": "Vital Signs"
        }
      ]
    }
  ],
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
    "reference": "Patient/example-patient"
  },
  "effectiveDateTime": "2024-01-15",
  "valueQuantity": {
    "value": 65.0,
    "unit": "kg",
    "system": "http://unitsofmeasure.org",
    "code": "kg"
  }
}
```

Notice how:
- `status` indicates this is a finalized result.
- `code` uses LOINC coding to identify what was measured.
- `subject` is a **reference** linking this observation to the Patient resource above.
- `valueQuantity` carries the actual measurement with its unit.

## The Resource Hierarchy

FHIR resources are organized into categories:

- **Foundation** -- Infrastructure resources (CapabilityStatement, StructureDefinition, OperationDefinition)
- **Base** -- Core resources used across domains (Patient, Practitioner, Organization)
- **Clinical** -- Clinical data (Observation, Condition, Procedure, MedicationRequest)
- **Financial** -- Billing and insurance (Claim, Coverage, ExplanationOfBenefit)

Resources within these categories frequently reference each other, forming a web of interconnected health data. For example, an Observation references a Patient as its subject, and may reference an Encounter as its context.
