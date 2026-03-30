# CHR FHIR API Reference

## Base URL

```
http://localhost:8000/fhir
```

## CapabilityStatement

```bash
curl http://localhost:8000/fhir/metadata
```

## Patient Endpoints

### Search by Identifier

```bash
# By Client Health ID
curl "http://localhost:8000/fhir/Patient?identifier=http://moh.gov.la/fhir/id/client-health-id|17011994-2-4821"

# By CVID
curl "http://localhost:8000/fhir/Patient?identifier=http://moh.gov.la/fhir/id/cvid|CVID-30481726"

# By National ID (Green Card)
curl "http://localhost:8000/fhir/Patient?identifier=http://moh.gov.la/fhir/id/green-national-id|GC-481726305917"
```

### Search by Demographics

```bash
curl "http://localhost:8000/fhir/Patient?given=Phouthasinh&family=Douangmala&gender=female&birthdate=1994-01-17"
```

### Search with Multiple Parameters

```bash
# Name + phone
curl "http://localhost:8000/fhir/Patient?name=Somchai&phone=856"

# Address search
curl "http://localhost:8000/fhir/Patient?address-city=Vientiane&address-state=Vientiane%20Capital"
```

### Read Patient

```bash
curl http://localhost:8000/fhir/Patient/seed-patient-101
```

### Create Patient (Conditional)

```bash
curl -X POST http://localhost:8000/fhir/Patient \
  -H "Content-Type: application/json" \
  -H "If-None-Exist: identifier=http://moh.gov.la/fhir/id/cvid|NEW-CVID-123" \
  -d '{
    "resourceType": "Patient",
    "name": [{"family": "Keomany", "given": ["Bounmy"]}],
    "gender": "male",
    "birthDate": "1990-06-15",
    "address": [{"state": "Vientiane Capital", "district": "Xaysetha", "city": "Dongdok", "country": "Lao PDR"}]
  }'
```

Response includes a generated `clientHealthId` in the identifiers.

### Update Patient

```bash
curl -X PUT http://localhost:8000/fhir/Patient/seed-patient-101 \
  -H "Content-Type: application/json" \
  -d '{ ... }'
```

## Immunization Endpoints

### Search by Patient

```bash
curl "http://localhost:8000/fhir/Immunization?patient=Patient/seed-patient-101"
```

### Read Immunization

```bash
curl http://localhost:8000/fhir/Immunization/imm-seed-patient-101-01
```

### Create Immunization

```bash
curl -X POST http://localhost:8000/fhir/Immunization \
  -H "Content-Type: application/json" \
  -d '{
    "resourceType": "Immunization",
    "status": "completed",
    "vaccineCode": {"coding": [{"system": "http://hl7.org/fhir/sid/cvx", "code": "19", "display": "BCG"}]},
    "patient": {"reference": "Patient/seed-patient-101"},
    "occurrenceDateTime": "2024-01-15",
    "lotNumber": "BCG-2024-A001"
  }'
```

## Search Parameters

| Parameter | Type | Description |
|---|---|---|
| `identifier` | token | `system\|value` or just `value` |
| `name` | string | Substring match across given + family |
| `given` | string | Given (first) name |
| `family` | string | Family (last) name |
| `gender` | token | `male` or `female` |
| `birthdate` | date | Exact date match |
| `phone` | token | Phone number (digit-only comparison) |
| `address` | string | General address text search |
| `address-city` | string | Village/city name |
| `address-state` | string | Province/state name |
| `_count` | number | Page size (default 20) |
| `_offset` | number | Pagination offset |

## Response Format

All responses use `application/fhir+json`:

- **Search** → `Bundle` with `type: "searchset"` and `total` count
- **Read** → The resource JSON directly
- **Create** → The created resource with `201` status and `Location` header
- **Error** → `OperationOutcome` with severity, code, and diagnostics
