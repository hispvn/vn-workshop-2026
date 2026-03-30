// Exercise 07: RuleSets - Solution
// Reusable RuleSets applied to multiple DHIS2 profiles.

RuleSet: DHIS2MetadataRuleSet
* meta.lastUpdated 1..1 MS
* meta.source 0..1 MS

RuleSet: DHIS2IdentifierRuleSet
* identifier 1..* MS
* identifier.system 1..1
* identifier.value 1..1

Profile: DHIS2Patient
Parent: Patient
Id: dhis2-patient-ex07
Title: "DHIS2 Patient (Exercise 07)"
Description: "A Patient profile using DHIS2 RuleSets."
* insert DHIS2MetadataRuleSet
* insert DHIS2IdentifierRuleSet
* name 1..* MS

Profile: DHIS2Organization
Parent: Organization
Id: dhis2-organization-ex07
Title: "DHIS2 Organization (Exercise 07)"
Description: "An Organization profile using DHIS2 RuleSets."
* insert DHIS2MetadataRuleSet
* insert DHIS2IdentifierRuleSet
* name 1..1 MS
