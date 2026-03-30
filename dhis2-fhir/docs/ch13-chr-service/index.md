# Community Health Record (CHR) Service

The **Community Health Record (CHR)** is a Lao PDR national health information system that manages patient registration and the **Electronic Immunization Registry (EIR)**. The original CHR service (HISPVietnam's `public-chr-service`) is implemented as a custom REST API backed by PostgreSQL and DHIS2 Tracker.

In this chapter, we explore how the same functionality can be expressed using **standard FHIR REST conventions** — so that patient search-or-create and immunization lookup work via standard FHIR operations on Patient and Immunization resources.

## What the CHR Service Does

The CHR service has three core operations:

1. **Search-or-Create** (`POST /chr/create`) — First search by unique identifiers (CVID, national ID, passport), then by demographics (name, sex, DOB, mobile, village). If no match is found, create a new record and return a generated `clientHealthId`.

2. **Search** (`GET /chr/search`) — Look up a CHR record by `clientHealthId`.

3. **EIR Lookup** (`GET /chr/eir`) — Get immunization history (from DHIS2 Tracker events) by `clientHealthId`.

## Why FHIR?

Expressing the CHR as FHIR resources provides:

- **Interoperability** — Any FHIR-compliant client can search patients and immunizations without knowing CHR-specific APIs.
- **Standard semantics** — Search-or-create maps to FHIR's conditional create (`POST` with `If-None-Exist` header).
- **Profile-based validation** — FSH profiles define exactly which identifiers, demographics, and extensions are required.
- **Ecosystem compatibility** — The same patient data can feed IPS documents, clinical decision support, and analytics.

## FHIR Resources

| CHR Concept | FHIR Resource |
|---|---|
| CHR patient record | `Patient` (DHIS2CHRPatient profile) |
| Client Health ID | `Patient.identifier` with system `http://moh.gov.la/fhir/id/client-health-id` |
| Immunization event | `Immunization` (DHIS2CHRImmunization profile) |
| Search by identifier | `GET /fhir/Patient?identifier=system\|value` |
| Search by demographics | `GET /fhir/Patient?given=X&family=Y&gender=Z&birthdate=D` |
| Search-or-create | `POST /fhir/Patient` with `If-None-Exist` header |
| EIR lookup | `GET /fhir/Immunization?patient=Patient/{id}` |

## Client Health ID

The CHR generates a unique `clientHealthId` for each registered patient. The format is:

```
DDMMYYYY-S-NNNN
```

Where:
- `DDMMYYYY` — date of birth
- `S` — sex code (1 = male, 2 = female)
- `NNNN` — 4-digit random sequence

Example: `17011994-2-4821` (female, born 17 January 1994).
