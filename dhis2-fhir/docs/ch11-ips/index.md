# International Patient Summary (IPS)

The **International Patient Summary (IPS)** is a standardized, minimal patient summary designed for cross-border and cross-system sharing of essential health information. Think of it as a "passport" for a patient's key clinical data -- it carries enough information for a clinician in another country or system to understand the patient's current health status.

This chapter documents how the DHIS2-FHIR Learning IG implements IPS with a focus on **demographics and immunization data**, the two areas most relevant to DHIS2 immunization programs operating in low- and middle-income countries.

## Why IPS Matters for DHIS2

DHIS2 is deployed in 80+ countries, many with cross-border health challenges. Common scenarios where IPS is useful:

- **Cross-border immunization verification** -- A child vaccinated in one country presents at a clinic in another. The IPS provides a standardized summary of their vaccination history.
- **Referral between systems** -- A pregnant woman enrolled in a DHIS2 ANC program is referred to a hospital running a different EMR. The IPS carries her demographics and immunization history in a universally understood format.
- **WHO SMART Guidelines** -- The WHO Digital Adaptation Kits (DAKs) recommend IPS as the exchange format for immunization data. DHIS2 implementations that produce IPS-compliant data align with these guidelines.
- **National health information exchange (HIE)** -- Countries building interoperability layers between DHIS2, OpenMRS, HAPI FHIR, and other systems use IPS as the common document format.

## IPS Architecture

An IPS document is a **FHIR Bundle of type `document`** containing four types of resources:

```
┌─────────────────────────────────────────────────┐
│  IPS Bundle (type: document)                    │
│                                                 │
│  ┌───────────────────────────────────────────┐  │
│  │  Composition (table of contents)          │  │
│  │  - subject → Patient                      │  │
│  │  - section[immunizations]                 │  │
│  │      entry[0] → Immunization              │  │
│  │      entry[1] → Immunization              │  │
│  │      entry[2] → Immunization              │  │
│  └───────────────────────────────────────────┘  │
│                                                 │
│  ┌───────────────┐  ┌────────────────────────┐  │
│  │  Patient       │  │  Immunization #1       │  │
│  │  (demographics)│  │  (BCG, 2019-01-15)     │  │
│  └───────────────┘  └────────────────────────┘  │
│                                                 │
│  ┌────────────────────────┐  ┌────────────────┐ │
│  │  Immunization #2       │  │  Immunization  │ │
│  │  (OPV dose 1, 2019-03) │  │  #3 (Measles)  │ │
│  └────────────────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────┘
```

The key insight: the **Composition** is a table of contents that organizes references to the actual resources. It does **not** contain the clinical data itself. The **Bundle** wraps everything together for transport -- it is the complete, self-contained payload.

## What's NOT in the Bundle

The IPS Bundle contains **resource instances** (the actual clinical data), not **definitions**:

| In the IPS Bundle | NOT in the Bundle (lives in the IG) |
|---|---|
| Composition (table of contents) | StructureDefinitions (profiles) |
| Patient (demographics) | CodeSystems (terminology definitions) |
| Immunization records | ValueSets (allowed codes) |
| Other clinical resources | ConceptMaps (code translations) |

Coded values like CVX `208` (Pfizer COVID vaccine) are embedded in the resources as `system` + `code` pairs. The receiving system looks up the meaning using the `system` URL if needed, but does not require the full CodeSystem definition in the bundle.

## Chapters

- [IPS Profiles](profiles.md) -- The four profiles: Patient, Immunization, Composition, Bundle
- [Vaccine Terminology](terminology.md) -- Code systems for vaccines, routes, sites, and target diseases
- [DHIS2 to IPS Mapping](mapping.md) -- How DHIS2 immunization data maps to IPS resources
- [Examples](examples.md) -- 55 complete IPS documents with walkthrough
