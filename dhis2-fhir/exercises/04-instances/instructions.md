# Exercise 04: Instances

## Objective

Create example instances of a DHIS2 Patient with realistic data that conform to a DHIS2Patient profile.

## Background

Instances in FSH represent concrete example resources. They serve as documentation (showing implementers what valid data looks like), test data (for validating systems), and quality assurance (the IG Publisher validates instances against their declared profiles). Good examples use realistic data that demonstrates the profile's constraints.

## Requirements

Create two Patient instances that conform to a DHIS2Patient profile:

1. **Instance 1** -- `PatientExampleMale`:
   - DHIS2 UID identifier: `AbC1dEf2gHi`
   - Name: John Kamau
   - Gender: male
   - Birth date: 1985-08-22
   - Add a national ID: `KE-12345678`

2. **Instance 2** -- `PatientExampleFemale`:
   - DHIS2 UID identifier: `XyZ9wVu8tSr`
   - Name: Amina Hassan
   - Gender: female
   - Birth date: 1992-11-03
   - Add a national ID: `KE-87654321`

## Instructions

1. Open `starter.fsh`
2. Fill in the instance data for both patients
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
Instance: InstanceName
InstanceOf: ProfileName
Title: "Title"
Description: "Description"
* element = "value"
* element.subElement = "value"
```

Common value types:
- Strings: `"text value"`
- Dates: `"2024-01-15"`
- Codes: `#code`
- References: `Reference(OtherInstance)`
