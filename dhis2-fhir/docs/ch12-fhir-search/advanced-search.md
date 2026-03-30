# Advanced Search

Beyond basic parameter matching, FHIR provides mechanisms for traversing references between resources, controlling what data is returned, and organizing results.

## Chaining

Chaining lets you search a resource based on properties of a **referenced** resource. The syntax uses dot notation to traverse the reference:

```
GET /fhir/Observation?subject.name=Jane
```

This returns all Observations where the referenced Patient (the subject) has "Jane" in their name. Without chaining, you would need two separate queries -- first find the Patient, then search Observations by patient ID.

You can chain multiple levels deep:

```
# Observations where the patient's managing organization is named "District Hospital"
GET /fhir/Observation?subject.organization.name=District+Hospital
```

When a reference parameter can point to multiple resource types, specify the type explicitly:

```
# The "subject" could be Patient, Group, etc. -- specify Patient
GET /fhir/Observation?subject:Patient.birthdate=gt2000-01-01
```

## Reverse Chaining (`_has`)

Reverse chaining searches in the opposite direction -- find resources that are **referenced by** other resources matching certain criteria:

```
# Find Patients who have at least one Observation with code 8480-6 (systolic BP)
GET /fhir/Patient?_has:Observation:subject:code=8480-6
```

The syntax is `_has:[ResourceType]:[reference parameter]:[search parameter]=[value]`.

Breaking down the example:
- Search for `Patient` resources
- That are referenced by `Observation` resources
- Via the `subject` reference parameter
- Where the Observation's `code` equals `8480-6`

A practical use case: find all patients who have received a specific vaccine:

```
GET /fhir/Patient?_has:Immunization:patient:vaccine-code=19
```

## `_include` and `_revinclude`

By default, a search returns only the matching resources. `_include` and `_revinclude` let you pull in **related resources** in the same response, avoiding the need for follow-up queries.

**`_include`** follows a reference **from** the matching resource to include the target:

```
# Search Observations and include the referenced Patient for each
GET /fhir/Observation?code=8480-6&_include=Observation:subject
```

The response Bundle contains both the matching Observations (with `search.mode` = `match`) and the referenced Patients (with `search.mode` = `include`).

**`_revinclude`** goes the other direction -- include resources that **reference** the matching resources:

```
# Search Patients and include all their Observations
GET /fhir/Patient?name=Smith&_revinclude=Observation:subject
```

The format is `_include=[SourceType]:[searchParam]` or `_include=[SourceType]:[searchParam]:[TargetType]`.

Use `:iterate` to follow references recursively:

```
# Include the Patient AND the Patient's managing Organization
GET /fhir/Observation?code=8480-6&_include=Observation:subject&_include:iterate=Patient:organization
```

## `_sort`

Control the order of results with `_sort`:

```
# Sort by family name ascending
GET /fhir/Patient?_sort=family

# Sort by birthdate descending (prefix with -)
GET /fhir/Patient?_sort=-birthdate

# Sort by multiple fields
GET /fhir/Patient?_sort=family,-birthdate
```

The `-` prefix indicates descending order. Multiple sort fields are separated by commas and applied in order.

## `_summary` and `_elements`

These parameters control how much data is returned for each resource, which is useful for reducing payload size.

**`_summary`** returns a predefined subset of each resource:

| Value | Returns |
|-------|---------|
| `true` | Elements marked as "summary" in the definition |
| `text` | Only the `text`, `id`, `meta`, and top-level mandatory elements |
| `data` | Everything except `text` |
| `count` | No resources at all -- just `Bundle.total` |
| `false` | Full resources (default) |

```
# Just get the count of matching patients
GET /fhir/Patient?family=Smith&_summary=count

# Get summary-level data (smaller payload)
GET /fhir/Patient?family=Smith&_summary=true
```

**`_elements`** gives fine-grained control -- specify exactly which top-level elements to include:

```
# Return only name and birthDate for each patient
GET /fhir/Patient?family=Smith&_elements=name,birthDate
```

The `resourceType`, `id`, and `meta` elements are always included regardless of the `_elements` list.

## Compartment Search

FHIR defines **compartments** -- logical groupings of resources related to a specific entity. The most common compartment is the **Patient compartment**, which includes all resources associated with a particular patient.

Instead of searching with a subject parameter:

```
GET /fhir/Observation?subject=Patient/123
```

You can use compartment syntax:

```
GET /fhir/Patient/123/Observation
```

Both queries return the same results -- all Observations for Patient 123. The compartment syntax is more intuitive and can be combined with additional search parameters:

```
# All blood pressure observations for Patient 123
GET /fhir/Patient/123/Observation?code=85354-9

# All encounters for Patient 123 in 2024
GET /fhir/Patient/123/Encounter?date=ge2024-01-01&date=le2024-12-31
```

You can also search all resources in a patient's compartment:

```
# Everything related to Patient 123
GET /fhir/Patient/123/*
```

## Combining Advanced Features

These features can be combined to build powerful queries with minimal round trips:

```
# Find all patients named "Kham", include their observations,
# sort by birthdate descending, return 20 per page
GET /fhir/Patient?name=Kham&_revinclude=Observation:subject&_sort=-birthdate&_count=20
```

```
# Find observations for patients born after 2000,
# include the patient resource, sort by date
GET /fhir/Observation?subject:Patient.birthdate=gt2000-01-01&_include=Observation:subject&_sort=-date
```

> **Note:** Not all servers support every advanced feature. Check the server's **CapabilityStatement** (at `GET /fhir/metadata`) to see which search parameters, includes, and modifiers are supported. The CapabilityStatement is your contract with the server -- if a feature is not listed, the server may silently ignore it.
