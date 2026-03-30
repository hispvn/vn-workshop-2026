# Aliases

An **Alias** assigns a short name to a long URI. FHIR is full of canonical URLs for code systems, naming systems, and structure definitions. Typing `http://loinc.org` or `http://snomed.info/sct` repeatedly makes your FSH verbose and error-prone. Aliases fix this.

## Syntax reference

```fsh
Alias: $NAME = <uri>
```

After declaration, use `$NAME` anywhere you would use the full URI.

Conventions:

- Alias names start with `$` by convention (not required, but strongly recommended for readability).
- Declare aliases at the top of your `.fsh` file, or in a dedicated `aliases.fsh` file.
- Alias names are case-sensitive.

## Example 1: Standard terminology aliases

These are the aliases you will use most often in health data work.

```fsh
Alias: $SCT = http://snomed.info/sct
Alias: $LOINC = http://loinc.org
Alias: $UCUM = http://unitsofmeasure.org
Alias: $ICD10 = http://hl7.org/fhir/sid/icd-10
Alias: $V2_0203 = http://terminology.hl7.org/CodeSystem/v2-0203
Alias: $OBSERVATION_CATEGORY = http://terminology.hl7.org/CodeSystem/observation-category
```

With these in place, you can write:

```fsh
* code = $LOINC#29463-7 "Body weight"
```

instead of:

```fsh
* code = http://loinc.org#29463-7 "Body weight"
```

Both produce identical JSON output. The alias is resolved at build time.

## Example 2: DHIS2-specific aliases

Define aliases for systems that appear repeatedly in your DHIS2 FHIR project.

```fsh
Alias: $DHIS2_TEI = https://dhis2.org/tracked-entity-instance
Alias: $DHIS2_OU = https://dhis2.org/organisation-unit
Alias: $DHIS2_DE = https://dhis2.org/data-element
Alias: $DHIS2_PROGRAM = https://dhis2.org/program
Alias: $DHIS2_BASE = https://play.dhis2.org/40.4.0/api
```

Now use them throughout your profiles and instances:

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"

* identifier 1..* MS
* identifier.system = $DHIS2_TEI

Instance:    DHIS2PatientExample
InstanceOf:  DHIS2Patient
Usage:       #example
Title:       "DHIS2 Patient Example"

* identifier[0].system = $DHIS2_TEI
* identifier[0].value = "DXz2k5eGbri"
* name.family = "Phiri"
* gender = #male
* birthDate = "1985-11-22"
```

## Example 3: Aliases in a dedicated file

For larger projects, create an `input/fsh/aliases.fsh` file that contains all your aliases in one place.

```fsh
// aliases.fsh - Centralized alias definitions

// Standard terminologies
Alias: $SCT = http://snomed.info/sct
Alias: $LOINC = http://loinc.org
Alias: $UCUM = http://unitsofmeasure.org

// FHIR infrastructure
Alias: $V2_0203 = http://terminology.hl7.org/CodeSystem/v2-0203
Alias: $OBSERVATION_CATEGORY = http://terminology.hl7.org/CodeSystem/observation-category
Alias: $CONDITION_CLINICAL = http://terminology.hl7.org/CodeSystem/condition-clinical

// DHIS2 naming systems
Alias: $DHIS2_TEI = https://dhis2.org/tracked-entity-instance
Alias: $DHIS2_OU = https://dhis2.org/organisation-unit
Alias: $DHIS2_DE = https://dhis2.org/data-element
Alias: $DHIS2_PROGRAM = https://dhis2.org/program
```

SUSHI collects aliases from all `.fsh` files in the project, so aliases defined in one file are available everywhere. That said, centralizing them prevents duplication and makes it easy to update a URI in one place.

## When to use aliases

| Situation | Use alias? |
|-----------|-----------|
| URI appears 3+ times across your project | Yes |
| Standard code system (SNOMED, LOINC, UCUM) | Yes |
| One-off URI used in a single instance | Optional -- inline is fine |
| URI might change (e.g., a DHIS2 server base URL) | Yes -- change once, update everywhere |

## Key takeaways

- Aliases are resolved at compile time. They produce no separate output artifact.
- The `$` prefix is convention, not syntax. But following it makes aliases instantly recognizable.
- Centralizing aliases in one file is a best practice for larger projects.
- Aliases prevent typos in long URIs, which are a common source of subtle bugs.

## Exercise

Open `exercises/ch04-aliases/` and complete the exercise. You will set up a project-wide aliases file and refactor an existing profile and instance to use aliases instead of inline URIs.
