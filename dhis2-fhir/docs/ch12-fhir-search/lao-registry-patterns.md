# Lao PDR Registry Search Patterns

The Lao PDR health registry requires searching patients across multiple identifier types and attribute combinations. This chapter translates those requirements into concrete FHIR REST queries.

## Identifier Systems

The Lao registry uses six identifier types, each with its own FHIR `system` URI:

| Identifier | System URI | Example Value |
|------------|-----------|---------------|
| CHR (Civil Health Registry) | `http://moh.gov.la/fhir/id/chr` | `CHR-20240001` |
| CVID (COVID Vaccination ID) | `http://moh.gov.la/fhir/id/cvid` | `CVID-2021-55432` |
| Insurance Number | `http://moh.gov.la/fhir/id/insurance` | `INS-987654` |
| Green Card (National ID) | `http://moh.gov.la/fhir/id/green-national-id` | `LA-1984-34521` |
| Passport | `urn:oid:2.16.840.1.113883.4.330.418` | `P1234567` |
| Family Book | `http://moh.gov.la/fhir/id/family-book` | `FB-VTE-2020-003` |

## Search by Identifier

Each identifier type uses the `identifier` token parameter with the full `system|value` syntax.

**CHR:**

```
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/chr|CHR-20240001
```

**CVID:**

```
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/cvid|CVID-2021-55432
```

**Insurance Number:**

```
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/insurance|INS-987654
```

**Green Card (National ID):**

```
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/green-national-id|LA-1984-34521
```

**Passport:**

```
GET /fhir/Patient?identifier=urn:oid:2.16.840.1.113883.4.330.418|P1234567
```

**Family Book:**

```
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/family-book|FB-VTE-2020-003
```

To find all patients who have **any** identifier in a given system (regardless of value), use a trailing pipe:

```
# All patients with a CHR number
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/chr|
```

## Search by Attribute Combinations

The Lao registry defines several attribute-based search patterns for situations where the patient's identifier is not known. Each pattern combines multiple parameters with AND semantics.

### Firstname + Lastname + Date of Birth + Sex

```
GET /fhir/Patient?given=Kham&family=Vongsa&birthdate=1990-05-20&gender=male
```

Use `:exact` on name parameters when you need a precise match rather than starts-with:

```
GET /fhir/Patient?given:exact=Kham&family:exact=Vongsa&birthdate=1990-05-20&gender=male
```

### Name + Date of Birth + Sex + District

```
GET /fhir/Patient?name=Kham&birthdate=1990-05-20&gender=male&address-city=Xaysettha
```

Using `name` instead of `given`/`family` searches across all name parts, which is useful when you are not sure which part of the name was recorded as given vs family.

### Phone + Date of Birth + Sex + District

```
GET /fhir/Patient?phone=02012345678&birthdate=1990-05-20&gender=male&address-city=Xaysettha
```

### Family Book + Date of Birth + Sex

```
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/family-book|FB-VTE-2020-003&birthdate=1990-05-20&gender=male
```

This pattern is common because multiple family members share the same Family Book number. Adding date of birth and sex narrows the result to a single individual.

## Mapping Table: Lao Requirement to FHIR Query

| Search Pattern | FHIR Parameters | Example |
|----------------|-----------------|---------|
| By CHR | `identifier` (token) | `identifier=http://moh.gov.la/fhir/id/chr\|CHR-20240001` |
| By CVID | `identifier` (token) | `identifier=http://moh.gov.la/fhir/id/cvid\|CVID-2021-55432` |
| By Insurance | `identifier` (token) | `identifier=http://moh.gov.la/fhir/id/insurance\|INS-987654` |
| By Green Card | `identifier` (token) | `identifier=http://moh.gov.la/fhir/id/green-national-id\|LA-1984-34521` |
| By Passport | `identifier` (token) | `identifier=urn:oid:2.16.840.1.113883.4.330.418\|P1234567` |
| By Family Book | `identifier` (token) | `identifier=http://moh.gov.la/fhir/id/family-book\|FB-VTE-2020-003` |
| Name + DOB + Sex | `given` + `family` + `birthdate` + `gender` | `given=Kham&family=Vongsa&birthdate=1990-05-20&gender=male` |
| Name + DOB + Sex + District | `name` + `birthdate` + `gender` + `address-city` | `name=Kham&birthdate=1990-05-20&gender=male&address-city=Xaysettha` |
| Phone + DOB + Sex + District | `phone` + `birthdate` + `gender` + `address-city` | `phone=02012345678&birthdate=1990-05-20&gender=male&address-city=Xaysettha` |
| Family Book + DOB + Sex | `identifier` + `birthdate` + `gender` | `identifier=http://moh.gov.la/fhir/id/family-book\|FB-VTE-2020-003&birthdate=1990-05-20&gender=male` |

## CapabilityStatement and SearchParameter Definitions

A FHIR server advertises which search parameters it supports in its **CapabilityStatement** resource, available at the `/metadata` endpoint:

```
GET /fhir/metadata
```

The response includes a `rest.resource` entry for each supported resource type, listing its search parameters:

```json
{
  "type": "Patient",
  "searchParam": [
    { "name": "identifier", "type": "token" },
    { "name": "name", "type": "string" },
    { "name": "family", "type": "string" },
    { "name": "given", "type": "string" },
    { "name": "gender", "type": "token" },
    { "name": "birthdate", "type": "date" },
    { "name": "phone", "type": "token" },
    { "name": "address-city", "type": "string" }
  ]
}
```

### Custom SearchParameter Definitions

The standard `identifier` search parameter searches across all identifiers. If you need to search by a **specific** identifier type without specifying the system each time, you can define a custom **SearchParameter** resource:

```json
{
  "resourceType": "SearchParameter",
  "url": "http://moh.gov.la/fhir/SearchParameter/patient-chr",
  "name": "chr",
  "status": "active",
  "description": "Search patients by CHR (Civil Health Registry) number",
  "code": "chr",
  "base": ["Patient"],
  "type": "token",
  "expression": "Patient.identifier.where(system='http://moh.gov.la/fhir/id/chr')"
}
```

With this SearchParameter loaded on the server, you can search more concisely:

```
# Instead of:
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/chr|CHR-20240001

# You can use:
GET /fhir/Patient?chr=CHR-20240001
```

This is optional -- the standard `identifier` parameter with `system|value` syntax works on every FHIR server. Custom SearchParameters are a convenience that requires server configuration.

### Implementation Considerations

When deploying these search patterns on a FHIR server for the Lao registry, keep the following in mind:

- **Verify support first.** Before building a client that relies on `address-city` or `phone`, confirm that the target server includes these parameters in its CapabilityStatement. Some servers support only a subset of the standard parameters.
- **Indexing matters.** Search parameters are only useful if the server indexes them. Loading a custom SearchParameter definition does not automatically create an index -- most servers require a reindex operation.
- **Encoding special characters.** The pipe character (`|`) in token values must be URL-encoded as `%7C` in some HTTP clients, though most FHIR-aware clients handle this automatically.
- **Approximate matching.** For name searches where spelling may vary (common with transliterated Lao names), consider using the `:contains` modifier or a server that supports phonetic matching.
