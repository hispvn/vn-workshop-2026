# CHR Profiles

## DHIS2CHRPatient

The CHR Patient profile extends `DHIS2Patient` with CHR-specific requirements.

### Key Constraints

- **`clientHealthId`** identifier (1..1) — Required. System: `http://moh.gov.la/fhir/id/client-health-id`. Generated server-side using format `DDMMYYYY-SexCode-NNNN`.
- **`name.given`** (1..*) and **`name.family`** (1..1) — Required.
- **`gender`** (1..1) and **`birthDate`** (1..1) — Required.
- Address with Lao hierarchy: `state` (province), `district`, `city` (village).

### Extensions

| Extension | Type | Description |
|---|---|---|
| `chr-nationality` | string | Patient's nationality |
| `chr-ethnicity` | string | Patient's ethnicity |
| `chr-occupation` | string | Patient's occupation |
| `chr-is-foreigner` | boolean | Whether the patient is a foreign national |
| `chr-birth-year` | integer | Birth year (when exact DOB unknown) |
| `chr-org-unit-code` | string | Org unit code on address (province/district/village) |

### Identifier Slices

Inherited from DHIS2Patient and tightened:

| Slice | Card. | System |
|---|---|---|
| `clientHealthId` | 1..1 | `http://moh.gov.la/fhir/id/client-health-id` |
| `dhis2uid` | 1..1 | `http://dhis2.org/fhir/id/tracked-entity` |
| `cvid` | 0..1 | `http://moh.gov.la/fhir/id/cvid` |
| `greenCard` | 0..1 | `http://moh.gov.la/fhir/id/green-national-id` |
| `passport` | 0..1 | (v2-0203 PPN) |

### Example

```json
{
  "resourceType": "Patient",
  "identifier": [
    {
      "system": "http://moh.gov.la/fhir/id/client-health-id",
      "value": "17011994-2-4821",
      "type": {"coding": [{"code": "CHR"}]}
    }
  ],
  "name": [{"family": "Douangmala", "given": ["Phouthasinh"]}],
  "gender": "female",
  "birthDate": "1994-01-17",
  "address": [{"state": "Vientiane Capital", "district": "Chanthabuly", "city": "Anou"}]
}
```

## DHIS2CHRImmunization

The CHR Immunization profile extends `DHIS2IPSImmunization` with EIR-specific fields.

### Key Constraints

- **`patient`** — Required reference to `DHIS2CHRPatient`
- **`location`** — Reference to the facility where the vaccine was administered
- **`placeOfVaccination`** extension — Code: `mass`, `facility`, or `outreach`

### Place of Vaccination Codes

| Code | Display | Description |
|---|---|---|
| `mass` | Mass Campaign | Vaccination during a mass campaign |
| `facility` | Health Facility | Vaccination at a health facility |
| `outreach` | Outreach | Vaccination during community outreach |

### Example

```json
{
  "resourceType": "Immunization",
  "status": "completed",
  "vaccineCode": {
    "coding": [{"system": "http://hl7.org/fhir/sid/cvx", "code": "19", "display": "BCG"}]
  },
  "patient": {"reference": "Patient/chr-phouthasinh"},
  "occurrenceDateTime": "1994-03-17",
  "lotNumber": "BCG-2024-C001",
  "extension": [{
    "url": "http://moh.gov.la/fhir/StructureDefinition/chr-place-of-vaccination",
    "valueCode": "facility"
  }]
}
```
