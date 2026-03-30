# Organization and Location Profiles

DHIS2's Organisation Unit is one of the three core dimensions of its data model (alongside data elements and time periods). A single org unit concept in DHIS2 simultaneously represents administrative identity, hierarchical position, and geographic location. FHIR separates these concerns into two resources: **Organization** (administrative) and **Location** (physical). This chapter covers both profiles.

## Design Pattern

```
DHIS2 Organisation Unit
    |
    ├── Administrative identity ──► DHIS2Organization
    |       (name, UID, hierarchy)
    |
    └── Physical site ──────────► DHIS2Location
            (GPS coordinates)       │
                                    └── managingOrganization ──► DHIS2Organization
```

The `managingOrganization` reference on Location links the physical and administrative representations. The `partOf` element on both Organization and Location preserves the DHIS2 hierarchy.

## DHIS2Organization

Maps the administrative identity of a DHIS2 Organisation Unit.

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `identifier` | 1..* MS | Must include DHIS2 UID |
| `identifier[dhis2uid]` | 1..1 MS | Sliced, system = `$DHIS2-OU`, type = `RI` |
| `identifier[dhis2code]` | 0..1 MS | Sliced, system = `$DHIS2-OU-CODE`, type = `XX` |
| `name` | 1..1 MS | Org unit name as displayed in DHIS2 |
| `partOf` | 0..1 MS | Parent org unit in the hierarchy |
| `type` | 0..* MS | Org unit level and/or group classification |

The identifier slicing uses a `#pattern` discriminator on `type` with `#open` rules. Two named slices are defined:

- **`dhis2uid`** (required): The auto-generated 11-character DHIS2 UID, typed as `RI` (Resource Identifier).
- **`dhis2code`** (optional): The human-readable code assigned by administrators (e.g., `OU_559`), typed as `XX` (Organization Identifier).

### FSH Source

```fsh
Profile: DHIS2Organization
Parent: Organization
Id: dhis2-organization
Title: "DHIS2 Organization"

* identifier 1..* MS
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
* identifier ^slicing.rules = #open

* identifier contains dhis2uid 1..1 MS and dhis2code 0..1 MS

// UID slice — always present
* identifier[dhis2uid].system = $DHIS2-OU (exactly)
* identifier[dhis2uid].type = $V2-0203#RI
* identifier[dhis2uid].value 1..1

// Code slice — optional human-readable code
* identifier[dhis2code].system = $DHIS2-OU-CODE (exactly)
* identifier[dhis2code].type = $V2-0203#XX
* identifier[dhis2code].value 1..1

* name 1..1 MS
* partOf MS
* type MS
```

### Organization Type

The `type` element can carry two kinds of classification simultaneously:

1. **Hierarchy level** from `DHIS2OrgUnitLevelCS`: `national`, `district`, `chiefdom`, `facility`
2. **Facility group** from `DHIS2OrgUnitGroupCS`: `CHP`, `CHC`, `MCHP`, `hospital`, `clinic`

A facility-level org unit typically has both:

```fsh
* type[0] = DHIS2OrgUnitLevelCS#facility "Facility"
* type[+] = DHIS2OrgUnitGroupCS#CHC "Community Health Centre"
```

### Example: Three-Level Hierarchy

The IG includes a three-level hierarchy demonstrating the `partOf` chain, identifier slices, and type classifications:

```
Level 1: Ministry of Health      (GOLswS44mh8, OU_525) -- national
  └─ Level 2: District A         (ImspTQPwCqd, OU_278371) -- district
       └─ Level 3: Facility Alpha (DiszpKrYNg8, OU_559) -- facility/CHC
```

```fsh
Instance: OrganizationMOH
InstanceOf: DHIS2Organization
Usage: #example
* identifier[dhis2uid].value = "GOLswS44mh8"
* identifier[dhis2code].value = "OU_525"
* name = "Ministry of Health"
* type = DHIS2OrgUnitLevelCS#national "National"
* active = true

Instance: OrganizationDistrictA
InstanceOf: DHIS2Organization
Usage: #example
* identifier[dhis2uid].value = "ImspTQPwCqd"
* identifier[dhis2code].value = "OU_278371"
* name = "District A Health Office"
* type = DHIS2OrgUnitLevelCS#district "District"
* partOf = Reference(OrganizationMOH)

Instance: OrganizationFacilityA
InstanceOf: DHIS2Organization
Usage: #example
* identifier[dhis2uid].value = "DiszpKrYNg8"
* identifier[dhis2code].value = "OU_559"
* name = "Facility Alpha Health Center"
* type[0] = DHIS2OrgUnitLevelCS#facility "Facility"
* type[+] = DHIS2OrgUnitGroupCS#CHC "Community Health Centre"
* partOf = Reference(OrganizationDistrictA)
```

### Example JSON

```json
{
  "resourceType": "Organization",
  "id": "OrganizationFacilityA",
  "meta": {
    "profile": ["http://dhis2.org/fhir/StructureDefinition/dhis2-organization"]
  },
  "identifier": [
    {
      "type": {
        "coding": [{ "system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "RI" }]
      },
      "system": "http://dhis2.org/fhir/id/org-unit",
      "value": "DiszpKrYNg8"
    },
    {
      "type": {
        "coding": [{ "system": "http://terminology.hl7.org/CodeSystem/v2-0203", "code": "XX" }]
      },
      "system": "http://dhis2.org/fhir/id/org-unit-code",
      "value": "OU_559"
    }
  ],
  "type": [
    {
      "coding": [{ "system": "http://dhis2.org/fhir/learning/CodeSystem/DHIS2OrgUnitLevelCS", "code": "facility" }]
    },
    {
      "coding": [{ "system": "http://dhis2.org/fhir/learning/CodeSystem/DHIS2OrgUnitGroupCS", "code": "CHC" }]
    }
  ],
  "active": true,
  "name": "Facility Alpha Health Center",
  "partOf": { "reference": "Organization/OrganizationDistrictA" }
}
```

## DHIS2Location

Captures the physical/geographic attributes of a DHIS2 Organisation Unit. In DHIS2, org units can carry GPS coordinates for GIS mapping features -- facility distribution maps, thematic maps, and catchment area analysis.

### Constraints

| Element | Cardinality | Notes |
|---------|-------------|-------|
| `name` | 1..1 MS | Location name (usually matches org unit name) |
| `position` | 0..1 MS | GPS coordinates |
| `position.latitude` | MS | Decimal degrees, WGS84 datum |
| `position.longitude` | MS | Decimal degrees, WGS84 datum |
| `managingOrganization` | 1..1 MS | Reference to DHIS2Organization |

The `managingOrganization` is constrained to only reference `DHIS2Organization`, ensuring the link between the physical and administrative representations is always present.

### FSH Source

```fsh
Profile: DHIS2Location
Parent: Location
Id: dhis2-location
Title: "DHIS2 Location"
Description: """
Represents the physical/geographic attributes of a DHIS2 Organisation Unit.
DHIS2 stores GPS coordinates (latitude/longitude) and optional polygon
geometries on org units.
"""

* name 1..1 MS
* position MS
* position.latitude MS
* position.longitude MS
* managingOrganization 1..1 MS
* managingOrganization only Reference(DHIS2Organization)
```

### Example: LocationFacilityA

```fsh
Instance: LocationFacilityA
InstanceOf: DHIS2Location
Usage: #example
* name = "Facility Alpha Health Center"
* status = #active
* position.latitude = -13.9626
* position.longitude = 33.7741
* managingOrganization = Reference(OrganizationFacilityA)
```

The coordinates (-13.9626, 33.7741) place this facility in Lilongwe, Malawi. In DHIS2, coordinates can be captured via manual entry, GPS on the Android Capture app, or bulk import from GIS datasets.

### Example JSON

```json
{
  "resourceType": "Location",
  "id": "LocationFacilityA",
  "meta": {
    "profile": ["http://dhis2.org/fhir/StructureDefinition/dhis2-location"]
  },
  "name": "Facility Alpha Health Center",
  "status": "active",
  "position": {
    "latitude": -13.9626,
    "longitude": 33.7741
  },
  "managingOrganization": {
    "reference": "Organization/OrganizationFacilityA"
  }
}
```

## Source Files

- Profile definitions: `ig/input/fsh/organization/profiles.fsh`
- Example instances: `ig/input/fsh/organization/examples.fsh`
