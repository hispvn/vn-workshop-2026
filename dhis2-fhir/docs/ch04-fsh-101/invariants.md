# Invariants

An **Invariant** is a validation constraint expressed as a FHIRPath expression. Invariants enforce business rules that cardinality and data types alone cannot capture -- for example, "a DHIS2 UID must be exactly 11 alphanumeric characters" or "birth date must not be in the future."

Invariants are evaluated by FHIR validators. When a resource violates an invariant, the validator reports an error or warning depending on the severity you assign.

## Syntax reference

```fsh
Invariant:   <name>
Description: "<what the rule checks>"
Expression:  "<FHIRPath expression>"
Severity:    #error | #warning
XPath:       "<optional XPath equivalent>"
```

To apply an invariant to a profile element, use the `obeys` keyword:

```fsh
* <path> obeys <invariant-name>
```

You can also apply it at the resource level (the root):

```fsh
* obeys <invariant-name>
```

## FHIRPath essentials

FHIRPath is the expression language used in invariants. A few patterns cover most use cases:

| Expression | Meaning |
|-----------|---------|
| `matches('regex')` | Tests a string against a regular expression |
| `exists()` | True if the element has a value |
| `empty()` | True if the element has no value |
| `length()` | Returns the string length |
| `today()` | Returns today's date |
| `<=`, `>=`, `<`, `>` | Comparison operators |
| `and`, `or`, `not` | Boolean logic |
| `implies` | If left is true, right must be true |

## Example 1: DHIS2 UID format validation

DHIS2 UIDs are exactly 11 characters long and consist of alphanumeric characters, where the first character is always a letter.

```fsh
Invariant:   dhis2-uid-format
Description: "DHIS2 UID must be 11 characters: first character a letter, remaining alphanumeric."
Expression:  "value.matches('^[a-zA-Z][a-zA-Z0-9]{10}$')"
Severity:    #error
```

Apply it to an identifier element in a profile:

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"
Description: "Patient from DHIS2 with validated identifier."

* identifier 1..* MS
* identifier.system 1..1
* identifier.value 1..1
* identifier.value obeys dhis2-uid-format
```

Now any Patient instance whose identifier value does not match the 11-character pattern will fail validation with an error.

## Example 2: Birth date not in the future

A warning-level invariant that flags suspicious data without rejecting it outright.

```fsh
Invariant:   birthdate-not-future
Description: "Birth date should not be in the future."
Expression:  "$this <= today()"
Severity:    #warning
```

Apply it to the `birthDate` element:

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"
Description: "Patient with birth date validation."

* birthDate 1..1 MS
* birthDate obeys birthdate-not-future
```

Using `#warning` instead of `#error` means the resource still validates, but the validator flags the issue. This is appropriate when the rule is a data quality check rather than a hard constraint.

## Example 3: Conditional invariant

An invariant that only applies when a condition is met. If a patient has a deceased indicator, they should also have a deceased date.

```fsh
Invariant:   deceased-date-required
Description: "If deceasedBoolean is true, deceasedDateTime should be present."
Expression:  "deceasedBoolean.exists() and deceasedBoolean = true implies deceasedDateTime.exists()"
Severity:    #warning
```

Apply it at the resource root:

```fsh
Profile:     DHIS2Patient
Parent:      Patient
Id:          dhis2-patient
Title:       "DHIS2 Patient"
Description: "Patient with deceased date logic."

* obeys deceased-date-required
* birthDate 1..1 MS
```

The `implies` operator means: "if the left side is true, the right side must also be true." If `deceasedBoolean` is absent or false, the invariant passes unconditionally.

## Multiple invariants on one element

You can stack invariants:

```fsh
* identifier.value obeys dhis2-uid-format
* identifier.value obeys identifier-not-empty
```

Or combine them on one line:

```fsh
* identifier.value obeys dhis2-uid-format and identifier-not-empty
```

## Key takeaways

- Invariants encode **business rules** as FHIRPath expressions.
- Use `#error` for hard constraints that must never be violated. Use `#warning` for data quality checks.
- The `obeys` keyword connects an invariant to a profile element.
- FHIRPath's `matches()` function is invaluable for format validation (UIDs, codes, phone numbers).
- Test your FHIRPath expressions carefully. An incorrect expression can silently pass or fail on every resource.

## Exercise

Open `exercises/ch04-invariants/` and complete the exercise. You will write an invariant that validates DHIS2 Organisation Unit codes (6-12 alphanumeric characters) and apply it to an Organization profile.
