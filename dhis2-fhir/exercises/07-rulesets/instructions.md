# Exercise 07: RuleSets

## Objective

Create reusable RuleSets that capture common DHIS2 metadata patterns, then apply them to multiple profiles.

## Background

RuleSets in FSH are named groups of rules that can be inserted into profiles, extensions, or instances using the `insert` keyword. They eliminate repetition when multiple profiles share the same constraints. For DHIS2 work, common patterns include requiring a DHIS2 UID identifier, adding metadata timestamps, and setting Must Support on standard elements.

## Requirements

1. Create a RuleSet named `DHIS2MetadataRuleSet` that adds:
   - `meta.lastUpdated` with cardinality `1..1` and Must Support
   - `meta.source` with cardinality `0..1` and Must Support

2. Create a RuleSet named `DHIS2IdentifierRuleSet` that adds:
   - `identifier` with cardinality `1..*` and Must Support
   - `identifier.system` with cardinality `1..1`
   - `identifier.value` with cardinality `1..1`

3. Create two profiles that use both RuleSets:
   - `DHIS2Patient` (Parent: Patient) -- also add `name 1..* MS`
   - `DHIS2Organization` (Parent: Organization) -- also add `name 1..1 MS`

## Instructions

1. Open `starter.fsh`
2. Define the RuleSets and insert them into the profiles
3. Compare with `solution.fsh`

## FSH Syntax Reference

```fsh
RuleSet: RuleSetName
* element cardinality flags

Profile: ProfileName
Parent: ParentResource
* insert RuleSetName
* additionalElement cardinality flags
```
