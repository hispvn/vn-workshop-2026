# Patient

The Patient resource is the central individual in almost every healthcare workflow. It holds demographic and administrative information about a person receiving care -- name, date of birth, gender, addresses, contact details, and identifiers. Nearly every other clinical resource (Observation, Encounter, Condition) references a Patient as its subject, making it the anchor of the clinical data graph.

Use a Patient resource whenever you need to represent a specific individual in the health system. This includes people enrolled in treatment programs, mothers in antenatal care, children in immunization schedules, or any person whose health data you are tracking.

## Key Elements

| Element | Type | Cardinality | Description |
|---------|------|-------------|-------------|
| `identifier` | Identifier[] | 0..* | External identifiers for the patient (national ID, DHIS2 UID, MRN) |
| `active` | boolean | 0..1 | Whether the patient record is in active use |
| `name` | HumanName[] | 0..* | Names associated with the patient |
| `telecom` | ContactPoint[] | 0..* | Phone numbers, email addresses |
| `gender` | code | 0..1 | `male` \| `female` \| `other` \| `unknown` |
| `birthDate` | date | 0..1 | Date of birth |
| `address` | Address[] | 0..* | Addresses for the patient |
| `contact` | BackboneElement[] | 0..* | Contact parties (next of kin, guardians) |
| `managingOrganization` | Reference(Organization) | 0..1 | Organization responsible for the record |

## Identifiers: The System + Value Pattern

One of the most important patterns in FHIR is how identifiers work. A patient typically has multiple identifiers from different systems -- a national ID, a hospital medical record number, a DHIS2 tracked entity UID. Each identifier is a pair: a `system` (a URI that names the namespace) and a `value` (the actual ID within that namespace).

This design lets you unambiguously identify a patient across systems without collisions. The system URI does not need to resolve to a real webpage -- it just needs to be a globally unique namespace.

## Complete JSON Example

```json
{
  "resourceType": "Patient",
  "id": "mw-patient-5428",
  "meta": {
    "profile": [
      "http://dhis2.org/fhir/StructureDefinition/DHISPatient"
    ]
  },
  "identifier": [
    {
      "use": "official",
      "system": "http://nationalid.gov.mw",
      "value": "MW-19900315-4821"
    },
    {
      "use": "secondary",
      "system": "http://dhis2.org/trackedentity",
      "value": "DXz7q34bVcR"
    }
  ],
  "active": true,
  "name": [
    {
      "use": "official",
      "family": "Banda",
      "given": ["Grace", "Thandiwe"]
    }
  ],
  "telecom": [
    {
      "system": "phone",
      "value": "+265 888 123 456",
      "use": "mobile"
    }
  ],
  "gender": "female",
  "birthDate": "1990-03-15",
  "address": [
    {
      "use": "home",
      "type": "physical",
      "line": ["14 Kamuzu Procession Road"],
      "city": "Lilongwe",
      "district": "Lilongwe District",
      "country": "MW"
    }
  ],
  "contact": [
    {
      "relationship": [
        {
          "coding": [
            {
              "system": "http://terminology.hl7.org/CodeSystem/v2-0131",
              "code": "N",
              "display": "Next-of-Kin"
            }
          ]
        }
      ],
      "name": {
        "family": "Banda",
        "given": ["James"]
      },
      "telecom": [
        {
          "system": "phone",
          "value": "+265 999 654 321"
        }
      ]
    }
  ],
  "managingOrganization": {
    "reference": "Organization/lilongwe-central-hospital",
    "display": "Lilongwe Central Hospital"
  }
}
```

Notice that the patient has two identifiers -- a national ID and a DHIS2 tracked entity UID -- each in its own namespace. The `name` element uses the HumanName data type, where `family` is the surname and `given` is an array (first name, middle name). The `contact` section records a next-of-kin with their own phone number.

## Common Patterns and Gotchas

**Multiple names.** `name` is an array. Use the `use` field to distinguish between official, maiden, nickname, and other name types. Always set `use` to avoid ambiguity.

**Gender vs. sex.** The `gender` element represents administrative gender, not biological sex or gender identity. FHIR provides extensions for more nuanced representations when needed.

**Deceased patients.** Use `deceasedBoolean` or `deceasedDateTime` (a choice type) to indicate death. Do not set both.

**Searching by identifier.** When querying a FHIR server, you can search by system and value together: `GET /Patient?identifier=http://dhis2.org/trackedentity|DXz7q34bVcR`. The pipe character separates system from value.

**Minimal vs. complete.** Only `resourceType` is strictly required by the base spec, but in practice you should always include at least one identifier and a name. Profiles typically tighten the cardinality.

## Relationship to DHIS2

The Patient resource maps directly to a DHIS2 **Tracked Entity Instance** (TEI) of type Person. DHIS2 tracked entity attributes (first name, last name, date of birth, national ID) become Patient elements. The DHIS2 UID of the tracked entity instance is carried as an identifier with `system` set to your DHIS2 instance's namespace. Organisation unit assignment maps to `managingOrganization`.
