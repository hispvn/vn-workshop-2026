# RuleSets

A **RuleSet** is a named group of rules that you can insert into multiple profiles, extensions, or instances. When you find yourself writing the same set of rules across several artifacts, a RuleSet eliminates the duplication. RuleSets can also accept parameters, making them flexible templates.

## Syntax reference

### Defining a RuleSet

```fsh
RuleSet: <name>
* <rule1>
* <rule2>
```

### Defining a parameterized RuleSet

```fsh
RuleSet: <name>(param1, param2)
* <rule using {param1}>
* <rule using {param2}>
```

Parameters are referenced inside the RuleSet body with curly braces: `{paramName}`.

### Inserting a RuleSet

```fsh
* insert <RuleSetName>
* insert <RuleSetName>(arg1, arg2)
```

## Example 1: Metadata RuleSet

Many profiles share common metadata constraints. Extract them into a RuleSet.

```fsh
RuleSet: MetadataRuleSet
* ^status = #active
* ^publisher = "DHIS2 FHIR Community"
* ^version = "1.0.0"
* ^date = "2025-01-01"
```

Apply it to multiple profiles:

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"
Description: "Patient profile for DHIS2 Tracker."

* insert MetadataRuleSet
* identifier 1..* MS
* name 1..* MS

Profile:     DHIS2Organization
Parent:      Organization
Id:          dhis2-organization
Title:       "DHIS2 Organisation Unit"
Description: "Organization profile for DHIS2 org units."

* insert MetadataRuleSet
* identifier 1..* MS
* name 1..1 MS
* type 1..1 MS
```

Both profiles now share the same publisher, version, and status without repeating those lines.

## Example 2: Parameterized identifier RuleSet

DHIS2 resources frequently need an identifier with a specific system. A parameterized RuleSet makes this reusable.

```fsh
RuleSet: DHIS2IdentifierRuleSet(system, display)
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains dhis2Id 1..1
* identifier[dhis2Id].system = "{system}"
* identifier[dhis2Id].type.text = "{display}"
* identifier[dhis2Id].value 1..1
```

Now use it in multiple profiles with different system URIs:

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"
Description: "Patient from DHIS2 Tracker."

* insert DHIS2IdentifierRuleSet(https://dhis2.org/tracked-entity-instance, DHIS2 TEI UID)
* name 1..* MS
* birthDate 1..1 MS

Profile:     DHIS2Organization
Parent:      Organization
Id:          dhis2-organization
Title:       "DHIS2 Organisation Unit"
Description: "Organization from DHIS2."

* insert DHIS2IdentifierRuleSet(https://dhis2.org/organisation-unit, DHIS2 OrgUnit UID)
* name 1..1 MS
```

Each profile gets full identifier slicing configured with a single `insert` line. The `{system}` and `{display}` placeholders are replaced with the arguments.

## Example 3: RuleSet for instances

RuleSets work in instances too. This is useful when many example instances share common metadata.

```fsh
RuleSet: ExampleMeta(profileUrl)
* meta.profile[0] = "{profileUrl}"
* meta.lastUpdated = "2025-06-01T00:00:00Z"

Instance:    PatientExample1
InstanceOf:  Patient
Usage:       #example
Title:       "Patient Example 1"

* insert ExampleMeta(http://example.org/fhir/StructureDefinition/dhis2-patient)
* name.family = "Chikwawa"
* gender = #female
```

## Important notes

- RuleSet names must be unique within your project.
- Parameters are **text substitution** -- SUSHI replaces `{param}` with the literal argument string before processing the rules. This means parameters are not typed.
- Be careful with commas in parameter values. If your argument contains a comma, you need to escape it or restructure the RuleSet.
- RuleSets do not appear as separate artifacts in the generated output. They are expanded inline during SUSHI processing.

## Key takeaways

- Use simple RuleSets for repeated groups of identical rules.
- Use parameterized RuleSets when the rules vary by one or more values.
- RuleSets reduce duplication and make your FSH easier to maintain.
- They are a pure authoring convenience -- they vanish after SUSHI processes them.

## RuleSets in This IG

The DHIS2-FHIR Learning IG defines four RuleSets (in `ig/input/fsh/foundation/rulesets.fsh`) that enforce consistency across all profiles and instances.

### DHIS2Identifier(system, value)

Adds a DHIS2 identifier to a resource instance. Every DHIS2 object has an 11-character alphanumeric UID, and this RuleSet stamps it into the FHIR resource with the appropriate system URI and identifier type code.

```fsh
RuleSet: DHIS2Identifier(system, value)
* identifier.system = {system}
* identifier.value = {value}
* identifier.type = $V2-0203#RI "Resource identifier"
```

**Parameters:**
- `{system}` -- the identifier system URI (e.g., `$DHIS2-TEI`, `$DHIS2-OU`)
- `{value}` -- the DHIS2 UID string (e.g., `"dNpxRu1mObG"`)

**Usage:**
```fsh
* insert DHIS2Identifier($DHIS2-TEI, "dNpxRu1mObG")
```

Note the use of `$V2-0203#RI` -- this assigns the HL7 v2 Table 0203 identifier type code "Resource Identifier" to every DHIS2 UID, marking it as a system-generated identifier.

### DHIS2MetaData

Constrains the `identifier` element on a profile so that every conforming resource must carry at least one well-formed identifier. This is a non-parameterized RuleSet intended for profiles (not instances).

```fsh
RuleSet: DHIS2MetaData
* identifier 1..* MS
* identifier.system 1..1
* identifier.value 1..1
```

**Usage:**
```fsh
Profile: DHIS2Patient
Parent: Patient
* insert DHIS2MetaData
```

This expands to require at least one identifier (1..*), with both `system` and `value` required on each identifier. The `MS` (Must Support) flag signals that conforming systems must be able to handle the identifier element.

### DHIS2Period(start, end)

Sets the `period.start` and `period.end` dates on an instance. DHIS2 uses period codes like "202401" for January 2024, but FHIR requires explicit date boundaries.

```fsh
RuleSet: DHIS2Period(start, end)
* period.start = {start}
* period.end = {end}
```

**Parameters:**
- `{start}` -- the period start date in FHIR date format (e.g., `"2024-01-01"`)
- `{end}` -- the period end date (e.g., `"2024-01-31"`)

**Usage:**
```fsh
* insert DHIS2Period("2024-01-01", "2024-01-31")
```

### DHIS2MeasurePopulation(popCode, popDisplay, criteriaText)

Adds a population component to a Measure group. FHIR Measures define their populations (initial-population, numerator, denominator, etc.) with coded entries and criteria expressions. This IG uses text-based criteria because DHIS2 indicator formulas are not expressed in CQL.

```fsh
RuleSet: DHIS2MeasurePopulation(popCode, popDisplay, criteriaText)
* code = $measure-population#{popCode} {popDisplay}
* criteria.language = #text/plain
* criteria.expression = {criteriaText}
```

**Parameters:**
- `{popCode}` -- the population code (e.g., `initial-population`, `numerator`, `denominator`)
- `{popDisplay}` -- the human-readable display for the code
- `{criteriaText}` -- a plain-text description of what this population captures

**Usage:**
```fsh
* group[0].population[0].insert DHIS2MeasurePopulation(
    initial-population, "Initial Population",
    "Count of confirmed malaria cases")
```

This RuleSet targets a nested element (population), so the caller must position it within the correct `group[n].population[m]` path.

## Exercise

Open `exercises/ch04-rulesets/` and complete the exercise. You will create a parameterized RuleSet that adds a coding to `Observation.code` with a configurable system, code, and display, then insert it into two different Observation profiles.
