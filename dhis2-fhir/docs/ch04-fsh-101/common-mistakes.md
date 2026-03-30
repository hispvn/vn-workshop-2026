# Common Mistakes

This page collects the mistakes that trip up nearly every FSH and FHIR beginner. Each entry shows what you wrote, what goes wrong, and how to fix it.

## Cardinality confusion

### Setting 1..1 when 0..1 is appropriate

WRONG -- forcing every patient to have exactly one phone number:

```fsh
Profile: MyPatient
Parent: Patient
* telecom 1..1
```

> Error at validation: instances without a phone number fail.

RIGHT -- the element is supported but not mandatory:

```fsh
Profile: MyPatient
Parent: Patient
* telecom 0..* MS
```

Most real-world data is incomplete. Only constrain to `1..` when the element is truly required for your use case.

### Forgetting that 1..* means "at least one"

WRONG -- expecting exactly two identifiers:

```fsh
Profile: MyPatient
Parent: Patient
* identifier 1..*
```

This allows one, two, or a hundred identifiers. If you need exactly two, use slicing with each slice set to `1..1`.

### Using 0..0 to remove elements

WRONG -- trying to hide an inherited element without understanding the impact:

```fsh
Profile: MyPatient
Parent: Patient
* maritalStatus 0..0
```

This is technically valid FSH, but it means any instance that includes `maritalStatus` will fail validation. Make sure you truly want to prohibit the element, not just mark it as unused. If upstream profiles require it, your profile will create a contradiction.

## Must Support misunderstanding

### Thinking MS means "required"

WRONG -- assuming `MS` makes the element mandatory:

```fsh
Profile: MyPatient
Parent: Patient
* birthDate MS
```

> A system sends a Patient without `birthDate`. The developer is surprised it validates.

`MS` means "if this element is present, systems must handle it." It says nothing about whether the element must be sent. Cardinality controls that.

RIGHT -- if you need the element to be present AND supported:

```fsh
Profile: MyPatient
Parent: Patient
* birthDate 1..1 MS
```

Combine cardinality (`1..1`) with `MS` when an element is both mandatory and must be processed.

## Slicing mistakes

### Forgetting the discriminator

WRONG -- defining slices without telling the validator how to distinguish them:

```fsh
Profile: MyPatient
Parent: Patient
* identifier contains
    NationalId 0..1 and
    DHIS2Id 1..1
```

> SUSHI warning: No slicing discriminator defined for `identifier`.

RIGHT -- always set up the discriminator before `contains`:

```fsh
Profile: MyPatient
Parent: Patient
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier contains
    NationalId 0..1 and
    DHIS2Id 1..1
* identifier[NationalId].system = "http://example.org/national-id"
* identifier[DHIS2Id].system = "http://example.org/dhis2"
```

### Using #value when #pattern is needed

WRONG -- using `#value` discriminator with `type.coding`:

```fsh
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "type.coding.code"
```

> Validator may fail to match slices because `type` is a CodeableConcept, and `#value` requires an exact full match on the element.

RIGHT -- use `#pattern` when matching on part of a complex type:

```fsh
* identifier ^slicing.discriminator.type = #pattern
* identifier ^slicing.discriminator.path = "type"
```

### Creating closed slicing that breaks existing instances

WRONG:

```fsh
* identifier ^slicing.rules = #closed
* identifier contains DHIS2Id 1..1
```

> Any instance with an additional identifier (e.g., a hospital MRN) fails validation.

RIGHT -- use `#open` unless you have a specific reason to lock it down:

```fsh
* identifier ^slicing.rules = #open
```

## Binding strength errors

### Using required when extensible is appropriate

WRONG -- locking a ValueSet to `#required`:

```fsh
Profile: MyObservation
Parent: Observation
* code from MyLocalCodes (required)
```

> Any code not in `MyLocalCodes` fails validation. Partner systems sending standard LOINC codes are rejected.

RIGHT -- use `#extensible` to allow codes outside your ValueSet:

```fsh
Profile: MyObservation
Parent: Observation
* code from MyLocalCodes (extensible)
```

`required` means the code MUST come from the ValueSet. Use it only for tightly controlled elements like `status`.

### Confusing CodeSystem with ValueSet in bindings

WRONG -- binding directly to a CodeSystem:

```fsh
* code from MyCodeSystem (required)
```

> SUSHI error: binding target must be a ValueSet.

RIGHT -- create a ValueSet that includes the CodeSystem, then bind to it:

```fsh
ValueSet: MyLocalCodes
* include codes from system MyCodeSystem

Profile: MyObservation
Parent: Observation
* code from MyLocalCodes (required)
```

## Extension mistakes

### Defining an extension but forgetting to add it to the profile

WRONG -- the extension exists but no profile uses it:

```fsh
Extension: BirthVillage
Id: birth-village
* value[x] only string

Profile: MyPatient
Parent: Patient
// forgot to add the extension here
```

> The extension is generated but never appears in the profile's StructureDefinition.

RIGHT -- use `extension contains` in the profile:

```fsh
Profile: MyPatient
Parent: Patient
* extension contains BirthVillage named birthVillage 0..1 MS
```

### Using the wrong value type

WRONG:

```fsh
Extension: BirthYear
Id: birth-year
* value[x] only string
```

Then in an instance:

```fsh
* extension[birthYear].valueInteger = 1990
```

> Error: `valueInteger` is not allowed; only `valueString` is permitted.

RIGHT -- match the type in the extension definition:

```fsh
Extension: BirthYear
Id: birth-year
* value[x] only integer
```

### Not specifying the extension URL

WRONG -- inline extension in an instance without the URL:

```fsh
Instance: ExamplePatient
InstanceOf: Patient
* extension[0].valueString = "some value"
```

> Error: extension must have a `url`.

RIGHT:

```fsh
Instance: ExamplePatient
InstanceOf: Patient
* extension[0].url = "http://example.org/fhir/StructureDefinition/my-ext"
* extension[0].valueString = "some value"
```

When you use a named extension from a profile, SUSHI handles the URL automatically. This issue appears when writing raw instances.

## Instance validation failures

### Instance does not match its profile

WRONG -- the instance claims to be a MyPatient but violates its constraints:

```fsh
Profile: MyPatient
Parent: Patient
* identifier 1..*
* name 1..*

Instance: BadPatient
InstanceOf: MyPatient
* gender = #male
// missing identifier and name
```

> Validation error: minimum cardinality of 1 not met for `identifier` and `name`.

RIGHT:

```fsh
Instance: GoodPatient
InstanceOf: MyPatient
* identifier[0].system = "http://example.org/ids"
* identifier[0].value = "12345"
* name[0].family = "Doe"
* name[0].given[0] = "John"
* gender = #male
```

### Wrong code in a bound ValueSet

WRONG:

```fsh
Instance: MyObs
InstanceOf: Observation
* status = #final
* code = http://loinc.org#WRONG-CODE "Not a real code"
```

> Validation warning or error: code not found in the bound ValueSet.

Always check that your code is actually defined in the target CodeSystem.

## RuleSet parameter issues

### Forgetting curly braces around parameters

WRONG:

```fsh
RuleSet: AddIdentifier(system, value)
* identifier[+].system = "system"
* identifier[=].value = "value"
```

> The literal strings `"system"` and `"value"` are inserted instead of parameter values.

RIGHT -- wrap parameters in `{curly braces}`:

```fsh
RuleSet: AddIdentifier(system, value)
* identifier[+].system = "{system}"
* identifier[=].value = "{value}"
```

### Passing the wrong number of arguments

WRONG:

```fsh
RuleSet: SetCode(system, code, display)
* code = {system}#{code} "{display}"

Instance: MyObs
InstanceOf: Observation
* insert SetCode(http://loinc.org, 1234-5)
```

> SUSHI error: RuleSet `SetCode` expects 3 arguments but received 2.

Always match the number of arguments to the RuleSet parameters.

### Parameters containing special characters

WRONG -- a URL with commas or parentheses confuses the parser:

```fsh
* insert AddIdentifier(http://example.org/id(v2), 12345)
```

> SUSHI misparses the parentheses in the URL as the end of the argument list.

RIGHT -- use an Alias to avoid special characters in RuleSet calls:

```fsh
Alias: $IDSystem = http://example.org/id(v2)

* insert AddIdentifier($IDSystem, 12345)
```

## Path and naming errors

### Wrong element path in a profile context

WRONG -- using the full resource path inside a profile rule:

```fsh
Profile: MyPatient
Parent: Patient
* Patient.name.family 1..1
```

> SUSHI error: path `Patient.name.family` not found.

RIGHT -- inside a profile, paths are relative to the resource:

```fsh
Profile: MyPatient
Parent: Patient
* name.family 1..1
```

### Case sensitivity in codes

WRONG:

```fsh
* status = #Final
```

> Validation error: code `Final` not found in required ValueSet. The correct code is `final` (lowercase).

FHIR codes are case-sensitive. Always check the CodeSystem definition for the exact casing.

### Forgetting that FSH arrays are 0-indexed

WRONG:

```fsh
Instance: MyPatient
InstanceOf: Patient
* name[1].family = "Doe"
```

> The first name entry is at index `[0]`. Index `[1]` creates a second (and the first is empty/missing).

RIGHT:

```fsh
* name[0].family = "Doe"
```

Use `[+]` to append to the next available index when building lists:

```fsh
* name[+].family = "Doe"
* name[+].family = "Smith"
```

## SUSHI compilation gotchas

### Circular dependencies

WRONG -- two profiles reference each other:

```fsh
// File: ProfileA.fsh
Profile: ProfileA
Parent: Patient
* extension contains ProfileB named ref 0..1

// File: ProfileB.fsh
Profile: ProfileB
Parent: Patient
* extension contains ProfileA named ref 0..1
```

> SUSHI may error or produce unexpected output due to circular references.

Restructure so that shared content lives in a common extension or base profile.

### Undefined aliases

WRONG:

```fsh
* code = $LNC#1234-5
```

> SUSHI error: Alias `$LNC` is not defined.

RIGHT -- define the alias at the top of any FSH file (or in an `aliases.fsh` file):

```fsh
Alias: $LNC = http://loinc.org
```

### Forgetting Usage: #example

WRONG -- an example instance is treated as a definitional resource:

```fsh
Instance: SamplePatient
InstanceOf: MyPatient
* name[0].family = "Test"
```

> SUSHI treats this as `Usage: #definition` by default, which may cause it to be placed in the wrong IG section.

RIGHT:

```fsh
Instance: SamplePatient
InstanceOf: MyPatient
Usage: #example
* name[0].family = "Test"
```

Always add `Usage: #example` to instances meant as sample data.

## JSON/FHIR conceptual mistakes

### Confusing code with CodeableConcept

WRONG -- assigning a bare code to a CodeableConcept element:

```fsh
Profile: MyObservation
Parent: Observation
* category = #vital-signs
```

> This works in FSH as shorthand, but beginners often assume `category` holds a simple string. In JSON, `category` is an array of CodeableConcept objects, each containing a `coding` array.

The FSH shorthand `#vital-signs` expands to a full CodeableConcept. Be aware of the underlying structure when debugging validation.

### Forgetting that value[x] is a choice type

WRONG -- trying to set two value types on the same instance:

```fsh
Instance: MyObs
InstanceOf: Observation
Usage: #example
* status = #final
* code = http://loinc.org#8867-4
* valueQuantity.value = 72
* valueString = "seventy-two"
```

> Error: only one `value[x]` variant is allowed per instance.

RIGHT -- pick one type:

```fsh
Instance: MyObs
InstanceOf: Observation
Usage: #example
* status = #final
* code = http://loinc.org#8867-4
* valueQuantity.value = 72
* valueQuantity.unit = "bpm"
```

### Assuming all elements are strings

WRONG -- quoting a numeric or boolean value:

```fsh
* valueQuantity.value = "72"
* active = "true"
```

> Type mismatch: `value` expects a decimal, `active` expects a boolean.

RIGHT -- use the native types:

```fsh
* valueQuantity.value = 72
* active = true
```

FSH is typed. Numbers, booleans, dates, and codes each have their own syntax.
