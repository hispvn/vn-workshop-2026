# Exercise 08: Aliases

## Objective

Define aliases for commonly used DHIS2 and FHIR URIs and use them in profiles and instances.

## Background

Aliases in FSH let you assign short names to long URIs. Instead of writing `http://terminology.hl7.org/CodeSystem/v2-0203` every time you reference an identifier type code system, you can define `Alias: $V2-0203 = http://terminology.hl7.org/CodeSystem/v2-0203` and then use `$V2-0203` throughout your FSH files. Aliases make FSH code more readable and reduce the chance of typos in long URIs.

Aliases are global within a SUSHI project -- defining an alias in any `.fsh` file makes it available in all other `.fsh` files.

## Requirements

1. Define the following aliases:
   - `$SCT` for `http://snomed.info/sct`
   - `$LOINC` for `http://loinc.org`
   - `$UCUM` for `http://unitsofmeasure.org`
   - `$V2-0203` for `http://terminology.hl7.org/CodeSystem/v2-0203`
   - `$DHIS2` for `http://dhis2.org/fhir`
   - `$DHIS2TEI` for `http://dhis2.org/fhir/id/tracked-entity`

2. Create a Patient instance that uses at least three of these aliases.

## Instructions

1. Open `starter.fsh`
2. Define the aliases and use them in the instance
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
Alias: $ShortName = http://full.uri/path

// Usage in code:
* identifier.system = $ShortName
* code = $LOINC#12345-6 "Display text"
```
