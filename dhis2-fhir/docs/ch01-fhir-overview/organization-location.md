# Organization and Location

Healthcare happens in places run by organizations. FHIR separates these into two distinct resources: **Organization** represents the administrative entity (a hospital, a district health office, an NGO), and **Location** represents the physical place (a building, a ward, a GPS coordinate). The two are linked but serve different purposes.

Understanding both resources is important because health facility hierarchies -- central to systems like DHIS2 -- require modeling both the organizational structure and the physical geography.

## Organization

### Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `identifier` | Identifier[] | 0..* | External identifiers (facility codes, DHIS2 UIDs) |
| `active` | boolean | 0..1 | Whether the organization is still active |
| `type` | CodeableConcept[] | 0..* | Kind of organization (hospital, department, government) |
| `name` | string | 0..1 | Human-readable name |
| `telecom` | ContactPoint[] | 0..* | Contact details |
| `address` | Address[] | 0..* | Physical addresses |
| `partOf` | Reference(Organization) | 0..1 | Parent organization in a hierarchy |
| `contact` | BackboneElement[] | 0..* | Contact persons for the organization |

### Organization JSON Example

```json
{
  "resourceType": "Organization",
  "id": "lilongwe-dho",
  "identifier": [
    {
      "system": "http://dhis2.org/orgunit",
      "value": "Rp2x7kJgFhG"
    },
    {
      "system": "http://moh.gov.mw/facility-code",
      "value": "MW-LLW-DHO"
    }
  ],
  "active": true,
  "type": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/organization-type",
          "code": "govt",
          "display": "Government"
        }
      ]
    }
  ],
  "name": "Lilongwe District Health Office",
  "telecom": [
    {
      "system": "phone",
      "value": "+265 1 753 200"
    }
  ],
  "address": [
    {
      "city": "Lilongwe",
      "country": "MW"
    }
  ],
  "partOf": {
    "reference": "Organization/central-region",
    "display": "Central Region Health Office"
  }
}
```

The `partOf` element is how you build organizational hierarchies. This district health office sits below the Central Region Health Office, which in turn might sit below the national Ministry of Health. Each level is its own Organization resource linked upward through `partOf`.

## Location

### Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `identifier` | Identifier[] | 0..* | External identifiers |
| `status` | code | 0..1 | `active` \| `suspended` \| `inactive` |
| `name` | string | 0..1 | Human-readable name |
| `description` | string | 0..1 | Additional details about the location |
| `type` | CodeableConcept[] | 0..* | Type of location (hospital, clinic, ward) |
| `telecom` | ContactPoint[] | 0..* | Contact details |
| `address` | Address | 0..1 | Physical address |
| `position` | BackboneElement | 0..1 | GPS coordinates (latitude, longitude, altitude) |
| `managingOrganization` | Reference(Organization) | 0..1 | Organization responsible for this location |
| `partOf` | Reference(Location) | 0..1 | Parent location in a hierarchy |
| `physicalType` | CodeableConcept | 0..1 | Physical form: building, room, area, etc. |

### Location JSON Example

```json
{
  "resourceType": "Location",
  "id": "area-25-health-centre",
  "identifier": [
    {
      "system": "http://dhis2.org/orgunit",
      "value": "Kj8b2Aq9xmT"
    }
  ],
  "status": "active",
  "name": "Area 25 Health Centre",
  "type": [
    {
      "coding": [
        {
          "system": "http://terminology.hl7.org/CodeSystem/v3-RoleCode",
          "code": "HOSP",
          "display": "Hospital"
        }
      ]
    }
  ],
  "address": {
    "line": ["Area 25"],
    "city": "Lilongwe",
    "district": "Lilongwe District",
    "country": "MW"
  },
  "position": {
    "longitude": 33.7741,
    "latitude": -13.9626
  },
  "managingOrganization": {
    "reference": "Organization/lilongwe-dho",
    "display": "Lilongwe District Health Office"
  },
  "partOf": {
    "reference": "Location/lilongwe-district",
    "display": "Lilongwe District"
  }
}
```

The `position` element holds GPS coordinates -- useful for mapping health facilities. Note that FHIR uses `longitude` and `latitude` as separate decimal fields (not a combined string). The `managingOrganization` links this physical location to the Organization that runs it.

## Organization vs. Location: When to Use Which

| Scenario | Resource |
|----------|----------|
| "Lilongwe DHO manages 47 facilities" | Organization |
| "Area 25 Health Centre is at GPS -13.96, 33.77" | Location |
| "The pharmacy is on the second floor of the hospital" | Location (partOf another Location) |
| "The pediatrics department reports to the hospital" | Organization (partOf another Organization) |

In many cases, a health facility is represented as both an Organization (the administrative entity) and a Location (the physical place), linked via `managingOrganization`.

## Common Patterns and Gotchas

**Dual hierarchy.** Organizations and Locations each have their own `partOf` hierarchy. These hierarchies often mirror each other but do not have to. A single organization can manage multiple locations.

**Position coordinates.** Latitude comes before longitude in everyday speech, but in the FHIR Location resource both are named fields, so order does not matter in JSON. Just make sure you do not swap the values.

**Facility codes.** Health facilities often have multiple identifiers -- a government facility code, a DHIS2 UID, an MFL (Master Facility List) code. Use separate identifier entries with different systems for each.

## Relationship to DHIS2

Organization and Location together map to the DHIS2 **Organisation Unit** hierarchy. DHIS2 organisation units combine administrative identity and physical location into one concept, while FHIR separates them. When mapping, each DHIS2 organisation unit typically becomes both an Organization and a Location. The DHIS2 hierarchy (country, region, district, facility) is represented through the `partOf` chains. The organisation unit UID becomes an identifier on both resources. Coordinates stored in DHIS2 map to `Location.position`.
