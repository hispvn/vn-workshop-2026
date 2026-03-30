# Search Parameters

Every FHIR resource type defines a set of **search parameters** -- named fields that you can query against. Each parameter has a **type** that determines the syntax for specifying values and the operators available.

## Parameter Types

| Type | Description | Example Parameter | Example Value |
|------|-------------|-------------------|---------------|
| `string` | Free-text match (case-insensitive, starts-with by default) | `Patient?name` | `Smith` |
| `token` | Coded value, matched as system\|code or just code | `Patient?identifier` | `http://moh.gov.la/fhir/id/chr\|CHR-001` |
| `date` | Date or date-time, supports prefixes for comparison | `Patient?birthdate` | `ge2000-01-01` |
| `reference` | Reference to another resource | `Observation?subject` | `Patient/123` |
| `quantity` | Numeric value with optional unit | `Observation?value-quantity` | `gt5.4\|http://unitsofmeasure.org\|mg` |
| `number` | Plain numeric value | `RiskAssessment?probability` | `gt0.8` |
| `uri` | A URI value | `ValueSet?url` | `http://example.org/fhir/ValueSet/my-vs` |
| `composite` | Combines two parameters in a single expression | `Observation?code-value-quantity` | `8480-6$gt140` |
| `special` | Parameter-specific semantics | `Location?near` | `42.36\|-71.06\|10\|km` |

## Common Patient Search Parameters

These are the parameters you will use most often when searching for patients in a DHIS2-FHIR context:

| Parameter | Type | Searches Against | Example |
|-----------|------|------------------|---------|
| `identifier` | token | `Patient.identifier` | `identifier=http://moh.gov.la/fhir/id/chr\|CHR-001` |
| `name` | string | All parts of `Patient.name` | `name=Somsak` |
| `family` | string | `Patient.name.family` | `family=Vongsa` |
| `given` | string | `Patient.name.given` | `given=Kham` |
| `gender` | token | `Patient.gender` | `gender=female` |
| `birthdate` | date | `Patient.birthDate` | `birthdate=1990-05-20` |
| `phone` | token | `Patient.telecom` where system=phone | `phone=02012345678` |
| `address` | string | Any part of `Patient.address` | `address=Vientiane` |
| `address-city` | string | `Patient.address.city` | `address-city=Luang+Prabang` |
| `address-state` | string | `Patient.address.state` | `address-state=Savannakhet` |

## Token Format

Token parameters match coded values. The full format is:

```
[system]|[code]
```

Examples:

```
# Match by system and code (most specific)
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/chr|CHR-001

# Match by code only (any system)
GET /fhir/Patient?identifier=CHR-001

# Match by system only (any code in that system)
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/chr|
```

For `gender`, the token values come from a fixed code system, so you can use the code alone:

```
GET /fhir/Patient?gender=male
```

## String Modifiers

By default, string parameters use **case-insensitive starts-with** matching. Modifiers change this behavior:

| Modifier | Behavior | Example |
|----------|----------|---------|
| (none) | Case-insensitive, starts-with | `name=Som` matches "Somsak", "Somphone" |
| `:exact` | Case-sensitive, exact match | `name:exact=Somsak` matches only "Somsak" |
| `:contains` | Case-insensitive, substring match | `name:contains=sak` matches "Somsak" |

```
# Starts-with (default)
GET /fhir/Patient?family=Vong

# Exact match
GET /fhir/Patient?family:exact=Vongsa

# Substring match
GET /fhir/Patient?name:contains=kham
```

## Other Modifiers

These modifiers work across multiple parameter types:

| Modifier | Applicable To | Behavior | Example |
|----------|---------------|----------|---------|
| `:missing` | All types | Match resources where the element is absent or present | `phone:missing=true` |
| `:not` | Token | Match resources where the value is NOT the given code | `gender:not=male` |
| `:text` | Token | Match against the display text instead of the code | `identifier:text=passport` |

```
# Find patients without a phone number
GET /fhir/Patient?phone:missing=true

# Find patients who are not male
GET /fhir/Patient?gender:not=male
```

## Date Prefixes

Date parameters support comparison prefixes that let you search for ranges:

| Prefix | Meaning | Example |
|--------|---------|---------|
| `eq` | Equal (default) | `birthdate=eq2000-01-15` |
| `gt` | Greater than | `birthdate=gt2000-01-01` |
| `lt` | Less than | `birthdate=lt2000-12-31` |
| `ge` | Greater than or equal | `birthdate=ge2000-01-01` |
| `le` | Less than or equal | `birthdate=le2000-12-31` |
| `ne` | Not equal | `birthdate=ne2000-06-15` |
| `sa` | Starts after | `birthdate=sa2000-01-01` |
| `eb` | Ends before | `birthdate=eb2000-12-31` |

Date ranges are constructed by combining two date parameters:

```
# Born in the year 2000
GET /fhir/Patient?birthdate=ge2000-01-01&birthdate=le2000-12-31

# Born after March 2020
GET /fhir/Patient?birthdate=gt2020-03-31
```

Date precision matters. `birthdate=2000` matches any date in the year 2000. `birthdate=2000-06` matches any date in June 2000.

## Combining Parameters

There are two ways to combine search criteria, and they have different logical meanings.

**Repeated parameters (AND)** -- When you repeat the same parameter name, results must match ALL values:

```
# Born on or after 2000-01-01 AND on or before 2000-12-31
GET /fhir/Patient?birthdate=ge2000-01-01&birthdate=le2000-12-31
```

**Comma-separated values (OR)** -- When you separate values with a comma within one parameter, results must match ANY value:

```
# Gender is male OR female
GET /fhir/Patient?gender=male,female

# Has a CHR identifier OR a CVID identifier
GET /fhir/Patient?identifier=http://moh.gov.la/fhir/id/chr|,http://moh.gov.la/fhir/id/cvid|
```

**Different parameters (AND)** -- When you use different parameter names, results must match ALL of them:

```
# Female patients born after 2000
GET /fhir/Patient?gender=female&birthdate=gt2000-01-01
```

Combining these rules lets you build precise queries:

```
# Female patients named "Kham" born between 1990 and 2000
GET /fhir/Patient?given=Kham&gender=female&birthdate=ge1990-01-01&birthdate=le2000-12-31
```
