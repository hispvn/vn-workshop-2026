# CHR to FHIR Mapping

This section details how each CHR service concept maps to FHIR resources and operations.

## Patient Identifiers

The CHR service uses several identifier types. Each maps to a `Patient.identifier` slice with a specific system URI:

| CHR Field | FHIR System URI | Type Code | Profile Slice |
|---|---|---|---|
| `clientHealthId` | `http://moh.gov.la/fhir/id/client-health-id` | CHR | `clientHealthId` (1..1) |
| `cvid` | `http://moh.gov.la/fhir/id/cvid` | CVID | `cvid` (0..1) |
| `nationalId` | `http://moh.gov.la/fhir/id/green-national-id` | GREENCARD | `greenCard` (0..1) |
| `passport` | (standard v2-0203) | PPN | `passport` (0..1) |

## Demographics Mapping

| CHR Field | FHIR Path |
|---|---|
| `firstName` | `Patient.name.given` |
| `lastName` | `Patient.name.family` |
| `sex` | `Patient.gender` |
| `dob` | `Patient.birthDate` |
| `mobile` | `Patient.telecom` (system=phone) |
| `villageCode` | `Patient.address.city` |
| `districtCode` | `Patient.address.district` |
| `provinceCode` | `Patient.address.state` |
| `nationality` | Extension: `chr-nationality` |
| `ethnicity` | Extension: `chr-ethnicity` |
| `occupation` | Extension: `chr-occupation` |

## Search Operations

### Case 1: Search by Unique Identifier

The CHR service searches by CVID, national ID, or passport — expecting at most one match.

**CHR**: `POST /chr/create` with `cvid=123456`
**FHIR**: `GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/cvid|123456`

### Case 2: Search by Demographics

The CHR service searches by first name + last name + sex + DOB + mobile + village using AND logic.

**CHR**: `POST /chr/create` with `firstName=Phouthasinh&lastName=Douangmala&sex=female&dob=1994-01-17`
**FHIR**: `GET /fhir/Patient?given=Phouthasinh&family=Douangmala&gender=female&birthdate=1994-01-17`

### Search-or-Create (Conditional Create)

The CHR's main `POST /chr/create` endpoint implements search-then-create logic. In FHIR, this is a **conditional create**:

```http
POST /fhir/Patient
Content-Type: application/fhir+json
If-None-Exist: identifier=http://moh.gov.la/fhir/id/cvid|123456

{
  "resourceType": "Patient",
  "name": [{"family": "Douangmala", "given": ["Phouthasinh"]}],
  "gender": "female",
  "birthDate": "1994-01-17"
}
```

Behavior:
- **0 matches** → Create the patient, generate `clientHealthId`, return `201 Created`
- **1 match** → Return the existing patient with `200 OK`
- **>1 matches** → Return `412 Precondition Failed`

## EIR (Immunization History)

**CHR**: `GET /chr/eir?clientHealthId=17011994-2-4821`
**FHIR**: `GET /fhir/Immunization?patient=Patient/{id}`

The response is a FHIR `searchset` Bundle containing Immunization resources.
