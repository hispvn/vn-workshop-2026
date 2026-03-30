# Syntax Basics

This section gives you an overview of FSH syntax. We will revisit each concept in detail in Part III (FSH 101), but this introduction will help you read and understand FSH code as you encounter it.

## Keywords

FSH uses keywords to declare different types of artifacts:

| Keyword | Purpose |
|---------|---------|
| `Profile` | Constrains a base FHIR resource |
| `Extension` | Defines a custom data element |
| `ValueSet` | Defines a set of coded values |
| `CodeSystem` | Defines a new coding system |
| `Instance` | Creates an example or fixed resource instance |
| `Logical` | Defines a logical model (custom data structure) |
| `Mapping` | Maps between a profile and another specification |
| `RuleSet` | A reusable group of rules |
| `Alias` | A shorthand name for a URL |
| `Invariant` | A constraint expression (FHIRPath) |

## Declaring an Artifact

Every FSH artifact starts with a keyword, a name, and metadata:

```fsh
Profile: MyPatientProfile
Parent: Patient
Id: my-patient-profile
Title: "My Patient Profile"
Description: "A constrained Patient for our use case."
```

## Rules

Rules are the heart of FSH. They go inside an artifact declaration and modify the definition. Here are the main types:

### Assignment Rules

Use `=` to set a fixed value:

```fsh
Profile: MyObservation
Parent: Observation
* status = #final
* code = http://loinc.org#29463-7 "Body weight"
```

### Cardinality Rules

Restrict how many times an element can appear:

```fsh
Profile: MyPatient
Parent: Patient
* name 1..1
* identifier 1..*
* photo 0..0
```

- `1..1` means exactly one (required, no repeats)
- `1..*` means at least one (required, may repeat)
- `0..0` means prohibited (element is removed)

### Binding Rules

Bind an element to a value set:

```fsh
Profile: MyObservation
Parent: Observation
* code from MyValueSet (required)
* category from MyCategories (extensible)
```

Binding strengths: `required`, `extensible`, `preferred`, `example`.

### Flag Rules

Flags mark elements with special properties:

```fsh
Profile: MyPatient
Parent: Patient
* name MS
* identifier MS SU
* deceased ?!
```

| Flag | Meaning |
|------|---------|
| `MS` | Must Support |
| `SU` | Summary -- included in summary searches |
| `D` | Draft -- element is under development |
| `?!` | Is-Modifier -- this element can change the meaning of the resource |

**What does Must Support actually mean?** The `MS` flag does *not* mean the element is required -- that is what cardinality does. Instead, it means that conforming systems must be able to **meaningfully handle** the element:

- **Senders** must populate the element when the data is available.
- **Receivers** must be able to process and store it -- they cannot silently ignore or drop it.

An element can be `0..1 MS`, meaning it is optional but if present, systems must support it. Conversely, an element can be `1..1` (required) without being MS, though that is less common in practice. The exact obligations of "support" can vary between IGs -- some (like US Core) define very specific behaviors. IG authors should document what MS means in their context.

### Type Rules

Constrain the allowed types for a choice element:

```fsh
Profile: MyObservation
Parent: Observation
* value[x] only Quantity
* effective[x] only dateTime or Period
```

## Paths

Paths navigate into nested elements using dot notation:

```fsh
Profile: MyPatient
Parent: Patient
* name.family 1..1 MS
* name.given 1..* MS
* contact.name.family MS
```

For elements that are arrays, you can use bracket notation to refer to slices (covered in detail later):

```fsh
* identifier[NationalId].system = "http://example.org/national-id"
```

## Putting It Together

Here is a complete, small FSH file that defines a profile and a value set:

```fsh
Alias: $LOINC = http://loinc.org

Profile: BodyWeightObservation
Parent: Observation
Id: body-weight-observation
Title: "Body Weight Observation"
Description: "An observation recording a patient's body weight."
* status = #final
* code = $LOINC#29463-7 "Body weight"
* value[x] only Quantity
* valueQuantity.unit = "kg"
* valueQuantity.system = "http://unitsofmeasure.org"
* subject 1..1 MS
* effective[x] 1..1 MS

ValueSet: VitalSignCodes
Id: vital-sign-codes
Title: "Vital Sign Codes"
Description: "Codes for vital sign observations."
* $LOINC#29463-7 "Body weight"
* $LOINC#8302-2 "Body height"
* $LOINC#8867-4 "Heart rate"
```

This compact syntax produces fully valid FHIR StructureDefinition and ValueSet resources when compiled with SUSHI. In Part III, we will explore each keyword and rule type in depth.
