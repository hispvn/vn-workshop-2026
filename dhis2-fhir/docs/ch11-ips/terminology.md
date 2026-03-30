# Vaccine Terminology

Immunization data requires standardized codes for vaccines, administration routes, injection sites, and the diseases vaccines protect against. This chapter documents the terminology used in the DHIS2 IPS profiles and the open-source code systems available for vaccine coding.

## Code Systems for Vaccines

Three major code systems exist for identifying vaccines. All are freely usable in FHIR:

### CDC CVX (Vaccine Administered)

| Property | Value |
|----------|-------|
| System URL | `http://hl7.org/fhir/sid/cvx` |
| Maintainer | CDC (Centers for Disease Control and Prevention) |
| License | Public domain (US government work) |
| Size | ~300 codes |
| FHIR support | Native — registered as a FHIR-known code system |

CVX is the **de facto standard** for vaccine coding in FHIR. It is the primary system used by IPS validators, the WHO SMART Vaccination IG, and most national immunization registries. Each code identifies a specific vaccine product type (not a brand).

Common CVX codes used in DHIS2 EPI programs:

| CVX Code | Display | Typical EPI Schedule |
|----------|---------|---------------------|
| `19` | BCG | Birth |
| `08` | Hep B, adolescent or pediatric | Birth, 6w, 14w |
| `02` | OPV, trivalent | 6w, 10w, 14w |
| `10` | IPV | 14w |
| `20` | DTaP | 6w, 10w, 14w |
| `17` | Hib | 6w, 10w, 14w |
| `133` | PCV13 | 6w, 10w, 14w |
| `116` | Rotavirus, pentavalent | 6w, 10w |
| `03` | MMR | 9m, 15m |
| `21` | Varicella | 12m |
| `83` | Hep A, ped/adol, 2 dose | 12m |
| `37` | Yellow fever | 9m |
| `62` | HPV, quadrivalent | 9y |
| `115` | Tdap | Booster |
| `114` | Meningococcal A | 9m |

COVID-19 vaccine codes:

| CVX Code | Display | Manufacturer |
|----------|---------|-------------|
| `207` | COVID-19, mRNA, 100 mcg/0.5mL | Moderna |
| `208` | COVID-19, mRNA, 30 mcg/0.3mL | Pfizer-BioNTech |
| `210` | COVID-19, vector-nr, rS-Ad26 | Janssen (J&J) |
| `211` | COVID-19, subunit, rS-nanoparticle | Novavax |
| `212` | COVID-19, vector-nr, rS-ChAdOx1 | AstraZeneca |
| `510` | COVID-19 IV Non-US | Sinopharm |
| `511` | COVID-19 IV Non-US | Sinovac |
| `213` | SARS-COV-2, unspecified | Generic/unknown |

### WHO ATC (Anatomical Therapeutic Chemical)

| Property | Value |
|----------|-------|
| System URL | `http://www.whocc.no/atc` |
| Maintainer | WHO Collaborating Centre for Drug Statistics |
| License | Free to browse; redistribution requires license |
| Size | Vaccines under `J07` branch |
| FHIR support | Recognized but less common than CVX |

ATC provides an international classification maintained by WHO. Vaccines fall under the `J07` branch. ATC codes are hierarchical (e.g., `J07AN01` = BCG, `J07BF01` = polio oral monovalent). Less commonly used in FHIR than CVX, but important for WHO-aligned implementations.

### SNOMED CT (Global Patient Set)

| Property | Value |
|----------|-------|
| System URL | `http://snomed.info/sct` |
| Maintainer | SNOMED International |
| License | **Free** for the GPS (Global Patient Set) subset used by IPS |
| Size | ~8,000 concepts in the GPS subset |
| FHIR support | Native — widely supported |

The SNOMED CT Global Patient Set (GPS) is a royalty-free subset specifically designed for IPS use. It includes vaccine product concepts (under `787859002`). SNOMED CT codes are the most precise (they can distinguish specific formulations) but also the most complex.

### CDC MVX (Manufacturer)

| Property | Value |
|----------|-------|
| System URL | `http://hl7.org/fhir/sid/mvx` |
| Maintainer | CDC |
| License | Public domain |
| Use | `Immunization.manufacturer` |

MVX codes identify vaccine manufacturers (e.g., `PFR` = Pfizer, `MOD` = Moderna, `SKB` = GlaxoSmithKline). Used alongside CVX to fully identify a vaccine product + manufacturer combination. Mapped to `Immunization.manufacturer.identifier`.

### Recommendation for DHIS2

Use **CVX as the primary system** with optional DHIS2 option set codes for round-tripping:

```
CVX code (interoperability) + DHIS2 code (round-trip) = best of both worlds
```

CVX is:
- Completely free and open (US government work, no license needed)
- The default expectation of FHIR validators and IPS tooling
- Comprehensive enough for all EPI and COVID-19 vaccines
- Maintained with regular updates (new vaccines added promptly)

## Administration Routes

Routes of administration are coded using SNOMED CT:

| SNOMED Code | Display | Common Vaccines |
|-------------|---------|----------------|
| `78421000` | Intramuscular route | Most injectable vaccines (DTaP, Hep B, PCV, HPV) |
| `34206005` | Subcutaneous route | MMR, Varicella, Yellow Fever |
| `26643006` | Oral route | OPV, Rotavirus, Typhoid oral |
| `46713006` | Nasal route | Live attenuated influenza (FluMist) |
| `6064005` | Topical route | Smallpox (scarification) |
| `47625008` | Intravenous route | Certain immunoglobulins |

## Injection Sites

Body sites for vaccine administration, also coded in SNOMED CT:

| SNOMED Code | Display | Typical Age Group |
|-------------|---------|------------------|
| `368208006` | Left upper arm | Children > 1 year, adults |
| `368209003` | Right upper arm | Children > 1 year, adults |
| `61396006` | Left thigh | Infants < 1 year |
| `11207009` | Right thigh | Infants < 1 year |

The choice between arm and thigh depends on the patient's age. Infants receive injections in the thigh (larger muscle mass relative to the deltoid). Older children and adults receive them in the upper arm (deltoid).

## Target Diseases

The `protocolApplied.targetDisease` element records which disease(s) a vaccine protects against. This is coded in SNOMED CT:

| SNOMED Code | Disease | Common Vaccines |
|-------------|---------|----------------|
| `397430003` | Diphtheria | DTaP, Tdap, Td |
| `76902006` | Tetanus | DTaP, Tdap, Td |
| `27836007` | Pertussis | DTaP, Tdap |
| `398102009` | Poliomyelitis | OPV, IPV |
| `14189004` | Measles | MMR, Measles |
| `36989005` | Mumps | MMR |
| `36653000` | Rubella | MMR |
| `38907003` | Varicella | Varicella |
| `66071002` | Hepatitis B | Hep B |
| `40468003` | Hepatitis A | Hep A |
| `56717001` | Tuberculosis | BCG |
| `840539006` | COVID-19 | All COVID-19 vaccines |
| `6142004` | Influenza | Influenza (seasonal) |
| `16541001` | Yellow fever | Yellow Fever |
| `14168008` | Rabies | Rabies |
| `23511006` | Meningococcal disease | Meningococcal A/ACWY |
| `16814004` | Pneumococcal disease | PCV13, PPSV23 |
| `240532009` | HPV infection | HPV quadrivalent/nonavalent |
| `18624000` | Rotavirus infection | Rotavirus |
| `4834000` | Typhoid fever | Typhoid oral/ViCPs |

## Binding Strength

The IPS specification uses **preferred** binding for vaccine codes. This means:

- You **should** use codes from the standard ValueSets (CVX, ATC, SNOMED CT)
- You **may** use other codes if no suitable standard code exists
- Validators will **warn** (not error) if a non-standard code is used

This is important for DHIS2 implementations that use custom option set codes for vaccines. The preferred binding gives you room to include DHIS2 codes alongside standard codes without failing validation.

## Mapping DHIS2 Option Sets to CVX

A typical DHIS2 immunization option set might look like:

| DHIS2 Option Code | DHIS2 Display | CVX Code | CVX Display |
|-------------------|---------------|----------|-------------|
| `BCG` | BCG | `19` | BCG |
| `OPV` | OPV | `02` | OPV, trivalent |
| `PENTA` | Pentavalent | `146` | DTaP-IPV-Hib-Hep B |
| `PCV` | Pneumococcal | `133` | PCV13 |
| `ROTA` | Rotavirus | `116` | Rotavirus, pentavalent |
| `MEASLES` | Measles | `05` | Measles |
| `MR` | Measles-Rubella | `04` | M/R |
| `YF` | Yellow Fever | `37` | Yellow fever |
| `HPV` | HPV | `62` | HPV, quadrivalent |
| `TT` | Tetanus Toxoid | `35` | Tetanus toxoid adsorbed |
| `IPV` | IPV | `10` | IPV |

This mapping can be implemented as:
- A **ConceptMap** FHIR resource (formal, machine-readable)
- A lookup table in your integration middleware
- A DHIS2 program rule that sets the CVX code automatically

## ValueSet Definitions

The IG defines four IPS-specific ValueSets:

| ValueSet | Id | Code System | Codes |
|----------|----|-------------|-------|
| DHIS2IPSVaccineVS | `dhis2-ips-vaccine-vs` | CVX | 42 common vaccines |
| DHIS2IPSRouteVS | `dhis2-ips-route-vs` | SNOMED CT | 6 routes |
| DHIS2IPSSiteVS | `dhis2-ips-site-vs` | SNOMED CT | 4 body sites |
| DHIS2IPSTargetDiseaseVS | `dhis2-ips-target-disease-vs` | SNOMED CT | 20 diseases |

## Source Files

- ValueSet definitions: `ig/input/fsh/ips/terminology.fsh`
