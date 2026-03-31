# FHIR Search

FHIR is built on REST. Every resource has a URL, and you interact with resources using standard HTTP methods -- `GET` to read, `POST` to create, `PUT` to update, `DELETE` to remove. But reading a single resource by ID is rarely enough. In practice, you need to **find** resources that match criteria: all patients born after 2000, observations with a certain code, encounters at a specific facility.

That is what FHIR search provides -- a standardized query language layered on top of REST. Instead of each server inventing its own query syntax, FHIR defines a common set of search parameters, operators, and response formats that work the same way across implementations.

## Why Search Matters for DHIS2-to-FHIR

When DHIS2 data is mapped to FHIR resources and stored on a FHIR server, search becomes the primary way that downstream systems consume the data:

- **Patient registries** need to look up patients by identifier, name, or demographic combination before creating a new record (to avoid duplicates).
- **Clinical decision support** queries observations for a specific patient -- blood pressure readings, lab results, or questionnaire responses.
- **Aggregate reporting** uses search to count resources matching criteria (e.g., all immunizations in a district during a reporting period).
- **Integration engines** pull changed resources since a given timestamp to keep systems in sync.

In the Lao PDR context, the health registry must support searching patients across six identifier types and multiple attribute combinations. Understanding FHIR search is essential to implementing these patterns correctly.

## Available FHIR Endpoints

The renderer's FHIR API (mounted at `/fhir/`) provides these searchable resources:

| Endpoint | Key Parameters |
|----------|---------------|
| `GET /fhir/Patient` | `name`, `given`, `family`, `gender`, `birthdate`, `identifier`, `phone`, `address` |
| `GET /fhir/Questionnaire` | `name`, `title`, `status` |
| `GET /fhir/QuestionnaireResponse` | `questionnaire`, `subject`, `status` |
| `GET /fhir/Immunization` | `patient` |
| `GET /fhir/ValueSet` | `name`, `url` |
| `GET /fhir/ValueSet/$expand` | `url` (returns expanded ValueSet with `expansion.contains`) |
| `GET /fhir/CodeSystem` | `name`, `url` |
| `GET /fhir/Bundle` | `type` |

All search endpoints return FHIR searchset Bundles and support `_count` and `_offset` for pagination.

## What This Chapter Covers

- [Search Basics](search-basics.md) -- HTTP mechanics, searchset Bundles, pagination, and response codes
- [Search Parameters](search-parameters.md) -- Parameter types, modifiers, date prefixes, and combining parameters
- [Advanced Search](advanced-search.md) -- Chaining, includes, sorting, summary views, and compartment search
- [Lao PDR Registry Patterns](lao-registry-patterns.md) -- Concrete queries for the Lao health registry use cases
