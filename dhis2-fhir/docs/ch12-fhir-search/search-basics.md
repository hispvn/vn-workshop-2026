# Search Basics

FHIR search is performed by sending an HTTP request to a FHIR server endpoint. The server evaluates the search criteria against its stored resources and returns the results in a **searchset Bundle**.

## HTTP GET vs POST

There are two ways to submit a search request.

**GET with query parameters** is the most common approach. Parameters are appended to the resource type URL:

```
GET /fhir/Patient?family=Smith&birthdate=2000-01-15
```

**POST to the `_search` endpoint** is used when the query string would be too long for a URL (some servers or proxies limit URL length to around 2,000 characters), or when you want to avoid logging sensitive search criteria in server access logs:

```
POST /fhir/Patient/_search
Content-Type: application/x-www-form-urlencoded

family=Smith&birthdate=2000-01-15
```

Both forms are semantically identical -- the server processes them the same way. Use GET for everyday queries and POST when query length or privacy is a concern.

## The Searchset Bundle

A search always returns a **Bundle** with `type` set to `searchset`. Even if there is only one matching resource (or none), the response is still a Bundle:

```json
{
  "resourceType": "Bundle",
  "type": "searchset",
  "total": 2,
  "link": [
    {
      "relation": "self",
      "url": "http://example.org/fhir/Patient?family=Smith&_count=10"
    },
    {
      "relation": "next",
      "url": "http://example.org/fhir/Patient?family=Smith&_count=10&_offset=10"
    }
  ],
  "entry": [
    {
      "fullUrl": "http://example.org/fhir/Patient/123",
      "resource": {
        "resourceType": "Patient",
        "id": "123",
        "name": [{ "family": "Smith", "given": ["John"] }]
      },
      "search": {
        "mode": "match"
      }
    },
    {
      "fullUrl": "http://example.org/fhir/Patient/456",
      "resource": {
        "resourceType": "Patient",
        "id": "456",
        "name": [{ "family": "Smith", "given": ["Jane"] }]
      },
      "search": {
        "mode": "match"
      }
    }
  ]
}
```

Key elements:

- **`total`** -- The total number of resources matching the query (may be absent if the server cannot determine the count efficiently).
- **`link`** -- Navigation links for pagination.
- **`entry[]`** -- The matching resources.
- **`entry[].search.mode`** -- Either `match` (the resource matched the search criteria) or `include` (the resource was pulled in via `_include` or `_revinclude`).

## Pagination

Most servers limit the number of results returned in a single response. Pagination is controlled with two parameters:

| Parameter | Description | Default |
|-----------|-------------|---------|
| `_count` | Maximum number of results per page | Server-defined (often 10 or 20) |
| `_offset` | Number of results to skip | 0 |

Request the first 5 patients:

```
GET /fhir/Patient?family=Smith&_count=5
```

If there are more results, the Bundle includes a `next` link:

```json
{
  "link": [
    { "relation": "self", "url": ".../Patient?family=Smith&_count=5" },
    { "relation": "next", "url": ".../Patient?family=Smith&_count=5&_offset=5" }
  ]
}
```

To get the next page, follow the `next` URL. When there is no `next` link, you have reached the last page.

Some servers also provide `previous`, `first`, and `last` links. The `next` link is the only one guaranteed to be present when more results exist.

> **Tip:** Always use `_count` in production queries. Without it, a broad search could return thousands of resources in a single response, causing timeouts or memory issues.

## The `total` Element

The `total` element in the Bundle tells you how many resources matched the query across all pages. Servers may choose not to return it if computing the total is expensive. You can request it explicitly:

```
GET /fhir/Patient?family=Smith&_total=accurate
```

Possible values for `_total`:

| Value | Behavior |
|-------|----------|
| `none` | Do not return a total |
| `estimate` | Return an approximate count |
| `accurate` | Return the exact count (may be slow) |

## Response Codes

| Status | Meaning |
|--------|---------|
| `200 OK` | Search succeeded. Results are in the Bundle (may be empty). |
| `400 Bad Request` | Invalid search parameter or syntax. Check the OperationOutcome in the response body. |
| `401 Unauthorized` | Authentication required. |
| `403 Forbidden` | Authenticated but not authorized for this search. |

A search that matches zero resources still returns `200 OK` with an empty Bundle -- this is not an error. The `400` code is reserved for syntactically invalid queries (e.g., using a parameter the server does not support).

## OperationOutcome

When a search fails or has issues, the server returns an **OperationOutcome** resource describing what went wrong:

```json
{
  "resourceType": "OperationOutcome",
  "issue": [
    {
      "severity": "error",
      "code": "invalid",
      "details": {
        "text": "Unknown search parameter 'birthDay' for resource type 'Patient'. Did you mean 'birthdate'?"
      }
    }
  ]
}
```

Servers may also include an OperationOutcome as a Bundle entry (with `search.mode` set to `outcome`) to provide warnings about the search -- for example, that an unsupported parameter was silently ignored.

## System-Level Search

You can search across all resource types using the base URL:

```
GET /fhir?_id=abc123
GET /fhir?_lastUpdated=gt2025-01-01
```

This is rarely needed in practice, but useful when you want to find a resource and do not know its type.
